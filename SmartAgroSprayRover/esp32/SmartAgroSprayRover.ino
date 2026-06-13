#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

// Replace with a secure SSID/password for the ESP32 AP
const char* ssid = "SmartAgroSpray";
const char* password = "SprayRover123";

// Motor pins (L298N)
const int in1Pin = 16; // Motor A input 1
const int in2Pin = 17; // Motor A input 2
const int in3Pin = 18; // Motor B input 1
const int in4Pin = 19; // Motor B input 2
const int enableAPin = 25; // Motor A speed control (PWM)
const int enableBPin = 26; // Motor B speed control (PWM)

const int relayPin = 27; // Relay for pump control

WebServer server(80);

bool sprayActive = false;

void setMotors(bool m1Forward, bool m1Backward, bool m2Forward, bool m2Backward) {
  digitalWrite(in1Pin, m1Forward ? HIGH : LOW);
  digitalWrite(in2Pin, m1Backward ? HIGH : LOW);
  digitalWrite(in3Pin, m2Forward ? HIGH : LOW);
  digitalWrite(in4Pin, m2Backward ? HIGH : LOW);
}

void stopRover() {
  setMotors(false, false, false, false);
  analogWrite(enableAPin, 0);
  analogWrite(enableBPin, 0);
}

void forwardRover() {
  setMotors(true, false, true, false);
  analogWrite(enableAPin, 255);
  analogWrite(enableBPin, 255);
}

void backwardRover() {
  setMotors(false, true, false, true);
  analogWrite(enableAPin, 255);
  analogWrite(enableBPin, 255);
}

void leftRover() {
  setMotors(false, true, true, false);
  analogWrite(enableAPin, 255);
  analogWrite(enableBPin, 255);
}

void rightRover() {
  setMotors(true, false, false, true);
  analogWrite(enableAPin, 255);
  analogWrite(enableBPin, 255);
}

void sprayOn() {
  sprayActive = true;
  digitalWrite(relayPin, HIGH);
}

void sprayOff() {
  sprayActive = false;
  digitalWrite(relayPin, LOW);
}

String createJsonResponse(const String& status, const String& message) {
  StaticJsonDocument<200> doc;
  doc["status"] = status;
  doc["message"] = message;
  doc["spray_active"] = sprayActive;
  doc["timestamp"] = millis();

  String payload;
  serializeJson(doc, payload);
  return payload;
}

void handleForward() {
  forwardRover();
  server.send(200, "application/json", createJsonResponse("ok", "forward"));
}

void handleBackward() {
  backwardRover();
  server.send(200, "application/json", createJsonResponse("ok", "backward"));
}

void handleLeft() {
  leftRover();
  server.send(200, "application/json", createJsonResponse("ok", "left"));
}

void handleRight() {
  rightRover();
  server.send(200, "application/json", createJsonResponse("ok", "right"));
}

void handleStop() {
  stopRover();
  server.send(200, "application/json", createJsonResponse("ok", "stop"));
}

void handleSprayOn() {
  sprayOn();
  server.send(200, "application/json", createJsonResponse("ok", "spray_on"));
}

void handleSprayOff() {
  sprayOff();
  server.send(200, "application/json", createJsonResponse("ok", "spray_off"));
}

void handleStatus() {
  StaticJsonDocument<300> doc;
  doc["status"] = "ok";
  doc["spray_active"] = sprayActive;
  doc["wifi_ssid"] = ssid;
  doc["pump_relay_pin"] = relayPin;
  doc["motor_controller"] = "L298N";
  doc["timestamp"] = millis();

  String payload;
  serializeJson(doc, payload);
  server.send(200, "application/json", payload);
}

void setupRoutes() {
  server.on("/forward", handleForward);
  server.on("/backward", handleBackward);
  server.on("/left", handleLeft);
  server.on("/right", handleRight);
  server.on("/stop", handleStop);
  server.on("/spray_on", handleSprayOn);
  server.on("/spray_off", handleSprayOff);
  server.on("/status", handleStatus);
  server.onNotFound([]() {
    server.send(404, "application/json", createJsonResponse("error", "Endpoint not found"));
  });
}

void setup() {
  pinMode(in1Pin, OUTPUT);
  pinMode(in2Pin, OUTPUT);
  pinMode(in3Pin, OUTPUT);
  pinMode(in4Pin, OUTPUT);
  pinMode(enableAPin, OUTPUT);
  pinMode(enableBPin, OUTPUT);
  pinMode(relayPin, OUTPUT);

  stopRover();
  sprayOff();

  Serial.begin(115200);
  WiFi.softAP(ssid, password);
  delay(1000);

  IPAddress ip = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(ip);
  Serial.print("SSID: ");
  Serial.println(ssid);

  setupRoutes();
  server.begin();
}

void loop() {
  server.handleClient();
}
