import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class AppButtonStyles {
  AppButtonStyles._();

  // =========================
  // Dynamic radius & padding
  // =========================
  static RoundedRectangleBorder shape(BuildContext context) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(context.scaleValue(12))),
      );

  static EdgeInsets padding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: context.scaleValue(24),
        vertical: context.scaleValue(16),
      );

  static TextStyle? _textPrimary(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge
      ?.copyWith(color: context.colors.gray0);

  static TextStyle? _textOnSurface(BuildContext context, Color color) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(color: color);

  // =========================
  // Material Button Styles
  // =========================
  static ButtonStyle filled(BuildContext context) => ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(context.colors.primary800),
        foregroundColor: WidgetStatePropertyAll(context.colors.gray0),
        textStyle: WidgetStatePropertyAll(_textPrimary(context)),
        padding: WidgetStatePropertyAll(padding(context)),
        shape: WidgetStatePropertyAll(shape(context)),
      );

  static ButtonStyle outlined(BuildContext context) => ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(context.colors.primary800),
        textStyle: WidgetStatePropertyAll(
            _textOnSurface(context, context.colors.primary800)),
        padding: WidgetStatePropertyAll(padding(context)),
        shape: WidgetStatePropertyAll(shape(context)),
        side: WidgetStatePropertyAll(
            BorderSide(color: context.colors.primary800)),
      );

  static ButtonStyle text(BuildContext context) => ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(context.colors.primary800),
        textStyle: WidgetStatePropertyAll(
            _textOnSurface(context, context.colors.primary800)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: context.scaleValue(12),
            vertical: context.scaleValue(16),
          ),
        ),
      );

  // =========================
  // Platform-aware buttons (full-width)
  // =========================

  static Widget primaryPlatform({
    required BuildContext context,
    required VoidCallback? onPressed,
    required String title,
    Color? backgroundColor,
    Color? titleColor,
    TextStyle? textStyle,
    bool isDisabled = false,
  }) {
    final effectiveOnPressed = isDisabled ? null : onPressed;
    final buttonColor = isDisabled
        ? context.colors.disabledButtonBackground
        : (backgroundColor ?? context.colors.primary800);
    final textColor = isDisabled
        ? context.colors.disabledButtonTitle
        : (titleColor ?? context.colors.white);
    if (Platform.isIOS) {
      return SizedBox(
        width: double.infinity, // Full width
        child: CupertinoButton(
          padding: padding(context),
          borderRadius:
              BorderRadius.all(Radius.circular(context.scaleValue(12))),
          color: buttonColor,
          onPressed: effectiveOnPressed,
          child: Text(title,
              style: textStyle ??
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: textColor)),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity, // Full width
        child: FilledButton(
          style: isDisabled
              ? filled(context).copyWith(
                  backgroundColor: WidgetStatePropertyAll(buttonColor),
                  foregroundColor: WidgetStatePropertyAll(textColor),
                )
              : filled(context),
          onPressed: effectiveOnPressed,
          child: Text(title,
              style: textStyle ??
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: textColor)),
        ),
      );
    }
  }

  static Widget outlinedPlatform({
    required BuildContext context,
    required VoidCallback onPressed,
    required String title,
    TextStyle? textStyle,
    Color? borderColor,
  }) {
    if (Platform.isIOS) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          // Remove inner padding for container
          borderRadius:
              BorderRadius.all(Radius.circular(context.scaleValue(12))),
          color: Colors.transparent,
          onPressed: onPressed,
          child: Container(
            width: double.infinity,
            padding: padding(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border:
                  Border.all(color: borderColor ?? context.colors.primary800),
              borderRadius: BorderRadius.circular(context.scaleValue(12)),
            ),
            child: Text(
              title,
              style: textStyle ??
                  Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: context.colors.primary800),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: borderColor != null
              ? outlined(context).copyWith(
                  side: WidgetStatePropertyAll(BorderSide(color: borderColor)))
              : outlined(context),
          onPressed: onPressed,
          child: Text(
            title,
            style: textStyle ??
                Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: context.colors.primary800),
          ),
        ),
      );
    }
  }

  static Widget textPlatform({
    required BuildContext context,
    required VoidCallback onPressed,
    required String title,
    TextStyle? textStyle,
  }) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        // no padding
        borderRadius: BorderRadius.zero,
        color: Colors.transparent,
        onPressed: onPressed,
        child: Text(
          title,
          style: textStyle ?? Theme.of(context).textTheme.titleMedium,
        ),
      );
    } else {
      return TextButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero), // no padding
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: textStyle ?? Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
  }

  static Widget iconButtonPlatform({
    required BuildContext context,
    required Widget icon,
    required VoidCallback onPressed,
    double? size,
    Color? color,
    EdgeInsets? padding,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    Widget flippedIcon = Transform.flip(
      flipX: isRTL,
      child: icon,
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        onPressed: onPressed,
        child: IconTheme(
          data: IconThemeData(
            size: size ?? 24,
            color: color ?? context.colors.primary800,
          ),
          child: flippedIcon,
        ),
      );
    } else {
      return IconButton(
        iconSize: size ?? 24,
        color: color ?? context.colors.primary800,
        padding: padding ?? const EdgeInsets.all(0.0),
        onPressed: onPressed,
        icon: flippedIcon,
      );
    }
  }
}
