import 'package:dio/dio.dart';

import '../config/env_config.dart';

/// Wraps Dio with request-ID tagging, short explicit timeouts (this is a
/// mobile app, not a batch job), and single-retry-with-backoff for
/// idempotent GETs. All calls go to the BFF — never directly to TMDB or
/// an LLM provider.
class DioClient {
  DioClient(EnvConfig config)
      : dio = Dio(
          BaseOptions(
            baseUrl: config.bffBaseUrl,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.add(_RequestIdInterceptor());
    // TODO: add retry-with-backoff interceptor for idempotent GETs.
    // TODO: add response validation -> AppException mapping interceptor.
  }

  final Dio dio;
}

class _RequestIdInterceptor extends Interceptor {
  int _counter = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-Id'] =
        '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';
    handler.next(options);
  }
}
