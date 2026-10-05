part of 'hotel_details_bloc.dart';

@freezed
abstract class HotelDetailsState with _$HotelDetailsState {
  const factory HotelDetailsState({
    required Hotel hotel,
    @Default(ViewState.loaded) ViewState viewState,
    @Default(false) bool isCollapsed,
    @Default(false) bool isDescriptionExpanded,
    @Default(null) NavigationType? navigationTo,
    String? pinAddress,
  }) = _HotelDetailsState;
  factory HotelDetailsState.initial(Hotel hotel) => HotelDetailsState(
        hotel: hotel,
      );
}

enum NavigationType { facilities, login, booking }
