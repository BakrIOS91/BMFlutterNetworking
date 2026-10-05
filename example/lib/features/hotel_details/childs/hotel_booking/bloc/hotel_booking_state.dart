part of 'hotel_booking_bloc.dart';

@freezed
abstract class HotelBookingState with _$HotelBookingState {


  /// Maximum number of guests allowed per booking.
  static const int maxGuests = 10;

  const HotelBookingState._();
  const factory HotelBookingState({
    required Hotel hotel,
    required DateTime checkIn,
    required DateTime checkOut,
    @Default(1) int guestCount,
    @Default(1) int nightCount,
    BookingModel? paymentDetails,
  }) = _HotelBookingState;

  factory HotelBookingState.initial(Hotel hotel) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return HotelBookingState(
      hotel: hotel,
      checkIn: today,
      checkOut: today.add(const Duration(days: 1)),
    );
  }

  bool get canDecrementGuest => guestCount > 1;
}
