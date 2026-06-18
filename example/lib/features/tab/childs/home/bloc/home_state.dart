part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(ViewState.loading) ViewState viewState,
    @Default(ViewState.loaded) ViewState popularViewState,
    @Default(ViewState.loaded) ViewState recommendedViewState,
    @Default(true) bool isInitializing,
    @Default(false) bool isLoggedIn,
    @Default('') String name,
    @Default('') String location,
    @Default('') String avatarUrl,
    @Default(0) int selectedCategoryIndex,
    @Default([]) List<lookups.Category> categories,
    @Default([]) List<Hotel> popularProperties,
    @Default([]) List<Hotel> recommendedProperties,
    @Default(1) int recommendedPageIndex,
    @Default(false) bool recommendedShouldPaginate,
    @Default(false) bool isRecommendedPaginating,
    @Default(false) bool shouldPaginate,
  }) = _HomeState;

  factory HomeState.initial() => const HomeState();
}
