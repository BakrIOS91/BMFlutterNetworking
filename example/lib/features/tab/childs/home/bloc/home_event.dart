part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = _Started;
  const factory HomeEvent.refresh() = _Refresh;
  // Popular hotels
  const factory HomeEvent.requestPopularHotels() = _RequestPopularHotels;
  const factory HomeEvent.popularHotelsResponse(
      Result<Hotels?, APIError> result) = _PopularHotelsResponse;
  // Recommended hotels
  const factory HomeEvent.requestRecommendedHotels(
      {@Default(AtPage.first) AtPage page}) = _RequestRecommendedHotels;
  const factory HomeEvent.recommendedHotelsResponse(
      Result<Hotels?, APIError> result) = _RecommendedHotelsResponse;
  // Misc
  const factory HomeEvent.requestToggleFavorite(Hotel hotel) =
      _RequestToggleFavorite;
  const factory HomeEvent.selectCategory(int index) = _SelectCategory;
  const factory HomeEvent.updateUserLocation(String location) =
      _UpdateUserLocation;
  const factory HomeEvent.logout() = _Logout;
  const factory HomeEvent.profileUpdated() = _ProfileUpdated;
}
