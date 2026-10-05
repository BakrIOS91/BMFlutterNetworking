import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

class ApplyFilterButtonWidget extends StatelessWidget {
  const ApplyFilterButtonWidget({super.key, this.onApply});

  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.scaleValue(56),
      child: AppButtonStyles.primaryPlatform(
        context: context,
        title: context.localization.filter_apply_button,
        onPressed: () {
          if (onApply != null) {
            onApply!();
          }
        },
      ),
    );
  }
}
