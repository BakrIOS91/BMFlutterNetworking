import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/storage_services/models/booking.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'hotel_booking_bloc.freezed.dart';
part 'hotel_booking_event.dart';
part 'hotel_booking_state.dart';

@injectable
class HotelBookingBloc extends Bloc<HotelBookingEvent, HotelBookingState> {
  HotelBookingBloc(@factoryParam Hotel hotel)
      : super(HotelBookingState.initial(hotel)) {
    on<_Started>(_onStarted);
    on<_CheckInSelected>(_onCheckInSelected);
    on<_CheckOutSelected>(_onCheckOutSelected);
    on<_GuestIncremented>(_onGuestIncremented);
    on<_GuestDecremented>(_onGuestDecremented);
  }

  void _onStarted(
    _Started event,
    Emitter<HotelBookingState> emit,
  ) {
    _recalculatePayment(emit);
  }

  void _onCheckInSelected(
    _CheckInSelected event,
    Emitter<HotelBookingState> emit,
  ) {
    final newCheckIn = event.date;
    DateTime? newCheckOut = state.checkOut;
    if (newCheckOut.isBefore(newCheckIn)) {
      newCheckOut = newCheckIn.add(const Duration(days: 1));
    }
    emit(state.copyWith(checkIn: newCheckIn, checkOut: newCheckOut));
    _recalculatePayment(emit);
  }

  void _onCheckOutSelected(
    _CheckOutSelected event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(checkOut: event.date));
    _recalculatePayment(emit);
  }

  void _onGuestIncremented(
    _GuestIncremented event,
    Emitter<HotelBookingState> emit,
  ) {
    if (state.guestCount >= HotelBookingState.maxGuests) return;
    emit(state.copyWith(guestCount: state.guestCount + 1));
    _recalculatePayment(emit);
  }

  void _onGuestDecremented(
    _GuestDecremented event,
    Emitter<HotelBookingState> emit,
  ) {
    if (state.guestCount > 1) {
      emit(state.copyWith(guestCount: state.guestCount - 1));
      _recalculatePayment(emit);
    }
  }

  /// Recalculates all fee fields from current state.
  /// No-ops when dates have not yet been selected.
  void _recalculatePayment(Emitter<HotelBookingState> emit) {
    final int diff = state.checkOut.difference(state.checkIn).inDays;
    final int nightCount = diff > 0 ? diff : 1;
    final double pricePerNight = state.hotel.pricePerNight?.toDouble() ?? 0;
    final double totalNightsPrice =
        nightCount * pricePerNight * state.guestCount;

    final double cleaningFee =
        double.parse((totalNightsPrice * 0.0125).toStringAsFixed(2));
    final double serviceFee =
        double.parse((totalNightsPrice * 0.0125).toStringAsFixed(2));

    emit(
      state.copyWith(
        nightCount: nightCount,
        paymentDetails: BookingModel(
          id: const Uuid().v4(),
          hotel: state.hotel,
          totalNightsPrice: totalNightsPrice,
          cleaningFee: cleaningFee,
          serviceFee: serviceFee,
          checkIn: state.checkIn,
          checkOut: state.checkOut,
          guestCount: state.guestCount,
        ),
      ),
    );
  }
}
