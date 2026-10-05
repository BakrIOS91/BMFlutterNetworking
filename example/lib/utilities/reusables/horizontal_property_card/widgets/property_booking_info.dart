import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import "package:flutter_example/core/storage_services/models/booking.dart";
import 'package:flutter_example/utilities/extensions/date_time_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';

class PropertyBookingInfo extends StatelessWidget {
  const PropertyBookingInfo({required this.booking, super.key});

  final BookingModel booking;

  EdgeInsetsDirectional _rowPadding(BuildContext context) =>
      EdgeInsetsDirectional.only(
        end: context.scaleValue(8),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
          color: context.colors.border,
          height: context.scaleValue(1),
          thickness: context.scaleValue(1),
        ),
        Padding(
            padding:
                _rowPadding(context).copyWith(bottom: context.scaleValue(4)),
            child: SizedBox(height: context.scaleValue(8))),
        if (booking.checkIn != null && booking.checkOut != null)
          Padding(
            padding:
                _rowPadding(context).copyWith(bottom: context.scaleValue(4)),
            child: _BookingInfoRow(
              icon: AppIcons.calendarIcon,
              label: context.localization.common_dates,
              value: booking.checkIn!.formatRange(
                  booking.checkOut!, context.localization.localeName),
            ),
          ),
        if (booking.guestCount != null)
          Padding(
            padding: _rowPadding(context),
            child: _BookingInfoRow(
              icon: AppIcons.guestIcon,
              label: context.localization.common_guest,
              value: context.localization.checkout_guest_count(booking.guestCount!),
            ),
          ),
        SizedBox(height: context.scaleValue(4)),
      ],
    );
  }
}

// ─── Booking Info Row ─────────────────────────────────────────────────────────

class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              asset: icon,
              size: context.scaleValue(20),
              color: context.colors.gray500,
            ),
            SizedBox(width: context.scaleValue(12)),
            Text(
              label,
              style: AppTextStyles.bodySmall(context,
                  color: context.colors.textGray0),
            ),
          ],
        ),
        SizedBox(width: context.scaleValue(8)),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.titleMSmall(context,
                color: context.colors.textGray0),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
