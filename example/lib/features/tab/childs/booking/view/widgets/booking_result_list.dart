import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/features/tab/childs/booking/bloc/booking_bloc.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/horizontal_property_card/horizontal_property_card.dart';
import 'package:flutter_example/utilities/reusables/status_view.dart';

class BookingResultList extends StatelessWidget {
  final BookingState state;
  const BookingResultList({
    required this.state,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsetsDirectional.symmetric(
          horizontal: context.scaleValue(24)),
      itemCount: state.filteredBookings.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.scaleValue(16)),
      itemBuilder: (context, index) {
        final booking = state.filteredBookings[index];
        return Dismissible(
          key: ValueKey(booking.id),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            bool result = false;
            await showDialog(
              context: context,
              builder: (context) => StatusAlertDialog(
                status: Status.warning,
                title: context
                    .localization.booking_delete_confirmation_title,
                message: context
                    .localization.booking_delete_confirmation_message,
                buttonText: context.localization.common_delete,
                cancelButtonText: context.localization.commonCancel,
                isDistructive: true,
                action: () {
                  result = true;
                },
              ),
            );
            return result;
          },
          onDismissed: (direction) {
            context
                .read<BookingBloc>()
                .add(BookingEvent.deleteBooking(booking));
          },
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            padding: EdgeInsetsDirectional.only(
                end: context.scaleValue(20)),
            decoration: BoxDecoration(
              color: context.colors.alertError100,
              borderRadius:
                  BorderRadius.circular(context.scaleValue(16)),
            ),
            child: Icon(
              Icons.delete_outline,
              color: context.colors.white,
              size: context.scaleValue(28),
            ),
          ),
          child: HorizontalPropertyCard(
            booking: booking,
            cardType: HorizontalPropertyCardType.booking,
            onTap: () async {
              await context.router.push(
                CheckoutRoute(
                  booking: booking,
                  isViewing: true,
                ),
              );

              if (context.mounted) {
                context
                    .read<BookingBloc>()
                    .add(const BookingEvent.started());
              }
            },
          ),
        );
      },
    );
  }
}
