import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class HotelDetailsBookingView extends StatelessWidget {
  const HotelDetailsBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailsBloc, HotelDetailsState>(
      builder: (context, state) {
        final price = state.hotel.pricePerNight ?? 0;

        return Container(
          height: context.scaleValue(90),
          padding: EdgeInsets.symmetric(
            horizontal: context.scaleValue(24),
            vertical: context.scaleValue(16),
          ),
          decoration: BoxDecoration(
            color: context.colors.gray0,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.scaleValue(24)),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.gray950.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.localization.hotel_details_booking_price_title,
                    style: AppTextStyles.labelSmall(
                      context,
                      color: context.colors.gray500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$$price',
                          style: AppTextStyles.headlineLarge(
                            context,
                            color: context.colors.gray950,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${context.localization.common_night}',
                          style: AppTextStyles.labelSmall(
                            context,
                            color: context.colors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: context.scaleValue(160),
                child: AppButtonStyles.primaryPlatform(
                  context: context,
                  title:
                      context.localization.hotel_details_booking_button_title,
                  onPressed: () {
                    context
                        .read<HotelDetailsBloc>()
                        .add(const HotelDetailsEvent.didPressOnBookNow());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
