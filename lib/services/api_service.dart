import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // FastAPI backend base URL
  // 10.0.2.2 is standard host loopback for Android emulator
  static String backendBaseUrl = 'http://10.0.2.2:8000';

  // ESP32 Rover base URL (when phone is connected directly to ESP32 WiFi Access Point)
  static String roverBaseUrl = 'http://192.168.4.1';

  // Configures the backend URL dynamically (useful for physical testing)
  void updateBackendUrl(String url) {
    backendBaseUrl = url;
  }

  // Configures the rover IP/URL dynamically
  void updateRoverUrl(String url) {
    roverBaseUrl = url;
  }

  // 1. POST /detect (Image upload for disease classification)
  Future<Map<String, dynamic>?> detectDisease(File imageFile) async {
    try {
      final uri = Uri.parse('$backendBaseUrl/detect');
      final request = http.MultipartRequest('POST', uri);
      
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'leaf.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error detecting disease: $e');
    }
    return null;
  }

  // 2. POST /chat (AI Agent text query)
  Future<String?> sendChatMessage(String message, String languageCode) async {
    try {
      final uri = Uri.parse('$backendBaseUrl/chat');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'language_code': languageCode,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] as String;
      }
    } catch (e) {
      print('Error sending chat message: $e');
    }
    return null;
  }

  // 3. POST /voice-chat (STT -> Gemini -> TTS)
  Future<Map<String, dynamic>?> sendVoiceChat(File audioFile, String languageCode) async {
    try {
      final uri = Uri.parse('$backendBaseUrl/voice-chat?language_code=$languageCode');
      final request = http.MultipartRequest('POST', uri);
      
      final stream = http.ByteStream(audioFile.openRead());
      final length = await audioFile.length();
      
      final multipartFile = http.MultipartFile(
        'audio',
        stream,
        length,
        filename: 'audio.wav',
        contentType: MediaType('audio', 'wav'),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error sending voice chat: $e');
    }
    return null;
  }

  // 4. GET /rover-status (Rover telemetry status)
  Future<Map<String, dynamic>?> getRoverStatus() async {
    // 1. Try direct ESP32 status check
    try {
      final uri = Uri.parse('$roverBaseUrl/status');
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'connected': true,
          'ip': roverBaseUrl.replaceAll('http://', '').replaceAll('https://', ''),
          'battery': 92, // Simulated or real
          'pump_status': data['spray_active'] == true ? 'ON' : 'OFF',
          'motor_status': 'CONNECTED',
          'wifi_strength': 'Excellent'
        };
      }
    } catch (e) {
      print('Direct status check failed: $e');
    }

    // 2. If direct check fails, check backend bridge but report offline/disconnected
    try {
      final uri = Uri.parse('$backendBaseUrl/rover-status');
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          ...data,
          'connected': false, // Device is not directly connected to Rover WiFi
          'wifi_strength': 'None',
          'motor_status': 'DISCONNECTED'
        };
      }
    } catch (e) {
      print('Backend status check failed: $e');
    }

    return {
      'connected': false,
      'ip': roverBaseUrl.replaceAll('http://', '').replaceAll('https://', ''),
      'battery': 0,
      'pump_status': 'OFF',
      'motor_status': 'DISCONNECTED',
      'wifi_strength': 'None'
    };
  }

  // 5. Send command to Rover (Direct ESP32 WiFi HTTP or bridged via Backend)
  Future<bool> sendRoverCommand(String command) async {
    // Attempt direct WiFi control
    try {
      final directUri = Uri.parse('$roverBaseUrl/$command');
      final response = await http.get(directUri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (directError) {
      print('Direct WiFi command failed ($command), attempting backend bridging: $directError');
      // Bridge via backend if direct WiFi is offline or simulated
      try {
        if (command == 'spray_on' || command == 'spray_off') {
          final endpoint = command == 'spray_on' ? 'spray-on' : 'spray-off';
          final response = await http.post(Uri.parse('$backendBaseUrl/$endpoint')).timeout(const Duration(seconds: 3));
          return response.statusCode == 200;
        }
      } catch (backendError) {
        print('Backend bridge control failed: $backendError');
      }
    }
    return false;
  }
}
