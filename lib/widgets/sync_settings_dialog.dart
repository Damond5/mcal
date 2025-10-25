import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/sync_settings.dart';

class SyncSettingsDialog extends StatefulWidget {
  const SyncSettingsDialog({super.key});

  @override
  State<SyncSettingsDialog> createState() => _SyncSettingsDialogState();
}

class _SyncSettingsDialogState extends State<SyncSettingsDialog> {
  late bool _autoSyncEnabled;
  late bool _resumeSyncEnabled;
  late double _syncFrequencyMinutes;

  @override
  void initState() {
    super.initState();
    final settings = context.read<EventProvider>().syncSettings;
    _autoSyncEnabled = settings.autoSyncEnabled;
    _resumeSyncEnabled = settings.resumeSyncEnabled;
    _syncFrequencyMinutes = settings.syncFrequencyMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Auto Sync'),
            subtitle: const Text('Automatically sync events periodically'),
            value: _autoSyncEnabled,
            onChanged: (value) => setState(() => _autoSyncEnabled = value),
          ),
          SwitchListTile(
            title: const Text('Sync on Resume'),
            subtitle: const Text('Sync when app is resumed'),
            value: _resumeSyncEnabled,
            onChanged: (value) => setState(() => _resumeSyncEnabled = value),
          ),
          ListTile(
            title: const Text('Sync Frequency (minutes)'),
            subtitle: Slider(
              value: _syncFrequencyMinutes,
              min: 5,
              max: 60,
              divisions: 11,
              label: _syncFrequencyMinutes.round().toString(),
              onChanged: (value) => setState(() => _syncFrequencyMinutes = value),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final newSettings = SyncSettings(
              autoSyncEnabled: _autoSyncEnabled,
              resumeSyncEnabled: _resumeSyncEnabled,
              syncFrequencyMinutes: _syncFrequencyMinutes.round(),
            );
            await context.read<EventProvider>().saveSyncSettings(newSettings);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}