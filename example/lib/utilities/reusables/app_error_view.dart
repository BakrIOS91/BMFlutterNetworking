import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final Widget? image;
  final String? mainActionTitle;
  final VoidCallback? onMainAction;
  final String? secondaryActionTitle;
  final VoidCallback? onSecondaryAction;
  final Widget? retryButton;

  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.image,
    this.mainActionTitle,
    this.onMainAction,
    this.secondaryActionTitle,
    this.onSecondaryAction,
    this.retryButton,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.scaleValue(16);

    return Padding(
      padding: EdgeInsets.all(context.scaleValue(24)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null) ...[
              image!,
              SizedBox(height: spacing * 2),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall(
                context,
                color: context.colors.gray900,
              ),
            ),
            SizedBox(height: spacing / 2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: context.colors.gray600,
              ),
            ),
            if (retryButton != null) ...[
              SizedBox(height: spacing * 2),
              retryButton!,
            ] else ...[
              if (mainActionTitle != null && onMainAction != null) ...[
                SizedBox(height: spacing * 2),
                AppButtonStyles.primaryPlatform(
                  context: context,
                  title: mainActionTitle!,
                  onPressed: onMainAction!,
                ),
              ],
              if (secondaryActionTitle != null &&
                  onSecondaryAction != null) ...[
                if (mainActionTitle == null) SizedBox(height: spacing * 2),
                if (mainActionTitle != null) SizedBox(height: spacing),
                AppButtonStyles.outlinedPlatform(
                  context: context,
                  title: secondaryActionTitle!,
                  onPressed: onSecondaryAction!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
