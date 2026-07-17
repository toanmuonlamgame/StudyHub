import 'package:flutter/foundation.dart';

import '../models/exam_attempt.dart';

abstract class AttemptRepository extends ChangeNotifier {
  Future<ExamAttemptDetail> saveExamAttempt(ExamAttemptSaveRequest request);

  Future<List<ExamAttemptSummary>> listExamAttempts();

  Future<ExamAttemptDetail?> getExamAttempt(String attemptId);
}
