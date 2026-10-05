part of 'facilities_list_bloc.dart';

@freezed
class FacilitiesListEvent with _$FacilitiesListEvent {
  const factory FacilitiesListEvent.started() = _Started;
  const factory FacilitiesListEvent.toggleExpansion(int index) =
      _ToggleExpansion;
}
