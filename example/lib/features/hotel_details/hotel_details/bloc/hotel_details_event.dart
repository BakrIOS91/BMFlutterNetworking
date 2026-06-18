part of 'hotel_details_bloc.dart';

@freezed
class HotelDetailsEvent with _$HotelDetailsEvent {
  const factory HotelDetailsEvent.started() = _Started;
  const factory HotelDetailsEvent.sheetSizeChanged(double size) =
      _SheetSizeChanged;
  const factory HotelDetailsEvent.toggleFavorite() = _ToggleFavorite;
  const factory HotelDetailsEvent.resetNavigation() = _ResetNavigation;
  const factory HotelDetailsEvent.didPressOnSeeAllFacilities() =
      _DidPressOnSeeAllFacilities;
  const factory HotelDetailsEvent.didPressOnToggleDescription() =
      _DidPressOnToggleDescription;
  const factory HotelDetailsEvent.didPressOnOpenMap() = _DidPressOnOpenMap;
  const factory HotelDetailsEvent.didPressOnBookNow() = _DidPressOnBookNow;
  const factory HotelDetailsEvent.didFetchAddress(double lat, double lon) =
      _DidFetchAddress;
}
