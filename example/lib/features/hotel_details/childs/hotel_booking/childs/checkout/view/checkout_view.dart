import 'package:auto_route/auto_route.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/childs/checkout/bloc/checkout_bloc.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/childs/checkout/view/widgets/checkout_app_bar.dart';
import 'package:flutter_example/features/hotel_details/childs/hotel_booking/childs/checkout/view/widgets/checkout_booking_details_widget.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';
import 'package:flutter_example/utilities/reusables/status_view.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/horizontal_property_card.dart';

@RoutePage()
class CheckoutView extends StatelessWidget implements AutoRouteWrapper {
  final BookingModel booking;
  final bool isViewing;

  const CheckoutView({
    super.key,
    required this.booking,
    this.isViewing = false,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CheckoutBloc>(param1: booking)
        ..add(const CheckoutEvent.started()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (previous, current) => previous.success != current.success,
      listener: (context, state) {
        if (state.success) {
          StatusBottomSheet.show(
            context,
            status: Status.success,
            title: context.localization.checkout_booking_complete,
            message: context.localization.checkout_booking_complete_subtitle,
            buttonText: context.localization.commonDone,
            customImageUrl: context.imageConstants.checkoutSuccess,
            action: () {
              context.router.popUntilRoot();
            },
          );
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.colors.gray0,
            appBar: CheckoutAppBar(isViewing: isViewing),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.scaleValue(24)),
                    Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: context.scaleValue(24)),
                        child: HorizontalPropertyCard(
                          property: booking.hotel,
                          cardType: HorizontalPropertyCardType.view,
                        )),
                    SizedBox(height: context.scaleValue(24)),
                    CheckoutBookingDetailsWidget(booking: booking),
                    SizedBox(height: context.scaleValue(24)),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: isViewing
                ? null
                : SafeArea(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: context.scaleValue(24),
                        end: context.scaleValue(24),
                        bottom: context.scaleValue(40),
                      ),
                      child: AppButtonStyles.primaryPlatform(
                        context: context,
                        title: context.localization.checkout_confirm_booking,
                        isDisabled: state.viewState == ViewState.loading,
                        onPressed: () {
                          context
                              .read<CheckoutBloc>()
                              .add(const CheckoutEvent.confirmPressed());
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
