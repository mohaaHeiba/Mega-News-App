abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => '$runtimeType: $message (Code: $statusCode)';
}

class ServerException extends ApiException {
  ServerException({required super.message, super.statusCode});
}

class NotFoundException extends ApiException {
  NotFoundException({required super.message, super.statusCode});
}

class BadRequestException extends ApiException {
  BadRequestException({required super.message, super.statusCode});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({required super.message, super.statusCode});
}

class NetworkException extends ApiException {
  NetworkException({required super.message});
}

class UnknownException extends ApiException {
  UnknownException({required super.message});
}
