import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_input_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/constants/color_constants.dart';
import 'package:injectable/injectable.dart';

@singleton
final class ThemeFactory {
  ThemeData light(BuildContext context) {
    const fontFamily = 'Jost';
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors(Brightness.light).gray0,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors(Brightness.light).primary500,
        brightness: Brightness.light,
        primary: AppColors(Brightness.light).primary500,
      ),
      textTheme: TextTheme(
        // H1 — Bold - 32
        displayLarge: AppTextStyles.displayLarge(context),
        // H2 — Bold — 28
        displayMedium: AppTextStyles.displayMedium(context),
        // H3 — Bold — 24
        displaySmall: AppTextStyles.displaySmall(context),
        // Big Title — Bold — 18
        headlineLarge: AppTextStyles.headlineLarge(context),
        // Title — Bold — 16
        headlineMedium: AppTextStyles.headlineMedium(context),
        // Subtitle — SemiBold — 14
        headlineSmall: AppTextStyles.headlineSmall(context),
        // Body Large SemiBold — 18
        titleLarge: AppTextStyles.titleLarge(context),
        // Body Medium SemiBold — 16
        titleMedium: AppTextStyles.titleMedium(context),
        // Body Small SemiBold — 14
        titleSmall: AppTextStyles.titleSmall(context),
        // Body Large — Regular / 18
        bodyLarge: AppTextStyles.bodyLarge(context),
        // Body Medium — Regular / 16
        bodyMedium: AppTextStyles.bodyMedium(context),
        // Body Small — Regular / 14
        bodySmall: AppTextStyles.bodySmall(context),
        // Big Button — Bold / 14
        labelLarge: AppTextStyles.labelLarge(context),
        // Small Button — SemiBold / 12
        labelMedium: AppTextStyles.labelMedium(context),
        // Caption — Regular / 12
        labelSmall: AppTextStyles.labelSmall(context),
      ),
      inputDecorationTheme: AppInputStyles.theme(context),
      filledButtonTheme: FilledButtonThemeData(
        style: AppButtonStyles.filled(context),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlined(context),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.text(context),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors(Brightness.light).primary500,
      ),
    );
  }

  ThemeData dark(BuildContext context) {
    const fontFamily = 'Jost';
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors(Brightness.dark).gray0,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors(Brightness.dark).primary500,
        brightness: Brightness.dark,
        primary: AppColors(Brightness.dark).primary500,
      ),
      textTheme: TextTheme(
        // H1 — Bold / 32
        displayLarge: AppTextStyles.displayLarge(context),
        // H2 — Bold / 28
        displayMedium: AppTextStyles.displayMedium(context),
        // H3 — Bold / 24
        displaySmall: AppTextStyles.displaySmall(context),
        // Big Title — Bold / 18
        headlineLarge: AppTextStyles.headlineLarge(context),
        // Title — Bold / 16
        headlineMedium: AppTextStyles.headlineMedium(context),
        // Subtitle — SemiBold / 14
        headlineSmall: AppTextStyles.headlineSmall(context),
        // Body Large SemiBold — 18
        titleLarge: AppTextStyles.titleLarge(context),
        // Body Medium SemiBold — 16
        titleMedium: AppTextStyles.titleMedium(context),
        // Body Small SemiBold — 14
        titleSmall: AppTextStyles.titleSmall(context),
        // Body Large — Regular / 18
        bodyLarge: AppTextStyles.bodyLarge(context),
        // Body Medium — Regular / 16
        bodyMedium: AppTextStyles.bodyMedium(context),
        // Body Small — Regular / 14
        bodySmall: AppTextStyles.bodySmall(context),
        // Big Button — Bold / 14
        labelLarge: AppTextStyles.labelLarge(context),
        // Small Button — SemiBold / 12
        labelMedium: AppTextStyles.labelMedium(context),
        // Caption — Regular / 12
        labelSmall: AppTextStyles.labelSmall(context),
      ),
      inputDecorationTheme: AppInputStyles.theme(context),
      filledButtonTheme: FilledButtonThemeData(
        style: AppButtonStyles.filled(context),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlined(context),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.text(context),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors(Brightness.dark).primary500,
      ),
    );
  }
}
