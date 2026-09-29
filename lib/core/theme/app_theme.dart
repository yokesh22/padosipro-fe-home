import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

abstract final class AppTheme {
  static const headingFont = 'Eina';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        error: AppColors.error,
        surface: AppColors.background,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
          .copyWith(
            headlineLarge: const TextStyle(
              fontFamily: headingFont,
              fontWeight: FontWeight.w600,
              fontSize: 30,
              letterSpacing: -0.3,
              color: AppColors.ink,
            ),
            headlineMedium: const TextStyle(
              fontFamily: headingFont,
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: AppColors.ink,
            ),
            titleLarge: const TextStyle(
              fontFamily: headingFont,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: AppColors.ink,
            ),
            bodyLarge: const TextStyle(fontSize: 16, color: AppColors.ink),
            bodyMedium: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.muted,
            ),
            labelMedium: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: outline(AppColors.border),
        enabledBorder: outline(AppColors.border),
        focusedBorder: outline(AppColors.primary, 1.5),
        errorBorder: outline(AppColors.error),
        focusedErrorBorder: outline(AppColors.error, 1.5),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
