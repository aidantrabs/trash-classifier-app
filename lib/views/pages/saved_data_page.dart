import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/data/notifiers.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';
import 'package:trash_classifier_app/utils/app_directory.dart';
import 'package:trash_classifier_app/views/pages/selected_item_page.dart';
import 'package:trash_classifier_app/views/widgets/empty_state_widget.dart';
import 'package:trash_classifier_app/views/widgets/item_list_tile.dart';

class SavedDataPage extends StatefulWidget {
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
    imageCache.clear();
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
    final theme = Theme.of(context);

    if (loadedFolders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.bookmark_outline,
        title: 'No Saved Items',
        subtitle: 'Items you save will appear here',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: loadedFolders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = loadedFolders[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                borderRadius: AppSpacing.borderRadiusMd,
                onPressed: (context) {
                  _deleteFolder(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text('Item deleted'),
                    ),
                  );
                },
                icon: Icons.delete_outline,
              ),
            ],
          ),
          child: ItemListTile(
            title: item.name,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => SelectedItemPage(item: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
