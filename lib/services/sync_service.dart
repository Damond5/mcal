import "dart:io";
import "dart:developer";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:path_provider/path_provider.dart";
import "../frb_generated.dart";
import "certificate_service.dart";

class SyncConflictException implements Exception {
  final String message;
  SyncConflictException(this.message);
}

class SyncService {
  static const String _remoteUrlKey = "git_remote_url";
  static const String _usernameKey = "git_username";
  static const String _passwordKey = "git_password";
  static const String _sshKeyKey = "git_ssh_key_path";
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final RustLibApi _api;
  final CertificateService _certificateService = CertificateService();

  // ignore: invalid_use_of_internal_member
  SyncService([RustLibApi? api]) : _api = api ?? RustLib.instance.api;

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

  Future<String?> _getSshKeyPath() async {
    return await _secureStorage.read(key: _sshKeyKey);
  }

  Future<void> updateCredentials(
    String? username,
    String? password, {
    String? sshKeyPath,
  }) async {
    await _setCredentials(username, password, sshKeyPath: sshKeyPath);
  }

  Future<void> _setCredentials(
    String? username,
    String? password, {
    String? sshKeyPath,
  }) async {
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
    if (sshKeyPath != null) {
      await _secureStorage.write(key: _sshKeyKey, value: sshKeyPath);
    } else {
      await _secureStorage.delete(key: _sshKeyKey);
    }
  }

  bool _isValidUrl(String url) {
    // Regex for HTTPS/HTTP: basic host validation
    final httpsRegex = RegExp(
      r'^https?://[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,})+(?:/.*)?$',
    );
    if (httpsRegex.hasMatch(url)) {
      return true;
    }
    // Regex for SSH: git@host:path or ssh://git@host/path
    final sshRegex = RegExp(
      r'^(git@[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,})+:|ssh://git@[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,})+/).+$',
    );
    if (sshRegex.hasMatch(url)) {
      return true;
    }
    return false;
  }

  Future<void> initSync(
    String url, {
    String? username,
    String? password,
    String? sshKeyPath,
  }) async {
    log(
      'Initializing sync for URL: <redacted>, with credentials: ${username != null && password != null ? 'provided' : 'none'}',
    );
    url = url.trim().replaceAll('"', '').replaceAll("'", '');
    if (!_isValidUrl(url)) {
      throw Exception("Invalid URL format. Use HTTPS, HTTP, or SSH URL.");
    }
    // Store credentials separately
    await _setCredentials(username, password, sshKeyPath: sshKeyPath);
    // Store base URL without credentials
    await _setRemoteUrl(url);
    final path = await _getAppDocDir();

    // Configure SSL CA certificates for git operations
    try {
      final caCerts = await _certificateService.getSystemCACertificates();
      if (caCerts.isNotEmpty) {
        await _api.crateApiSetSslCaCerts(pemCerts: caCerts);
        log('Configured ${caCerts.length} CA certificates for SSL validation');
      } else {
        log('No CA certificates available, using default SSL behavior');
      }
    } catch (e) {
      log('Failed to configure CA certificates: $e, falling back to default');
    }

    try {
      await _api.crateApiGitInit(path: path);
      await _api.crateApiGitAddRemote(path: path, name: 'origin', url: url);
      try {
        await _api.crateApiGitFetch(
          path: path,
          remote: 'origin',
          username: username,
          password: password,
        );
        try {
          await _api.crateApiGitCheckout(path: path, branch: 'main');
        } catch (e) {
          try {
            await _api.crateApiGitCheckout(path: path, branch: 'master');
          } catch (e) {
            try {
              await _api.crateApiGitCheckout(path: path, branch: 'develop');
            } catch (e) {
              await _api.crateApiGitCheckout(path: path, branch: 'trunk');
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
      throw Exception(
        "No remote URL configured. Please initialize sync first.",
      );
    }
    final path = await _getAppDocDir();
    try {
      final username = await _getUsername();
      final password = await _getPassword();
      final sshKeyPath = await _getSshKeyPath();
      final result = await _api.crateApiGitPull(
        path: path,
        username: username,
        password: password,
        sshKeyPath: sshKeyPath,
      );
      if (result.contains('Non-fast-forward')) {
        log('Pull sync detected non-fast-forward merge, treating as conflict');
        throw SyncConflictException(
          "Merge conflict detected during pull. Please resolve manually.",
        );
      }
      log('Pull sync completed successfully: $result');
    } catch (e) {
      log('Pull sync failed: $e');
      if (e.toString().toLowerCase().contains('conflict')) {
        throw SyncConflictException(
          "Merge conflict detected during pull. Please resolve manually.",
        );
      }
      throw Exception("Pull sync failed: $e");
    }
  }

  Future<void> pushSync() async {
    log('Pushing sync to remote');
    final url = await _getRemoteUrl();
    if (url == null) {
      throw Exception(
        "No remote URL configured. Please initialize sync first.",
      );
    }
    final path = await _getAppDocDir();
    final username = await _getUsername();
    final password = await _getPassword();
    final sshKeyPath = await _getSshKeyPath();
    try {
      final status = await _api.crateApiGitStatus(path: path);
      if (status.isEmpty) {
        log('Push sync skipped: no changes to push');
        return;
      }
      log('Adding and committing changes');
      await _api.crateApiGitAddAll(path: path);
      await _api.crateApiGitCommit(path: path, message: 'Sync events');
      log('Pushing to remote');
      await _api.crateApiGitPush(
        path: path,
        username: username,
        password: password,
        sshKeyPath: sshKeyPath,
      );
      log('Push sync completed successfully');
    } catch (e) {
      log('Push sync failed: $e');
      throw Exception("Push sync failed: $e");
    }
  }

  Future<String> getSyncStatus() async {
    final path = await _getAppDocDir();
    try {
      final status = await _api.crateApiGitStatus(path: path);
      if (status.isEmpty) {
        return "clean";
      } else {
        return "modified";
      }
    } catch (e) {
      if (e.toString().contains('not a git repository')) {
        return "not initialized";
      }
      log('Failed to get git status: $e');
      throw Exception("Failed to get git status: $e");
    }
  }

  Future<bool> isSyncInitialized() async {
    final url = await _getRemoteUrl();
    return url != null;
  }

  Future<void> resolveConflictPreferRemote() async {
    final path = await _getAppDocDir();
    try {
      log('Resolving merge conflict by preferring remote changes');
      await _api.crateApiGitMergePreferRemote(path: path);
      log('Merge conflict resolved successfully by preferring remote');
    } catch (e) {
      log('Resolve conflict failed: $e');
      throw Exception("Failed to resolve conflict: $e");
    }
  }

  Future<void> abortConflict() async {
    final path = await _getAppDocDir();
    try {
      log('Aborting merge conflict');
      await _api.crateApiGitMergeAbort(path: path);
      log('Merge conflict aborted successfully');
    } catch (e) {
      log('Abort conflict failed: $e');
      throw Exception("Failed to abort conflict: $e");
    }
  }
}
