import 'package:flutter/widgets.dart';

import 'repositories/progress_store.dart';

class ProgressStoreScope extends InheritedWidget {
  const ProgressStoreScope({
    super.key,
    required this.progressStore,
    required super.child,
  });

  final ProgressStore progressStore;

  static ProgressStore of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ProgressStoreScope>();
    assert(scope != null, 'No ProgressStoreScope found in context.');
    return scope!.progressStore;
  }

  static ProgressStore? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<ProgressStoreScope>()
        ?.progressStore;
  }

  @override
  bool updateShouldNotify(ProgressStoreScope oldWidget) {
    return progressStore != oldWidget.progressStore;
  }
}
