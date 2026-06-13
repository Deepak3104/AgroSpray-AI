from typing import Optional, Dict, Any
import firebase_admin
from firebase_admin import credentials, firestore

from .config import FIREBASE_SERVICE_ACCOUNT_JSON, FIRESTORE_CHAT_COLLECTION

_firestore_client: Optional[firestore.Client] = None


def get_firestore_client() -> Optional[firestore.Client]:
    global _firestore_client
    if _firestore_client is not None:
        return _firestore_client

    if not FIREBASE_SERVICE_ACCOUNT_JSON:
        return None

    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_JSON)
            firebase_admin.initialize_app(cred)
        _firestore_client = firestore.client()
        return _firestore_client
    except Exception:
        return None


def save_chat_history(entry: Dict[str, Any]) -> Optional[str]:
    client = get_firestore_client()
    if client is None:
        return None
    added = client.collection(FIRESTORE_CHAT_COLLECTION).add(entry)
    if added and isinstance(added, tuple):
        document_ref = added[0]
        return getattr(document_ref, 'id', None)
    return None
