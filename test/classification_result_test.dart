import 'package:flutter_test/flutter_test.dart';
import 'package:trash_classifier_app/data/classes/classification_result.dart';

void main() {
  group('ClassificationResult', () {
    test('stores label and confidence', () {
      const result = ClassificationResult(label: 'Glass', confidence: 0.87);
      expect(result.label, 'Glass');
      expect(result.confidence, 0.87);
    });

    test('confidencePercent formats to one decimal place', () {
      const result = ClassificationResult(label: 'Glass', confidence: 0.873);
      expect(result.confidencePercent, '87.3%');
    });

    test('confidencePercent handles 100%', () {
      const result = ClassificationResult(label: 'Glass', confidence: 1);
      expect(result.confidencePercent, '100.0%');
    });

    test('confidencePercent handles 0%', () {
      const result = ClassificationResult(label: 'Unknown', confidence: 0);
      expect(result.confidencePercent, '0.0%');
    });

    test('confidencePercent rounds correctly', () {
      const result = ClassificationResult(label: 'Compost', confidence: 0.5556);
      expect(result.confidencePercent, '55.6%');
    });
  });
}
