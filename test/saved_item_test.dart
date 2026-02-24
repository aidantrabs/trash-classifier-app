import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';

void main() {
  group('SavedItem', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('saved_item_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('name returns directory basename', () {
      final item = SavedItem(directory: Directory('${tempDir.path}/My Bottle'));
      expect(item.name, 'My Bottle');
    });

    test('imagePath returns correct jpg path', () {
      final item = SavedItem(directory: Directory('${tempDir.path}/My Bottle'));
      expect(item.imagePath, '${tempDir.path}/My Bottle/My Bottle.jpg');
    });

    test('classificationPath returns correct txt path', () {
      final item = SavedItem(directory: Directory('${tempDir.path}/My Bottle'));
      expect(item.classificationPath, '${tempDir.path}/My Bottle/classification.txt');
    });

    test('readClassification returns null when file does not exist', () async {
      final itemDir = Directory('${tempDir.path}/Empty Item');
      await itemDir.create();
      final item = SavedItem(directory: itemDir);

      expect(await item.readClassification(), isNull);
    });

    test('readClassification returns content when file exists', () async {
      final itemDir = Directory('${tempDir.path}/Classified');
      await itemDir.create();
      await File('${itemDir.path}/classification.txt').writeAsString('Glass (92.5%)');
      final item = SavedItem(directory: itemDir);

      expect(await item.readClassification(), 'Glass (92.5%)');
    });

    test('delete removes the directory', () async {
      final itemDir = Directory('${tempDir.path}/ToDelete');
      await itemDir.create();
      await File('${itemDir.path}/test.txt').writeAsString('data');
      final item = SavedItem(directory: itemDir);

      await item.delete();
      expect(await itemDir.exists(), isFalse);
    });

    test('delete does nothing when directory does not exist', () async {
      final item = SavedItem(directory: Directory('${tempDir.path}/NonExistent'));
      // should not throw
      await item.delete();
    });
  });
}
