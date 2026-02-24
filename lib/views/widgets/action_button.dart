import 'package:flutter/material.dart';

/// A themed circular icon button for primary actions (delete, save, etc.).
class ActionButton extends StatelessWidget {
  const ActionButton({required this.icon, required this.onPressed, this.color, this.tooltip, super.key});

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = color ?? theme.colorScheme.primary;

    return Material(
      shape: const CircleBorder(),
      color: bg,
      child: IconButton(icon: Icon(icon), color: theme.colorScheme.onPrimary, onPressed: onPressed, tooltip: tooltip),
    );
  }
}
