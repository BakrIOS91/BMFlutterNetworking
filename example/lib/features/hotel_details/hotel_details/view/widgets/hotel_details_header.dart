import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';

class HotelDetailsContentHeader extends StatelessWidget {
  const HotelDetailsContentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocBuilder<HotelDetailsBloc, HotelDetailsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
              top: state.isCollapsed ? kToolbarHeight + topPadding : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.hotel.title ?? "n/a",
                    style: AppTextStyles.displaySmall(
                      context,
                      color: context.colors.titleColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: context.scaleValue(16),
                        color: context.colors.primary800,
                      ),
                      SizedBox(
                        width: context.scaleValue(5),
                      ),
                      Text(
                        state.hotel.location?.address ?? "n/a",
                        style: AppTextStyles.bodySmall(
                          context,
                          color: context.colors.gray400,
                        ),
                      ),
                      SizedBox(
                        width: context.scaleValue(16),
                      ),
                      AppIcon(
                        asset: context.imageConstants.star,
                        size: context.scaleValue(16),
                      ),
                      Text(
                        '${state.hotel.rate ?? 0.0}',
                        style: AppTextStyles.labelMedium(
                          context,
                          color: context.colors.gray600,
                        ),
                      ),
                      SizedBox(
                        width: context.scaleValue(5),
                      ),
                    ],
                  )
                ],
              ),
              const Spacer(),
              AppButtonStyles.iconButtonPlatform(
                context: context,
                icon: AppIcon(
                  asset: (state.hotel.isFavorite ?? false)
                      ? context.imageConstants.favoriteSelected
                      : context.imageConstants.favorite,
                  size: context.scaleValue(35),
                  color: (state.hotel.isFavorite ?? false)
                      ? context.colors.alertError100
                      : context.colors.gray600,
                ),
                onPressed: () {
                  context.read<HotelDetailsBloc>().add(
                        const HotelDetailsEvent.toggleFavorite(),
                      );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
