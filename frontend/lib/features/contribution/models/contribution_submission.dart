import 'question_set_draft.dart';

enum ContributionStatus { draft, pendingReview, approved, rejected }

class ContributionSubmission {
  const ContributionSubmission({
    required this.id,
    required this.status,
    required this.draft,
    required this.createdAt,
    required this.updatedAt,
    this.rejectionReason,
  });

  final String id;
  final ContributionStatus status;
  final QuestionSetDraft draft;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;

  bool get canEdit => status == ContributionStatus.draft;
}
