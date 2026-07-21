import 'package:flutter/foundation.dart';

import '../features/learning/repositories/api_learning_repository.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/repositories/mock_learning_repository.dart';
import '../features/contribution/repositories/api_contribution_repository.dart';
import '../features/contribution/repositories/contribution_repository.dart';
import '../features/contribution/repositories/mock_contribution_repository.dart';
import '../features/attempts/repositories/api_attempt_repository.dart';
import '../features/attempts/repositories/attempt_repository.dart';
import '../features/attempts/repositories/mock_attempt_repository.dart';
import '../features/auth/auth_session_store.dart';
import '../features/auth/repositories/api_auth_repository.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/repositories/mock_auth_repository.dart';
import '../features/saved/repositories/api_bookmark_repository.dart';
import '../features/saved/repositories/bookmark_repository.dart';
import '../features/saved/repositories/mock_bookmark_repository.dart';
import '../features/media/repositories/api_media_repository.dart';
import '../features/media/repositories/media_repository.dart';
import '../features/media/repositories/mock_media_repository.dart';

const _learningSource = String.fromEnvironment(
  'STUDYHUB_LEARNING_SOURCE',
  defaultValue: '',
);
const _apiBaseUrl = String.fromEnvironment(
  'STUDYHUB_API_BASE_URL',
  defaultValue: '',
);

const _androidEmulatorApiBaseUrl = 'http://10.0.2.2:3000';

({String source, String apiBaseUrl}) resolveLearningRuntimeConfig({
  String source = _learningSource,
  String apiBaseUrl = _apiBaseUrl,
  bool isReleaseMode = kReleaseMode,
}) {
  final normalizedSource = source.trim().toLowerCase();
  final resolvedSource = normalizedSource.isEmpty
      ? (isReleaseMode
            ? throw StateError(
                'Release builds require STUDYHUB_LEARNING_SOURCE=api.',
              )
            : 'mock')
      : normalizedSource;
  if (resolvedSource != 'mock' && resolvedSource != 'api') {
    throw StateError('Unsupported STUDYHUB_LEARNING_SOURCE: $source');
  }
  if (isReleaseMode && resolvedSource != 'api') {
    throw StateError('Release builds require STUDYHUB_LEARNING_SOURCE=api.');
  }

  final normalizedBaseUrl = apiBaseUrl.trim();
  if (resolvedSource == 'api' && normalizedBaseUrl.isEmpty && isReleaseMode) {
    throw StateError('API release builds require STUDYHUB_API_BASE_URL.');
  }
  if (isReleaseMode) {
    final uri = Uri.tryParse(normalizedBaseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      throw StateError(
        'Release STUDYHUB_API_BASE_URL must be an HTTPS origin without credentials, query, or fragment.',
      );
    }
  }
  return (
    source: resolvedSource,
    apiBaseUrl: normalizedBaseUrl.isEmpty
        ? _androidEmulatorApiBaseUrl
        : normalizedBaseUrl,
  );
}

LearningRepository createLearningRepositoryFromEnvironment() {
  final config = resolveLearningRuntimeConfig();
  switch (config.source) {
    case 'mock':
      return const MockLearningRepository();
    case 'api':
      return ApiLearningRepository(baseUrl: config.apiBaseUrl);
    default:
      throw StateError(
        'Unsupported STUDYHUB_LEARNING_SOURCE: ${config.source}',
      );
  }
}

ContributionRepository createContributionRepositoryFromEnvironment() {
  final config = resolveLearningRuntimeConfig();
  const sessionStore = AuthSessionStore();
  switch (config.source) {
    case 'mock':
      return MockContributionRepository();
    case 'api':
      return ApiContributionRepository(
        baseUrl: config.apiBaseUrl,
        accessTokenProvider: sessionStore.loadAccessToken,
      );
    default:
      throw StateError(
        'Unsupported STUDYHUB_LEARNING_SOURCE: ${config.source}',
      );
  }
}

AttemptRepository createAttemptRepositoryFromEnvironment() {
  final config = resolveLearningRuntimeConfig();
  const sessionStore = AuthSessionStore();
  switch (config.source) {
    case 'mock':
      return MockAttemptRepository();
    case 'api':
      return ApiAttemptRepository(
        baseUrl: config.apiBaseUrl,
        accessTokenProvider: sessionStore.loadAccessToken,
      );
    default:
      throw StateError(
        'Unsupported STUDYHUB_LEARNING_SOURCE: ${config.source}',
      );
  }
}

AuthRepository createAuthRepositoryFromEnvironment() {
  final config = resolveLearningRuntimeConfig();
  return config.source == 'api'
      ? ApiAuthRepository(baseUrl: config.apiBaseUrl)
      : MockAuthRepository();
}

BookmarkRepository createBookmarkRepositoryFromEnvironment() {
  final config = resolveLearningRuntimeConfig();
  const sessionStore = AuthSessionStore();
  return config.source == 'api'
      ? ApiBookmarkRepository(
          baseUrl: config.apiBaseUrl,
          accessTokenProvider: sessionStore.loadAccessToken,
        )
      : MockBookmarkRepository();
}

MediaRepository createMediaRepositoryFromEnvironment() {
  final config = resolveLearningRuntimeConfig();
  const sessionStore = AuthSessionStore();
  return config.source == 'api'
      ? ApiMediaRepository(
          baseUrl: config.apiBaseUrl,
          accessTokenProvider: sessionStore.loadAccessToken,
        )
      : MockMediaRepository();
}
