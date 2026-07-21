import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/learning_repository_config.dart';

void main() {
  test('debug configuration defaults to local mock mode', () {
    final config = resolveLearningRuntimeConfig(isReleaseMode: false);
    expect(config.source, 'mock');
    expect(config.apiBaseUrl, 'http://10.0.2.2:3000');
  });

  test('release configuration never silently defaults to mock mode', () {
    expect(
      () => resolveLearningRuntimeConfig(isReleaseMode: true),
      throwsStateError,
    );
  });

  test('release API mode requires an explicit base URL', () {
    expect(
      () => resolveLearningRuntimeConfig(source: 'api', isReleaseMode: true),
      throwsStateError,
    );
  });

  test('release API mode accepts an explicit non-secret base URL', () {
    final config = resolveLearningRuntimeConfig(
      source: 'api',
      apiBaseUrl: 'https://api.example.test',
      isReleaseMode: true,
    );
    expect(config.source, 'api');
    expect(config.apiBaseUrl, 'https://api.example.test');
  });
}
