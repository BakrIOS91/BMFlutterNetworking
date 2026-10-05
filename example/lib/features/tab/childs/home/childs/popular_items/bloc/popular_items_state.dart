part of 'popular_items_bloc.dart';

@freezed
abstract class PopularItemsState with _$PopularItemsState {
  const factory PopularItemsState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default([]) List<Hotel> items,
    @Default('') String currentLanguage,
    @Default(false) bool isLoggedIn,
    @Default(1) int pageIndex,
    @Default(false) bool shouldPaginate,
    @Default(false) bool isPaginating,
  }) = _PopularItemsState;

  factory PopularItemsState.initial() => const PopularItemsState();
}
