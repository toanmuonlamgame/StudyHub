import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/device_permissions/device_permission_service.dart';
import 'package:frontend/features/notifications/controllers/study_reminder_controller.dart';
import 'package:frontend/features/notifications/models/study_reminder_settings.dart';
import 'package:frontend/features/notifications/repositories/study_reminder_store.dart';
import 'package:frontend/features/notifications/services/study_notification_service.dart';

void main() {
  test('reminder permission is requested only after enable intent', () async {
    final permissions = _FakePermissions(DevicePermissionState.denied);
    final notifications = _FakeNotifications();
    final store = _MemoryStore();
    final controller = StudyReminderController(
      store: store,
      notifications: notifications,
      permissions: permissions,
    );

    await controller.load();
    expect(permissions.requestCount, 0);
    await controller.setEnabled(true, title: 'Study', body: 'Continue');
    expect(permissions.requestCount, 1);
    expect(controller.settings.enabled, isFalse);

    await controller.setEnabled(true, title: 'Study', body: 'Continue');
    expect(permissions.requestCount, 1);
  });

  test('granted reminder schedules once and persists selected time', () async {
    final permissions = _FakePermissions(DevicePermissionState.granted);
    final notifications = _FakeNotifications();
    final store = _MemoryStore();
    final controller = StudyReminderController(
      store: store,
      notifications: notifications,
      permissions: permissions,
    );
    await controller.load();
    await controller.setTime(20, 15, title: 'Study', body: 'Continue');
    await controller.setEnabled(true, title: 'Study', body: 'Continue');

    expect(controller.settings.enabled, isTrue);
    expect(notifications.scheduleCount, 1);
    expect(store.value.hour, 20);
    expect(store.value.minute, 15);
  });
}

class _MemoryStore implements StudyReminderStore {
  StudyReminderSettings value = const StudyReminderSettings();
  @override
  Future<StudyReminderSettings> load() async => value;
  @override
  Future<void> save(StudyReminderSettings settings) async => value = settings;
}

class _FakePermissions implements DevicePermissionService {
  _FakePermissions(this.state);
  DevicePermissionState state;
  int requestCount = 0;
  @override
  Future<DevicePermissionState> notificationStatus() async => state;
  @override
  Future<DevicePermissionState> requestNotifications() async {
    requestCount++;
    return state;
  }

  @override
  Future<bool> openSettings() async => true;
}

class _FakeNotifications implements StudyNotificationService {
  int scheduleCount = 0;
  @override
  Future<String?> initialize(void Function(String payload) onTap) async => null;
  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    scheduleCount++;
  }

  @override
  Future<void> cancelDaily() async {}
  @override
  Future<void> showTest({required String title, required String body}) async {}
}
