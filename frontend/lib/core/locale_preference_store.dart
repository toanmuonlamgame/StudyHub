import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';

class LocalePreferenceStore {
  const LocalePreferenceStore();

  static const _key = 'studyhub_interface_locale';

  Future<AppLocaleSelection> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return AppLocaleSelectionX.fromStorageValue(preferences.getString(_key));
    } catch (_) {
      return AppLocaleSelection.system;
    }
  }

  Future<void> save(AppLocaleSelection selection) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_key, selection.storageValue);
    } catch (_) {
      // Locale changes still apply for the current session if persistence fails.
    }
  }
}
