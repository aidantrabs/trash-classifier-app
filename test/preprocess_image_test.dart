import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trash_classifier_app/utils/preprocess_image.dart';

void main() {
  group('preProcessImage', () {
    late File testImageFile;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('preprocess_test_');

      // create a 50x50 red test image
      final testImage = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          testImage.setPixelRgb(x, y, 255, 0, 0);
        }
      }
      testImageFile = File('${tempDir.path}/test.png');
      await testImageFile.writeAsBytes(img.encodePng(testImage));
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns tensor with shape [1, 224, 224, 3]', () async {
      final result = await preProcessImage(testImageFile);

      expect(result.length, 1);
      expect(result[0].length, 224);
      expect(result[0][0].length, 224);
      expect(result[0][0][0].length, 3);
    });

    test('pixel values are in 0-255 range (raw, not normalized)', () async {
      final result = await preProcessImage(testImageFile);

      final r = result[0][0][0][0];
      final g = result[0][0][0][1];
      final b = result[0][0][0][2];

      // red image: R should be 255, G and B should be 0
      expect(r, closeTo(255, 1));
      expect(g, closeTo(0, 1));
      expect(b, closeTo(0, 1));
    });

    test('throws on invalid image data', () async {
      final badFile = File('${tempDir.path}/bad.png');
      await badFile.writeAsBytes([0, 1, 2, 3]);

      expect(preProcessImage(badFile), throwsA(anything));
    });
  });
}
