part of 'hotel_booking_bloc.dart';

@freezed
class HotelBookingEvent with _$HotelBookingEvent {
  const factory HotelBookingEvent.started() = _Started;
  const factory HotelBookingEvent.checkInSelected(DateTime date) = _CheckInSelected;
  const factory HotelBookingEvent.checkOutSelected(DateTime date) = _CheckOutSelected;
  const factory HotelBookingEvent.guestIncremented() = _GuestIncremented;
  const factory HotelBookingEvent.guestDecremented() = _GuestDecremented;
}
