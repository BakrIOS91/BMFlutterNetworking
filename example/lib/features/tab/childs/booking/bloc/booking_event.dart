part of 'booking_bloc.dart';

@freezed
abstract class BookingEvent with _$BookingEvent {
  const factory BookingEvent.started() = _Started;
  const factory BookingEvent.queryChanged(String query) = _QueryChanged;
  const factory BookingEvent.clearSearch() = _ClearSearch;
  const factory BookingEvent.deleteBooking(BookingModel booking) = _DeleteBooking;
}
