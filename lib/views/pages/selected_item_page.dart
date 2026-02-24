import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/saved_item.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';
import 'package:trash_classifier_app/views/widgets/info_card.dart';

class SelectedItemPage extends StatefulWidget {
  const SelectedItemPage({required this.item, super.key});

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: _loaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // ── Image ────────────────────────────────────────
                  ClipRRect(
                    borderRadius: AppSpacing.borderRadiusLg,
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.file(item.imageFile, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Name ─────────────────────────────────────────
                  InfoCard(
                    label: 'Name',
                    child: Text(item.name, style: theme.textTheme.bodyLarge),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Classification ───────────────────────────────
                  InfoCard(
                    label: 'Classification',
                    child: Text(
                      prediction ?? 'No classification data found',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
