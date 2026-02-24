import 'package:flutter/material.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';

/// A vertical label-above-value card used for displaying classification
/// results, names, and other key-value information.
class InfoCard extends StatelessWidget {
  const InfoCard({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
            const SizedBox(height: AppSpacing.xs),
            child,
          ],
        ),
      ),
    );
  }
}
