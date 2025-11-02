import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/event_provider.dart";
import "../services/sync_service.dart";
import "../utils/error_logger.dart";
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
        const PopupMenuItem(
          value: 'update_creds',
          child: Text('Update Credentials'),
        ),
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
      case 'update_creds':
        _showUpdateCredentialsDialog(context);
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

  void _showUpdateCredentialsDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    final creds = await _showCredentialsInputDialog(context);
    if (creds != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Updating credentials..."),
            ],
          ),
        ),
      );
      try {
        await eventProvider.updateCredentials(
          creds['username'],
          creds['password'],
        );
        if (context.mounted) {
          Navigator.of(context).pop(); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Credentials updated successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // close loading
          logGuiError(
            "Credentials update failed",
            error: e,
            context: "update_credentials",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
          );
        }
      }
    }
  }

  void _showInitDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    final creds = await _showUrlInputDialog(context);
    if (creds != null && creds['url']!.isNotEmpty && context.mounted) {
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
        await eventProvider.syncInit(
          creds['url']!,
          username: creds['username'],
          password: creds['password'],
        );
        if (context.mounted) {
          Navigator.of(context).pop(); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sync initialized successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // close loading
          logGuiError(
            "Sync initialization failed",
            error: e,
            context: "sync_init",
          );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pulled successfully")));
      }
    } on SyncConflictException {
      if (context.mounted) {
        Navigator.of(context).pop();
        await ConflictResolutionDialog.show(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        logGuiError("Sync pull failed", error: e, context: "sync_pull");
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pushed successfully")));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        logGuiError("Sync push failed", error: e, context: "sync_push");
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Status: $status")));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        logGuiError(
          "Sync status check failed",
          error: e,
          context: "sync_status",
        );
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

  Future<Map<String, String>?> _showCredentialsInputDialog(
    BuildContext context,
  ) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String? usernameError;
    String? passwordError;
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Update Credentials"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    errorText: usernameError,
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password/Token",
                    errorText: passwordError,
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();
                final credsValid =
                    (username.isEmpty && password.isEmpty) ||
                    (username.isNotEmpty && password.isNotEmpty);
                if (username.isNotEmpty || password.isNotEmpty) {
                  // Validate credential length and characters
                  if (username.length > 100 || password.length > 100) {
                    setState(() {
                      usernameError = username.length > 100
                          ? "Username too long"
                          : null;
                      passwordError = password.length > 100
                          ? "Password/Token too long"
                          : null;
                    });
                    return;
                  }
                  final invalidChars = RegExp(
                    r'[^\x20-\x7E]',
                  ); // Non-printable ASCII
                  if (invalidChars.hasMatch(username) ||
                      invalidChars.hasMatch(password)) {
                    setState(() {
                      usernameError = invalidChars.hasMatch(username)
                          ? "Username contains invalid characters"
                          : null;
                      passwordError = invalidChars.hasMatch(password)
                          ? "Password/Token contains invalid characters"
                          : null;
                    });
                    return;
                  }
                }
                if (credsValid) {
                  Navigator.of(
                    context,
                  ).pop({'username': username, 'password': password});
                } else {
                  setState(() {
                    usernameError = username.isEmpty
                        ? "Username required if password provided"
                        : null;
                    passwordError = password.isEmpty
                        ? "Password required if username provided"
                        : null;
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

  Future<Map<String, String>?> _showUrlInputDialog(BuildContext context) async {
    final urlController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String? urlError;
    String? usernameError;
    String? passwordError;
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Initialize Sync"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: "Repository URL",
                    hintText:
                        "https://gitlab.com/user/repo.git (use for auth) or git@gitlab.com:user/repo.git",
                    errorText: urlError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      urlError = _validateUrl(value);
                    });
                  },
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username (for HTTPS only)",
                    errorText: usernameError,
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password/Token (for HTTPS only)",
                    errorText: passwordError,
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final url = urlController.text.trim();
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();
                final urlValid = _validateUrl(url) == null && url.isNotEmpty;
                final credsValid =
                    (username.isEmpty && password.isEmpty) ||
                    (username.isNotEmpty && password.isNotEmpty);
                if (username.isNotEmpty || password.isNotEmpty) {
                  if (!url.startsWith('https://')) {
                    setState(() {
                      urlError =
                          "Credentials are only supported for HTTPS URLs. For SSH, leave username/password empty.";
                    });
                    return;
                  }
                  // Validate credential length and characters
                  if (username.length > 100 || password.length > 100) {
                    setState(() {
                      usernameError = username.length > 100
                          ? "Username too long"
                          : null;
                      passwordError = password.length > 100
                          ? "Password/Token too long"
                          : null;
                    });
                    return;
                  }
                  final invalidChars = RegExp(
                    r'[^\x20-\x7E]',
                  ); // Non-printable ASCII
                  if (invalidChars.hasMatch(username) ||
                      invalidChars.hasMatch(password)) {
                    setState(() {
                      usernameError = invalidChars.hasMatch(username)
                          ? "Username contains invalid characters"
                          : null;
                      passwordError = invalidChars.hasMatch(password)
                          ? "Password/Token contains invalid characters"
                          : null;
                    });
                    return;
                  }
                }
                if (urlValid && credsValid) {
                  Navigator.of(context).pop({
                    'url': url,
                    'username': username,
                    'password': password,
                  });
                } else {
                  setState(() {
                    urlError = _validateUrl(url);
                    if (!credsValid) {
                      usernameError = username.isEmpty
                          ? "Username required if password provided"
                          : null;
                      passwordError = password.isEmpty
                          ? "Password required if username provided"
                          : null;
                    }
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
    String message = e is Exception
        ? e.toString().replaceFirst("Exception: ", "")
        : e.toString();
    // Sanitize any URLs with credentials
    message = message.replaceAll(RegExp(r'https?://[^@]+@[^/]+'), '<redacted>');
    return message;
  }
}
