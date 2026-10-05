import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/property_category_list/filter_item_model.dart';

/// Internal widget for a single filter button
/// Handles selection styling and optional icon
class FilterItemWidget extends StatelessWidget {
  final FilterItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // Animate color & border changes on selection
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaleValue(16),
          vertical: context.scaleValue(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary800 : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaleValue(8)),
          border: Border.all(
            color:
                isSelected ? context.colors.primary800 : context.colors.border,
            width: context.scaleValue(1.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Optional icon before text
            if (item.iconPath != null && item.iconPath!.isNotEmpty) ...[
              FilterItemIcon(iconPath: item.iconPath),
              SizedBox(width: context.scaleValue(8)),
            ],
            // Filter label
            Text(
              item.label,
              style: AppTextStyles.bodySmall(
                context,
                color: isSelected
                    ? context.colors.white
                    : context.colors.textGray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
