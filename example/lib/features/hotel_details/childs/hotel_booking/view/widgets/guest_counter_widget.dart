import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/bloc/hotel_booking_bloc.dart';

import 'package:flutter_example/utilities/extensions/context_extension.dart';

class HotelBookingGuestCounterWidget extends StatelessWidget {
  const HotelBookingGuestCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBookingBloc, HotelBookingState>(
      buildWhen: (prev, curr) => prev.guestCount != curr.guestCount,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.localization.booking_view_guest_count,
              style: AppTextStyles.titleMedium(
                context,
                color: context.colors.gray900,
              ),
            ),
            Row(
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onTap: state.canDecrementGuest
                      ? () => context
                          .read<HotelBookingBloc>()
                          .add(const HotelBookingEvent.guestDecremented())
                      : null,
                  filled: false,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                      horizontal: context.scaleValue(16)),
                  child: Text(
                    '${state.guestCount}',
                    style: AppTextStyles.headlineMedium(
                      context,
                      color: context.colors.gray900,
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add,
                  onTap: state.guestCount < HotelBookingState.maxGuests
                      ? () => context
                          .read<HotelBookingBloc>()
                          .add(const HotelBookingEvent.guestIncremented())
                      : null,
                  filled: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: context.scaleValue(36),
        height: context.scaleValue(36),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (isEnabled
                    ? context.colors.primary800
                    : context.colors.gray200)
                : Colors.transparent,
            border: filled
                ? null
                : (isEnabled
                    ? Border.all(color: context.colors.primary800, width: 1.5)
                    : Border.all(color: context.colors.gray200, width: 1.5))),
        child: Icon(
          icon,
          size: context.scaleValue(18),
          color: filled
              ? context.colors.gray0
              : (isEnabled
                  ? context.colors.primary800
                  : context.colors.gray300),
        ),
      ),
    );
  }
}
