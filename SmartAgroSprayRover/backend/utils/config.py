import os
from pathlib import Path
from dotenv import load_dotenv

root = Path(__file__).resolve().parent.parent
env_path = root / ".env"
if env_path.exists():
    load_dotenv(env_path)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
GEMINI_API_URL = os.getenv("GEMINI_API_URL", "https://generativelanguage.googleapis.com/v1beta2/models")
SARVAM_API_KEY = os.getenv("SARVAM_API_KEY", "")
SARVAM_BASE_URL = os.getenv("SARVAM_BASE_URL", "https://api.sarvam.ai/v1")
FIREBASE_SERVICE_ACCOUNT_JSON = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON", "")
FIRESTORE_CHAT_COLLECTION = os.getenv("FIRESTORE_CHAT_COLLECTION", "farmer_assistant_chats")
