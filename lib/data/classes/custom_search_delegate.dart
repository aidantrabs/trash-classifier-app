import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/data/constants.dart';
import 'package:trash_classifier_app/views/pages/selected_item_page.dart';

class CustomSearchDelegate extends SearchDelegate {
  /// Holds widgets which give functionality to the search bar. (Ui of the search bar + Displaying the results)
  List<SavedItem> loadedFolders;

  CustomSearchDelegate({required this.loadedFolders});

  List<String> searchTerms = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  Widget _buildMatchList(BuildContext context) {
    List<SavedItem> matchQuery = [];
    for (var item in loadedFolders) {
      if (item.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8),
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final SavedItem item = matchQuery[index];
        return Column(
          children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              title: Text(item.name, style: KTextStyle.labelStyle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SelectedItemPage(item: item);
                    },
                  ),
                );
              },
            ),
            Divider(
              height: 1,
              thickness: 1.5,
              indent: 8,
              endIndent: 8,
              color: Colors.grey,
            ),
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
