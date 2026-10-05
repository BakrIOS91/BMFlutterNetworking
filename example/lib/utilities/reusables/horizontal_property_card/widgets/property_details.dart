import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

class PropertyDetails extends StatelessWidget {
  const PropertyDetails(
      {required this.property, required this.isBooking, super.key});

  final Hotel property;
  final bool isBooking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        0,
        context.scaleValue(12),
        0,
        isBooking ? 0 : context.scaleValue(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PropertyTitle(title: property.title),
          SizedBox(height: context.scaleValue(8)),
          _PropertyLocation(address: property.location?.address),
          SizedBox(height: context.scaleValue(8)),
          _PropertyPrice(
              pricePerNight: (property.pricePerNight ?? 0.0).toDouble()),
        ],
      ),
    );
  }
}

// ─── Property Title ───────────────────────────────────────────────────────────

class _PropertyTitle extends StatelessWidget {
  const _PropertyTitle({this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? '',
      style:
          AppTextStyles.titleMedium(context, color: context.colors.textGray0),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─── Property Location ────────────────────────────────────────────────────────

class _PropertyLocation extends StatelessWidget {
  const _PropertyLocation({this.address});

  final String? address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(asset: AppIcons.location, size: context.scaleValue(14)),
        SizedBox(width: context.scaleValue(4)),
        Flexible(
          child: Text(
            address ?? '',
            style: AppTextStyles.labelSmall(context,
                color: context.colors.gray800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Property Price ───────────────────────────────────────────────────────────

class _PropertyPrice extends StatelessWidget {
  const _PropertyPrice({this.pricePerNight});

  final double? pricePerNight;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '\$${pricePerNight ?? 0.0}',
        style: AppTextStyles.titleMMedium(context,
            color: context.colors.textPrimary800),
        children: [
          TextSpan(
            text: ' /${context.localization.common_night}',
            style: AppTextStyles.titleMMedium(context,
                color: context.colors.textGray0),
          ),
        ],
      ),
    );
  }
}
