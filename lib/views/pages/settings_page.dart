import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash_classifier_app/data/constants.dart';
import 'package:trash_classifier_app/data/notifiers.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';
import 'package:trash_classifier_app/utils/app_directory.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all saved items. '
          'This action cannot be undone.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await clearAllSavedData();
      newSavedDataNotifier.value = !newSavedDataNotifier.value;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          content: Text('All saved data cleared'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Dark Mode'),
                  value: darkModeNotifier.value,
                  onChanged: (value) async {
                    darkModeNotifier.value = value;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(KConstant.darkModeKey, value);
                  },
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                  color: theme.colorScheme.outline,
                ),
                ListTile(
                  title: Text(
                    'Clear All Data',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  trailing: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  onTap: _clearAllData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
