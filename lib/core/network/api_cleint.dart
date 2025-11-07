import 'package:dio/dio.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options.connectTimeout = const Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 10000);
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
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        message: 'Connection timed out. Check your internet.',
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return NetworkException(
        message: 'Connection error. Check your internet.',
      );
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?['message'] ?? 'Server returned an error';

      if (statusCode == 404) {
        return NotFoundException(message: message, statusCode: statusCode);
      }
      if (statusCode == 400) {
        return BadRequestException(message: message, statusCode: statusCode);
      }
      if (statusCode == 401 || statusCode == 403) {
        return UnauthorizedException(message: message, statusCode: statusCode);
      }
      if (statusCode != null && statusCode >= 500) {
        return ServerException(message: message, statusCode: statusCode);
      }
    }

    return UnknownException(message: e.message ?? 'An unknown error occurred');
  }
}
