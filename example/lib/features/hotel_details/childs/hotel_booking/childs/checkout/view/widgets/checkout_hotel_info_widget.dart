import 'package:flutter/material.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';

class CheckoutHotelInfoWidget extends StatelessWidget {
  final Hotel hotel;

  const CheckoutHotelInfoWidget({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.scaleValue(24),
        left: context.scaleValue(24),
        right: context.scaleValue(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
            imageUrl: hotel.image ?? '',
            width: context.scaleValue(78),
            height: context.scaleValue(78),
            radius: BorderRadius.circular(context.scaleValue(16)),
            fit: BoxFit.cover,
          ),
          SizedBox(width: context.scaleValue(12)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.title ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: context.scaleValue(20),
                              fontWeight: FontWeight.w500,
                              color: context.colors.gray900,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: context.scaleValue(16)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: context.colors.ratingColor,
                          size: context.scaleValue(20),
                        ),
                        SizedBox(width: context.scaleValue(4)),
                        Text(
                          (hotel.rate ?? 0.0).toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.colors.gray900,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.scaleValue(8)),
                
                // Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: context.colors.subTitleColor,
                      size: context.scaleValue(16),
                    ),
                    SizedBox(width: context.scaleValue(4)),
                    Expanded(
                      child: Text(
                        hotel.location?.address ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.subTitleColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scaleValue(8)),
                
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$${hotel.pricePerNight ?? 0}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.colors.primary500,
                          ),
                    ),
                    Text(
                      ' /${context.localization.common_night}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.gray500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
