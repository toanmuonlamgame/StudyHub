import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/device_permissions/device_permission_service.dart';
import '../models/study_reminder_settings.dart';
import '../repositories/study_reminder_store.dart';
import '../services/study_notification_service.dart';

class StudyReminderController extends ChangeNotifier {
  StudyReminderController({
    required StudyReminderStore store,
    required StudyNotificationService notifications,
    required DevicePermissionService permissions,
  }) : this._(store, notifications, permissions);

  StudyReminderController._(
    this._store,
    this._notifications,
    this._permissions,
  );

  final StudyReminderStore _store;
  final StudyNotificationService _notifications;
  final DevicePermissionService _permissions;

  StudyReminderSettings settings = const StudyReminderSettings();
  DevicePermissionState permissionState = DevicePermissionState.unavailable;
  bool loading = true;
  String? error;

  Future<void> load() async {
    try {
      settings = await _store.load();
    } catch (_) {
      error = 'load_failed';
    }
    loading = false;
    notifyListeners();
    unawaited(refreshPermission());
  }

  Future<void> setEnabled(
    bool enabled, {
    required String title,
    required String body,
  }) async {
    error = null;
    if (!enabled) {
      settings = settings.copyWith(enabled: false);
      await _notifications.cancelDaily();
      await _store.save(settings);
      notifyListeners();
      return;
    }
    permissionState = await _permissions.notificationStatus();
    if (permissionState != DevicePermissionState.granted &&
        !settings.permissionPrompted) {
      permissionState = await _permissions.requestNotifications();
      settings = settings.copyWith(permissionPrompted: true);
    }
    if (permissionState != DevicePermissionState.granted) {
      settings = settings.copyWith(enabled: false);
      await _store.save(settings);
      notifyListeners();
      return;
    }
    try {
      await _notifications.scheduleDaily(
        hour: settings.hour,
        minute: settings.minute,
        title: title,
        body: body,
      );
      settings = settings.copyWith(enabled: true);
      await _store.save(settings);
    } catch (_) {
      error = 'schedule_failed';
    }
    notifyListeners();
  }

  Future<void> setTime(
    int hour,
    int minute, {
    required String title,
    required String body,
  }) async {
    settings = settings.copyWith(hour: hour, minute: minute);
    await _store.save(settings);
    if (settings.enabled) {
      await _notifications.scheduleDaily(
        hour: hour,
        minute: minute,
        title: title,
        body: body,
      );
    }
    notifyListeners();
  }

  Future<void> openSettings() => _permissions.openSettings();

  Future<void> refreshPermission() async {
    permissionState = await _permissions.notificationStatus();
    if (permissionState != DevicePermissionState.granted && settings.enabled) {
      settings = settings.copyWith(enabled: false);
      await _store.save(settings);
      await _notifications.cancelDaily();
    }
    notifyListeners();
  }

  Future<void> showTest({required String title, required String body}) =>
      _notifications.showTest(title: title, body: body);
}
