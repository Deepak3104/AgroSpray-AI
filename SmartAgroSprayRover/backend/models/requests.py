from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    language: str = "en"
    persona: Optional[str] = None

class VoiceChatRequest(BaseModel):
    audio_base64: str
    language: str = "en"
    persona: Optional[str] = None

class DiseaseChatRequest(BaseModel):
    disease: str
    confidence: float
    severity: str
    infection_percentage: int
    language: str = "en"

class RecommendationChatRequest(BaseModel):
    disease: str
    severity: str
    infection_percentage: int
    notes: Optional[str] = None
    crop: Optional[str] = None
    language: str = "en"
