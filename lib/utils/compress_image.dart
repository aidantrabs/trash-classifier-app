import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const int _maxDimension = 1024;
const int _jpegQuality = 85;

Uint8List _compress(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) throw Exception('Could not decode image for compression');

  var resized = image;
  if (image.width > _maxDimension || image.height > _maxDimension) {
    resized = image.width >= image.height
        ? img.copyResize(image, width: _maxDimension)
        : img.copyResize(image, height: _maxDimension);
  }

  return Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
}

Future<void> compressAndSave(File source, String destinationPath) async {
  final imageBytes = await source.readAsBytes();
  final compressed = await Isolate.run(() => _compress(imageBytes));
  await File(destinationPath).writeAsBytes(compressed);
}
