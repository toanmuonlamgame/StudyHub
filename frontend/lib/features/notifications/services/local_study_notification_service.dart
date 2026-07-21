import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'study_notification_service.dart';

class LocalStudyNotificationService implements StudyNotificationService {
  LocalStudyNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _dailyId = 4100;
  static const _testId = 4101;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<String?> initialize(void Function(String payload) onTap) async {
    if (!_supported || _initialized) return null;
    const android = AndroidInitializationSettings('ic_stat_studyhub');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: darwin),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null) onTap(payload);
        },
      );
    } catch (_) {
      return null;
    }
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    _initialized = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? launch?.notificationResponse?.payload
        : null;
  }

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_supported || !_initialized) return;
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.cancel(id: _dailyId);
    await _plugin.zonedSchedule(
      id: _dailyId,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'home',
    );
  }

  @override
  Future<void> cancelDaily() => _plugin.cancel(id: _dailyId);

  @override
  Future<void> showTest({required String title, required String body}) async {
    if (!_supported || !_initialized) return;
    await _plugin.show(
      id: _testId,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: 'home',
    );
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'study_reminders',
      'Study reminders',
      channelDescription:
          'Quiet daily reminders for planned StudyHub learning.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: false,
      enableVibration: false,
      icon: 'ic_stat_studyhub',
    ),
    iOS: DarwinNotificationDetails(presentSound: false),
  );
}
