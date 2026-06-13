import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/class_labels.dart';

class TfliteService {
  TfliteService._();

  static final TfliteService instance = TfliteService._();

  Interpreter? _interpreter;
  bool _loaded = false;

  Future<void> loadModel() async {
    if (_loaded) {
      return;
    }
    _interpreter = await Interpreter.fromAsset('models/agrospray_model.tflite');
    _loaded = true;
  }

  Future<Map<String, dynamic>> predict(Uint8List bytes) async {
    await loadModel();
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('TensorFlow Lite interpreter is not available.');
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Unable to decode the selected image.');
    }

    final resized = img.copyResize(decoded, width: 224, height: 224);
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(classLabels.length, 0.0));
    interpreter.run(input, output);

    final scores = output.first;
    var bestIndex = 0;
    var bestScore = scores.first;
    for (var index = 1; index < scores.length; index++) {
      if (scores[index] > bestScore) {
        bestScore = scores[index];
        bestIndex = index;
      }
    }

    return {
      'label': classLabels[bestIndex],
      'confidence': bestScore,
      'scores': scores,
    };
  }
}
