import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

const int _kDescriptionCollapsedThreshold = 150;

class HotelDetailsDescription extends StatelessWidget {
  const HotelDetailsDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailsBloc, HotelDetailsState>(
      builder: (context, state) {
        final description = state.hotel.description ?? "";
        if (description.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.localization.hotel_details_description_title,
              style: AppTextStyles.titleMedium(
                context,
                color: context.colors.titleColor,
              ),
            ),
            SizedBox(height: context.scaleValue(8)),
            Text(
              description,
              maxLines: state.isDescriptionExpanded ? null : 3,
              overflow: state.isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall(
                context,
                color: context.colors.gray600,
              ),
            ),
            if (description.length > _kDescriptionCollapsedThreshold)
              GestureDetector(
                onTap: () {
                  context
                      .read<HotelDetailsBloc>()
                      .add(const HotelDetailsEvent.didPressOnToggleDescription());
                },
                child: Padding(
                  padding: EdgeInsets.only(top: context.scaleValue(4)),
                  child: Text(
                    state.isDescriptionExpanded
                        ? context.localization.hotel_details_read_less
                        : context.localization.hotel_details_read_more,
                    style: AppTextStyles.labelMedium(
                      context,
                      color: context.colors.primary800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
