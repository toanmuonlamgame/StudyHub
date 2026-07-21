typedef AccessTokenProvider = Future<String?> Function();

Future<Map<String, String>> authenticatedJsonHeaders(
  AccessTokenProvider? provider,
) async {
  if (provider == null) return const {'content-type': 'application/json'};
  final token = await provider();
  if (token == null || token.isEmpty) {
    throw const MissingAccessTokenException();
  }
  return {'content-type': 'application/json', 'authorization': 'Bearer $token'};
}

class MissingAccessTokenException implements Exception {
  const MissingAccessTokenException();
}
