import 'package:flutter/foundation.dart';

import '../models/completed_learning_session.dart';

abstract class ProgressStore extends ChangeNotifier {
  Future<List<CompletedLearningSession>> loadSessions();

  Future<void> saveCompletedSession(CompletedLearningSession session);

  Future<void> clearHistory();
}
