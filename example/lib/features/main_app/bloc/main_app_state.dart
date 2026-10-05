part of 'main_app_bloc.dart';

@freezed
abstract class MainAppState with _$MainAppState {
  const factory MainAppState({
    @Default(ThemeMode.system) ThemeMode mode,
  }) = _MainAppState;
  factory MainAppState.initial() => const MainAppState(
        mode: ThemeMode.system,
      );
}
