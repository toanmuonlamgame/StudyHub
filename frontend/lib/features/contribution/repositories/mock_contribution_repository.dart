import '../models/question_set_draft.dart';
import '../models/contribution_submission.dart';
import '../models/submission_confirmation.dart';
import 'contribution_repository.dart';

class MockContributionRepository implements ContributionRepository {
  MockContributionRepository();

  final Map<String, ContributionSubmission> _submissions = {};
  int _nextId = 1;

  @override
  Future<List<ContributionSubmission>> listSubmissions() async {
    final values = _submissions.values.toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return values;
  }

  @override
  Future<ContributionSubmission> createDraft(QuestionSetDraft draft) async {
    final issues = draft.validateForDraft();
    if (issues.isNotEmpty) throw ContributionValidationException(issues);
    final now = DateTime.now();
    final submission = ContributionSubmission(
      id: 'mock-draft-${_nextId++}',
      status: ContributionStatus.draft,
      draft: draft,
      createdAt: now,
      updatedAt: now,
    );
    _submissions[submission.id] = submission;
    return submission;
  }

  @override
  Future<ContributionSubmission> updateDraft(
    String submissionId,
    QuestionSetDraft draft,
  ) async {
    final current = _submissions[submissionId];
    if (current == null || !current.canEdit) {
      throw const ContributionSubmissionException('Draft cannot be edited.');
    }
    final updated = ContributionSubmission(
      id: current.id,
      status: current.status,
      draft: draft,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    _submissions[submissionId] = updated;
    return updated;
  }

  @override
  Future<void> deleteDraft(String submissionId) async =>
      _submissions.remove(submissionId);

  @override
  Future<SubmissionConfirmation> submitDraftForReview(
    String submissionId,
  ) async {
    final current = _submissions[submissionId];
    if (current == null) {
      throw const ContributionSubmissionException('Draft not found.');
    }
    final issues = current.draft.validateForSubmission();
    if (issues.isNotEmpty) throw ContributionValidationException(issues);
    _submissions[submissionId] = ContributionSubmission(
      id: current.id,
      status: ContributionStatus.pendingReview,
      draft: current.draft,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    return SubmissionConfirmation(
      id: current.id,
      status: 'pendingReview',
      title: current.draft.title,
    );
  }

  @override
  Future<SubmissionConfirmation> submitForReview(
    QuestionSetDraft draft, {
    required String submissionId,
  }) async {
    final issues = draft.validateForSubmission();
    if (issues.isNotEmpty) throw ContributionValidationException(issues);
    final confirmation = SubmissionConfirmation(
      id: 'mock-$submissionId',
      status: 'pendingReview',
      title: draft.title.trim(),
    );
    _submissions[confirmation.id] = ContributionSubmission(
      id: confirmation.id,
      status: ContributionStatus.pendingReview,
      draft: draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return confirmation;
  }
}
