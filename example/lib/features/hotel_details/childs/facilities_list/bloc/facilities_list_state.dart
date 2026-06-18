part of 'facilities_list_bloc.dart';

@freezed
abstract class FacilitiesListState with _$FacilitiesListState {
  const factory FacilitiesListState({
    required List<Facility> facilities,
    @Default({}) Set<int> expandedIndices,
  }) = _FacilitiesListState;
  factory FacilitiesListState.initial(List<Facility> facilities) =>
      FacilitiesListState(facilities: facilities);
}
