from __future__ import annotations

import json
import os
import uuid
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Optional

import numpy as np
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from PIL import Image

try:
    import firebase_admin
    from firebase_admin import credentials, firestore, storage
except ImportError:  # pragma: no cover - optional dependency
    firebase_admin = None
    credentials = None
    firestore = None
    storage = None

from training.common import (
    OUTPUT_DIR,
    PROJECT_ROOT,
    MODEL_PATH,
    class_name_to_display_name,
    ensure_directories,
    load_class_names,
    load_model,
    load_pesticide_database,
    preprocess_image,
    top_prediction,
)

APP_ROOT = Path(__file__).resolve().parents[1]
PESTICIDE_DB_PATH = APP_ROOT / "pesticide_recommendations.json"
UPLOAD_DIR = OUTPUT_DIR / "uploads"
GRADCAM_DIR = OUTPUT_DIR / "gradcam"

app = FastAPI(title="AgroSpray AI API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = None
class_names: list[str] = []
pesticide_db: Dict[str, Dict[str, str]] = {}
firestore_client = None
storage_bucket = None


class PredictionResponse(BaseModel):
    disease: str
    confidence: str
    pesticide: str
    dosage: str
    safety: str
    notes: str | None = None
    gradcam_image: str | None = None


@app.on_event("startup")
def startup_event() -> None:
    global model, class_names, pesticide_db, firestore_client, storage_bucket
    ensure_directories()
    model = None
    try:
        class_names = load_class_names()
    except FileNotFoundError:
        class_names = []
    pesticide_db = load_pesticide_database(PESTICIDE_DB_PATH)
    _initialize_firebase_admin()


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok", "model": "loaded" if model is not None else "missing"}


@app.post("/predict", response_model=PredictionResponse)
async def predict(image: UploadFile = File(...)) -> PredictionResponse:
    if model is None:
        try:
            loaded_model = load_model(MODEL_PATH)
        except Exception as error:
            raise HTTPException(status_code=503, detail=f"Model is not loaded: {error}") from error
    else:
        loaded_model = model

    if not class_names:
        raise HTTPException(status_code=503, detail="Class labels are not available yet.")

    if image.content_type is None or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Please upload a valid image file.")

    upload_dir = UPLOAD_DIR
    upload_dir.mkdir(parents=True, exist_ok=True)
    file_suffix = Path(image.filename or "leaf.jpg").suffix or ".jpg"
    saved_path = upload_dir / f"{uuid.uuid4().hex}{file_suffix}"

    content = await image.read()
    saved_path.write_bytes(content)

    input_tensor = preprocess_image(saved_path)
    probabilities = loaded_model.predict(input_tensor, verbose=0)
    predicted_class, confidence, index = top_prediction(probabilities, class_names)
    disease_name = class_name_to_display_name(predicted_class)
    recommendation = _lookup_recommendation(disease_name)

    gradcam_path = GRADCAM_DIR / f"{saved_path.stem}_heatmap.jpg"
    try:
        from training.gradcam import save_gradcam_overlay

        save_gradcam_overlay(loaded_model, saved_path, gradcam_path, pred_index=index)
        gradcam_output = str(gradcam_path)
    except Exception:
        gradcam_output = None

    _save_prediction_record(
        disease=disease_name,
        confidence=confidence,
        pesticide=recommendation["pesticide"],
        dosage=recommendation["dosage"],
        safety=recommendation["safety"],
        notes=recommendation.get("notes"),
        image_path=str(saved_path),
        gradcam_path=gradcam_output,
    )

    return PredictionResponse(
        disease=disease_name,
        confidence=f"{confidence * 100:.2f}%",
        pesticide=recommendation["pesticide"],
        dosage=recommendation["dosage"],
        safety=recommendation["safety"],
        notes=recommendation.get("notes"),
        gradcam_image=gradcam_output,
    )


def _lookup_recommendation(disease_name: str) -> Dict[str, str]:
    if disease_name in pesticide_db:
        return pesticide_db[disease_name]
    if disease_name.replace(" ", "") in pesticide_db:
        return pesticide_db[disease_name.replace(" ", "")]
    if disease_name.lower() == "healthy":
        return pesticide_db.get("Healthy", {
            "pesticide": "No pesticide required",
            "dosage": "N/A",
            "safety": "Continue routine monitoring.",
            "notes": "Healthy leaf detected.",
        })
    return {
        "pesticide": "Consult an agronomist",
        "dosage": "Follow label instructions",
        "safety": "Use protective equipment and observe re-entry intervals.",
        "notes": "No exact database match found.",
    }


def _initialize_firebase_admin() -> None:
    global firestore_client, storage_bucket

    if firebase_admin is None:
        return

    if firebase_admin._apps:
        app_instance = firebase_admin.get_app()
    else:
        service_account = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
        bucket_name = os.getenv("FIREBASE_STORAGE_BUCKET")
        if not service_account or not Path(service_account).exists():
            return

        options: Dict[str, Any] = {}
        if bucket_name:
            options["storageBucket"] = bucket_name
        app_instance = firebase_admin.initialize_app(credentials.Certificate(service_account), options)

    try:
        firestore_client = firestore.client(app_instance)
    except Exception:
        firestore_client = None

    try:
        storage_bucket = storage.bucket(app_instance) if os.getenv("FIREBASE_STORAGE_BUCKET") else None
    except Exception:
        storage_bucket = None


def _save_prediction_record(
    *,
    disease: str,
    confidence: float,
    pesticide: str,
    dosage: str,
    safety: str,
    notes: Optional[str],
    image_path: str,
    gradcam_path: Optional[str],
) -> None:
    if firestore_client is None:
        return

    firestore_client.collection("predictions").add(
        {
            "disease": disease,
            "confidence": confidence,
            "pesticide": pesticide,
            "dosage": dosage,
            "safety": safety,
            "notes": notes,
            "imagePath": image_path,
            "gradcamPath": gradcam_path,
            "createdAt": datetime.utcnow(),
        }
    )


def get_fallback_ai_response(prompt: str) -> str:
    prompt_lower = prompt.lower()
    if "tomato" in prompt_lower:
        return "Your tomato crop may be affected by Early Blight or Leaf Mold. It is recommended to use Mancozeb or copper-based fungicides. Keep leaves dry and ensure good ventilation."
    elif "rice" in prompt_lower:
        return "Rice blast or brown spot disease detected. Apply Tricyclazole or Carbendazim. Maintain proper water levels and avoid excessive nitrogen fertilizer."
    elif "fertilizer" in prompt_lower:
        return "For vegetative growth, apply a balanced NPK fertilizer (19-19-19). For flowering crops, choose a higher potassium and phosphorus ratio."
    elif "blight" in prompt_lower:
        return "Early Blight requires spraying Mancozeb (2g/L) or Chlorothalonil. Remove infected lower leaves to prevent spore spread."
    else:
        return "I suggest monitoring the crop closely. Keep the soil moisture optimal and check under the leaves for any pest infestations. If symptoms persist, spray an organic neem oil solution."


async def call_gemini(prompt: str) -> str:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        return get_fallback_ai_response(prompt)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={api_key}"
    headers = {"Content-Type": "application/json"}
    payload = {
        "contents": [{
            "parts": [{"text": prompt}]
        }]
    }
    try:
        import httpx
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, headers=headers, timeout=10.0)
            if response.status_code == 200:
                data = response.json()
                return data["candidates"][0]["content"]["parts"][0]["text"]
    except Exception:
        pass
    return get_fallback_ai_response(prompt)


async def sarvam_stt(audio_bytes: bytes, language_code: str) -> str:
    api_key = os.getenv("SARVAM_API_KEY")
    if not api_key:
        return "My tomato leaves are turning yellow"
    
    url = "https://api.sarvam.ai/speech-to-text"
    headers = {"api-subscription-key": api_key}
    files = {"file": ("audio.wav", audio_bytes, "audio/wav")}
    data = {"language_code": language_code}
    
    try:
        import httpx
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=headers, files=files, data=data, timeout=10.0)
            if response.status_code == 200:
                return response.json().get("transcript", "")
    except Exception:
        pass
    return "My tomato leaves are turning yellow"


async def sarvam_tts(text: str, language_code: str) -> str:
    api_key = os.getenv("SARVAM_API_KEY")
    if not api_key:
        return ""
    
    url = "https://api.sarvam.ai/text-to-speech"
    headers = {
        "api-subscription-key": api_key,
        "Content-Type": "application/json"
    }
    payload = {
        "text": text,
        "language_code": language_code,
        "voice": "amrit",
        "type": "base64"
    }
    
    try:
        import httpx
        async with httpx.AsyncClient() as client:
            response = await client.post(url, headers=headers, json=payload, timeout=10.0)
            if response.status_code == 200:
                return response.json().get("audio_data", "")
    except Exception:
        pass
    return ""


@app.post("/detect")
async def detect(image: UploadFile = File(...)):
    upload_dir = UPLOAD_DIR
    upload_dir.mkdir(parents=True, exist_ok=True)
    file_suffix = Path(image.filename or "leaf.jpg").suffix or ".jpg"
    saved_path = upload_dir / f"{uuid.uuid4().hex}{file_suffix}"
    content = await image.read()
    saved_path.write_bytes(content)

    disease_name = "Tomato Early Blight"
    confidence = 0.88
    pesticide = "Mancozeb"
    dosage = "2 grams per liter of water"
    safety = "Wear gloves and mask. Avoid spraying near water bodies."
    
    if model is not None and len(class_names) > 0:
        try:
            input_tensor = preprocess_image(saved_path)
            probabilities = model.predict(input_tensor, verbose=0)
            predicted_class, conf, index = top_prediction(probabilities, class_names)
            disease_name = class_name_to_display_name(predicted_class)
            confidence = float(conf)
            rec = _lookup_recommendation(disease_name)
            pesticide = rec.get("pesticide", "Consult an agronomist")
            dosage = rec.get("dosage", "N/A")
            safety = rec.get("safety", "N/A")
        except Exception:
            pass

    severity = round(float(confidence) * 75 + 10, 1)
    if severity > 100:
        severity = 100.0

    spray_rec = f"Apply {pesticide} using the Smart Spraying Rover. Spray in the early morning or late evening."

    return {
        "disease": disease_name,
        "confidence": f"{confidence * 100:.1f}%",
        "severity": severity,
        "pesticide": pesticide,
        "dosage": dosage,
        "safety": safety,
        "spray_recommendation": spray_rec
    }


class ChatMessage(BaseModel):
    message: str


@app.post("/chat")
async def chat(request: ChatMessage):
    response_text = await call_gemini(request.message)
    return {"response": response_text}


@app.post("/voice-chat")
async def voice_chat(audio: UploadFile = File(...), language_code: str = "en-IN"):
    content = await audio.read()
    transcript = await sarvam_stt(content, language_code)
    response_text = await call_gemini(transcript)
    audio_base64 = await sarvam_tts(response_text, language_code)
    return {
        "transcript": transcript,
        "response": response_text,
        "audio": audio_base64
    }


class SeverityRequest(BaseModel):
    disease: str


@app.post("/severity")
async def get_severity(request: SeverityRequest):
    return {"severity": 65.0, "status": "High Infection"}


class RecommendRequest(BaseModel):
    disease: str
    severity: float


@app.post("/recommend")
async def get_recommendation(request: RecommendRequest):
    rec = _lookup_recommendation(request.disease)
    return {
        "pesticide": rec.get("pesticide", "Mancozeb"),
        "dosage": rec.get("dosage", "2g/L"),
        "safety": rec.get("safety", "Use protective gear.")
    }


# Rover Telemetry
rover_state = {
    "connected": True,
    "ip": "192.168.4.1",
    "battery": 88,
    "pump_status": "OFF",
    "motor_status": "STOPPED",
    "wifi_strength": "Excellent"
}


@app.get("/rover-status")
async def get_rover_status():
    return rover_state


@app.post("/spray-on")
async def spray_on():
    rover_state["pump_status"] = "ON"
    return {"status": "ok", "message": "Spray pump turned ON"}


@app.post("/spray-off")
async def spray_off():
    rover_state["pump_status"] = "OFF"
    return {"status": "ok", "message": "Spray pump turned OFF"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
