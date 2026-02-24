import 'package:flutter/material.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';

/// A card-style list row for displaying saved items.
/// Used by both saved_data_page and search results.
class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              if (trailing != null) trailing!,
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
