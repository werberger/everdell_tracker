class EverdellApiException implements Exception {
  EverdellApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? body;

  @override
  String toString() => 'EverdellApiException($statusCode): $message';
}

class EverdellConflictException extends EverdellApiException {
  EverdellConflictException({
    required String message,
    required this.current,
  }) : super(message, statusCode: 409);

  final Map<String, dynamic>? current;
}
