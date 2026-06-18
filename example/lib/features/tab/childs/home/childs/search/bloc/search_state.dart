part of 'search_bloc.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(false) bool isLoggedIn,
    @Default([]) List<Hotel> searchResults,
    @Default(1) int pageIndex,
    @Default(false) bool shouldPaginate,
    @Default(false) bool isPaginating,
    @Default("") String query,
    @Default(null) FilterHotelsRequest? lastFilterRequest,
    @Default(false) bool showFilerView,
  }) = _SearchState;

  factory SearchState.initial() => const SearchState();
}
