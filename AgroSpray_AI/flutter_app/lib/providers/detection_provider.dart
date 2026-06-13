import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/detection_result.dart';
import '../services/recommendation_service.dart';
import '../services/tflite_service.dart';

class DetectionProvider extends ChangeNotifier {
  DetectionProvider({RecommendationService? recommendationService})
      : _recommendationService = recommendationService ?? RecommendationService();

  final RecommendationService _recommendationService;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  DetectionResult? _result;
  bool _loading = false;
  String? _error;

  File? get selectedImage => _selectedImage;
  DetectionResult? get result => _result;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 92);
    if (image == null) {
      return;
    }
    _selectedImage = File(image.path);
    _result = null;
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeImage() async {
    final image = _selectedImage;
    if (image == null) {
      _error = 'Please capture or upload a leaf image first.';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prediction = await TfliteService.instance.predict(await image.readAsBytes());
      final disease = _normalizeDisease(prediction['label'] as String);
      final confidence = (prediction['confidence'] as num).toDouble();
      _result = await _recommendationService.enrichPrediction(
        disease: disease,
        confidence: confidence,
        imagePath: image.path,
      );
      await _saveHistory();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final result = _result;
    if (result == null) {
      return;
    }
    await FirebaseFirestore.instance.collection('scan_history').add(result.toMap());
  }

  String _normalizeDisease(String className) {
    if (className.contains('___')) {
      return className.split('___').last.replaceAll('_', ' ').trim().toTitleCase();
    }
    return className.replaceAll('_', ' ').trim().toTitleCase();
  }
}

extension _TitleCase on String {
  String toTitleCase() {
    if (isEmpty) {
      return this;
    }
    return split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) {
        return word;
      }
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}
