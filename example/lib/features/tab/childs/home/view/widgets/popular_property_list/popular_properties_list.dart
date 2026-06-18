import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/tab/childs/home/bloc/home_bloc.dart';
import 'package:flutter_example/utilities/reusables/section_header.dart';
import 'package:flutter_example/features/tab/childs/home/view/widgets/popular_property_list/popular_property_card.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

const int _kPopularHomePreviewCount = 3;

class PopularPropertiesSection extends StatelessWidget {
  final List<Hotel> properties;
  final void Function(Hotel property) onFavoriteTap;
  final void Function(Hotel property) onPropertyTap;
  final VoidCallback onSeeAllPressed;

  const PopularPropertiesSection({
    super.key,
    required this.properties,
    required this.onFavoriteTap,
    required this.onSeeAllPressed,
    required this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: context.scaleValue(24.0)),
              child: SectionHeader(
                title: context.localization.home_popular_section_title,
                seeAllTitle: state.shouldPaginate
                    ? context.localization.commonSeeAll
                    : null,
                onSeeAllPressed: onSeeAllPressed,
              ),
            ),
            SizedBox(height: context.scaleValue(16.0)),
            _PopularPropertyList(
              properties: properties.take(_kPopularHomePreviewCount).toList(),
              onFavoriteTap: onFavoriteTap,
              onPropertyTap: onPropertyTap,
            ),
            SizedBox(height: context.scaleValue(24.0)),
          ],
        );
      },
    );
  }
}

class _PopularPropertyList extends StatelessWidget {
  final List<Hotel> properties;
  final void Function(Hotel property) onFavoriteTap;
  final void Function(Hotel property) onPropertyTap;

  const _PopularPropertyList({
    required this.properties,
    required this.onFavoriteTap,
    required this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsetsDirectional.fromSTEB(context.scaleValue(16.0), 0, 0.0, 0.0),
      child: SizedBox(
        height: context.scaleValue(260),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: properties.length,
          itemBuilder: (_, index) {
            final property = properties[index];
            return PopularPropertyCard(
              property: property,
              onFavoriteTap: () => onFavoriteTap(property),
              onTap: () => onPropertyTap(property),
            );
          },
        ),
      ),
    );
  }
}
