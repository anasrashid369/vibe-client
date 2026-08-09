import '../errors/app_exception.dart';

/// All BFF responses are parsed through this wrapper — the UI never
/// touches raw HTTP status codes or raw JSON directly.
sealed class Result<T> {
  const Result();

  factory Result.ok(T data) = Ok<T>;
  factory Result.err(AppException error) = Err<T>;

  R when<R>({
    required R Function(T data) ok,
    required R Function(AppException error) err,
  }) {
    final self = this;
    if (self is Ok<T>) return ok(self.data);
    if (self is Err<T>) return err(self.error);
    throw StateError('Unreachable');
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppException error;
}
