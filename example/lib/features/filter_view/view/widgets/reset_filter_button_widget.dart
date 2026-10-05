import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

class ResetFilterButtonWidget extends StatelessWidget {
  const ResetFilterButtonWidget({super.key, this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.scaleValue(56),
      child: AppButtonStyles.outlinedPlatform(
        context: context,
        textStyle:
            Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
        title: context.localization.filter_reset_button,
        onPressed: () {
          if (onReset != null) {
            onReset!();
          }
        },
      ),
    );
  }
}
