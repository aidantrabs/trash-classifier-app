import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';

Future<Directory> getAppDirectory() async {
  /// Returns the applications documents directory
  return getApplicationDocumentsDirectory();
}

Future<List<SavedItem>> loadFolders() async {
  /// Returns a list of all user saved items in the application documents directory

  final appDirectory = await getAppDirectory();
  final appDirectoryPath = appDirectory.path;

  final userSavedDataDir = Directory('$appDirectoryPath/user_saved_data');

  if (!await userSavedDataDir.exists()) {
    await userSavedDataDir.create(recursive: true);
  }

  final userSavedDataContents = await userSavedDataDir.list().toList();
  final allItems = <SavedItem>[];

  for (final entity in userSavedDataContents) {
    if (entity is Directory) {
      log('Folder: ${entity.path}');
      allItems.add(SavedItem(directory: entity));
    }
  }
  allItems.sort((a, b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return allItems;
}

Future<void> deleteSelectedFolder(SavedItem item) async {
  try {
    await item.delete();
    log('Deleted Item: ${item.name}');
  } on Exception catch (e) {
    log('Error deleting folder: $e');
  }
}

Future<void> clearAllSavedData() async {
  final appDirectory = await getAppDirectory();
  final userSavedDataDir = Directory('${appDirectory.path}/user_saved_data');
  if (await userSavedDataDir.exists()) {
    await userSavedDataDir.delete(recursive: true);
    await userSavedDataDir.create();
    log('All saved data cleared');
  }
}
