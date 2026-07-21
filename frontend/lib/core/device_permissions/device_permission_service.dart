import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum DevicePermissionState { granted, denied, permanentlyDenied, unavailable }

abstract interface class DevicePermissionService {
  Future<DevicePermissionState> notificationStatus();
  Future<DevicePermissionState> requestNotifications();
  Future<bool> openSettings();
}

class PlatformDevicePermissionService implements DevicePermissionService {
  const PlatformDevicePermissionService();

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<DevicePermissionState> notificationStatus() async {
    if (!_supported) return DevicePermissionState.unavailable;
    try {
      return _map(await Permission.notification.status);
    } catch (_) {
      return DevicePermissionState.unavailable;
    }
  }

  @override
  Future<DevicePermissionState> requestNotifications() async {
    if (!_supported) return DevicePermissionState.unavailable;
    try {
      return _map(await Permission.notification.request());
    } catch (_) {
      return DevicePermissionState.unavailable;
    }
  }

  @override
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  DevicePermissionState _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return DevicePermissionState.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return DevicePermissionState.permanentlyDenied;
    }
    return DevicePermissionState.denied;
  }
}
