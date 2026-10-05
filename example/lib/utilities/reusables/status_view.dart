import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

class StatusAlertDialog extends StatelessWidget {
  final Status status;
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? action;
  final String? cancelButtonText;
  final VoidCallback? cancelAction;
  final bool? isDistructive;

  const StatusAlertDialog({
    super.key,
    required this.status,
    this.title,
    this.message,
    this.buttonText,
    this.action,
    this.cancelButtonText,
    this.cancelAction,
    this.isDistructive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.scaleValue(20)),
              child: Material(
                color: Colors.transparent,
                child: IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.gray0,
                      borderRadius:
                          BorderRadius.circular(context.scaleValue(20)),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.black.withValues(alpha: 0.2),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(context.scaleValue(30)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DialogIcon(
                          status: status,
                          scale: context.scaleValue(1),
                          colors: context.colors,
                        ),
                        if (title != null) ...[
                          SizedBox(height: context.scaleValue(16)),
                          _DialogTitle(title: title!, context: context),
                        ],
                        if (message != null) ...[
                          SizedBox(height: context.scaleValue(8)),
                          _DialogMessage(message: message!, context: context),
                        ],
                        SizedBox(height: context.scaleValue(20)),
                        _DialogActions(
                          buttonText: buttonText,
                          isDistructive: isDistructive,
                          cancelButtonText: cancelButtonText,
                          cancelAction: cancelAction,
                          action: action,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Private widget: Icon
class _DialogIcon extends StatelessWidget {
  final Status status;
  final double scale;
  final dynamic colors;

  const _DialogIcon(
      {required this.status, required this.scale, required this.colors});

  @override
  Widget build(BuildContext context) {
    String icon;
    switch (status) {
      case Status.success:
        icon = context.imageConstants.success;
        break;
      case Status.fail:
        icon = context.imageConstants.fail;
        break;
      case Status.warning:
        icon = context.imageConstants.warning;
        break;
      case Status.question:
        icon = context.imageConstants.question;
        break;
    }
    return Image.asset(
      icon,
      width: 100 * scale,
      height: 100 * scale,
    );
  }
}

/// Private widget: Title
class _DialogTitle extends StatelessWidget {
  final String title;
  final BuildContext context;

  const _DialogTitle({required this.title, required this.context});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(this.context).textTheme.titleLarge,
    );
  }
}

/// Private widget: Message
class _DialogMessage extends StatelessWidget {
  final String message;
  final BuildContext context;

  const _DialogMessage({required this.message, required this.context});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(this.context).textTheme.bodyMedium?.copyWith(
            color: context.colors.gray600,
          ),
    );
  }
}

/// Private widget: Actions row
class _DialogActions extends StatelessWidget {
  final String? buttonText;
  final VoidCallback? action;
  final String? cancelButtonText;
  final VoidCallback? cancelAction;
  final bool? isDistructive;

  const _DialogActions({
    this.buttonText,
    this.action,
    this.cancelButtonText,
    this.cancelAction,
    this.isDistructive,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.scaleValue(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (action != null)
          Flexible(
            child: AppButtonStyles.outlinedPlatform(
              context: context,
              onPressed: () {
                Navigator.pop(context);
                action?.call();
              },
              title: buttonText ?? "",
              textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDistructive ?? false
                        ? context.colors.alertError100
                        : context.colors.primary800,
                  ),
              borderColor: isDistructive ?? false
                  ? context.colors.alertError100
                  : context.colors.primary800,
            ),
          ),
        if (cancelButtonText != null && action != null)
          SizedBox(width: 12 * scale),
        if (cancelButtonText != null)
          Flexible(
            child: AppButtonStyles.primaryPlatform(
              context: context,
              onPressed: () {
                Navigator.pop(context);
                cancelAction?.call();
              },
              title: cancelButtonText!,
              titleColor: context.colors.gray0,
              textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.colors.gray0,
                  ),
            ),
          )
      ],
    );
  }
}

class StatusBottomSheet extends StatelessWidget {
  final Status status;
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? action;
  final String? customImageUrl;

  const StatusBottomSheet({
    super.key,
    required this.status,
    this.title,
    this.message,
    this.buttonText,
    this.action,
    this.customImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.gray0,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaleValue(24)),
        ),
      ),
      padding: EdgeInsets.all(context.scaleValue(24)),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.scaleValue(16)),
            if (customImageUrl != null)
              AppImage(
                imageUrl: customImageUrl!,
                width: context.scaleValue(200),
                height: context.scaleValue(200),
                fit: BoxFit.contain,
              )
            else
              _DialogIcon(
                status: status,
                scale: context.scaleValue(1),
                colors: context.colors,
              ),
            if (title != null) ...[
              SizedBox(height: context.scaleValue(24)),
              Text(
                title ?? "",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: context.colors.grayScale),
              )
            ],
            if (message != null) ...[
              SizedBox(height: context.scaleValue(8)),
              Text(
                message ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.colors.subTitleColor),
                textAlign: TextAlign.center,
              )
            ],
            SizedBox(height: context.scaleValue(32)),
            SizedBox(
              width: double.infinity,
              child: AppButtonStyles.primaryPlatform(
                context: context,
                onPressed: () {
                  Navigator.pop(context);
                  action?.call();
                },
                title: buttonText ?? "",
              ),
            ),
            SizedBox(height: context.scaleValue(16)),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required Status status,
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? action,
    String? customImageUrl,
  }) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (context) => PopScope(
              canPop: false,
              child: StatusBottomSheet(
                status: status,
                title: title,
                message: message,
                buttonText: buttonText,
                action: action,
                customImageUrl: customImageUrl,
              ),
            )
    );
  }
}
