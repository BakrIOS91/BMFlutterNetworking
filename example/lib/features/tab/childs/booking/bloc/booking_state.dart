part of 'booking_bloc.dart';

@freezed
abstract class BookingState with _$BookingState {
  const BookingState._();

  const factory BookingState.initial({
    @Default([]) List<BookingModel> bookings,
    @Default('') String searchQuery,
    @Default(ViewState.loading) ViewState viewState,
    @Default(ViewState.loading) ViewState resultsViewState,
  }) = _Initial;

  List<BookingModel> get filteredBookings {
    if (searchQuery.isEmpty) return bookings;
    final query = searchQuery.toLowerCase();
    return bookings
        .where((b) => b.hotel.title?.toLowerCase().contains(query) ?? true)
        .toList();
  }
}
