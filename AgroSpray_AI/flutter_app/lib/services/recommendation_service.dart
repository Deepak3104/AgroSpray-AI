import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/detection_result.dart';
import '../data/class_labels.dart';

class RecommendationService {
  RecommendationService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Map<String, Map<String, String>> _defaults = {
    'Healthy': {
      'pesticide': 'No pesticide required',
      'dosage': 'N/A',
      'safety': 'Continue monitoring and maintain field hygiene.',
      'notes': 'Healthy foliage detected.',
    },
    'Early Blight': {
      'pesticide': 'Mancozeb',
      'dosage': '2 g/L water',
      'safety': 'Wear gloves, mask, and protective clothing.',
      'notes': 'Apply early and repeat according to label instructions.',
    },
    'Late Blight': {
      'pesticide': 'Chlorothalonil',
      'dosage': '3 g/L water',
      'safety': 'Avoid spraying before rain and follow local regulations.',
      'notes': 'Use in rotation to reduce resistance pressure.',
    },
    'Bacterial Spot': {
      'pesticide': 'Copper hydroxide',
      'dosage': '2.5 g/L water',
      'safety': 'Do not spray in hot conditions; use PPE.',
      'notes': 'Remove infected leaves and sanitize tools.',
    },
  };

  Future<DetectionResult> enrichPrediction({
    required String disease,
    required double confidence,
    required String imagePath,
  }) async {
    final remote = await _fetchRemoteRecommendation(disease);
    final local = _defaults[disease] ?? _defaults['Healthy']!;
    final merged = remote ?? local;

    return DetectionResult(
      disease: disease,
      confidence: confidence,
      pesticide: merged['pesticide'] ?? local['pesticide']!,
      dosage: merged['dosage'] ?? local['dosage']!,
      safety: merged['safety'] ?? local['safety']!,
      notes: merged['notes'] ?? local['notes']!,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
  }

  Future<Map<String, String>?> _fetchRemoteRecommendation(String disease) async {
    try {
      final document = await _firestore.collection('pesticide_recommendations').doc(disease).get();
      if (!document.exists) {
        return null;
      }
      final data = document.data();
      if (data == null) {
        return null;
      }
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return null;
    }
  }

  List<String> get labels => classLabels;
}
