part of 'tab_bloc.dart';

@freezed
abstract class TabState with _$TabState {
  const factory TabState({
    @Default(0) int currentSelectTabIndex,
  }) = _TabState;
  factory TabState.initial() => TabState();
}
