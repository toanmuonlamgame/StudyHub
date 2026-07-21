import 'package:flutter/widgets.dart';

import 'repositories/bookmark_repository.dart';

class BookmarkScope extends InheritedNotifier<BookmarkRepository> {
  const BookmarkScope({
    super.key,
    required BookmarkRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static BookmarkRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BookmarkScope>();
    assert(scope != null, 'BookmarkScope is missing.');
    return scope!.notifier!;
  }
}
