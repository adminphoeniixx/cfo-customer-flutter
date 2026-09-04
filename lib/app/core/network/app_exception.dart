/// A typed exception every repository throws instead of raw Dio errors,
/// so controllers/UI only ever deal with one shape of failure.
class AppException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, List<String>>? fieldErrors; // 422 `errors` object
  final AppExceptionType type;

  AppException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
    required this.type,
  });

  factory AppException.fromStatus(int? status, String message, {Map<String, List<String>>? errors}) {
    switch (status) {
      case 401:
        return AppException(statusCode: status, message: message, type: AppExceptionType.unauthorized);
      case 403:
        return AppException(statusCode: status, message: message, type: AppExceptionType.forbidden);
      case 404:
        return AppException(statusCode: status, message: message, type: AppExceptionType.notFound);
      case 422:
        return AppException(
            statusCode: status, message: message, fieldErrors: errors, type: AppExceptionType.validation);
      case 429:
        return AppException(statusCode: status, message: message, type: AppExceptionType.rateLimited);
      default:
        return AppException(statusCode: status, message: message, type: AppExceptionType.unknown);
    }
  }

  /// First error message for a field, if any — handy for inline form errors.
  String? fieldError(String field) => fieldErrors?[field]?.first;

  @override
  String toString() => message;
}

enum AppExceptionType { unauthorized, forbidden, notFound, validation, rateLimited, network, unknown }
