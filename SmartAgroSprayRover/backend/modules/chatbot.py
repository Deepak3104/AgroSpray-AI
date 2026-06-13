import base64
from typing import Optional, Dict, Any
import requests

from utils.config import GEMINI_API_KEY, GEMINI_API_URL, GEMINI_MODEL, SARVAM_API_KEY, SARVAM_BASE_URL
from utils.firebase_client import save_chat_history

class GeminiChatModule:
    def __init__(self, api_key: str = GEMINI_API_KEY, model: str = GEMINI_MODEL):
        self.api_key = api_key
        self.model = model

    def _headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

    def generate_text(self, prompt: str, language: str = "en") -> str:
        if not self.api_key:
            raise RuntimeError("Gemini API key is not configured.")

        endpoint = f"{GEMINI_API_URL}/{self.model}:generate"
        payload = {
            "prompt": {
                "text": prompt,
            },
            "temperature": 0.7,
            "maxOutputTokens": 512,
        }

        response = requests.post(endpoint, json=payload, headers=self._headers(), timeout=30)
        response.raise_for_status()
        data = response.json()

        candidates = data.get("candidates")
        if isinstance(candidates, list) and candidates:
            return candidates[0].get("output", "")

        return data.get("output", "") or ""

class SarvamSpeechModule:
    def __init__(self, api_key: str = SARVAM_API_KEY, base_url: str = SARVAM_BASE_URL):
        self.api_key = api_key
        self.base_url = base_url

    def _headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key}",
        }

    def transcribe_audio(self, audio_bytes: bytes, language: str = "en") -> str:
        if not self.api_key:
            raise RuntimeError("Sarvam API key is not configured.")

        endpoint = f"{self.base_url}/speech-to-text"
        files = {"file": ("voice.wav", audio_bytes, "audio/wav")}
        data = {"language": language}
        response = requests.post(endpoint, headers=self._headers(), files=files, data=data, timeout=60)
        response.raise_for_status()
        result = response.json()
        return result.get("transcript", "")

    def synthesize_speech(self, text: str, language: str = "en") -> bytes:
        if not self.api_key:
            raise RuntimeError("Sarvam API key is not configured.")

        endpoint = f"{self.base_url}/text-to-speech"
        payload = {
            "text": text,
            "language": language,
            "voice": "alloy",
        }
        response = requests.post(endpoint, headers={**self._headers(), "Content-Type": "application/json"}, json=payload, timeout=60)
        response.raise_for_status()
        return response.content

class FarmerAssistantChatService:
    def __init__(self):
        self.gemini = GeminiChatModule()
        self.sarvam = SarvamSpeechModule()

    def _save_history(self, record: Dict[str, Any]) -> None:
        try:
            save_chat_history(record)
        except Exception:
            pass

    def _build_system_prompt(self) -> str:
        return (
            "You are a helpful multilingual farmer assistant. "
            "Provide concise, safe, and actionable crop health advice, pesticide recommendations, and irrigation guidance. "
            "Respond in the requested language and preserve the user tone."
        )

    def chat(self, message: str, language: str = "en", persona: Optional[str] = None) -> str:
        prompt = self._build_system_prompt()
        if persona:
            prompt += f"\nPersona: {persona}."
        prompt += f"\nUser: {message}" 

        response_text = self.gemini.generate_text(prompt, language=language)
        self._save_history({
            "type": "text_chat",
            "language": language,
            "persona": persona,
            "user_message": message,
            "assistant_response": response_text,
        })
        return response_text

    def voice_chat(self, audio_base64: str, language: str = "en", persona: Optional[str] = None) -> Dict[str, str]:
        audio_bytes = base64.b64decode(audio_base64)
        user_text = self.sarvam.transcribe_audio(audio_bytes, language=language)
        assistant_text = self.chat(user_text, language=language, persona=persona)
        audio_response = self.sarvam.synthesize_speech(assistant_text, language=language)
        encoded_audio = base64.b64encode(audio_response).decode("utf-8")

        return {
            "text": assistant_text,
            "audio_base64": encoded_audio,
        }

    def disease_chat(self, disease: str, confidence: float, severity: str, infection_percentage: int, language: str = "en") -> str:
        prompt = (
            f"A crop disease detector found '{disease}' with {confidence:.1f}% confidence. "
            f"The infection severity is {severity}, estimated at {infection_percentage}% infected leaf area. "
            "Provide a farmer-friendly diagnosis and recommend the next monitoring or treatment steps."
        )
        response_text = self.chat(prompt, language=language)
        return response_text

    def recommendation_chat(self, disease: str, severity: str, infection_percentage: int, notes: Optional[str] = None, crop: Optional[str] = None, language: str = "en") -> str:
        prompt = (
            f"Crop: {crop or 'unknown'}. Disease: {disease}. Severity: {severity}. "
            f"Infection level: {infection_percentage}%. Notes: {notes or 'No additional notes'}. "
            "Provide pesticide, dosage, and field action advice for this situation."
        )
        response_text = self.chat(prompt, language=language)
        return response_text
