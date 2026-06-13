import io
import numpy as np
from PIL import Image
from tensorflow.keras.applications.mobilenet_v2 import MobileNetV2, preprocess_input, decode_predictions
from tensorflow.keras.preprocessing.image import img_to_array

class DiseaseDetectionModule:
    def __init__(self):
        self.model_name = "MobileNetV2"
        self.model = self._load_model()
        self.is_ready = self.model is not None

    def _load_model(self):
        try:
            model = MobileNetV2(weights="imagenet", include_top=True)
            return model
        except Exception:
            return None

    def _prepare_image(self, image_bytes: bytes):
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize((224, 224))
        array = img_to_array(image)
        array = np.expand_dims(array, axis=0)
        array = preprocess_input(array)
        return array

    def predict(self, image_bytes: bytes):
        if not self.is_ready:
            return {"disease": "Unknown", "confidence": 0.0}

        input_tensor = self._prepare_image(image_bytes)
        preds = self.model.predict(input_tensor, verbose=0)
        decoded = decode_predictions(preds, top=1)[0][0]
        disease_name = decoded[1].replace("_", " ").title()
        confidence_score = float(decoded[2] * 100)
        return {"disease": disease_name, "confidence": round(confidence_score, 2)}
