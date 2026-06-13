from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from modules.disease_detection import DiseaseDetectionModule
from modules.infection_severity import InfectionSeverityClassificationModule
from modules.decision_making import ControlAndDecisionMakingModule
from modules.chatbot import FarmerAssistantChatService
from models.responses import ChatResponse, DetectionResponse, VoiceChatResponse
from models.requests import ChatRequest, DiseaseChatRequest, RecommendationChatRequest, VoiceChatRequest

app = FastAPI(title="Smart AgroSpray Rover API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model_loader = DiseaseDetectionModule()
severity_classifier = InfectionSeverityClassificationModule()
decision_engine = ControlAndDecisionMakingModule()


@app.get("/health")
def health():
    return {"status": "ok", "model": model_loader.model_name, "loaded": model_loader.is_ready}


@app.post("/detect", response_model=DetectionResponse)
async def detect(image: UploadFile = File(...)):
    if image.content_type is None or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Upload a valid image file.")

    image_bytes = await image.read()
    detection = model_loader.predict(image_bytes)
    severity = severity_classifier.estimate_severity(image_bytes)
    decision = decision_engine.decide(severity)

    return DetectionResponse(
        disease=detection["disease"],
        confidence=detection["confidence"],
        severity=severity["severity"],
        infection_percentage=severity["infection_percentage"],
        spray=decision["spray"],
        pesticide=decision["pesticide"],
        dosage=decision["dosage"],
        notes=decision["notes"],
    )

assistant = FarmerAssistantChatService()

@app.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    response_text = assistant.chat(request.message, language=request.language, persona=request.persona)
    return ChatResponse(text=response_text)

@app.post("/voice-chat", response_model=VoiceChatResponse)
def voice_chat(request: VoiceChatRequest):
    response = assistant.voice_chat(request.audio_base64, language=request.language, persona=request.persona)
    return VoiceChatResponse(text=response["text"], audio_base64=response["audio_base64"])

@app.post("/disease-chat", response_model=ChatResponse)
def disease_chat(request: DiseaseChatRequest):
    response_text = assistant.disease_chat(
        disease=request.disease,
        confidence=request.confidence,
        severity=request.severity,
        infection_percentage=request.infection_percentage,
        language=request.language,
    )
    return ChatResponse(text=response_text)

@app.post("/recommendation-chat", response_model=ChatResponse)
def recommendation_chat(request: RecommendationChatRequest):
    response_text = assistant.recommendation_chat(
        disease=request.disease,
        severity=request.severity,
        infection_percentage=request.infection_percentage,
        notes=request.notes,
        crop=request.crop,
        language=request.language,
    )
    return ChatResponse(text=response_text)
