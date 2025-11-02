import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../services/sync_service.dart';
import '../utils/error_logger.dart';

class ConflictResolutionDialog extends StatelessWidget {
  const ConflictResolutionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Conflict'),
      content: const Text(
        'A merge conflict occurred during sync. Choose how to resolve it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop('local'),
          child: const Text('Keep Local'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop('remote'),
          child: const Text('Use Remote'),
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ConflictResolutionDialog(),
    );

    if (!context.mounted) return;

    if (result == 'remote') {
      if (context.mounted) {
        try {
          await SyncService().resolveConflictPreferRemote();
          if (!context.mounted) return;
          await context.read<EventProvider>().syncPull(); // retry pull
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conflict resolved, pulled successfully')),
          );
         } catch (e) {
           if (!context.mounted) return;
           logGuiError("Conflict resolution failed", error: e, context: "conflict_resolution");
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Failed to resolve conflict: $e')),
           );
         }
      }
    } else if (result == 'local') {
      if (context.mounted) {
        try {
          await SyncService().abortConflict();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conflict aborted, kept local changes')),
          );
         } catch (e) {
           if (!context.mounted) return;
           logGuiError("Conflict abort failed", error: e, context: "conflict_abort");
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Failed to abort conflict: $e')),
           );
         }
      }
    }
  }
}