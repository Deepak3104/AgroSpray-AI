import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String backendUrl = 'http://192.168.4.1:8000';

  static Future<String> sendChatMessage(String message, String language) async {
    final uri = Uri.parse('$backendUrl/chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'language': language,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['text'] as String? ?? '';
    }

    throw Exception('Chat backend error: ${response.statusCode} ${response.body}');
  }

  static Future<Map<String, dynamic>> sendVoiceChat(String audioBase64, String language) async {
    final uri = Uri.parse('$backendUrl/voice-chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'audio_base64': audioBase64,
        'language': language,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Voice chat backend error: ${response.statusCode} ${response.body}');
  }
}
