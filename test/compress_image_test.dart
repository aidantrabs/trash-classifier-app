import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trash_classifier_app/utils/compress_image.dart';

void main() {
  group('compressAndSave', () {
    late Directory tempDir;
    late File largeImageFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('compress_test_');

      // create a 2000x1500 test image as JPEG (larger than _maxDimension of 1024)
      final largeImage = img.Image(width: 2000, height: 1500);
      for (var y = 0; y < 1500; y++) {
        for (var x = 0; x < 2000; x++) {
          largeImage.setPixelRgb(x, y, x % 256, y % 256, (x + y) % 256);
        }
      }

      largeImageFile = File('${tempDir.path}/large.jpg');
      await largeImageFile.writeAsBytes(img.encodeJpg(largeImage, quality: 100));
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('creates output file at destination path', () async {
      final destPath = '${tempDir.path}/output.jpg';
      await compressAndSave(largeImageFile, destPath);

      expect(await File(destPath).exists(), isTrue);
    });

    test('output is smaller than input', () async {
      final destPath = '${tempDir.path}/output.jpg';
      await compressAndSave(largeImageFile, destPath);

      final inputSize = await largeImageFile.length();
      final outputSize = await File(destPath).length();

      expect(outputSize, lessThan(inputSize));
    });

    test('output image is resized to max 1024px on longest side', () async {
      final destPath = '${tempDir.path}/output.jpg';
      await compressAndSave(largeImageFile, destPath);

      final outputBytes = await File(destPath).readAsBytes();
      final outputImage = img.decodeImage(outputBytes)!;

      expect(outputImage.width, 1024);
      expect(outputImage.height, lessThanOrEqualTo(1024));
    });

    test('does not upscale small images', () async {
      // create a 200x100 image (smaller than 1024)
      final smallImage = img.Image(width: 200, height: 100);
      final smallFile = File('${tempDir.path}/small.png');
      await smallFile.writeAsBytes(img.encodePng(smallImage));

      final destPath = '${tempDir.path}/small_output.jpg';
      await compressAndSave(smallFile, destPath);

      final outputBytes = await File(destPath).readAsBytes();
      final outputImage = img.decodeImage(outputBytes)!;

      expect(outputImage.width, 200);
      expect(outputImage.height, 100);
    });
  });
}
