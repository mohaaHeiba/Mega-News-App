abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() {
    final code = statusCode != null ? ' (HTTP $statusCode)' : '';
    return '[$runtimeType] $message$code';
  }
}

class ServerException extends ApiException {
  ServerException({
    super.message = "Internal server error",
    super.statusCode = 500,
  });
}

class NotFoundException extends ApiException {
  NotFoundException({
    super.message = "Resource not found",
    super.statusCode = 404,
  });
}

class BadRequestException extends ApiException {
  BadRequestException({super.message = "Bad request", super.statusCode = 400});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.message = "Unauthorized access",
    super.statusCode = 401,
  });
}

class ForbiddenException extends ApiException {
  ForbiddenException({
    super.message = "Access forbidden. Please check your API key.",
    super.statusCode = 403,
  });
}

class RateLimitException extends ApiException {
  final Duration? retryAfter;
  
  RateLimitException({
    super.message = "Too many requests. Please try again later.",
    super.statusCode = 429,
    this.retryAfter,
  });
}

class NetworkException extends ApiException {
  NetworkException({super.message = "No internet connection"});
}

class UnknownException extends ApiException {
  UnknownException({super.message = "An unknown error occurred"});
}
