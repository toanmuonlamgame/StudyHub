import '../models/question_set_draft.dart';
import '../models/submission_confirmation.dart';
import 'contribution_repository.dart';

class MockContributionRepository implements ContributionRepository {
  const MockContributionRepository();

  @override
  Future<SubmissionConfirmation> submitForReview(QuestionSetDraft draft) async {
    final issues = draft.validateForSubmission();
    if (issues.isNotEmpty) throw ContributionValidationException(issues);
    return SubmissionConfirmation(
      id: 'mock-submission-${DateTime.now().microsecondsSinceEpoch}',
      status: 'pendingReview',
      title: draft.title.trim(),
    );
  }
}
