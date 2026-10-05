part of 'search_bloc.dart';

@freezed
class SearchEvent with _$SearchEvent {
  const factory SearchEvent.started() = _Started;
  const factory SearchEvent.requestSearch(
      {@Default(AtPage.first) AtPage page}) = _RequestSearch;
  const factory SearchEvent.searchResponse(Result<Hotels?, APIError> result) =
      _SearchResponse;
  const factory SearchEvent.didTapToggleFavorite(Hotel hotel) =
      _DidTapToggleFavorite;
  const factory SearchEvent.filterViewToggled(bool show) = _FilterViewToggled;
  const factory SearchEvent.filterIsDismissed(FilterHotelsRequest? request) =
      _FilterIsDismissed;
  const factory SearchEvent.queryChanged(String query) = _QueryChanged;
  const factory SearchEvent.clearSearch() = _ClearSearch;
}
