import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/custom_search_delegate.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/utils/app_directory.dart';

class SearchBarWidget extends StatefulWidget {
  /// Allows for users to access a search bar
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  List<SavedItem> loadedFolders = [];

  Future<void> _loadContent() async {
    loadedFolders = await loadFolders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _loadContent();
        if (!mounted) {
          return;
        }

        // ignore: use_build_context_synchronously — mounted check above guards this
        await showSearch(context: context, delegate: CustomSearchDelegate(loadedFolders: loadedFolders));
      },
      icon: const Icon(Icons.search),
    );
  }
}
