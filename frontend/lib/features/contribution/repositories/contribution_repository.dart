import '../models/question_set_draft.dart';
import '../models/contribution_submission.dart';
import '../models/submission_confirmation.dart';

abstract interface class ContributionRepository {
  Future<List<ContributionSubmission>> listSubmissions();
  Future<ContributionSubmission> createDraft(QuestionSetDraft draft);
  Future<ContributionSubmission> updateDraft(
    String submissionId,
    QuestionSetDraft draft,
  );
  Future<void> deleteDraft(String submissionId);
  Future<SubmissionConfirmation> submitDraftForReview(String submissionId);
  Future<SubmissionConfirmation> submitForReview(
    QuestionSetDraft draft, {
    required String submissionId,
  });
}

class ContributionValidationException implements Exception {
  const ContributionValidationException(this.issues);
  final List<DraftValidationIssue> issues;
}

class ContributionSubmissionException implements Exception {
  const ContributionSubmissionException(this.message);
  final String message;
}
