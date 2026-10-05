part of 'onboarding_bloc.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.started() = _Started;
  const factory OnboardingEvent.loadPages() = _LoadPages;
  const factory OnboardingEvent.changePage(int index) = _ChangePage;
  const factory OnboardingEvent.getStartedPressed() = _GetStartedPressed;
}
