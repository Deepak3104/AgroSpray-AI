# AgroSpray AI

AgroSpray AI is an end-to-end crop disease detection and pesticide recommendation system built with TensorFlow, FastAPI, Firebase, and Flutter.

## Project Structure

```text
AgroSpray_AI/
  dataset/
  training/
    train.py
    evaluate.py
    predict.py
    convert_tflite.py
    common.py
    gradcam.py
  models/
  output/
  backend/
    main.py
  flutter_app/
```

## 1. Installation

### Python environment

```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

If you prefer installing packages one by one:

```powershell
pip install tensorflow
pip install numpy
pip install pandas
pip install matplotlib
pip install scikit-learn
pip install pillow
pip install opencv-python
pip install fastapi
pip install uvicorn
pip install grad-cam
```

## 2. Dataset Setup

Use the PlantVillage dataset and place it in `dataset/` with the following structure:

```text
dataset/
  Tomato___Healthy/
  Tomato___Early_blight/
  Tomato___Late_blight/
  Potato___Healthy/
  Potato___Early_blight/
  Potato___Late_blight/
  Pepper___Healthy/
  Pepper___Bacterial_spot/
```

Each class folder should contain leaf images for that disease category.

## 3. Training Process

Train the MobileNetV2 transfer learning model:

```powershell
python training\train.py --dataset dataset --epochs 20
```

Training details:
- Image size: `224x224`
- Batch size: `32`
- Validation split: `20%`
- Augmentation: rotation, zoom, horizontal flip
- Architecture: MobileNetV2 + GAP + Dense 128 + Dropout 0.3 + Softmax

The trained model is saved to:

```text
output/agrospray_model.keras
models/class_names.json
```

## 4. Evaluation

Run evaluation metrics and confusion matrix generation:

```powershell
python training\evaluate.py --dataset dataset --model output\agrospray_model.keras
```

This generates:
- Accuracy
- Precision
- Recall
- F1 Score
- Confusion matrix image in `output/confusion_matrix.png`

## 5. Prediction

Predict a single test image and optionally save a Grad-CAM heatmap:

```powershell
python training\predict.py path\to\leaf.jpg --save-heatmap
```

Output:
- Disease name
- Confidence score
- Grad-CAM image if requested

## 6. TFLite Conversion

Convert the trained Keras model to TensorFlow Lite for mobile deployment:

```powershell
python training\convert_tflite.py
```

The converted model is saved to:

```text
output/agrospray_model.tflite
```

## 7. API Deployment

Run the FastAPI backend:

```powershell
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```

API endpoint:

- `POST /predict`

Request:
- multipart file upload named `image`

Response example:

```json
{
  "disease": "Early Blight",
  "confidence": "98.00%",
  "pesticide": "Mancozeb",
  "dosage": "2 g/L water",
  "safety": "Wear gloves, mask, and protective clothing.",
  "notes": "Apply early and repeat according to label instructions.",
  "gradcam_image": "output/gradcam/example_heatmap.jpg"
}
```

Firebase support:
- Firestore is used for optional prediction logging.
- Firebase Storage can be enabled through `FIREBASE_STORAGE_BUCKET` and service account credentials.
- Set `FIREBASE_SERVICE_ACCOUNT_JSON` to the path of a Firebase Admin service account JSON file.

## 8. Flutter Integration

The Flutter client lives in `flutter_app/` and supports:
- Camera capture
- Gallery upload
- TensorFlow Lite inference
- Disease confidence display
- Pesticide recommendation display
- Dosage and safety instructions
- Firebase Authentication
- Firestore history tracking

### Flutter setup

```powershell
cd flutter_app
flutter pub get
flutter run
```

Before running, place the converted model at:

```text
flutter_app/assets/models/agrospray_model.tflite
```

and replace the placeholders in `flutter_app/lib/firebase_options.dart`.

## 9. Troubleshooting

- If training fails because the dataset path is wrong, verify the directory names exactly match the class folders.
- If FastAPI cannot load the model, confirm `output/agrospray_model.keras` exists.
- If Flutter fails to load the TFLite model, confirm the asset path matches `pubspec.yaml`.
- If Firebase auth fails, verify the Firebase project configuration and platform-specific options.
- If Grad-CAM generation fails, ensure the model contains convolution layers and that the image is readable.

## Notes

- The backend and Flutter app are designed to work independently, but they share the same disease and pesticide taxonomy.
- The project uses clean separation between training, inference, API, and mobile UI layers.
