import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32Service {
  static Future<String> sendCommand(String ip, String endpoint) async {
    final url = Uri.parse('http://$ip/$endpoint');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['message'] as String? ?? 'success';
      }
      return 'error: ${response.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }
}
