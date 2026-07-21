import 'package:flutter/widgets.dart';

import 'repositories/media_repository.dart';

class MediaRepositoryScope extends InheritedWidget {
  const MediaRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });
  final MediaRepository repository;

  static MediaRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MediaRepositoryScope>();
    if (scope == null) throw StateError('MediaRepositoryScope is missing.');
    return scope.repository;
  }

  @override
  bool updateShouldNotify(MediaRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
