import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/reusables/section_header.dart';
import 'package:flutter_example/utilities/reusables/property_category_list/property_category_list.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/horizontal_property_card.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart'
    as lookups;

class RecommendedPropertiesSection extends StatelessWidget {
  final List<Hotel> properties;
  final List<lookups.Category> categories;
  final int selectedCategoryIndex;
  final void Function(int index) onCategorySelected;
  final void Function(Hotel hotel)? onFavoriteTap;
  final void Function(Hotel hotel)? onPropertyTap;

  const RecommendedPropertiesSection({
    super.key,
    required this.properties,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    this.onFavoriteTap,
    this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
              horizontal: context.scaleValue(24.0)),
          child: SectionHeader(
            title: context.localization.home_recommended_section_title,
          ),
        ),
        SizedBox(height: context.scaleValue(16.0)),
        if (categories.isNotEmpty) ...[
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                context.scaleValue(16.0), 0, 0.0, 0.0),
            child: PropertyCategoryList(
              categories: categories,
              selectedIndex: selectedCategoryIndex,
              onSelected: onCategorySelected,
            ),
          ),
          SizedBox(height: context.scaleValue(16.0)),
        ],
        RecommendedPropertyList(
          properties: properties,
          onFavoriteTap: onFavoriteTap,
          onPropertyTap: onPropertyTap,
        ),
      ],
    );
  }
}

class RecommendedPropertyList extends StatelessWidget {
  final List<Hotel> properties;
  final void Function(Hotel hotel)? onFavoriteTap;
  final void Function(Hotel hotel)? onPropertyTap;

  const RecommendedPropertyList({
    super.key,
    required this.properties,
    this.onFavoriteTap,
    this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsetsDirectional.symmetric(horizontal: context.scaleValue(24.0)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(bottom: context.scaleValue(16.0)),
        itemCount: properties.length,
        separatorBuilder: (_, __) => Padding(
          padding: EdgeInsetsDirectional.symmetric(
              vertical: context.scaleValue(16.0)),
          child: Divider(
            height: context.scaleValue(1),
            color: context.colors.border,
          ),
        ),
        itemBuilder: (_, index) {
          final property = properties[index];
          return HorizontalPropertyCard(
            property: property,
            onFavoriteTap:
                onFavoriteTap != null ? () => onFavoriteTap!(property) : null,
            onTap:
                onPropertyTap != null ? () => onPropertyTap!(property) : null,
          );
        },
      ),
    );
  }
}
