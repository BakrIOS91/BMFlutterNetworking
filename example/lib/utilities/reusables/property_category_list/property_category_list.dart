import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/reusables/property_category_list/filter_item_model.dart';
import 'package:flutter_example/utilities/reusables/property_category_list/filter_item_widget.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart' as lookups;
import 'package:flutter_example/utilities/extensions/context_extension.dart';

/// Horizontal scrollable filter bar
/// Handles selection changes via callback
class PropertyCategoryList extends StatelessWidget {
  final List<lookups.Category> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PropertyCategoryList({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // SizedBox defines the height of the filter bar
    return SizedBox(
      height: context.scaleValue(44),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: EdgeInsets.symmetric(horizontal: context.scaleValue(4.0)),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedIndex;

          // Map lookups.Category to FilterItem
          final item = FilterItem(
            label: category.title ?? '',
            iconPath: category.iconUrl,
          );

          return Padding(
            padding: EdgeInsets.only(right: context.scaleValue(8.0)),
            child: FilterItemWidget(
              item: item,
              isSelected: isSelected,
              onTap: () => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}
