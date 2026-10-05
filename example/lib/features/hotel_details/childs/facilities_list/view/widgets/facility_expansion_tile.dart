import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/hotel_details/childs/facilities_list/bloc/facilities_list_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

class FacilityExpansionTile extends StatelessWidget {
  final Facility facility;
  final bool isExpanded;
  final int index;

  const FacilityExpansionTile({
    super.key,
    required this.facility,
    required this.isExpanded,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.hotelBackground,
        borderRadius: BorderRadius.circular(context.scaleValue(12)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: PageStorageKey(index),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (_) => context.read<FacilitiesListBloc>().add(
                FacilitiesListEvent.toggleExpansion(index),
              ),
          trailing: _FacilityTrailingIcon(isExpanded: isExpanded),
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
          ),
          collapsedShape: const RoundedRectangleBorder(
            side: BorderSide.none,
          ),
          leading: _FacilityLeadingIcon(imageUrl: facility.icon),
          title: _FacilityTitle(
            title: facility.categoryTitle ?? "",
            count: facility.subFacilities?.length ?? 0,
          ),
          children: facility.subFacilities
                  ?.map((sub) => _FacilitySubItem(text: sub))
                  .toList() ??
              [],
        ),
      ),
    );
  }
}

class _FacilityLeadingIcon extends StatelessWidget {
  final String? imageUrl;
  const _FacilityLeadingIcon({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AppImage(
      imageUrl: imageUrl,
      width: context.scaleValue(15),
      height: context.scaleValue(15),
      color: context.colors.gray950,
    );
  }
}

class _FacilityTitle extends StatelessWidget {
  final String title;
  final int count;
  const _FacilityTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: context.scaleValue(5),
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium(
            context,
            color: context.colors.gray950,
          ),
        ),
        Text(
          context.localization.hotel_details_facilities_count(count),
          style: AppTextStyles.labelSmall(
            context,
            color: context.colors.gray300,
          ),
        ),
      ],
    );
  }
}

class _FacilityTrailingIcon extends StatelessWidget {
  final bool isExpanded;
  const _FacilityTrailingIcon({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isExpanded ? Icons.remove : Icons.add,
      color: context.colors.gray950,
      size: context.scaleValue(20),
    );
  }
}

class _FacilitySubItem extends StatelessWidget {
  final String text;
  const _FacilitySubItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.scaleValue(64),
        right: context.scaleValue(16),
        bottom: context.scaleValue(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: context.scaleValue(6),
            color: context.colors.gray600,
          ),
          SizedBox(width: context.scaleValue(12)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(
                context,
                color: context.colors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
