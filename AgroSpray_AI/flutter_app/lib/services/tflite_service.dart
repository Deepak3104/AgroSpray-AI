import 'dart:typed_data';

// tflite_flutter temporarily disabled due to compatibility issues
// import 'package:tflite_flutter/tflite_flutter.dart';

// import '../data/class_labels.dart';

class TfliteService {
  TfliteService._();

  static final TfliteService instance = TfliteService._();

  // Interpreter? _interpreter;
  bool _loaded = false;

  Future<void> loadModel() async {
    if (_loaded) {
      return;
    }
    // ML model loading disabled - will be restored when tflite_flutter compatibility is fixed
    _loaded = true;
  }

  Future<Map<String, dynamic>> predict(Uint8List bytes) async {
    await loadModel();
    
    // Temporary stub: return dummy predictions until tflite_flutter is compatible
    return {
      'label': 'Unknown (ML temporarily disabled)',
      'confidence': 0.0,
      'scores': [],
    };
  }
}
