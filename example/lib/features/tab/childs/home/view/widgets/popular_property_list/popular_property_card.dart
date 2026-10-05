import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';
import 'package:flutter_example/utilities/constants/image_constants.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

List<Shadow> _cardTextShadows() => [
      const Shadow(
        color: Color(0x80000000),
        offset: Offset(0, 1),
        blurRadius: 4,
      ),
    ];

class PopularPropertyCard extends StatelessWidget {
  final Hotel property;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;

  const PopularPropertyCard({
    super.key,
    required this.property,
    required this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: context.scaleValue(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scaleValue(16)),
        child: Container(
          height: context.scaleValue(220),
          width: context.scaleValue(156),
          decoration: BoxDecoration(
            color: context.colors.additional0,
            borderRadius: BorderRadius.circular(context.scaleValue(16)),
            border: Border.all(
              color: context.colors.border,
              width: context.scaleValue(1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.scaleValue(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PropertyImage(image: property.image),
                const _GradientOverlay(),
                _FavoriteButton(
                  isFavorite: property.isFavorite ?? false,
                  onTap: onFavoriteTap,
                ),
                _PropertyInfo(property: property),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  final String? image;

  const _PropertyImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return AppImage(
      imageUrl: image,
      placeholder: ImageConstants.noImage,
      fit: BoxFit.cover,
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      bottom: 0,
      start: 0,
      end: 0,
      child: Container(
        height: context.scaleValue(140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(context.scaleValue(16))),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              context.colors.gradientblack80,
              context.colors.gradientblack30,
              context.colors.transparentBackground,
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: context.scaleValue(12),
      end: context.scaleValue(12),
      child: Container(
        width: context.scaleValue(28),
        height: context.scaleValue(28),
        decoration: BoxDecoration(
          color: context.colors.transparentBackground,
          shape: BoxShape.circle,
        ),
        child: AppButtonStyles.iconButtonPlatform(
          context: context,
          size: context.scaleValue(16.0),
          icon: AppIcon(
              asset: isFavorite ? AppIcons.favoriteSelected : AppIcons.favorite,
              size: context.scaleValue(16.0)),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _PropertyInfo extends StatelessWidget {
  final Hotel property;

  const _PropertyInfo({required this.property});

  @override
  Widget build(BuildContext context) {
    final shadows = _cardTextShadows();

    return PositionedDirectional(
      bottom: context.scaleValue(12),
      start: context.scaleValue(12),
      end: context.scaleValue(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            property.title ?? "",
            style: AppTextStyles.titleMedium(
              context,
              color: Colors.white,
            ).copyWith(shadows: shadows),
          ),
          SizedBox(height: context.scaleValue(4)),
          Text(
            property.location?.address ?? "",
            style: AppTextStyles.bodySmall(
              context,
              color: Colors.white.withValues(alpha: 0.9),
            ).copyWith(shadows: shadows),
          ),
          SizedBox(height: context.scaleValue(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${property.pricePerNight ?? ""}/${context.localization.common_night}",
                style: AppTextStyles.labelMedium(
                  context,
                  color: Colors.white,
                ).copyWith(shadows: shadows),
              ),
              _RatingWidget(rating: property.rate),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingWidget extends StatelessWidget {
  final double? rating;

  const _RatingWidget({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(asset: AppIcons.star, size: context.scaleValue(10)),
        SizedBox(width: context.scaleValue(4)),
        Text(
          "${rating ?? 0.0}",
          style: AppTextStyles.labelSmall(
            context,
            color: Colors.white,
          ).copyWith(shadows: _cardTextShadows()),
        ),
      ],
    );
  }
}
