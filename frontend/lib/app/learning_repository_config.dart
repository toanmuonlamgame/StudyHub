import '../features/learning/repositories/api_learning_repository.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/repositories/mock_learning_repository.dart';

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
