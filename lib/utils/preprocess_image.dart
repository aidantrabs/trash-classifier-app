import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

// top level function so it can run in an isolate
// takes raw image bytes, returns tensor shaped [1, 224, 224, 3]
List<List<List<List<double>>>> _processBytes(Uint8List imageBytes) {
  const int imageSize = 224;

  img.Image? image = img.decodeImage(imageBytes);
  if (image == null) throw Exception("Could not decode image");

  img.Image resizedImage = img.copyResize(
    image,
    width: imageSize,
    height: imageSize,
  );

  List<List<List<double>>> imageAsFloatList = List.generate(
    imageSize,
    (index) => List.generate(imageSize, (index) => List.filled(3, 0.0)),
  );

  for (int y = 0; y < imageSize; y++) {
    for (int x = 0; x < imageSize; x++) {
      img.Pixel pixel = resizedImage.getPixel(x, y);

      // Raw RGB values (0-255) — model has a built-in Rescaling(1./255) layer
      imageAsFloatList[y][x][0] = pixel.r.toDouble();
      imageAsFloatList[y][x][1] = pixel.g.toDouble();
      imageAsFloatList[y][x][2] = pixel.b.toDouble();
    }
  }

  return [imageAsFloatList]; // shape: [1, 224, 224, 3]
}

Future<List<List<List<List<double>>>>> preProcessImage(File imagePath) async {
  log("PreProcessing Image");

  final Uint8List imageBytes = await imagePath.readAsBytes();
  return Isolate.run(() => _processBytes(imageBytes));
}
