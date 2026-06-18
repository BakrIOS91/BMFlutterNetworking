import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/features/splash/bloc/splash_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/router/app_router.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/services/client/common_client.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

class MockAppRouter extends Mock implements AppRouter {}

class MockCommonClient extends Mock implements CommonClient {}

class MockSecurityCheckResult extends Mock implements SecurityCheckResult {}

class FakeSecureResult extends Fake implements SecurityCheckResult {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;

  late MockAppPreferences mockPrefs;
  late MockAppRouter mockRouter;
  late MockSecurityCheckResult mockSecureResult;
  late MockSecurityCheckResult mockInsecureResult;
  late MockCommonClient mockCommonClient;

  setUpAll(() {
    mockPrefs = MockAppPreferences();
    registerFallbackValue(TabRoute(pref: mockPrefs));
    registerFallbackValue(const LoginRoute());
    registerFallbackValue(FakeSecureResult());
  });

  setUp(() {
    mockPrefs = MockAppPreferences();
    mockRouter = MockAppRouter();
    mockSecureResult = MockSecurityCheckResult();
    mockInsecureResult = MockSecurityCheckResult();
    mockCommonClient = MockCommonClient();

    getIt.registerSingleton<AppPreferences>(mockPrefs);
    getIt.registerSingleton<AppRouter>(mockRouter);

    when(() => mockPrefs.isFreshInstalled).thenReturn(false);
    when(() => mockPrefs.loggedIn).thenReturn(false);
    when(() => mockRouter.replace(any())).thenAnswer((_) async => null);

    when(() => mockSecureResult.isSecure).thenReturn(true);
    when(() => mockSecureResult.reason).thenReturn('');

    when(() => mockInsecureResult.isSecure).thenReturn(false);
    when(() => mockInsecureResult.reason).thenReturn('Device is jailbroken');
  });

  tearDown(() {
    if (getIt.isRegistered<AppPreferences>()) {
      getIt.unregister<AppPreferences>();
    }
    if (getIt.isRegistered<AppRouter>()) {
      getIt.unregister<AppRouter>();
    }
  });

  group('SplashBloc', () {
    group('Jailbreak Response - Secure Device', () {
      blocTest<SplashBloc, SplashState>(
        'emits loaded state with onboarding navigation when fresh installed',
        build: () {
          when(() => mockPrefs.isFreshInstalled).thenReturn(true);
          return SplashBloc(
            pref: mockPrefs,
            commonClient: mockCommonClient,
          );
        },
        act: (bloc) =>
            bloc.add(SplashEvent.jailbreakResponse(mockSecureResult)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          SplashState.initial().copyWith(
            viewState: ViewState.loaded,
            navigation: SplashNavigation.onboarding,
          ),
        ],
      );

      blocTest<SplashBloc, SplashState>(
        'emits loaded state with tab navigation when not fresh installed',
        build: () {
          when(() => mockPrefs.isFreshInstalled).thenReturn(false);
          return SplashBloc(
            pref: mockPrefs,
            commonClient: mockCommonClient,
          );
        },
        act: (bloc) =>
            bloc.add(SplashEvent.jailbreakResponse(mockSecureResult)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          SplashState.initial().copyWith(
            viewState: ViewState.loaded,
            navigation: SplashNavigation.tab,
          ),
        ],
      );
    });

    group('Jailbreak Response - Insecure Device', () {
      blocTest<SplashBloc, SplashState>(
        'emits jailBroken state when device is not secure',
        build: () => SplashBloc(
          pref: mockPrefs,
          commonClient: mockCommonClient,
        ),
        act: (bloc) =>
            bloc.add(SplashEvent.jailbreakResponse(mockInsecureResult)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          SplashState.initial().copyWith(viewState: ViewState.jailBroken),
        ],
      );
    });

    group('Security Check Result Handling', () {
      blocTest<SplashBloc, SplashState>(
        'handles secure result correctly',
        build: () {
          when(() => mockPrefs.isFreshInstalled).thenReturn(false);
          return SplashBloc(
            pref: mockPrefs,
            commonClient: mockCommonClient,
          );
        },
        act: (bloc) =>
            bloc.add(SplashEvent.jailbreakResponse(mockSecureResult)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          SplashState.initial().copyWith(
            viewState: ViewState.loaded,
            navigation: SplashNavigation.tab,
          ),
        ],
      );

      blocTest<SplashBloc, SplashState>(
        'handles insecure result with debug detected',
        build: () {
          when(() => mockInsecureResult.reason).thenReturn('Debugging enabled');
          return SplashBloc(
            pref: mockPrefs,
            commonClient: mockCommonClient,
          );
        },
        act: (bloc) =>
            bloc.add(SplashEvent.jailbreakResponse(mockInsecureResult)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          SplashState.initial().copyWith(viewState: ViewState.jailBroken),
        ],
      );

      blocTest<SplashBloc, SplashState>(
        'handles insecure result with emulator detected',
        build: () {
          when(() => mockInsecureResult.reason).thenReturn('Emulator detected');
          return SplashBloc(
            pref: mockPrefs,
            commonClient: mockCommonClient,
          );
        },
        act: (bloc) =>
            bloc.add(SplashEvent.jailbreakResponse(mockInsecureResult)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          SplashState.initial().copyWith(viewState: ViewState.jailBroken),
        ],
      );
    });

    group('Edge Cases', () {
      blocTest<SplashBloc, SplashState>(
        'handles multiple jailbreak response events with secure result',
        build: () {
          when(() => mockPrefs.isFreshInstalled).thenReturn(false);
          return SplashBloc(
            pref: mockPrefs,
            commonClient: mockCommonClient,
          );
        },
        act: (bloc) async {
          bloc.add(SplashEvent.jailbreakResponse(mockSecureResult));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(SplashEvent.jailbreakResponse(mockSecureResult));
        },
        wait: const Duration(milliseconds: 150),
        expect: () => [
          SplashState.initial().copyWith(
            viewState: ViewState.loaded,
            navigation: SplashNavigation.tab,
          ),
        ],
      );
    });
  });
}
