import 'dart:developer';
import 'dart:io';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:trash_classifier_app/data/classes/classification_result.dart';
import 'package:trash_classifier_app/utils/preprocess_image.dart';

//Input Shape = [1, 224, 224, 3]
//Input Type = float32

//Output Shape: [1, 6]
//Output Type: float32

class ClassifierModel {
  ClassifierModel._();
  static final ClassifierModel instance = ClassifierModel._();

  Interpreter? _interpreter;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  static const String modelPath = 'assets/trash-classifier-model-v0_2.tflite';
  static const double confidenceThreshold = 0.50;

  final List<String> _labels = [
    'Compost',
    'Garbage',
    'Glass',
    'Hazardous Waste',
    'Recycling (Paper)',
    'Recycling (Plastic)',
  ];

  Future<bool> loadModel() async {
    if (_isLoaded) return true;
    try {
      _interpreter = await Interpreter.fromAsset(modelPath, options: InterpreterOptions()..threads = 4);
      _interpreter!.allocateTensors();
      _isLoaded = true;
      return true;
    } on Exception catch (e) {
      log('Error while Creating Interpreter: $e');
      return false;
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }

  Future<ClassificationResult?> runModel(String imagePath) async {
    if (!_isLoaded || _interpreter == null) return null;
    try {
      final image = File(imagePath);
      final output = List<List<double>>.generate(1, (_) => List<double>.filled(6, 0));
      final input = await preProcessImage(image);

      log('Running Model');
      _interpreter!.run(input, output);

      var maxIndex = 0;
      for (var i = 1; i < output[0].length; i++) {
        if (output[0][maxIndex] < output[0][i]) {
          maxIndex = i;
        }
      }

      final maxVal = output[0].reduce((a, b) => a > b ? a : b);

      log('Model output: ${output[0]}');
      log('Model Prediction: ${_labels[maxIndex]}');
      log('Model Confidence: ${(maxVal * 100).toStringAsFixed(2)}%');

      final label = maxVal >= confidenceThreshold ? _labels[maxIndex] : 'Unknown';

      return ClassificationResult(label: label, confidence: maxVal);
    } on Exception catch (e) {
      log('Error running model: $e');
      return null;
    }
  }
}
