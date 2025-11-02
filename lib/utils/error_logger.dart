import 'dart:developer';
import 'package:flutter/foundation.dart';

/// Utility for logging GUI errors to console for debugging purposes.
/// Only active in debug mode to avoid impacting production.
void logGuiError(
  String message, {
  dynamic error,
  StackTrace? stackTrace,
  String? context,
}) {
  if (kDebugMode) {
    final logMessage =
        'GUI Error: $message${context != null ? ' (Context: $context)' : ''}';
    log(logMessage, name: 'UI_ERROR', error: error, stackTrace: stackTrace);
    debugPrint(logMessage);
    if (error != null) {
      debugPrint('Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
