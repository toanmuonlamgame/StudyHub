import 'package:flutter/material.dart';

import 'app_design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      secondary: const Color(0xFF8AD6BC),
      tertiary: const Color(0xFFF4BD8C),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData get light => _build(
    const ColorScheme.light(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      primaryContainer: AppColors.brandContainer,
      onPrimaryContainer: AppColors.brandDark,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.tealContainer,
      onSecondaryContainer: Color(0xFF134E4A),
      tertiary: AppColors.warm,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.warmContainer,
      onTertiaryContainer: Color(0xFF7C2D12),
      error: AppColors.error,
      errorContainer: Color(0xFFFEE4E2),
      onErrorContainer: Color(0xFF7A271A),
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.mutedInk,
      outline: AppColors.outline,
      outlineVariant: Color(0xFFEEE6F5),
    ),
  );

  static ThemeData _build(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    final primary = colorScheme.primary;
    final surface = dark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surface;
    final background = dark ? colorScheme.surface : AppColors.canvas;
    final outline = dark ? colorScheme.outlineVariant : colorScheme.outline;
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    final textTheme = base.textTheme
        .copyWith(
          headlineMedium: const TextStyle(
            fontSize: 29,
            height: 1.13,
            fontWeight: FontWeight.w800,
            letterSpacing: -.75,
          ),
          headlineSmall: const TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w800,
            letterSpacing: -.45,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: const TextStyle(
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          side: BorderSide(color: outline),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size.square(48)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        elevation: AppElevation.overlay,
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.feature),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: colorScheme.primaryContainer,
        linearMinHeight: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: surface,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          );
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
        dividerColor: colorScheme.outlineVariant,
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: 56,
        iconColor: colorScheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
    );
  }
}
