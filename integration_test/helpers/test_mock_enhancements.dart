import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/frb_generated.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef MethodChannelHandler = Future<dynamic> Function(MethodCall methodCall);

/// Enhanced FFI/Rust mock with complete functionality.
///
/// This class provides comprehensive mocking for all Rust FFI calls:
/// - Proper return values (not null)
/// - Simulated delays for realistic timing
/// - Error simulation for testing error handling
/// - Call tracking for verification
class EnhancedFFIMock {
  final Map<String, dynamic> _callHistory = {};
  final Map<String, Exception> _errorSimulation = {};
  final Map<String, Duration> _delaySimulation = {};
  bool _isInitialized = false;

  /// Initializes the enhanced FFI mock
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    _setupDefaultDelays();
    debugPrint('EnhancedFFIMock: Initialized');
  }

  /// Sets up default simulated delays for realistic behavior
  void _setupDefaultDelays() {
    _delaySimulation.addAll({
      'gitInit': const Duration(milliseconds: 50),
      'gitAdd': const Duration(milliseconds: 20),
      'gitCommit': const Duration(milliseconds: 100),
      'gitPull': const Duration(milliseconds: 200),
      'gitPush': const Duration(milliseconds: 150),
      'gitStatus': const Duration(milliseconds: 10),
      'gitFetch': const Duration(milliseconds: 100),
      'gitCheckout': const Duration(milliseconds: 50),
    });
  }

  /// Sets simulated delay for a specific operation
  void setDelay(String operation, Duration delay) {
    _delaySimulation[operation] = delay;
  }

  /// Enables error simulation for a specific operation
  void simulateError(String operation, Exception error) {
    _errorSimulation[operation] = error;
  }

  /// Disables error simulation for a specific operation
  void clearError(String operation) {
    _errorSimulation.remove(operation);
  }

  /// Gets the call history for a specific operation
  List<Map<String, dynamic>> getCallHistory(String operation) {
    return _callHistory[operation] as List<Map<String, dynamic>>? ?? [];
  }

  /// Gets the total number of calls for a specific operation
  int getCallCount(String operation) {
    return getCallHistory(operation).length;
  }

  /// Clears all call history
  void clearCallHistory() {
    _callHistory.clear();
    debugPrint('EnhancedFFIMock: Call history cleared');
  }

  /// Records a method call for tracking
  void _recordCall(String method, Map<String, dynamic> params) {
    if (!_callHistory.containsKey(method)) {
      _callHistory[method] = [];
    }
    (_callHistory[method] as List).add({
      'timestamp': DateTime.now().toIso8601String(),
      'params': params,
    });
  }

  /// Creates the method channel handler for the FFI mock
  MethodChannelHandler createHandler() {
    return (MethodCall methodCall) async {
      final method = methodCall.method;
      final params = Map<String, dynamic>.from(methodCall.arguments ?? {});

      _recordCall(method, params);

      // Check for simulated errors
      if (_errorSimulation.containsKey(method)) {
        throw _errorSimulation[method]!;
      }

      // Apply simulated delay
      final delay = _delaySimulation[method];
      if (delay != null) {
        await Future.delayed(delay);
      }

      // Route to appropriate handler
      return _handleMethodCall(method, params);
    };
  }

  /// Handles method calls and returns appropriate responses
  Future<dynamic> _handleMethodCall(
    String method,
    Map<String, dynamic> params,
  ) async {
    switch (method) {
      // Git operations
      case 'gitInit':
      case 'crateApiGitInit':
        return 'Initialized empty Git repository';

      case 'gitAdd':
      case 'crateApiGitAddAll':
        return 'Staged files';

      case 'gitAddRemote':
      case 'crateApiGitAddRemote':
        return 'Remote added';

      case 'gitCommit':
      case 'crateApiGitCommit':
        return 'Committed changes';

      case 'gitPull':
      case 'crateApiGitPull':
        return 'Pulled 0 changes';

      case 'gitPush':
      case 'crateApiGitPush':
        return 'Pushed 1 commit';

      case 'gitStatus':
      case 'crateApiGitStatus':
        return 'Clean working directory';

      case 'gitFetch':
      case 'crateApiGitFetch':
        return 'Fetch completed';

      case 'gitCheckout':
      case 'crateApiGitCheckout':
        return 'Checkout completed';

      case 'getCredentials':
        return null;

      case 'setCredentials':
        return true;

      case 'clearCredentials':
        return true;

      case 'crateApiAdd':
        return params['left'] + params['right'];

      default:
        debugPrint('EnhancedFFIMock: Unknown method $method');
        return null;
    }
  }

  /// Resets the mock to initial state
  void reset() {
    _callHistory.clear();
    _errorSimulation.clear();
    _delaySimulation.clear();
    _setupDefaultDelays();
    debugPrint('EnhancedFFIMock: Reset to initial state');
  }
}

/// Enhanced notification mock with complete functionality.
///
/// This class provides comprehensive mocking for notifications:
/// - Proper success return values
/// - Simulated notification display
/// - Permission handling simulation
/// - Scheduling confirmation
/// - Call tracking
class EnhancedNotificationMock {
  final List<Map<String, dynamic>> _scheduledNotifications = [];
  final List<Map<String, dynamic>> _displayedNotifications = [];
  bool _permissionsGranted = true;
  int _nextNotificationId = 0;

  /// Creates the method channel handler for the notification mock
  MethodChannelHandler createHandler() {
    return (MethodCall methodCall) async {
      final method = methodCall.method;
      final params = Map<String, dynamic>.from(methodCall.arguments ?? {});

      debugPrint('EnhancedNotificationMock: $method');

      switch (method) {
        case 'initialize':
          return true;

        case 'requestNotificationsPermission':
          return _permissionsGranted;

        case 'requestPermission':
          return _permissionsGranted;

        case 'zonedSchedule':
        case 'schedule':
          final notification = {
            'id': _nextNotificationId++,
            'title': params['title'] ?? 'Notification',
            'body': params['body'] ?? '',
            'scheduledTime':
                params['scheduledTime'] ?? DateTime.now().toIso8601String(),
          };
          _scheduledNotifications.add(notification);
          debugPrint(
            'EnhancedNotificationMock: Scheduled notification ${notification['id']}',
          );
          return notification['id'];

        case 'cancel':
          final id = params['id'] ?? params['notificationId'];
          if (id != null) {
            _scheduledNotifications.removeWhere((n) => n['id'] == id);
            debugPrint('EnhancedNotificationMock: Cancelled notification $id');
          }
          return null;

        case 'cancelAll':
          _scheduledNotifications.clear();
          debugPrint('EnhancedNotificationMock: Cancelled all notifications');
          return null;

        case 'show':
          final notification = {
            'title': params['title'] ?? 'Notification',
            'body': params['body'] ?? '',
            'displayedAt': DateTime.now().toIso8601String(),
          };
          _displayedNotifications.add(notification);
          debugPrint('EnhancedNotificationMock: Displayed notification');
          return null;

        default:
          debugPrint('EnhancedNotificationMock: Unknown method $method');
          return null;
      }
    };
  }

  /// Sets whether permissions are granted
  void setPermissionsGranted(bool granted) {
    _permissionsGranted = granted;
    debugPrint('EnhancedNotificationMock: Permissions set to $granted');
  }

  /// Gets all scheduled notifications
  List<Map<String, dynamic>> getScheduledNotifications() {
    return List<Map<String, dynamic>>.from(_scheduledNotifications);
  }

  /// Gets all displayed notifications
  List<Map<String, dynamic>> getDisplayedNotifications() {
    return List<Map<String, dynamic>>.from(_displayedNotifications);
  }

  /// Clears all scheduled notifications
  void clearScheduledNotifications() {
    _scheduledNotifications.clear();
    debugPrint('EnhancedNotificationMock: Cleared scheduled notifications');
  }

  /// Clears all displayed notifications
  void clearDisplayedNotifications() {
    _displayedNotifications.clear();
    debugPrint('EnhancedNotificationMock: Cleared displayed notifications');
  }

  /// Resets the mock to initial state
  void reset() {
    _scheduledNotifications.clear();
    _displayedNotifications.clear();
    _permissionsGranted = true;
    _nextNotificationId = 0;
    debugPrint('EnhancedNotificationMock: Reset to initial state');
  }
}

/// Enhanced Git operation mock with complete functionality.
///
/// This class provides comprehensive mocking for Git operations:
/// - Complete git operation simulation
/// - Conflict detection simulation
/// - Network operation simulation
/// - Proper error handling
class EnhancedGitOperationMock {
  final Map<String, dynamic> _repositoryState = {
    'initialized': false,
    'remoteUrl': null,
    'branch': 'main',
    'commits': [],
    'stagedFiles': [],
    'localChanges': false,
  };

  final List<Map<String, dynamic>> _operationHistory = [];
  bool _simulateNetworkErrors = false;
  bool _simulateConflicts = false;
  Duration _simulatedDelay = const Duration(milliseconds: 100);

  /// Sets simulated network error mode
  void setSimulateNetworkErrors(bool simulate) {
    _simulateNetworkErrors = simulate;
  }

  /// Sets simulated conflict mode
  void setSimulateConflicts(bool simulate) {
    _simulateConflicts = simulate;
  }

  /// Sets simulated delay for operations
  void setSimulatedDelay(Duration delay) {
    _simulatedDelay = delay;
  }

  /// Records an operation for tracking
  void _recordOperation(
    String operation,
    Map<String, dynamic> params,
    bool success,
  ) {
    _operationHistory.add({
      'operation': operation,
      'params': params,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Gets operation history
  List<Map<String, dynamic>> getOperationHistory() {
    return List<Map<String, dynamic>>.from(_operationHistory);
  }

  /// Clears operation history
  void clearOperationHistory() {
    _operationHistory.clear();
  }

  /// Creates the method channel handler for the Git mock
  MethodChannelHandler createHandler() {
    return (MethodCall methodCall) async {
      final method = methodCall.method;
      final params = Map<String, dynamic>.from(methodCall.arguments ?? {});

      // Apply simulated delay
      await Future.delayed(_simulatedDelay);

      // Check for network errors
      if (_simulateNetworkErrors) {
        _recordOperation(method, params, false);
        throw Exception(
          'Network error: Unable to connect to remote repository',
        );
      }

      try {
        final result = await _handleGitOperation(method, params);
        _recordOperation(method, params, true);
        return result;
      } catch (e) {
        _recordOperation(method, params, false);
        rethrow;
      }
    };
  }

  /// Handles Git operations
  Future<dynamic> _handleGitOperation(
    String method,
    Map<String, dynamic> params,
  ) async {
    switch (method) {
      case 'gitInit':
      case 'crateApiGitInit':
        _repositoryState['initialized'] = true;
        _repositoryState['commits'] = [];
        return 'Initialized empty Git repository';

      case 'gitAdd':
      case 'crateApiGitAddAll':
        _repositoryState['stagedFiles'] = ['*.md', '*.ics'];
        return 'Staged files';

      case 'gitAddRemote':
      case 'crateApiGitAddRemote':
        _repositoryState['remoteUrl'] = params['url'];
        return 'Remote added';

      case 'gitCommit':
      case 'crateApiGitCommit':
        final message = params['message'] ?? 'Sync events';
        _repositoryState['commits'].add({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'hash': 'abc123def456',
        });
        _repositoryState['stagedFiles'].clear();
        return 'Committed changes';

      case 'gitPull':
      case 'crateApiGitPull':
        if (_simulateConflicts) {
          throw Exception(
            'Non-fast-forward merge required. Please resolve conflicts manually.',
          );
        }
        return 'Pulled 0 changes';

      case 'gitPush':
      case 'crateApiGitPush':
        return 'Pushed 1 commit';

      case 'gitStatus':
      case 'crateApiGitStatus':
        return _repositoryState['localChanges']
            ? 'M calendar/test_event.md'
            : '';

      case 'gitFetch':
      case 'crateApiGitFetch':
        return 'Fetch completed';

      case 'gitCheckout':
      case 'crateApiGitCheckout':
        _repositoryState['branch'] = params['branch'] ?? 'main';
        return 'Checkout completed';

      case 'gitMergeAbort':
      case 'crateApiGitMergeAbort':
        return 'Merge aborted';

      case 'gitMergePreferRemote':
      case 'crateApiGitMergePreferRemote':
        return 'Merge completed preferring remote changes';

      default:
        debugPrint('EnhancedGitOperationMock: Unknown method $method');
        return null;
    }
  }

  /// Sets repository state for testing
  void setRepositoryState(Map<String, dynamic> state) {
    _repositoryState.addAll(state);
  }

  /// Gets current repository state
  Map<String, dynamic> getRepositoryState() {
    return Map<String, dynamic>.from(_repositoryState);
  }

  /// Resets the mock to initial state
  void reset() {
    _repositoryState.clear();
    _repositoryState.addAll({
      'initialized': false,
      'remoteUrl': null,
      'branch': 'main',
      'commits': [],
      'stagedFiles': [],
      'localChanges': false,
    });
    _operationHistory.clear();
    _simulateNetworkErrors = false;
    _simulateConflicts = false;
    _simulatedDelay = const Duration(milliseconds: 100);
    debugPrint('EnhancedGitOperationMock: Reset to initial state');
  }
}

/// Utility class to set up all enhanced mocks at once
class EnhancedMockSetup {
  static final EnhancedFFIMock ffiMock = EnhancedFFIMock();
  static final EnhancedNotificationMock notificationMock =
      EnhancedNotificationMock();
  static final EnhancedGitOperationMock gitMock = EnhancedGitOperationMock();

  /// Sets up all enhanced mocks with default configuration
  static void setupAll() {
    ffiMock.initialize();
    ffiMock.reset();
    notificationMock.reset();
    gitMock.reset();

    _setupChannelHandlers();
    debugPrint('EnhancedMockSetup: All mocks configured');
  }

  /// Sets up method channel handlers
  static void _setupChannelHandlers() {
    // FFI/Rust channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('mcal_flutter/rust_lib'),
          ffiMock.createHandler(),
        );

    // Notification channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          notificationMock.createHandler(),
        );
  }

  /// Resets all mocks to initial state
  static void resetAll() {
    ffiMock.reset();
    notificationMock.reset();
    gitMock.reset();
    debugPrint('EnhancedMockSetup: All mocks reset');
  }

  /// Clears all call/operation history
  static void clearAllHistory() {
    ffiMock.clearCallHistory();
    notificationMock.clearDisplayedNotifications();
    notificationMock.clearScheduledNotifications();
    gitMock.clearOperationHistory();
    debugPrint('EnhancedMockSetup: All history cleared');
  }
}
