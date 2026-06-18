import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:flutter_example/features/onboarding/models/page_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

void main() {
  late MockAppPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockAppPreferences();
  });

  group('OnboardingBloc', () {
    test('initial state is correct', () {
      final bloc = OnboardingBloc(mockPrefs);
      expect(bloc.state.selectedIndex, equals(0));
      expect(bloc.state.pages, isEmpty);
      expect(bloc.state.currentPageData, isNull);
      expect(bloc.state.navigation, equals(OnboardingNavigation.none));
      bloc.close();
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'emits pages and first page data when loadPages is added',
      build: () => OnboardingBloc(mockPrefs),
      act: (bloc) => bloc.add(const OnboardingEvent.loadPages()),
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.pages, 'pages', isNotEmpty)
            .having((s) => s.currentPageData, 'currentPageData', isNotNull),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'emits updated selectedIndex and currentPageData when changePage is added',
      build: () => OnboardingBloc(mockPrefs),
      seed: () {
        final pages = PageModelData.onboardingPages;
        return OnboardingState(pages: pages, currentPageData: pages.first);
      },
      act: (bloc) => bloc.add(const OnboardingEvent.changePage(1)),
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.selectedIndex, 'selectedIndex', 1)
            .having((s) => s.currentPageData?.imagePath, 'imagePath',
                PageModelData.onboardingPages[1].imagePath),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'emits navigation to tab and updates preference when getStartedPressed is added',
      build: () {
        return OnboardingBloc(mockPrefs);
      },
      act: (bloc) => bloc.add(const OnboardingEvent.getStartedPressed()),
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.navigation, 'navigation', OnboardingNavigation.tab),
      ],
      verify: (_) {
        verify(() => mockPrefs.isFreshInstalled = false).called(1);
      },
    );
  });
}
