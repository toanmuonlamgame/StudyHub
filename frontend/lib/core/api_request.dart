const defaultApiRequestTimeout = Duration(seconds: 15);

Future<T> withApiTimeout<T>(Future<T> request, Duration timeout) {
  return request.timeout(timeout);
}
