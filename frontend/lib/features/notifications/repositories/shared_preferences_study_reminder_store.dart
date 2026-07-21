import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_reminder_settings.dart';
import 'study_reminder_store.dart';

class SharedPreferencesStudyReminderStore implements StudyReminderStore {
  const SharedPreferencesStudyReminderStore();
  static const _enabled = 'studyReminder.enabled';
  static const _hour = 'studyReminder.hour';
  static const _minute = 'studyReminder.minute';
  static const _prompted = 'studyReminder.permissionPrompted';

  @override
  Future<StudyReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_hour) ?? 19;
    final minute = prefs.getInt(_minute) ?? 0;
    return StudyReminderSettings(
      enabled: prefs.getBool(_enabled) ?? false,
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
      permissionPrompted: prefs.getBool(_prompted) ?? false,
    );
  }

  @override
  Future<void> save(StudyReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_enabled, settings.enabled),
      prefs.setInt(_hour, settings.hour),
      prefs.setInt(_minute, settings.minute),
      prefs.setBool(_prompted, settings.permissionPrompted),
    ]);
  }
}
