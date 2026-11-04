import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTextSize { system, large, extraLarge }

class TextSizePreferences extends InheritedWidget {
  const TextSizePreferences({
    super.key,
    required this.value,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeChanged,
    required super.child,
  });

  final AppTextSize value;
  final ValueChanged<AppTextSize> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  static const storageKey = 'studyhub_text_size';
  static const themeStorageKey = 'studyhub_theme_mode';

  static TextSizePreferences? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TextSizePreferences>();

  static Future<AppTextSize> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppTextSize.values
              .where((size) => size.name == prefs.getString(storageKey))
              .firstOrNull ??
          AppTextSize.system;
    } catch (_) {
      return AppTextSize.system;
    }
  }

  static Future<void> save(AppTextSize value) async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        storageKey,
        value.name,
      );
    } catch (_) {
      // The in-session setting still applies.
    }
  }

  static Future<ThemeMode> loadTheme() async {
    try {
      final value = (await SharedPreferences.getInstance()).getString(
        themeStorageKey,
      );
      return ThemeMode.values.where((mode) => mode.name == value).firstOrNull ??
          ThemeMode.system;
    } catch (_) {
      return ThemeMode.system;
    }
  }

  static Future<void> saveTheme(ThemeMode value) async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        themeStorageKey,
        value.name,
      );
    } catch (_) {
      // The in-session theme still applies.
    }
  }

  @override
  bool updateShouldNotify(TextSizePreferences oldWidget) =>
      value != oldWidget.value || themeMode != oldWidget.themeMode;
}
