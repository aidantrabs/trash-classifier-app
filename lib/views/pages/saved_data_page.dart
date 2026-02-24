import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/data/constants.dart';
import 'package:trash_classifier_app/data/notifiers.dart';
import 'package:trash_classifier_app/utils/app_directory.dart';
import 'package:trash_classifier_app/views/pages/selected_item_page.dart';

class SavedDataPage extends StatefulWidget {
  /// Displays user saved data
  const SavedDataPage({super.key});

  @override
  State<SavedDataPage> createState() => _SavedDataPageState();
}

class _SavedDataPageState extends State<SavedDataPage> {
  List<SavedItem> loadedFolders = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
    newSavedDataNotifier.addListener(_onNewSavedData);
  }

  @override
  void dispose() {
    newSavedDataNotifier.removeListener(_onNewSavedData);
    super.dispose();
  }

  void _onNewSavedData() {
    imageCache.clear(); //This works but clears all loaded images. should be changed.
    _loadContent();
  }

  Future<void> _loadContent() async {
    loadedFolders = await loadFolders();
    setState(() {});
  }

  Future<void> _deleteFolder(SavedItem item) async {
    await deleteSelectedFolder(item);
    setState(() {
      loadedFolders.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadedFolders.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: loadedFolders.length,
        itemBuilder: (context, index) {
          final item = loadedFolders[index];
          return Column(
            children: [
              Slidable(
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.red,
                      onPressed: (context) {
                        _deleteFolder(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(duration: Duration(seconds: 3), content: Text('Item Delete Successfully')),
                        );
                      },
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),

                  title: Text(item.name, style: KTextStyle.labelStyle),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) {
                          return SelectedItemPage(item: item);
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, thickness: 1.5, indent: 8, endIndent: 8, color: Colors.grey),
            ],
          );
        },
      );
    } else {
      return const Center(child: Text('No Saved Data', style: KTextStyle.descriptionStyle));
    }
  }
}
