import '../features/learning/repositories/api_learning_repository.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/repositories/mock_learning_repository.dart';
import '../features/contribution/repositories/api_contribution_repository.dart';
import '../features/contribution/repositories/contribution_repository.dart';
import '../features/contribution/repositories/mock_contribution_repository.dart';
import '../features/attempts/repositories/api_attempt_repository.dart';
import '../features/attempts/repositories/attempt_repository.dart';
import '../features/attempts/repositories/mock_attempt_repository.dart';

const _learningSource = String.fromEnvironment(
  'STUDYHUB_LEARNING_SOURCE',
  defaultValue: 'mock',
);
const _apiBaseUrl = String.fromEnvironment(
  'STUDYHUB_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

LearningRepository createLearningRepositoryFromEnvironment() {
  switch (_learningSource) {
    case 'mock':
      return const MockLearningRepository();
    case 'api':
      return ApiLearningRepository(baseUrl: _apiBaseUrl);
    default:
      throw StateError(
        'Unsupported STUDYHUB_LEARNING_SOURCE: $_learningSource',
      );
  }
}

ContributionRepository createContributionRepositoryFromEnvironment() {
  switch (_learningSource) {
    case 'mock':
      return const MockContributionRepository();
    case 'api':
      return ApiContributionRepository(baseUrl: _apiBaseUrl);
    default:
      throw StateError(
        'Unsupported STUDYHUB_LEARNING_SOURCE: $_learningSource',
      );
  }
}

AttemptRepository createAttemptRepositoryFromEnvironment() {
  switch (_learningSource) {
    case 'mock':
      return MockAttemptRepository();
    case 'api':
      return ApiAttemptRepository(baseUrl: _apiBaseUrl);
    default:
      throw StateError(
        'Unsupported STUDYHUB_LEARNING_SOURCE: $_learningSource',
      );
  }
}
