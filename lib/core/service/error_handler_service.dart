import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/utils/logger.dart';
import 'package:mega_news_app/generated/l10n.dart';

/// Centralized error handling service for GetX controllers
/// Provides user-friendly error messages and logging
class ErrorHandlerService {
  /// Handle API errors and show appropriate SnackBar to user
  static void handleError(
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
  }) {
    // Log the error
    AppLogger.error(
      customMessage ?? 'An error occurred',
      error,
      error is Error ? error.stackTrace : null,
    );

    if (!showSnackBar) return;

    final s = S.current;
    String userMessage;
    String title = s.error;

    if (error is ApiException) {
      userMessage = _getUserFriendlyMessage(error, s);
      title = _getErrorTitle(error, s);
    } else {
      userMessage = customMessage ?? s.anErrorOccurred;
    }

    // Show SnackBar
    Get.snackbar(
      title,
      userMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onError,
    );
  }

  /// Get user-friendly message from ApiException
  static String _getUserFriendlyMessage(ApiException error, S s) {
    if (error is RateLimitException) {
      return 'Too many requests. Please try again later.';
    } else if (error is ForbiddenException) {
      return 'API key is invalid. Please check your configuration.';
    } else if (error is UnauthorizedException) {
      return 'Unauthorized access. Please check your credentials.';
    } else if (error is NetworkException) {
      return 'No internet connection. Please check your network.';
    } else if (error is ServerException) {
      return 'Server error. Please try again later.';
    } else if (error is NotFoundException) {
      return 'Resource not found.';
    } else if (error is BadRequestException) {
      return 'Invalid request. Please try again.';
    } else {
      return error.message;
    }
  }

  /// Get error title from ApiException
  static String _getErrorTitle(ApiException error, S s) {
    if (error is RateLimitException) {
      return 'Rate Limit Exceeded';
    } else if (error is ForbiddenException || error is UnauthorizedException) {
      return 'Authentication Error';
    } else if (error is NetworkException) {
      return 'Network Error';
    } else {
      return s.error;
    }
  }

  /// Handle errors silently (log only, no UI feedback)
  static void handleErrorSilently(dynamic error, [String? context]) {
    AppLogger.error(
      context ?? 'Silent error',
      error,
      error is Error ? error.stackTrace : null,
    );
  }
}

