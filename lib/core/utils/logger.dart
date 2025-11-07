import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app
class AppLogger {
  static const String _tag = 'MegaNewsApp';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🐛 [$_tag] $message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [$_tag] $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      print('⚠️ [$_tag] $message');
      if (error != null) {
        print('   Error: $error');
      }
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [$_tag] $message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }
  }

  /// Log API-specific errors
  static void apiError(String apiName, String message, [Object? error]) {
    AppLogger.error('[$apiName API] $message', error);
  }
}

