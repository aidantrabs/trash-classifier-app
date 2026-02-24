import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/data/constants.dart';

class SelectedItemPage extends StatefulWidget {
  const SelectedItemPage({required this.item, super.key});
  // Displays the item the user selected from the app directory
  final SavedItem item;

  @override
  State<SelectedItemPage> createState() => _SelectedItemPageState();
}

class _SelectedItemPageState extends State<SelectedItemPage> {
  String? prediction;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    prediction = await widget.item.readClassification();
    _loaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _loaded
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  width: double.infinity,
                  child: Card(
                    child: ListTile(
                      leading: const Text('Name: ', style: KTextStyle.descriptionStyle),
                      title: Text(item.name),
                    ),
                  ),
                ),
                SizedBox(height: 500, width: double.infinity, child: Image.file(item.imageFile)),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  width: double.infinity,
                  child: Card(
                    child: ListTile(
                      leading: const Text('Type: ', style: KTextStyle.descriptionStyle),
                      title: prediction == null ? const Text('No Classification Data Found') : Text(prediction!),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
