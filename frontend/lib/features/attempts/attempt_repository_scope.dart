import 'package:flutter/widgets.dart';

import 'repositories/attempt_repository.dart';

class AttemptRepositoryScope extends InheritedWidget {
  const AttemptRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final AttemptRepository repository;

  static AttemptRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AttemptRepositoryScope>();
    assert(scope != null, 'No AttemptRepositoryScope found in context.');
    return scope!.repository;
  }

  static AttemptRepository? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<AttemptRepositoryScope>()
        ?.repository;
  }

  @override
  bool updateShouldNotify(AttemptRepositoryScope oldWidget) =>
      repository != oldWidget.repository;
}
