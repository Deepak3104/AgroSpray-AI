import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/detection_result.dart';

class ApiService {
  static const String backendUrl = 'http://192.168.4.1:8000';

  static Future<DetectionResult> uploadImage(File imageFile) async {
    final uri = Uri.parse('$backendUrl/detect');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return DetectionResult.fromJson(json);
    }
    throw HttpException('Backend error ${response.statusCode}: $body');
  }
}
