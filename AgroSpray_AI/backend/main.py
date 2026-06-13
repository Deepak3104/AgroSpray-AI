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
from training.gradcam import save_gradcam_overlay

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
    model = load_model(MODEL_PATH)
    class_names = load_class_names()
    pesticide_db = load_pesticide_database(PESTICIDE_DB_PATH)
    _initialize_firebase_admin()


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok", "model": "loaded" if model is not None else "missing"}


@app.post("/predict", response_model=PredictionResponse)
async def predict(image: UploadFile = File(...)) -> PredictionResponse:
    if model is None:
        raise HTTPException(status_code=503, detail="Model is not loaded.")

    if image.content_type is None or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Please upload a valid image file.")

    upload_dir = UPLOAD_DIR
    upload_dir.mkdir(parents=True, exist_ok=True)
    file_suffix = Path(image.filename or "leaf.jpg").suffix or ".jpg"
    saved_path = upload_dir / f"{uuid.uuid4().hex}{file_suffix}"

    content = await image.read()
    saved_path.write_bytes(content)

    input_tensor = preprocess_image(saved_path)
    probabilities = model.predict(input_tensor, verbose=0)
    predicted_class, confidence, index = top_prediction(probabilities, class_names)
    disease_name = class_name_to_display_name(predicted_class)
    recommendation = _lookup_recommendation(disease_name)

    gradcam_path = GRADCAM_DIR / f"{saved_path.stem}_heatmap.jpg"
    try:
        save_gradcam_overlay(model, saved_path, gradcam_path, pred_index=index)
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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
