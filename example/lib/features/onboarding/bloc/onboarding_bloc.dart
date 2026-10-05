import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/onboarding/models/page_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';
part 'onboarding_bloc.freezed.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final AppPreferences _pref;

  OnboardingBloc(this._pref) : super(OnboardingState.initial()) {
    on<OnboardingEvent>(_onEvent);
  }

  Future<void> _onEvent(
    OnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    event.when(
        started: () {},
        loadPages: () {
          final pages = PageModelData.onboardingPages;
          emit(state.copyWith(pages: pages, currentPageData: pages.first));
        },
        changePage: (index) {
          emit(
            state.copyWith(
              selectedIndex: index,
              currentPageData: state.pages[index],
            ),
          );
        },
        getStartedPressed: () async {
          _pref.isFreshInstalled = false;
          emit(state.copyWith(navigation: OnboardingNavigation.tab));
        });
  }
}
