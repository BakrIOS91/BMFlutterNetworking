import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/constants/color_constants.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class AppInputStyles {
  AppInputStyles._();

  static Color getFillColor(
    AppColors colors, {
    required bool isIOS,
    bool isError = false,
  }) {
    if (isError) {
      return colors.alertError100.withValues(alpha: 0.1);
    }
    return colors.textFieldBackground;
  }

  static InputDecorationTheme theme(
    BuildContext context,
  ) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.scaleValue(12)),
      borderSide: BorderSide.none, // no visible border
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: getFillColor(context.colors, isIOS: isIOS),
      hintStyle: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(color: context.colors.gray500),
      errorStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: context.colors.alertError100),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: roundedBorder,
      enabledBorder: roundedBorder,
      focusedBorder: roundedBorder,
      errorBorder: roundedBorder,
      prefixIconConstraints:
          BoxConstraints.tight(Size(context.scaleValue(16), context.scaleValue(52))),
      focusedErrorBorder: roundedBorder,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ---------------------------------------------------------------------------
  // Decoration Helper
  // ---------------------------------------------------------------------------

  static InputDecoration decoration(
    BuildContext context, {
    String? placeholder,
    bool isError = false,
    String? error,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final fillColor = getFillColor(
      context.colors,
      isIOS: isIOS,
      isError: isError,
    );
    return InputDecoration(
      hintText: placeholder,
      errorText: isError ? error : null,
      prefixIcon: prefixIcon ??
          Container(
            width: 0,
          ),
      suffixIcon: suffixIcon,
      suffixIconColor:
          isError ? context.colors.alertError100 : context.colors.primary800,
      prefixIconColor:
          isError ? context.colors.alertError100 : context.colors.primary800,
      fillColor: fillColor,
      errorMaxLines: 10,
    );
  }
}
