part of 'popular_items_bloc.dart';

@freezed
class PopularItemsEvent with _$PopularItemsEvent {
  const factory PopularItemsEvent.started() = _Started;
  const factory PopularItemsEvent.requestPopularItems(AtPage page) =
      _RequestPopularItems;
  const factory PopularItemsEvent.itemsResponse(
      Result<Hotels?, APIError> result) = _ItemsResponse;
  const factory PopularItemsEvent.didTapToggleFavorite(Hotel hotel) =
      _DidTapToggleFavorite;
}
