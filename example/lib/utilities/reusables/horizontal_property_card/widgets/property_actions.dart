import 'package:flutter/material.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

class PropertyActions extends StatelessWidget {
  const PropertyActions(
      {required this.property,
      required this.isBooking,
      this.onFavoriteTap,
      super.key});

  final Hotel property;
  final bool isBooking;
  final VoidCallback? onFavoriteTap;

  bool get _isFavorite => property.isFavorite ?? false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        0.0,
        context.scaleValue(12),
        isBooking ? context.scaleValue(12) : 0.0,
        context.scaleValue(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (onFavoriteTap != null) ...[
            _FavoriteButton(isFavorite: _isFavorite, onTap: onFavoriteTap!),
            SizedBox(height: context.scaleValue(4))
          ],
          _RatingBadge(rate: property.rate),
        ],
      ),
    );
  }
}

// ─── Favorite Button ──────────────────────────────────────────────────────────

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AppIcon(
        asset: isFavorite ? AppIcons.favoriteSelected : AppIcons.favorite,
        size: context.scaleValue(20),
        color: isFavorite
            ? context.colors.alertError100
            : context.colors.textGray0,
      ),
    );
  }
}

// ─── Rating Badge ─────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({this.rate});

  final double? rate;

  String get _formattedRate => '${rate ?? 0.0}'.replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(asset: AppIcons.star, size: context.scaleValue(14)),
        SizedBox(width: context.scaleValue(4)),
        Text(
          _formattedRate,
          style: AppTextStyles.titleMSmall(context,
              color: context.colors.textGray0),
        ),
      ],
    );
  }
}
