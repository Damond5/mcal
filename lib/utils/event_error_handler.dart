import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/event.dart';

/// Abstract base class for all event-related errors.
///
/// This provides a consistent interface for all event operation errors,
/// including error messages, causes, and recovery suggestions.
abstract class EventError implements Exception {
  final String message;
  final dynamic cause;
  final String? recoverySuggestion;
  final Event? relatedEvent;

  const EventError(
    this.message, {
    this.cause,
    this.recoverySuggestion,
    this.relatedEvent,
  });

  @override
  String toString() =>
      'EventError: $message${cause != null ? ' (Cause: $cause)' : ''}';

  /// Returns the error category for classification
  ErrorCategory get category;

  /// Returns whether this error is transient and may succeed on retry
  bool get isTransient;
}

/// Error categories for classifying event errors
enum ErrorCategory {
  validation,
  storage,
  sync,
  notification,
  parsing,
  network,
  permission,
  unknown,
}

/// Error for event validation failures
class EventValidationError extends EventError {
  final String? fieldName;
  final dynamic invalidValue;

  const EventValidationError(
    String message, {
    this.fieldName,
    this.invalidValue,
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ??
             'Please check the event details and try again.',
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.validation;

  @override
  bool get isTransient => false;
}

/// Error for event storage failures
class EventStorageError extends EventError {
  const EventStorageError(
    String message, {
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ??
             'Please check storage permissions and try again.',
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.storage;

  @override
  bool get isTransient => true;
}

/// Error for sync-related failures
class EventSyncError extends EventError {
  final bool isConflict;

  const EventSyncError(
    String message, {
    this.isConflict = false,
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ??
             (isConflict
                 ? 'Resolve the conflict and try again.'
                 : 'Check your network connection and try again.'),
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.sync;

  @override
  bool get isTransient => !isConflict;
}

/// Error for notification-related failures
class EventNotificationError extends EventError {
  const EventNotificationError(
    String message, {
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ??
             'Check notification permissions and try again.',
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.notification;

  @override
  bool get isTransient => true;
}

/// Error for event parsing failures
class EventParseError extends EventError {
  final String? rawContent;

  const EventParseError(
    String message, {
    this.rawContent,
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ?? 'Check the event format and try again.',
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.parsing;

  @override
  bool get isTransient => false;
}

/// Error for network-related failures
class EventNetworkError extends EventError {
  const EventNetworkError(
    String message, {
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ??
             'Check your network connection and try again.',
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.network;

  @override
  bool get isTransient => true;
}

/// Error for permission-related failures
class EventPermissionError extends EventError {
  const EventPermissionError(
    String message, {
    dynamic cause,
    String? recoverySuggestion,
    Event? relatedEvent,
  }) : super(
         message,
         cause: cause,
         recoverySuggestion:
             recoverySuggestion ?? 'Check app permissions and try again.',
         relatedEvent: relatedEvent,
       );

  @override
  ErrorCategory get category => ErrorCategory.permission;

  @override
  bool get isTransient => false;
}

/// Extension methods for error handling
extension EventErrorExtensions on EventError {
  /// Returns a user-friendly error message
  String get userFriendlyMessage {
    return '$message${recoverySuggestion != null ? '\n\nSuggestion: $recoverySuggestion' : ''}';
  }

  /// Returns the error as a map for logging
  Map<String, dynamic> toLogMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'cause': cause?.toString(),
      'category': category.toString(),
      'is_transient': isTransient,
      'recovery_suggestion': recoverySuggestion,
      'event_title': relatedEvent?.title,
      'event_filename': relatedEvent?.filename,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Result type for operations that can fail
sealed class EventOperationResult<T> {
  const factory EventOperationResult.success(T value) =
      _EventOperationSuccess<T>;
  const factory EventOperationResult.failure(EventError error) =
      _EventOperationFailure<T>;
}

/// Success result for event operations
class _EventOperationSuccess<T> implements EventOperationResult<T> {
  final T value;

  const _EventOperationSuccess(this.value);

  /// Returns true if this is a success
  bool get isSuccess => true;

  /// Returns false (not a failure)
  bool get isFailure => false;
}

/// Failure result for event operations
class _EventOperationFailure<T> implements EventOperationResult<T> {
  final EventError error;

  const _EventOperationFailure(this.error);

  /// Returns false (not a success)
  bool get isSuccess => false;

  /// Returns true if this is a failure
  bool get isFailure => true;
}

/// Success result for event operations
class EventOperationSuccess<T> implements EventOperationResult<T> {
  final T value;

  const EventOperationSuccess(this.value);

  /// Returns true if this is a success
  bool get isSuccess => true;

  /// Returns false (not a failure)
  bool get isFailure => false;
}

/// Failure result for event operations
class EventOperationFailure<T> implements EventOperationResult<T> {
  final EventError error;

  const EventOperationFailure(this.error);

  /// Returns false (not a success)
  bool get isSuccess => false;

  /// Returns true if this is a failure
  bool get isFailure => true;
}

/// Retry configuration for transient errors
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool Function(dynamic error)? shouldRetry;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 100),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
    this.shouldRetry,
  });
}

/// Default retry configuration
const RetryConfig defaultRetryConfig = RetryConfig();

/// Executes an operation with retry logic for transient errors.
///
/// This function attempts the operation multiple times with exponential backoff
/// if transient errors occur.
///
/// Parameters:
/// - [operation]: The async operation to execute
/// - [config]: Retry configuration (optional, defaults to [defaultRetryConfig])
/// - [operationName]: Name of the operation for logging
///
/// Returns:
/// The result of the operation if successful
///
/// Throws:
/// The last error if all retries are exhausted
Future<T> retryOnFailure<T>(
  Future<T> Function() operation, {
  RetryConfig config = defaultRetryConfig,
  String operationName = 'operation',
}) async {
  dynamic lastError;

  for (int attempt = 0; attempt < config.maxRetries; attempt++) {
    try {
      return await operation();
    } catch (e) {
      lastError = e;

      // Check if we should retry this error
      if (config.shouldRetry != null && !config.shouldRetry!(e)) {
        rethrow;
      }

      // Check if this is a transient error
      final isTransient = e is EventError && e.isTransient;
      if (!isTransient) {
        rethrow;
      }

      // Don't wait after the last attempt
      if (attempt == config.maxRetries - 1) {
        break;
      }

      // Calculate delay with exponential backoff
      final delay =
          config.initialDelay * pow(config.backoffMultiplier, attempt);
      final effectiveDelay = delay > config.maxDelay ? config.maxDelay : delay;

      // Wait before retrying
      await Future.delayed(effectiveDelay);
    }
  }

  // All retries exhausted, throw the last error
  throw lastError;
}

/// Error boundary widget for catching and displaying event errors.
///
/// Wraps a child widget and catches event-related errors, displaying
/// a user-friendly error message with recovery options.
class EventErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(EventError) onError;
  final Widget Function(BuildContext, dynamic)? errorBuilder;

  const EventErrorBoundary({
    super.key,
    required this.child,
    required this.onError,
    this.errorBuilder,
  });

  @override
  State<EventErrorBoundary> createState() => _EventErrorBoundaryState();
}

class _EventErrorBoundaryState extends State<EventErrorBoundary> {
  dynamic _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset error state when dependencies change
    _error = null;
  }

  @override
  void didUpdateWidget(EventErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error state when widget updates
    _error = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error);
      }

      return _defaultErrorWidget(_error);
    }

    return widget.child;
  }

  Widget _defaultErrorWidget(dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts various error types to EventError for consistent handling
EventError toEventError(dynamic error, {Event? relatedEvent}) {
  if (error is EventError) {
    return error;
  }

  if (error is ArgumentError) {
    return EventValidationError(
      error.message ?? 'Invalid argument',
      cause: error,
      relatedEvent: relatedEvent,
    );
  }

  if (error is FormatException) {
    return EventParseError(
      error.message,
      cause: error,
      relatedEvent: relatedEvent,
    );
  }

  if (error is TimeoutException) {
    return EventNetworkError(
      'Request timed out',
      cause: error,
      relatedEvent: relatedEvent,
    );
  }

  if (error is FileSystemException || error.toString().contains('file')) {
    return EventStorageError(
      'Storage operation failed',
      cause: error,
      relatedEvent: relatedEvent,
    );
  }

  // Default to unknown error
  return EventStorageError(
    error?.toString() ?? 'Unknown error occurred',
    cause: error,
    relatedEvent: relatedEvent,
  );
}
