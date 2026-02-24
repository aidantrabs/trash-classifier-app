import 'dart:io';

import 'package:path/path.dart';

class SavedItem {
  SavedItem({required this.directory});
  final Directory directory;

  String get name => basename(directory.path);

  String get imagePath => '${directory.path}/$name.jpg';

  String get classificationPath => '${directory.path}/classification.txt';

  File get imageFile => File(imagePath);

  Future<String?> readClassification() async {
    final file = File(classificationPath);
    if (await file.exists()) {
      return file.readAsString();
    }
    return null;
  }

  Future<void> delete() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
