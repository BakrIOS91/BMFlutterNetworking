import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_facilities.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_description.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_header.dart';
import 'package:flutter_example/features/hotel_details/hotel_details/view/widgets/hotel_details_location.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';

class HotelDetailsContentView extends StatelessWidget {
  const HotelDetailsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HotelDetailsBloc, HotelDetailsState, bool>(
      selector: (state) => state.hotel.facilities?.isNotEmpty ?? false,
      builder: (context, hasFacilities) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              right: context.scaleValue(20),
              left: context.scaleValue(20),
              bottom: context.scaleValue(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.scaleValue(16),
              children: [
                const HotelDetailsContentHeader(),
                if (hasFacilities) const HotelDetailsCommonFacilities(),
                const HotelDetailsDescription(),
                const HotelDetailsLocation(),
              ],
            ),
          ),
        );
      },
    );
  }
}
