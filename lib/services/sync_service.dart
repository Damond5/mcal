   import "dart:io";
   import "dart:developer";
   import "package:flutter_secure_storage/flutter_secure_storage.dart";
   import "package:path_provider/path_provider.dart";

class SyncConflictException implements Exception {
  final String message;
  SyncConflictException(this.message);
}

class SyncService {
  static const String _remoteUrlKey = "git_remote_url";
  static const String _usernameKey = "git_username";
  static const String _passwordKey = "git_password";
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> _getGitExecutable() async {
    return 'git';
  }

  Future<String> _getAppDocDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final calendarDir = Directory('${dir.path}/calendar');
    await calendarDir.create(recursive: true);
    return calendarDir.path;
  }

  Future<String?> _getRemoteUrl() async {
    return await _secureStorage.read(key: _remoteUrlKey);
  }

  Future<void> _setRemoteUrl(String url) async {
    await _secureStorage.write(key: _remoteUrlKey, value: url);
  }

  Future<String?> _getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  Future<String?> _getPassword() async {
    return await _secureStorage.read(key: _passwordKey);
  }

  Future<void> updateCredentials(String? username, String? password) async {
    await _setCredentials(username, password);
  }

  Future<void> _setCredentials(String? username, String? password) async {
    if (username != null) {
      await _secureStorage.write(key: _usernameKey, value: username);
    } else {
      await _secureStorage.delete(key: _usernameKey);
    }
    if (password != null) {
      await _secureStorage.write(key: _passwordKey, value: password);
    } else {
      await _secureStorage.delete(key: _passwordKey);
    }
  }

  Future<void> _runGitCommand(List<String> args, {String? errorMessage}) async {
    final result = await _runGitCommandWithResult(args);
    if (result.exitCode != 0) {
      final sanitizedStderr = result.stderr.toString().replaceAll(RegExp(r'https?://[^@]+@[^/]+'), '<redacted>');
      log('Git command failed: git ${args.join(' ')}, stderr: $sanitizedStderr');
      throw Exception(errorMessage ?? "Git command failed: $sanitizedStderr");
    }
  }

  Future<ProcessResult> _runGitCommandWithResult(List<String> args) async {
    final executable = await _getGitExecutable();
    final workingDirectory = await _getAppDocDir();
    final modifiedArgs = await _injectCredentialsIntoArgs(args);
    final sanitizedArgs = modifiedArgs.map((arg) {
      if (arg.startsWith('https://') || arg.startsWith('http://') || arg.startsWith('git@') || arg.startsWith('ssh://')) {
        return '<redacted>';
      }
      return arg;
    }).toList();
    try {
      final result = await Process.run(executable, modifiedArgs, workingDirectory: workingDirectory);
      return result;
    } catch (e) {
      final sanitizedError = e.toString().replaceAll(RegExp(r'https?://[^@]+@[^/]+'), '<redacted>');
      log('Failed to run git command: $executable ${sanitizedArgs.join(' ')}, error: $sanitizedError');
      throw Exception("Failed to run git command: $sanitizedError");
    }
  }

  Future<List<String>> _injectCredentialsIntoArgs(List<String> args) async {
    final username = await _getUsername();
    final password = await _getPassword();
    final url = await _getRemoteUrl();
    if (url == null || username == null || password == null) {
      return args; // No injection needed
    }
    return args.map((arg) {
      if (arg == url && (url.startsWith('https://') || url.startsWith('http://'))) {
        final scheme = url.startsWith('https://') ? 'https://' : 'http://';
        final afterScheme = url.substring(scheme.length);
        if (!afterScheme.contains('@')) {
          return '$scheme${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}@$afterScheme';
        }
      }
      return arg;
    }).toList();
  }

  bool _isValidUrl(String url) {
    // Regex for HTTPS/HTTP: basic host validation
    final httpsRegex = RegExp(r'^https?://[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,})+(?:/.*)?$');
    if (httpsRegex.hasMatch(url)) {
      return true;
    }
    // Regex for SSH: git@host:path or ssh://git@host/path
    final sshRegex = RegExp(r'^(git@[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,})+:|ssh://git@[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,})+/).+$');
    if (sshRegex.hasMatch(url)) {
      return true;
    }
    return false;
  }

  Future<void> _checkGitAvailability() async {
    await _runGitCommand(['--version']);
  }

  Future<void> initSync(String url, {String? username, String? password}) async {
    if (Platform.isAndroid) {
      throw Exception("Git sync is not supported on Android due to libc compatibility issues. Please install Termux (from F-Droid or Google Play) and Git manually, then use the app.");
    }
    log('Initializing sync for URL: <redacted>, with credentials: ${username != null && password != null ? 'provided' : 'none'}');
    url = url.trim().replaceAll('"', '').replaceAll("'", '');
    if (!_isValidUrl(url)) {
      throw Exception("Invalid URL format. Use HTTPS, HTTP, or SSH URL.");
    }
    // Store credentials separately
    await _setCredentials(username, password);
    // Store base URL without credentials
    await _setRemoteUrl(url);
    await _checkGitAvailability();
    try {
      await _runGitCommand(['init']);
      await _runGitCommand(['remote', 'remove', 'origin'], errorMessage: "Failed to remove existing remote");
      await _runGitCommand(['remote', 'add', 'origin', url]);
      try {
        await _runGitCommand(['fetch', 'origin']);
        try {
          await _runGitCommand(['checkout', 'main']);
          await _runGitCommand(['branch', '--set-upstream-to=origin/main']);
        } catch (e) {
          try {
            await _runGitCommand(['checkout', 'master']);
            await _runGitCommand(['branch', '--set-upstream-to=origin/master']);
          } catch (e) {
            try {
              await _runGitCommand(['checkout', 'develop']);
              await _runGitCommand(['branch', '--set-upstream-to=origin/develop']);
            } catch (e) {
              await _runGitCommand(['checkout', 'trunk']);
              await _runGitCommand(['branch', '--set-upstream-to=origin/trunk']);
            }
          }
        }
      } catch (e) {
        // Ignore if remote is empty
      }
     } catch (e) {
       log('Sync initialization failed: $e');
       throw Exception("Sync initialization failed: $e");
     }
  }

  Future<void> pullSync() async {
    log('Pulling sync from remote');
    final url = await _getRemoteUrl();
    if (url == null) {
      throw Exception("No remote URL configured. Please initialize sync first.");
    }
    await _checkGitAvailability();
     try {
       await _runGitCommand(['pull', 'origin']);
     } catch (e) {
       log('Pull sync failed: $e');
       if (e.toString().toLowerCase().contains('conflict')) {
         throw SyncConflictException("Merge conflict detected during pull. Please resolve manually.");
       }
       throw Exception("Pull sync failed: $e");
     }
  }

  Future<void> pushSync() async {
    log('Pushing sync to remote');
    final url = await _getRemoteUrl();
    if (url == null) {
      throw Exception("No remote URL configured. Please initialize sync first.");
    }
    await _checkGitAvailability();
    try {
      final result = await _runGitCommandWithResult(['status', '--porcelain']);
      if (result.exitCode != 0 || result.stdout.toString().trim().isEmpty) {
        throw Exception("No changes to push");
      }
      await _runGitCommand(['add', '.']);
      await _runGitCommand(['commit', '-m', 'Sync events']);
      await _runGitCommand(['push', 'origin']);
     } catch (e) {
       log('Push sync failed: $e');
       throw Exception("Push sync failed: $e");
     }
  }

  Future<String> getSyncStatus() async {
    await _checkGitAvailability();
    try {
      final result = await _runGitCommandWithResult(['status', '--porcelain']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim().isEmpty ? "clean" : "modified";
      } else {
        if (result.stderr.toString().contains("not a git repository")) {
          return "not initialized";
        }
        throw Exception("Failed to get git status: ${result.stderr}");
      }
    } catch (e) {
      log('Failed to get git status: $e');
      throw Exception("Failed to get git status: $e");
    }
  }

  Future<bool> isSyncInitialized() async {
    final url = await _getRemoteUrl();
    return url != null;
  }

  Future<void> resolveConflictPreferRemote() async {
    await _checkGitAvailability();
    try {
      await _runGitCommand(['add', '.']);
      await _runGitCommand(['rebase', '--continue']);
    } catch (e) {
      log('Resolve conflict failed: $e');
      throw Exception("Failed to resolve conflict: $e");
    }
  }

  Future<void> abortConflict() async {
    await _checkGitAvailability();
    try {
      await _runGitCommand(['rebase', '--abort']);
    } catch (e) {
      log('Abort conflict failed: $e');
      throw Exception("Failed to abort conflict: $e");
    }
  }
}