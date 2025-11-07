import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/utils/logger.dart';

/// Service to validate API keys before making requests
class ApiKeyValidator {
  /// Validates that an API key exists and is not empty
  /// Throws ForbiddenException if key is missing or invalid
  static String validateApiKey(String keyName, {String? customMessage}) {
    try {
      final apiKey = dotenv.env[keyName];
      
      if (apiKey == null || apiKey.isEmpty || apiKey.trim().isEmpty) {
        final message = customMessage ?? 
            'API key "$keyName" is missing or invalid. Please check your .env file.';
        AppLogger.error('API Key Validation Failed', message);
        throw ForbiddenException(
          message: message,
          statusCode: 403,
        );
      }
      
      // Basic format validation (most API keys are alphanumeric and at least 10 chars)
      if (apiKey.trim().length < 10) {
        AppLogger.warning('API key "$keyName" seems too short. It may be invalid.');
      }
      
      return apiKey.trim();
    } catch (e) {
      if (e is ForbiddenException) {
        rethrow;
      }
      // If dotenv is not loaded, throw a helpful error
      AppLogger.error('API Key Validation Error', e);
      throw ForbiddenException(
        message: 'Failed to validate API key "$keyName". Please ensure .env file is loaded.',
        statusCode: 403,
      );
    }
  }

  /// Validates multiple API keys at once
  /// Returns a map of validated keys
  /// Throws the first ForbiddenException encountered
  static Map<String, String> validateApiKeys(List<String> keyNames) {
    final validatedKeys = <String, String>{};
    
    for (final keyName in keyNames) {
      validatedKeys[keyName] = validateApiKey(keyName);
    }
    
    return validatedKeys;
  }

  /// Checks if an API key exists (without throwing)
  /// Returns false if key is missing, empty, or dotenv is not loaded
  static bool hasApiKey(String keyName) {
    try {
      final apiKey = dotenv.env[keyName];
      return apiKey != null && apiKey.isNotEmpty && apiKey.trim().isNotEmpty;
    } catch (e) {
      AppLogger.warning('Could not check API key "$keyName": $e');
      return false;
    }
  }

  /// Validates API key format (basic check)
  /// Returns true if key seems valid, false otherwise
  static bool isValidFormat(String apiKey) {
    if (apiKey.isEmpty || apiKey.trim().isEmpty) return false;
    if (apiKey.length < 10) return false;
    // Most API keys contain alphanumeric characters
    return apiKey.trim().isNotEmpty;
  }
}

