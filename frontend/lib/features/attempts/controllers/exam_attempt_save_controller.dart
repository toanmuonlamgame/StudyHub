import 'package:flutter/foundation.dart';

import '../models/exam_attempt.dart';
import '../repositories/attempt_repository.dart';

enum ExamAttemptSaveStatus { saving, saved, failed }

class ExamAttemptSaveController extends ChangeNotifier {
  ExamAttemptSaveController({required this.repository, required this.request});

  final AttemptRepository repository;
  final ExamAttemptSaveRequest request;
  ExamAttemptSaveStatus _status = ExamAttemptSaveStatus.saving;
  ExamAttemptDetail? _savedAttempt;
  bool _started = false;

  ExamAttemptSaveStatus get status => _status;
  ExamAttemptDetail? get savedAttempt => _savedAttempt;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    await _save();
  }

  Future<void> retry() async {
    if (_status != ExamAttemptSaveStatus.failed) {
      return;
    }
    await _save();
  }

  Future<void> _save() async {
    _status = ExamAttemptSaveStatus.saving;
    notifyListeners();
    try {
      _savedAttempt = await repository.saveExamAttempt(request);
      _status = ExamAttemptSaveStatus.saved;
    } catch (_) {
      _status = ExamAttemptSaveStatus.failed;
    }
    notifyListeners();
  }
}
