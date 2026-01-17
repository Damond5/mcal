import 'dart:developer';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/event.dart';

/// Structured logging utility for event operations with timing and trace ID support.
///
/// This class provides comprehensive logging for all event management operations,
/// including creation, modification, and deletion. It includes:
/// - Operation timing information
/// - Success/failure tracking with error details
/// - Trace IDs for tracking operations across components
/// - Debug-only logging to avoid production overhead
class EventOperationLogger {
  /// Singleton instance for global access
  static final EventOperationLogger _instance =
      EventOperationLogger._internal();

  factory EventOperationLogger() => _instance;

  EventOperationLogger._internal();

  /// Current trace ID for tracking operations across components
  String _currentTraceId = '';

  /// Start time for the current operation
  DateTime? _operationStartTime;

  /// Generates a new trace ID for tracking operations
  String generateTraceId() {
    _currentTraceId =
        '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    return _currentTraceId;
  }

  /// Sets the current trace ID for tracking operations across components
  void setTraceId(String traceId) {
    _currentTraceId = traceId;
  }

  /// Gets the current trace ID
  String get currentTraceId => _currentTraceId;

  /// Starts timing an operation
  void startOperation() {
    _operationStartTime = DateTime.now();
  }

  /// Logs event creation with comprehensive details
  ///
  /// Parameters:
  /// - [event]: The event that was created
  /// - [duration]: Optional duration of the operation
  /// - [error]: Optional error if the operation failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logEventCreation(
    Event event, {
    Duration? duration,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': 'event_creation',
      'trace_id': effectiveTraceId,
      'event_id': event.filename ?? 'unknown',
      'event_title': event.title,
      'event_date':
          '${event.startDate.year}-${event.startDate.month.toString().padLeft(2, '0')}-${event.startDate.day.toString().padLeft(2, '0')}',
      'event_time': event.startTime ?? 'all-day',
      'duration_ms':
          duration?.inMilliseconds ?? _calculateDuration()?.inMilliseconds,
      'success': error == null,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry('Event creation', logEntry);

    if (error != null) {
      _logError('Event creation failed', error, effectiveTraceId);
    }
  }

  /// Logs event modification with comprehensive details
  ///
  /// Parameters:
  /// - [oldEvent]: The original event before modification
  /// - [newEvent]: The updated event after modification
  /// - [duration]: Optional duration of the operation
  /// - [error]: Optional error if the operation failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logEventModification(
    Event oldEvent,
    Event newEvent, {
    Duration? duration,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': 'event_modification',
      'trace_id': effectiveTraceId,
      'event_id': oldEvent.filename ?? 'unknown',
      'old_event_title': oldEvent.title,
      'new_event_title': newEvent.title,
      'old_date':
          '${oldEvent.startDate.year}-${oldEvent.startDate.month.toString().padLeft(2, '0')}-${oldEvent.startDate.day.toString().padLeft(2, '0')}',
      'new_date':
          '${newEvent.startDate.year}-${newEvent.startDate.month.toString().padLeft(2, '0')}-${newEvent.startDate.day.toString().padLeft(2, '0')}',
      'duration_ms':
          duration?.inMilliseconds ?? _calculateDuration()?.inMilliseconds,
      'success': error == null,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry('Event modification', logEntry);

    if (error != null) {
      _logError('Event modification failed', error, effectiveTraceId);
    }
  }

  /// Logs event deletion with comprehensive details
  ///
  /// Parameters:
  /// - [event]: The event that was deleted
  /// - [duration]: Optional duration of the operation
  /// - [error]: Optional error if the operation failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logEventDeletion(
    Event event, {
    Duration? duration,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': 'event_deletion',
      'trace_id': effectiveTraceId,
      'event_id': event.filename ?? 'unknown',
      'event_title': event.title,
      'event_date':
          '${event.startDate.year}-${event.startDate.month.toString().padLeft(2, '0')}-${event.startDate.day.toString().padLeft(2, '0')}',
      'duration_ms':
          duration?.inMilliseconds ?? _calculateDuration()?.inMilliseconds,
      'success': error == null,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry('Event deletion', logEntry);

    if (error != null) {
      _logError('Event deletion failed', error, effectiveTraceId);
    }
  }

  /// Logs batch event operation with comprehensive details
  ///
  /// Parameters:
  /// - [operationType]: Type of batch operation ('batch_creation', 'batch_modification', 'batch_deletion')
  /// - [eventCount]: Number of events in the batch
  /// - [duration]: Duration of the entire batch operation
  /// - [error]: Optional error if the operation failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logBatchOperation(
    String operationType,
    int eventCount, {
    required Duration duration,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': operationType,
      'trace_id': effectiveTraceId,
      'event_count': eventCount,
      'duration_ms': duration.inMilliseconds,
      'success': error == null,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry('Batch event operation', logEntry);

    if (error != null) {
      _logError('Batch operation failed', error, effectiveTraceId);
    }
  }

  /// Logs sync operation with comprehensive details
  ///
  /// Parameters:
  /// - [operationType]: Type of sync operation ('sync_pull', 'sync_push', 'sync_init')
  /// - [success]: Whether the operation succeeded
  /// - [duration]: Duration of the sync operation
  /// - [eventsAffected]: Number of events affected by the sync
  /// - [error]: Optional error if the operation failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logSyncOperation(
    String operationType, {
    required bool success,
    required Duration duration,
    int eventsAffected = 0,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': operationType,
      'trace_id': effectiveTraceId,
      'success': success,
      'duration_ms': duration.inMilliseconds,
      'events_affected': eventsAffected,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry('Sync operation', logEntry);

    if (!success && error != null) {
      _logError('Sync operation failed', error, effectiveTraceId);
    }
  }

  /// Logs notification scheduling with comprehensive details
  ///
  /// Parameters:
  /// - [event]: The event for which notification is scheduled [success]: Whether the notification was scheduled
  /// - successfully
  /// - [error]: Optional error if scheduling failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logNotificationScheduling(
    Event event, {
    required bool success,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': 'notification_scheduling',
      'trace_id': effectiveTraceId,
      'event_id': event.filename ?? 'unknown',
      'event_title': event.title,
      'notification_time':
          '${event.startDate.year}-${event.startDate.month.toString().padLeft(2, '0')}-${event.startDate.day.toString().padLeft(2, '0')} ${event.startTime ?? 'all-day'}',
      'success': success,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry('Notification scheduling', logEntry);

    if (!success && error != null) {
      _logError('Notification scheduling failed', error, effectiveTraceId);
    }
  }

  /// Logs a custom operation with comprehensive details
  ///
  /// Parameters:
  /// - [operationName]: Name of the custom operation
  /// - [details]: Map of additional details to log
  /// - [success]: Whether the operation succeeded
  /// - [duration]: Optional duration of the operation
  /// - [error]: Optional error if the operation failed
  /// - [traceId]: Optional trace ID override (uses current if not provided)
  void logCustomOperation(
    String operationName, {
    required Map<String, dynamic> details,
    required bool success,
    Duration? duration,
    dynamic error,
    String? traceId,
  }) {
    final effectiveTraceId = traceId ?? _currentTraceId;
    final logEntry = {
      'operation': operationName,
      'trace_id': effectiveTraceId,
      ...details,
      'success': success,
      'duration_ms':
          duration?.inMilliseconds ?? _calculateDuration()?.inMilliseconds,
      'error': error?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEntry(operationName, logEntry);

    if (!success && error != null) {
      _logError('Custom operation failed', error, effectiveTraceId);
    }
  }

  /// Helper method to calculate duration from start time
  Duration? _calculateDuration() {
    if (_operationStartTime != null) {
      return DateTime.now().difference(_operationStartTime!);
    }
    return null;
  }

  /// Internal method to log structured entry
  void _logEntry(String operation, Map<String, dynamic> entry) {
    if (kDebugMode) {
      final jsonString = jsonEncode(entry);
      log('$operation: $jsonString', name: 'EVENT_OPS');
      debugPrint('EVENT_OPS | $operation | $jsonString');
    }
  }

  /// Internal method to log errors
  void _logError(String context, dynamic error, String traceId) {
    if (kDebugMode) {
      log('$context [Trace: $traceId]', name: 'EVENT_ERROR', error: error);
      debugPrint('EVENT_ERROR | $context | Trace: $traceId | Error: $error');
    }
  }

  /// Resets the operation timing
  void resetOperation() {
    _operationStartTime = null;
  }

  /// Clears the current trace ID
  void clearTraceId() {
    _currentTraceId = '';
  }
}
