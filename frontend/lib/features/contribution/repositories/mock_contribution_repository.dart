import '../models/question_set_draft.dart';
import '../models/submission_confirmation.dart';
import 'contribution_repository.dart';

class MockContributionRepository implements ContributionRepository {
  const MockContributionRepository();

  @override
  Future<SubmissionConfirmation> submitForReview(
    QuestionSetDraft draft, {
    required String submissionId,
  }) async {
    final issues = draft.validateForSubmission();
    if (issues.isNotEmpty) throw ContributionValidationException(issues);
    return SubmissionConfirmation(
      id: 'mock-$submissionId',
      status: 'pendingReview',
      title: draft.title.trim(),
    );
  }
}
