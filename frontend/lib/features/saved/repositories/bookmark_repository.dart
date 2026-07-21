import 'package:flutter/foundation.dart';

import '../../learning/models/question_set.dart';

abstract class BookmarkRepository extends ChangeNotifier {
  Future<List<QuestionSet>> listBookmarks();
  Future<void> save(QuestionSet questionSet);
  Future<void> remove(String questionSetId);

  Future<bool> contains(String questionSetId) async =>
      (await listBookmarks()).any((item) => item.id == questionSetId);
}
