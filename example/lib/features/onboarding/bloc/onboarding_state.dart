part of 'onboarding_bloc.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default([]) List<PageModel> pages,
    @Default(0) int selectedIndex,
    @Default(null) PageModel? currentPageData,
    @Default(OnboardingNavigation.none) OnboardingNavigation navigation,
  }) = _OnboardingState;

  factory OnboardingState.initial() => const OnboardingState(
    navigation: OnboardingNavigation.none,
  );
}

enum OnboardingNavigation {
  none,
  tab,
}
