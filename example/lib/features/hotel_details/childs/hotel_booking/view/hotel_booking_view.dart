import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/bloc/hotel_booking_bloc.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/view/widgets/date_card_widget.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/view/widgets/guest_counter_widget.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/view/widgets/payment_details_widget.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/view/widgets/select_date_dialog.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/features/tab/childs/booking/bloc/booking_bloc.dart';

@RoutePage()
class HotelBookingView extends StatelessWidget implements AutoRouteWrapper {
  final Hotel hotel;
  const HotelBookingView({super.key, required this.hotel});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HotelBookingBloc>(param1: hotel)
        ..add(const HotelBookingEvent.started()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.gray0,
      appBar: AppBar(
        backgroundColor: context.colors.gray0,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(
          context.localization.booking_view_title,
          style: AppTextStyles.headlineLarge(
            context,
            color: context.colors.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HotelBookingBloc, HotelBookingState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: context.scaleValue(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.scaleValue(20)),
                  // Date section
                  Text(
                    context.localization.booking_view_date,
                    style: AppTextStyles.titleMedium(
                      context,
                      color: context.colors.gray900,
                    ),
                  ),
                  SizedBox(height: context.scaleValue(12)),
                  Row(
                    children: [
                      HotelBookingDateCardWidget(
                        label: context.localization.booking_view_check_in,
                        date: state.checkIn,
                        onTap: () async {
                          final picked =
                              await HotelBookingSelectDateDialog.show(
                            context,
                            title: context
                                .localization.booking_view_select_date_in_title,
                            initialDate: state.checkIn,
                            firstDate: DateTime.now(),
                          );
                          if (picked != null && context.mounted) {
                            context.read<HotelBookingBloc>().add(
                                  HotelBookingEvent.checkInSelected(picked),
                                );
                          }
                        },
                      ),
                      SizedBox(width: context.scaleValue(12)),
                      HotelBookingDateCardWidget(
                        label: context.localization.booking_view_check_out,
                        date: state.checkOut,
                        onTap: () async {
                          final picked =
                              await HotelBookingSelectDateDialog.show(
                            context,
                            title: context.localization
                                .booking_view_select_date_out_title,
                            initialDate: state.checkOut,
                            firstDate: state.checkIn,
                          );
                          if (picked != null && context.mounted) {
                            context.read<HotelBookingBloc>().add(
                                  HotelBookingEvent.checkOutSelected(picked),
                                );
                          }
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: context.scaleValue(28)),
                  // Guest counter
                  const HotelBookingGuestCounterWidget(),

                  SizedBox(height: context.scaleValue(28)),
                  // Payment details
                  const HotelBookingPaymentDetailsWidget(),

                  const Spacer(),
                  // Checkout button
                  AppButtonStyles.primaryPlatform(
                    context: context,
                    title: context.localization.common_checkout,
                    textStyle: AppTextStyles.labelLarge(
                      context,
                      color: context.colors.white,
                    ),
                    onPressed: state.paymentDetails != null
                        ? () async {
                            await context.router.push(
                              CheckoutRoute(
                                booking: state.paymentDetails!,
                                isViewing: false,
                              ),
                            );

                            if (context.mounted) {
                              context
                                  .read<BookingBloc>()
                                  .add(const BookingEvent.started());
                            }
                          }
                        : null,
                  ),

                  SizedBox(height: context.scaleValue(24)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
