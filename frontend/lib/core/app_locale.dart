import 'dart:ui';

enum AppLocaleSelection { system, english, vietnamese }

extension AppLocaleSelectionX on AppLocaleSelection {
  Locale? get locale => switch (this) {
    AppLocaleSelection.system => null,
    AppLocaleSelection.english => const Locale('en'),
    AppLocaleSelection.vietnamese => const Locale('vi'),
  };

  String get storageValue => switch (this) {
    AppLocaleSelection.system => 'system',
    AppLocaleSelection.english => 'en',
    AppLocaleSelection.vietnamese => 'vi',
  };

  static AppLocaleSelection fromStorageValue(String? value) {
    return switch (value) {
      'en' => AppLocaleSelection.english,
      'vi' => AppLocaleSelection.vietnamese,
      _ => AppLocaleSelection.system,
    };
  }
}
