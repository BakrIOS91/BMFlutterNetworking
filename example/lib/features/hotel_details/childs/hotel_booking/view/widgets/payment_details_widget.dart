import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/bloc/hotel_booking_bloc.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class HotelBookingPaymentDetailsWidget extends StatelessWidget {
  const HotelBookingPaymentDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBookingBloc, HotelBookingState>(
      buildWhen: (prev, curr) =>
          prev.nightCount != curr.nightCount ||
          prev.paymentDetails != curr.paymentDetails,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localization.booking_view_payment_details,
              style: AppTextStyles.titleMedium(
                context,
                color: context.colors.gray900,
              ),
            ),
            SizedBox(height: context.scaleValue(12)),
            _PaymentRow(
              label: context.localization
                  .booking_view_total_nights(state.nightCount.toString()),
              amount:
                  '\$${state.paymentDetails?.totalNightsPrice.toStringAsFixed(2) ?? '0.00'}',
              isGrey: true,
            ),
            SizedBox(height: context.scaleValue(10)),
            _PaymentRow(
              label: context.localization.booking_view_cleaning_fee,
              amount:
                  '\$${state.paymentDetails?.cleaningFee.toStringAsFixed(2) ?? '0.00'}',
              isGrey: true,
            ),
            SizedBox(height: context.scaleValue(10)),
            _PaymentRow(
              label: context.localization.booking_view_service_fee,
              amount:
                  '\$${state.paymentDetails?.serviceFee.toStringAsFixed(2) ?? '0.00'}',
              isGrey: true,
            ),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: context.scaleValue(12)),
              child: Divider(color: context.colors.gray100, thickness: 1),
            ),
            _PaymentRow(
              label: context.localization.booking_view_total_payment,
              amount:
                  '\$${state.paymentDetails?.totalPayment.toStringAsFixed(2)}',
              isGrey: false,
            ),
          ],
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.amount,
    required this.isGrey,
  });

  final String label;
  final String amount;
  final bool isGrey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isGrey
              ? AppTextStyles.bodySmall(
                  context,
                  color: context.colors.gray500,
                )
              : AppTextStyles.titleSmall(
                  context,
                  color: context.colors.gray900,
                ),
        ),
        Text(
          amount,
          style: isGrey
              ? AppTextStyles.bodySmall(
                  context,
                  color: context.colors.gray900,
                )
              : AppTextStyles.titleSmall(
                  context,
                  color: context.colors.gray900,
                ),
        ),
      ],
    );
  }
}
