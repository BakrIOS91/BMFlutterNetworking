import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

class VerticalPropertyCard extends StatelessWidget {
  final Hotel property;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const VerticalPropertyCard({
    super.key,
    required this.property,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scaleValue(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Stack
            _buildImageStack(context),
            SizedBox(height: context.scaleValue(12)),

            // Info Row
            Padding(
              padding: EdgeInsetsDirectional.only(
                  start: context.scaleValue(10),
                  end: context.scaleValue(10),
                  bottom: context.scaleValue(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDescription(context),
                  _buildPrice(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageStack(BuildContext context) {
    return Stack(
      children: [
        // Main Image
        ClipRRect(
          borderRadius: BorderRadius.circular(context.scaleValue(16)),
          child: AppImage(
            imageUrl: property.image,
            width: double.infinity,
            height: context.scaleValue(180),
            fit: BoxFit.cover,
          ),
        ),

        // Overlay Gradient (minimal as per CSS)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.scaleValue(16)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  context.colors.gradientblack30,
                  context.colors.gradientblack30,
                ],
              ),
            ),
          ),
        ),

        // Overlays (Rate & Heart)
        Positioned(
          top: context.scaleValue(10),
          left: context.scaleValue(12),
          right: context.scaleValue(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rate Chip
              _GlassChip(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: context.scaleValue(8),
                  vertical: context.scaleValue(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      asset: AppIcons.star,
                      size: context.scaleValue(16),
                    ),
                    SizedBox(width: context.scaleValue(5)),
                    Text(
                      "${property.rate ?? 0.0}".replaceAll('.', ','),
                      style: AppTextStyles.labelLarge(context).copyWith(
                        fontSize: context.scaleValue(12),
                        color: context.colors.gray0,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Button
              _GlassChip(
                padding: EdgeInsetsDirectional.all(context.scaleValue(5)),
                onTap: onFavoriteTap,
                blur: 2.5,
                child: AppIcon(
                  asset: (property.isFavorite ?? false)
                      ? AppIcons.favoriteSelected
                      : AppIcons.favorite,
                  size: context.scaleValue(20),
                  color: (property.isFavorite ?? false)
                      ? context.colors.alertError100
                      : context.colors.gray0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            property.title ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineMedium(context).copyWith(
                fontSize: context.scaleValue(16),
                color: context.colors.textGray0),
          ),

          SizedBox(height: context.scaleValue(5)),

          // Location
          Text(
            property.location?.address ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall(context).copyWith(
                fontSize: context.scaleValue(12),
                color: context.colors.textGray0),
          ),

          SizedBox(height: context.scaleValue(12)),

          // Facilities
          Row(
            children: [
              _FacilityItem(
                icon: Icon(
                  Icons.bed_outlined,
                  size: context.scaleValue(16),
                  color: context.colors.textGray700,
                ),
                text:
                    "${property.beds ?? 0} ${context.localization.common_bed}",
              ),
              SizedBox(width: context.scaleValue(8)),
              Container(
                width: context.scaleValue(2),
                height: context.scaleValue(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.textGray700,
                ),
              ),
              SizedBox(width: context.scaleValue(8)),
              _FacilityItem(
                icon: Icon(
                  Icons.bathtub_outlined,
                  size: context.scaleValue(16),
                  color: context.colors.textGray700,
                ),
                text:
                    "${property.bathrooms ?? 0} ${context.localization.common_bathroom}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "\$${property.pricePerNight?.toInt() ?? 0}",
          style: AppTextStyles.titleLarge(context).copyWith(
            fontSize: context.scaleValue(18),
            fontWeight: FontWeight.bold,
            color: context.colors.primary800,
          ),
        ),
        SizedBox(height: context.scaleValue(5)),
        Text(
          context.localization.common_per_night,
          style: AppTextStyles.bodySmall(context).copyWith(
            fontSize: context.scaleValue(12),
            color: context.colors.textGray700,
          ),
        ),
      ],
    );
  }
}

class _GlassChip extends StatelessWidget {
  final Widget child;
  final EdgeInsetsDirectional padding;
  final VoidCallback? onTap;
  final double blur;

  const _GlassChip({
    required this.child,
    required this.padding,
    this.onTap,
    this.blur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(context.scaleValue(50)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: context.colors.transparentBackground,
            borderRadius: BorderRadius.circular(context.scaleValue(50)),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: content,
      );
    }
    return content;
  }
}

class _FacilityItem extends StatelessWidget {
  final Widget icon;
  final String text;

  const _FacilityItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: context.scaleValue(5)),
        Text(
          text,
          style: AppTextStyles.bodySmall(context).copyWith(
            fontSize: context.scaleValue(14),
            color: context.colors.textGray0,
          ),
        ),
      ],
    );
  }
}
