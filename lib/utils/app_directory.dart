import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';

Future<Directory> getAppDirectory() async {
  /// Returns the applications documents directory
  return (await getApplicationDocumentsDirectory());
}

Future<List<SavedItem>> loadFolders() async {
  /// Returns a list of all user saved items in the application documents directory

  final Directory appDirectory = await getAppDirectory();
  final String appDirectoryPath = appDirectory.path;

  final Directory userSavedDataDir = Directory(
    "$appDirectoryPath/user_saved_data",
  );

  if (!await userSavedDataDir.exists()) {
    await userSavedDataDir.create(recursive: true);
  }

  final List<FileSystemEntity> userSavedDataContents = await userSavedDataDir
      .list()
      .toList();
  final List<SavedItem> allItems = [];

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
  /// Deletes a saved item from the application document directory
  try {
    await item.delete();
    log("Deleted Item: ${item.name}");
  } catch (e) {
    log("Error deleting folder: $e");
  }
}
