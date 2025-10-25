import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/event_provider.dart";
import "../services/sync_service.dart";
import "sync_settings_dialog.dart";
import "conflict_resolution_dialog.dart";

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sync),
      tooltip: "Sync",
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'init', child: Text('Init Sync')),
        const PopupMenuItem(value: 'pull', child: Text('Pull')),
        const PopupMenuItem(value: 'push', child: Text('Push')),
        const PopupMenuItem(value: 'status', child: Text('Status')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'init':
        _showInitDialog(context);
        break;
      case 'pull':
        _showPullDialog(context);
        break;
      case 'push':
        _showPushDialog(context);
        break;
      case 'status':
        _showStatusDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
    }
  }

  void _showInitDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    final url = await _showUrlInputDialog(context);
    if (url != null && url.isNotEmpty && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Initializing sync..."),
            ],
          ),
        ),
      );
      try {
        await eventProvider.syncInit(url);
        if (context.mounted) {
          Navigator.of(context).pop(); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sync initialized successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
          );
        }
      }
    }
  }

  void _showPullDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Pulling..."),
          ],
        ),
      ),
    );
    try {
      await eventProvider.syncPull();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pulled successfully")),
        );
      }
    } on SyncConflictException {
      if (context.mounted) {
        Navigator.of(context).pop();
        await ConflictResolutionDialog.show(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
        );
      }
    }
  }

  void _showPushDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Pushing..."),
          ],
        ),
      ),
    );
    try {
      await eventProvider.syncPush();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pushed successfully")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
        );
      }
    }
  }

  void _showStatusDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Checking status..."),
          ],
        ),
      ),
    );
    try {
      final status = await eventProvider.syncStatus();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status: $status")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
        );
      }
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SyncSettingsDialog(),
    );
  }

  Future<String?> _showUrlInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? errorText;
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Enter Repository URL"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "https://github.com/user/repo.git",
              errorText: errorText,
            ),
            onChanged: (value) {
              setState(() {
                errorText = _validateUrl(value);
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final url = controller.text.trim();
                if (_validateUrl(url) == null && url.isNotEmpty) {
                  Navigator.of(context).pop(url);
                } else {
                  setState(() {
                    errorText = _validateUrl(url);
                  });
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateUrl(String url) {
    if (url.isEmpty) return "URL cannot be empty";
    if (!url.startsWith("http") && !url.startsWith("git@")) {
      return "URL must start with http or git@";
    }
    return null;
  }

  String _extractErrorMessage(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceFirst("Exception: ", "");
    }
    return e.toString();
  }
}