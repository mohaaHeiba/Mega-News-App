import 'package:dio/dio.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/retry_interceptor.dart';
import 'package:mega_news_app/core/utils/logger.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio, {bool enableRetry = true}) {
    _dio.options.connectTimeout = const Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    
    // Add retry interceptor for handling 429 errors
    if (enableRetry) {
      _dio.interceptors.add(RetryInterceptor(maxRetries: 3, dio: _dio));
    }
  }

  //================Get===============
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(message: 'An unexpected error occurred: $e');
    }
  }

  //================post===============

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(message: 'An unexpected error occurred: $e');
    }
  }

  ApiException _handleDioException(DioException e) {
    // Log the error for debugging
    AppLogger.apiError(
      'ApiClient',
      'Request failed: ${e.requestOptions.path}',
      e,
    );

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        message: 'Connection timed out. Check your internet connection.',
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return NetworkException(
        message: 'Connection error. Check your internet connection.',
      );
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      // Try to extract error message from response
      String message = 'Server returned an error';
      if (responseData is Map) {
        message = responseData['message'] ?? 
                  responseData['error'] ?? 
                  responseData['status'] ?? 
                  message;
      } else if (responseData is String) {
        message = responseData;
      }

      if (statusCode == 404) {
        return NotFoundException(message: message, statusCode: statusCode);
      }
      if (statusCode == 400) {
        return BadRequestException(message: message, statusCode: statusCode);
      }
      if (statusCode == 401) {
        return UnauthorizedException(
          message: message.isNotEmpty ? message : 'Unauthorized. Please check your credentials.',
          statusCode: statusCode,
        );
      }
      if (statusCode == 403) {
        return ForbiddenException(
          message: message.isNotEmpty ? message : 'Access forbidden. Please check your API key.',
          statusCode: statusCode,
        );
      }
      if (statusCode == 429) {
        // Extract Retry-After header if available
        Duration? retryAfter;
        final retryAfterHeader = e.response?.headers.value('retry-after');
        if (retryAfterHeader != null) {
          final seconds = int.tryParse(retryAfterHeader);
          if (seconds != null) {
            retryAfter = Duration(seconds: seconds);
          }
        }
        
        return RateLimitException(
          message: message.isNotEmpty ? message : 'Too many requests. Please try again later.',
          statusCode: statusCode,
          retryAfter: retryAfter,
        );
      }
      if (statusCode != null && statusCode >= 500) {
        return ServerException(message: message, statusCode: statusCode);
      }
    }

    return UnknownException(
      message: e.message ?? 'An unknown error occurred',
    );
  }
}
