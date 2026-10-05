import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

class HotelDetailsCommonFacilities extends StatelessWidget {
  const HotelDetailsCommonFacilities({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailsBloc, HotelDetailsState>(
      builder: (context, state) {
        final facilities = (state.hotel.facilities ?? []).take(4).toList();
        final shouldStretch = facilities.length >= 4;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.localization.hotel_details_common_facilities,
                  style: AppTextStyles.titleMedium(
                    context,
                    color: context.colors.titleColor,
                  ),
                ),
                const Spacer(),
                AppButtonStyles.textPlatform(
                  context: context,
                  title: context.localization.commonSeeAll,
                  textStyle: AppTextStyles.labelSmall(
                    context,
                    color: context.colors.primary800,
                  ),
                  onPressed: () {
                    context
                        .read<HotelDetailsBloc>()
                        .add(HotelDetailsEvent.didPressOnSeeAllFacilities());
                  },
                )
              ],
            ),
            if (facilities.isNotEmpty) ...[
              SizedBox(height: context.scaleValue(10)),
              Row(
                mainAxisAlignment: shouldStretch
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: facilities.asMap().entries.map((entry) {
                  final i = entry.key;
                  final facility = entry.value;
                  final isLast = i == (facilities.length - 1);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HotelDetailsFacilityItem(facility: facility),
                      if (!shouldStretch && !isLast)
                        SizedBox(width: context.scaleValue(12)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}

class HotelDetailsFacilityItem extends StatelessWidget {
  final Facility facility;

  const HotelDetailsFacilityItem({
    super.key,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.scaleValue(75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.scaleValue(55),
            height: context.scaleValue(55),
            padding: EdgeInsets.all(context.scaleValue(16)),
            decoration: BoxDecoration(
              color: context.colors.primary300.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: AppImage(
              imageUrl: facility.icon,
              fit: BoxFit.contain,
              color: context.colors.black,
            ),
          ),
          SizedBox(height: context.scaleValue(8)),
          Text(
            facility.categoryTitle ?? "",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall(
              context,
              color: context.colors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
