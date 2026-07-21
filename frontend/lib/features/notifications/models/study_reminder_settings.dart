class StudyReminderSettings {
  const StudyReminderSettings({
    this.enabled = false,
    this.hour = 19,
    this.minute = 0,
    this.permissionPrompted = false,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final bool permissionPrompted;

  StudyReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? permissionPrompted,
  }) => StudyReminderSettings(
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    permissionPrompted: permissionPrompted ?? this.permissionPrompted,
  );
}
