import '../models/question_set_draft.dart';
import '../models/contribution_submission.dart';
import '../models/submission_confirmation.dart';
import 'contribution_repository.dart';
import '../../materials/models/study_material_submission.dart';

class MockContributionRepository implements ContributionRepository {
  MockContributionRepository();

  final Map<String, ContributionSubmission> _submissions = {};
  final Map<String, StudyMaterialSubmission> _materialSubmissions = {};
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

  @override
  Future<List<StudyMaterialSubmission>> listMaterialSubmissions() async {
    final values = _materialSubmissions.values.toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return values;
  }

  @override
  Future<StudyMaterialSubmission> createMaterialDraft(
    StudyMaterialDraft draft, {
    String? submissionId,
  }) async {
    final now = DateTime.now();
    final submission = StudyMaterialSubmission(
      id: 'mock-material-${_nextId++}',
      draft: draft,
      status: StudyMaterialSubmissionStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
    _materialSubmissions[submission.id] = submission;
    return submission;
  }

  @override
  Future<StudyMaterialSubmission> updateMaterialDraft(
    String submissionId,
    StudyMaterialDraft draft,
  ) async {
    final current = _materialSubmissions[submissionId];
    if (current == null || !current.canEdit) {
      throw const ContributionSubmissionException(
        'Material draft cannot be edited.',
      );
    }
    final updated = StudyMaterialSubmission(
      id: current.id,
      draft: draft,
      status: current.status,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    _materialSubmissions[submissionId] = updated;
    return updated;
  }

  @override
  Future<void> deleteMaterialDraft(String submissionId) async {
    final current = _materialSubmissions[submissionId];
    if (current == null || !current.canEdit) {
      throw const ContributionSubmissionException(
        'Material draft cannot be deleted.',
      );
    }
    _materialSubmissions.remove(submissionId);
  }

  @override
  Future<StudyMaterialSubmission> submitMaterialDraftForReview(
    String submissionId,
  ) async {
    final current = _materialSubmissions[submissionId];
    if (current == null || !current.canEdit) {
      throw const ContributionSubmissionException(
        'Material draft cannot be submitted.',
      );
    }
    final submitted = StudyMaterialSubmission(
      id: current.id,
      draft: current.draft,
      status: StudyMaterialSubmissionStatus.pendingReview,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      submittedAt: DateTime.now(),
    );
    _materialSubmissions[submissionId] = submitted;
    return submitted;
  }
}
