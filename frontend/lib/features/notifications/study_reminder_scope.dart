import 'package:flutter/widgets.dart';

import 'controllers/study_reminder_controller.dart';

class StudyReminderScope extends InheritedNotifier<StudyReminderController> {
  const StudyReminderScope({
    super.key,
    required StudyReminderController controller,
    required super.child,
  }) : super(notifier: controller);

  static StudyReminderController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<StudyReminderScope>();
    if (scope?.notifier == null) {
      throw StateError('StudyReminderScope is missing.');
    }
    return scope!.notifier!;
  }
}
