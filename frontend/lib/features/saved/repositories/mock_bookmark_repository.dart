import '../../learning/models/question_set.dart';
import 'bookmark_repository.dart';

class MockBookmarkRepository extends BookmarkRepository {
  final Map<String, QuestionSet> _items = {};

  @override
  Future<List<QuestionSet>> listBookmarks() async =>
      _items.values.toList(growable: false);

  @override
  Future<void> save(QuestionSet questionSet) async {
    _items[questionSet.id] = questionSet;
    notifyListeners();
  }

  @override
  Future<void> remove(String questionSetId) async {
    _items.remove(questionSetId);
    notifyListeners();
  }
}
