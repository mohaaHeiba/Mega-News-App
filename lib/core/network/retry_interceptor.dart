import 'dart:math';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final Random _random = Random();
  final Dio? _dio;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    Dio? dio,
  }) : _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      super.onError(err, handler);
      return;
    }

    if (statusCode == 429 ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

      if (retryCount < maxRetries) {
        final delay = _calculateDelay(retryCount);

        // Check for Retry-After header (429 responses)
        Duration? retryAfter;
        if (statusCode == 429 &&
            err.response?.headers.value('retry-after') != null) {
          final retryAfterSeconds = int.tryParse(
            err.response!.headers.value('retry-after')!,
          );
          if (retryAfterSeconds != null) {
            retryAfter = Duration(seconds: retryAfterSeconds);
          }
        }

        // Use Retry-After if available, otherwise use exponential backoff
        final waitTime = retryAfter ?? delay;

        // Log retry attempt
        print(
          '🔄 Retrying request (attempt ${retryCount + 1}/$maxRetries) after ${waitTime.inSeconds}s...',
        );

        await Future.delayed(waitTime);

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Retry the request using the same Dio instance
        try {
          // Use the Dio instance from the interceptor or create a new one
          final dio = _dio ?? Dio();
          final response = await dio.fetch(err.requestOptions);
          print('✅ Retry successful');
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry also fails, continue with error handling
          if (e is DioException) {
            super.onError(e, handler);
          } else {
            super.onError(err, handler);
          }
          return;
        }
      } else {
        print('❌ Max retries ($maxRetries) reached. Giving up.');
      }
    }

    // Don't retry, pass error to next handler
    super.onError(err, handler);
  }

  /// Calculate exponential backoff delay with jitter
  Duration _calculateDelay(int retryCount) {
    final exponentialDelay = baseDelay * pow(2, retryCount).toInt();
    // Add jitter (random 0-25% of delay) to prevent thundering herd
    final jitter = Duration(
      milliseconds: _random.nextInt(exponentialDelay.inMilliseconds ~/ 4),
    );
    return exponentialDelay + jitter;
  }
}
