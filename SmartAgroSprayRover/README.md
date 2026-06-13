# Smart AgroSpray Rover System

This project contains:

- `esp32/`: ESP32 firmware for rover movement and pump control.
- `mobile/`: Flutter mobile app for control, image capture, and spray commands.
- `backend/`: FastAPI backend with AI-based disease detection and severity decision logic.

## Deployment Overview

1. Flash `esp32/SmartAgroSprayRover.ino` to the ESP32.
2. Use the mobile app to connect to the ESP32 WiFi AP.
3. Drive the rover, capture crop images, and upload to backend.
4. Backend returns disease, confidence, severity, spray instructions.
7. Use the Farmer Assistant chat to get AI-guided crop care advice and recommendations.
8. Mobile app sends `/spray_on` or `/spray_off` to the ESP32.

## Backend Chatbot Support

- Configure `backend/.env` using `backend/.env.example`.
- Set `GEMINI_API_KEY`, `SARVAM_API_KEY`, and optional `FIREBASE_SERVICE_ACCOUNT_JSON`.
- Start the backend with `uvicorn main:app --reload --host 0.0.0.0 --port 8000`.
- Available chat endpoints:
  - `POST /chat`
  - `POST /voice-chat`
  - `POST /disease-chat`
  - `POST /recommendation-chat`
