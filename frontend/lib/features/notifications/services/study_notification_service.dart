abstract interface class StudyNotificationService {
  Future<String?> initialize(void Function(String payload) onTap);
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  });
  Future<void> cancelDaily();
  Future<void> showTest({required String title, required String body});
}
