/// Explicit exception hierarchy so the UI can map each case to a specific,
/// actionable message instead of a generic "Something went wrong."
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No network connection.']);
}

final class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request timed out.']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
}

final class ValidationException extends AppException {
  const ValidationException([super.message = 'Invalid data received.']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'The server returned an error.']);
}

final class ParsingException extends AppException {
  const ParsingException([super.message = 'Could not parse the response.']);
}
