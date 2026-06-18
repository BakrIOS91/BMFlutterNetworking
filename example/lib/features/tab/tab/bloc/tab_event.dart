part of 'tab_bloc.dart';

@freezed
class TabEvent with _$TabEvent {
  const factory TabEvent.started() = _Started;
  const factory TabEvent.tabChanged(int indx) = _TabChanged;
}
