import 'package:flutter/material.dart';
import 'package:flutter_example/utilities/reusables/app_image.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

class PropertyImage extends StatelessWidget {
  const PropertyImage(
      {required this.property, required this.isBooking, super.key});

  final Hotel property;
  final bool isBooking;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(context.scaleValue(14)),
      child: AppImage(
        imageUrl: property.image,
        width: context.scaleValue(96),
        height: context.scaleValue(isBooking ? 152 : 100),
        fit: BoxFit.cover,
      ),
    );

    return isBooking
        ? Padding(padding: EdgeInsets.all(context.scaleValue(12)), child: image)
        : image;
  }
}
