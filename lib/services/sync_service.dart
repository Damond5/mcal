import "dart:io";
import "dart:developer";
import "package:shared_preferences/shared_preferences.dart";
import "package:path_provider/path_provider.dart";

class SyncService {
  static const String _remoteUrlKey = "git_remote_url";

  Future<String> _getAppDocDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final calendarDir = Directory('${dir.path}/calendar');
    await calendarDir.create(recursive: true);
    return calendarDir.path;
  }

  Future<String?> _getRemoteUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_remoteUrlKey);
  }

  Future<void> _setRemoteUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_remoteUrlKey, url);
  }

  Future<void> _runGitCommand(String executable, List<String> args, {String? errorMessage}) async {
    final workingDirectory = await _getAppDocDir();
    try {
      final result = await Process.run(executable, args, workingDirectory: workingDirectory);
      if (result.exitCode != 0) {
        log('Git command failed: $executable ${args.join(' ')}, stderr: ${result.stderr}');
        throw Exception(errorMessage ?? "Git command failed: ${result.stderr}");
      }
    } catch (e) {
      log('Failed to run git command: $executable ${args.join(' ')}, error: $e');
      throw Exception(errorMessage ?? "Failed to run git command: $e");
    }
  }

  bool _isValidUrl(String url) {
    if (url.startsWith("http") || url.startsWith("git@")) {
      // For HTTP, validate as URI
      if (url.startsWith("http")) {
        return Uri.tryParse(url) != null;
      }
      // For SSH, basic check
      return url.contains("@") && url.contains(":");
    }
    return false;
  }

  Future<void> _checkGitAvailability() async {
    try {
      await _runGitCommand("git", ["--version"], errorMessage: "Git is not installed or not available in PATH");
    } catch (e) {
      throw Exception("Git is not available: $e");
    }
  }

  Future<void> initSync(String url) async {
    url = url.trim().replaceAll('"', '').replaceAll("'", '');
    if (!_isValidUrl(url)) {
      throw Exception("Invalid URL format. Use HTTPS or SSH URL.");
    }
    await _checkGitAvailability();
    try {
      await _runGitCommand("git", ["init"], errorMessage: "Failed to initialize git repository");
      // Remove existing remote if any
      final workingDirectory = await _getAppDocDir();
      try {
        await Process.run("git", ["remote", "remove", "origin"], workingDirectory: workingDirectory);
      } catch (_) {
        // Ignore if not exists
      }
      await _runGitCommand("git", ["remote", "add", "origin", url], errorMessage: "Failed to add remote origin");
      // Try to fetch and checkout the default branch
      try {
        await _runGitCommand("git", ["fetch", "origin"], errorMessage: "Failed to fetch from remote");
         try {
           await _runGitCommand("git", ["checkout", "-b", "main", "origin/main"], errorMessage: "Failed to checkout main branch");
         } catch (e) {
           try {
             await _runGitCommand("git", ["checkout", "-b", "master", "origin/master"], errorMessage: "Failed to checkout master branch");
           } catch (e) {
             // Try other common branches
             try {
               await _runGitCommand("git", ["checkout", "-b", "develop", "origin/develop"], errorMessage: "Failed to checkout develop branch");
             } catch (e) {
               await _runGitCommand("git", ["checkout", "-b", "trunk", "origin/trunk"], errorMessage: "Failed to checkout trunk branch");
             }
           }
         }
      } catch (e) {
        // Ignore if remote is empty or not accessible
      }
       await _setRemoteUrl(url);
     } catch (e) {
       log('Sync initialization failed: $e');
       throw Exception("Sync initialization failed: $e");
     }
  }

  Future<void> pullSync() async {
    final url = await _getRemoteUrl();
    if (url == null) {
      throw Exception("No remote URL configured. Please initialize sync first.");
    }
    await _checkGitAvailability();
     try {
       await _runGitCommand("git", ["pull", "--rebase", "origin"], errorMessage: "Failed to pull from remote");
     } catch (e) {
       log('Pull sync failed: $e');
       throw Exception("Pull sync failed: $e");
     }
  }

  Future<void> pushSync() async {
    final url = await _getRemoteUrl();
    if (url == null) {
      throw Exception("No remote URL configured. Please initialize sync first.");
    }
    await _checkGitAvailability();
    try {
      // Check for changes before committing
      final workingDirectory = await _getAppDocDir();
      final statusResult = await Process.run("git", ["status", "--porcelain"], workingDirectory: workingDirectory);
      if (statusResult.exitCode != 0) {
        throw Exception("Failed to check git status");
      }
      final statusOutput = statusResult.stdout.toString().trim();
      if (statusOutput.isEmpty) {
        throw Exception("No changes to push");
      }
      await _runGitCommand("git", ["add", "."], errorMessage: "Failed to add files");
      await _runGitCommand("git", ["-c", "user.name=MCal App", "-c", "user.email=mcal@app.local", "commit", "-m", "Sync events"], errorMessage: "Failed to commit changes");
       await _runGitCommand("git", ["push", "origin"], errorMessage: "Failed to push to remote");
     } catch (e) {
       log('Push sync failed: $e');
       throw Exception("Push sync failed: $e");
     }
  }

  Future<String> getSyncStatus() async {
    await _checkGitAvailability();
    final workingDirectory = await _getAppDocDir();
    final result = await Process.run("git", ["status", "--porcelain"], workingDirectory: workingDirectory);
    if (result.exitCode != 0) {
      // Check if it's because no git repo
      final initCheck = await Process.run("git", ["status"], workingDirectory: workingDirectory);
      if (initCheck.stderr.toString().contains("not a git repository")) {
        return "not initialized";
      }
      log('Failed to get git status: ${result.stderr}');
      throw Exception("Failed to get git status: ${result.stderr}");
    }
    final output = result.stdout.toString().trim();
    return output.isEmpty ? "clean" : "modified";
  }
}