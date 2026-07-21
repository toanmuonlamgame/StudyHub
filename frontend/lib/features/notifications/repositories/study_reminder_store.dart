import '../models/study_reminder_settings.dart';

abstract interface class StudyReminderStore {
  Future<StudyReminderSettings> load();
  Future<void> save(StudyReminderSettings settings);
}
