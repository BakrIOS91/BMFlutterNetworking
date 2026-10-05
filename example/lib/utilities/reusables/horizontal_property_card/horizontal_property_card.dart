import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import "package:flutter_example/core/storage_services/models/booking.dart";
import 'package:flutter_example/utilities/reusables/horizontal_property_card/widgets/property_actions.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/widgets/property_booking_info.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/widgets/property_details.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/widgets/property_image.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum HorizontalPropertyCardType { view, booking }

// ─── Main Widget ─────────────────────────────────────────────────────────────

class HorizontalPropertyCard extends StatelessWidget {
  const HorizontalPropertyCard({
    super.key,
    this.property,
    this.booking,
    this.cardType = HorizontalPropertyCardType.view,
    this.onFavoriteTap,
    this.onTap,
  });

  final Hotel? property;
  final BookingModel? booking;
  final HorizontalPropertyCardType cardType;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  bool get _isBooking => cardType == HorizontalPropertyCardType.booking;
  Hotel get _hotel => booking?.hotel ?? property!;
  bool get _hasDatesOrGuest =>
      _isBooking && (booking?.checkIn != null || booking?.checkOut != null || booking?.guestCount != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: _buildDecoration(context),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PropertyImage(property: _hotel, isBooking: _isBooking),
              if (!_isBooking) SizedBox(width: context.scaleValue(16)),
              Expanded(child: _buildInfoColumn(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PropertyDetails(
                property: _hotel,
                isBooking: _isBooking,
              ),
            ),
            PropertyActions(
              property: _hotel,
              onFavoriteTap: onFavoriteTap,
              isBooking: _isBooking,
            ),
          ],
        ),
        if (_hasDatesOrGuest) ...[
          SizedBox(height: context.scaleValue(12)),
          PropertyBookingInfo(booking: booking!),
        ],
      ],
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    if (!_isBooking) return const BoxDecoration(color: Colors.transparent);

    return BoxDecoration(
      color: context.colors.gray0,
      borderRadius: BorderRadius.circular(context.scaleValue(16)),
      border: Border.all(
        color: context.colors.border,
        width: context.scaleValue(1),
      ),
    );
  }
}
