import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/event_provider.dart";

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: "Sync",
      onPressed: () => _showSyncDialog(context),
    );
  }

  void _showSyncDialog(BuildContext context) {
    final eventProvider = context.read<EventProvider>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Sync Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final url = await _showUrlInputDialog(context);
                        if (url != null && url.isNotEmpty) {
                          setState(() => isLoading = true);
                          try {
                            await eventProvider.syncInit(url);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Sync initialized successfully")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
                              );
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Init Sync"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          await eventProvider.syncPull();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pulled successfully")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
                            );
                          }
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Pull"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          await eventProvider.syncPush();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pushed successfully")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
                            );
                          }
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Push"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          final status = await eventProvider.syncStatus();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Status: $status")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${_extractErrorMessage(e)}")),
                            );
                          }
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Status"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
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