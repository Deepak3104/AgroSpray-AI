from pydantic import BaseModel

class DetectionResponse(BaseModel):
    disease: str
    confidence: float
    severity: str
    infection_percentage: int
    spray: str
    pesticide: str
    dosage: str
    notes: str | None = None

class ChatResponse(BaseModel):
    text: str

class VoiceChatResponse(BaseModel):
    text: str
    audio_base64: str
