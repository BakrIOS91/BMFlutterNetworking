part of 'splash_bloc.dart';

@freezed
abstract class SplashState with _$SplashState {
  const factory SplashState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(SplashNavigation.none) SplashNavigation navigation,
  }) = _SplashState;

  factory SplashState.initial() => const SplashState(
    viewState: ViewState.loaded,
    navigation: SplashNavigation.none,
  );
}

enum SplashNavigation {
  none,
  onboarding,
  tab,
}
