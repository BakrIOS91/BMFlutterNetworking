import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? seeAllTitle;
  final VoidCallback? onSeeAllPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllTitle,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleLarge(context,
                color: context.colors.textGray0),
          ),
        ),
        if (seeAllTitle != null)
          TextButton(
            onPressed: onSeeAllPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              seeAllTitle!,
              style: AppTextStyles.labelMedium(context,
                  color: context.colors.textPrimary800),
            ),
          ),
      ],
    );
  }
}
