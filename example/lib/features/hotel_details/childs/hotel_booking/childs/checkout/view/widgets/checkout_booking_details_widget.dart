import 'package:flutter/material.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/extensions/date_time_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CheckoutBookingDetailsWidget extends StatelessWidget {
  final BookingModel booking;

  const CheckoutBookingDetailsWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsetsDirectional.symmetric(horizontal: context.scaleValue(24)),
      decoration: BoxDecoration(
        color: context.colors.gray0,
        borderRadius: BorderRadius.circular(context.scaleValue(16)),
        border: Border.all(color: context.colors.divider),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(context.scaleValue(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your Booking Section
            Text(
              context.localization.checkout_your_booking,
              style: AppTextStyles.titleMedium(
                context,
                color: context.colors.primary800,
              ),
            ),
            SizedBox(height: context.scaleValue(16)),

            // Dates
            _buildDetailRow(
              context,
              icon: AppIcons.calendarIcon,
              label: context.localization.common_dates,
              value: booking.checkIn?.formatRange(
                      booking.checkOut, context.localization.localeName) ??
                  '',
            ),
            SizedBox(height: context.scaleValue(16)),

            // Guest
            _buildDetailRow(
              context,
              icon: AppIcons.guestIcon,
              label: context.localization.common_guest,
              value: context.localization
                  .checkout_guest_count(booking.guestCount ?? 1),
            ),
            SizedBox(height: context.scaleValue(16)),

            // Room type
            _buildDetailRow(
              context,
              icon: AppIcons.buildingIcon,
              label: context.localization.checkout_room_type,
              value: booking.hotel.category?.title ??
                  context.localization.checkout_default_room_type,
            ),
            SizedBox(height: context.scaleValue(16)),

            // Phone
            _buildDetailRow(
              context,
              icon: AppIcons.callIcon,
              label: context.localization.account_info_phone_label,
              value: booking.hotel.phone ?? context.localization.common_none,
              onTap: booking.hotel.phone != null
                  ? () => launchUrlString('tel:${booking.hotel.phone}')
                  : null,
            ),
            SizedBox(height: context.scaleValue(16)),

            // Dashed Divider
            _DashedDivider(color: context.colors.divider),

            SizedBox(height: context.scaleValue(16)),

            // Price Details Section
            Text(
              context.localization.checkout_price_details,
              style: AppTextStyles.titleMedium(
                context,
                color: context.colors.primary800,
              ),
            ),
            SizedBox(height: context.scaleValue(16)),

            // Price
            _buildPriceRow(
              context,
              label: context.localization.hotel_details_booking_price_title,
              value: booking.formattedPrice(booking.totalNightsPrice),
            ),
            SizedBox(height: context.scaleValue(12)),

            // Admin fee / service fee
            _buildPriceRow(
              context,
              label: context.localization.checkout_admin_fee,
              value: booking
                  .formattedPrice(booking.cleaningFee + booking.serviceFee),
            ),
            SizedBox(height: context.scaleValue(16)),

            // Total price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.localization.checkout_total_price,
                  style: AppTextStyles.titleSmall(
                    context,
                    color: context.colors.gray900,
                  ),
                ),
                Text(
                  booking.formattedPrice(booking.totalPayment),
                  style: AppTextStyles.titleSmall(
                    context,
                    color: context.colors.gray900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        AppIcon(
          asset: icon,
          size: context.scaleValue(20),
          color: context.colors.gray500,
        ),
        SizedBox(width: context.scaleValue(8)),
        Text(
          label,
          style:
              AppTextStyles.bodySmall(context, color: context.colors.gray900),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          child: Text(
            value,
            style: AppTextStyles.bodySmall(context,
                color: onTap != null
                    ? context.colors.primary500
                    : context.colors.gray900),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(
            context,
            color: context.colors.gray900,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall(
            context,
            color: context.colors.gray900,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
