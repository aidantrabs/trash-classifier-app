import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';
import 'package:trash_classifier_app/views/pages/selected_item_page.dart';
import 'package:trash_classifier_app/views/widgets/item_list_tile.dart';

class CustomSearchDelegate extends SearchDelegate<void> {
  CustomSearchDelegate({required this.loadedFolders});

  List<SavedItem> loadedFolders;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  Widget _buildMatchList(BuildContext context) {
    final matchQuery = <SavedItem>[];
    for (final item in loadedFolders) {
      if (item.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: matchQuery.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = matchQuery[index];
        return ItemListTile(
          title: item.name,
          onTap: () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (context) => SelectedItemPage(item: item)));
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildMatchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatchList(context);
}
