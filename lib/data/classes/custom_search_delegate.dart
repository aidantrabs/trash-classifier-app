import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/views/pages/selected_item_page.dart';

class CustomSearchDelegate extends SearchDelegate<void> {
  CustomSearchDelegate({required this.loadedFolders});

  /// Holds widgets which give functionality to the search bar. (Ui of the search bar + Displaying the results)
  List<SavedItem> loadedFolders;

  List<String> searchTerms = [];

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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final item = matchQuery[index];
        return Column(
          children: [
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: Text(
                item.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
            const Divider(height: 1, thickness: 1.5, indent: 8, endIndent: 8, color: Colors.grey),
          ],
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildMatchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatchList(context);
}
