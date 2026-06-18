import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:bm_flutter/core.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _style(
    BuildContext context, {
    required double size,
    required AppFontWeight weight,
    Color? color,
  }) {
    return FontHelper.style(
      context: context,
      size: size,
      weight: weight,
      color: color ?? context.colors.primary800,
    );
  }

  // ---------------------------------------------------------------------------
  // DISPLAY
  // ---------------------------------------------------------------------------

  /// displayLarge → H1
  /// FontWeight: Bold
  /// FontSize: 32
  static TextStyle displayLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 32, weight: AppFontWeight.bold, color: color);

  /// displayMedium → H2
  /// FontWeight: Bold
  /// FontSize: 28
  static TextStyle displayMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 28, weight: AppFontWeight.bold, color: color);

  /// displaySmall → H3
  /// FontWeight: Bold
  /// FontSize: 24
  static TextStyle displaySmall(BuildContext context, {Color? color}) =>
      _style(context, size: 24, weight: AppFontWeight.bold, color: color);

  // ---------------------------------------------------------------------------
  // HEADLINE
  // ---------------------------------------------------------------------------

  /// headlineLarge → Big Title
  /// FontWeight: Bold
  /// FontSize: 18
  static TextStyle headlineLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 18, weight: AppFontWeight.bold, color: color);

  /// headlineMedium → Title
  /// FontWeight: Bold
  /// FontSize: 16
  static TextStyle headlineMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 16, weight: AppFontWeight.bold, color: color);

  /// headlineSmall → Subtitle
  /// FontWeight: SemiBold
  /// FontSize: 14
  static TextStyle headlineSmall(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.semiBold, color: color);

  // ---------------------------------------------------------------------------
  // TITLE (SEMIBOLD BODY)
  // ---------------------------------------------------------------------------

  /// titleLarge → Body Large SemiBold
  /// FontWeight: SemiBold
  /// FontSize: 18
  static TextStyle titleLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 18, weight: AppFontWeight.semiBold, color: color);

  /// titleMedium → Body Medium SemiBold
  /// FontWeight: SemiBold
  /// FontSize: 16
  static TextStyle titleMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 16, weight: AppFontWeight.semiBold, color: color);

  /// titleSmall → Body Small SemiBold
  /// FontWeight: SemiBold
  /// FontSize: 14
  static TextStyle titleSmall(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.semiBold, color: color);

  // ---------------------------------------------------------------------------
  // TITLE (MEDIUM BODY)
  // ---------------------------------------------------------------------------

  /// titleLarge → Body Large Medium
  /// FontWeight: Medium
  /// FontSize: 18
  static TextStyle titleMLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 18, weight: AppFontWeight.medium, color: color);

  /// titleMedium → Body Medium Medium
  /// FontWeight: Medium
  /// FontSize: 16
  static TextStyle titleMMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 16, weight: AppFontWeight.medium, color: color);

  /// titleSmall → Body Small Medium
  /// FontWeight: Medium
  /// FontSize: 14
  static TextStyle titleMSmall(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.medium, color: color);

  // ---------------------------------------------------------------------------
  // BODY
  // ---------------------------------------------------------------------------

  /// bodyLarge
  /// FontWeight: Regular
  /// FontSize: 18
  static TextStyle bodyLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 18, weight: AppFontWeight.regular, color: color);

  /// bodyMedium
  /// FontWeight: Regular
  /// FontSize: 16
  static TextStyle bodyMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 16, weight: AppFontWeight.regular, color: color);

  /// bodySmall
  /// FontWeight: Regular
  /// FontSize: 14
  static TextStyle bodySmall(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.regular, color: color);

  // ---------------------------------------------------------------------------
  // LABEL (BUTTONS / CAPTIONS)
  // ---------------------------------------------------------------------------

  /// labelLarge → Big Button
  /// FontWeight: Bold
  /// FontSize: 14
  static TextStyle labelLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.bold, color: color);

  /// labelMedium → Small Button
  /// FontWeight: SemiBold
  /// FontSize: 12
  static TextStyle labelMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 12, weight: AppFontWeight.semiBold, color: color);

  /// labelSmall → Caption / Small Text
  /// FontWeight: Regular
  /// FontSize: 12
  static TextStyle labelSmall(BuildContext context, {Color? color}) =>
      _style(context, size: 12, weight: AppFontWeight.regular, color: color);
}
