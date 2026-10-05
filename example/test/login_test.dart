import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/features/auth/login/bloc/login_bloc.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/core/router/app_router.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

class MockAuthClient extends Mock implements AuthClient {}

class MockAppRouter extends Mock implements AppRouter {}

void main() {
  final getIt = GetIt.instance;

  late MockAppPreferences mockPrefs;
  late MockAuthClient mockAuth;
  late MockAppRouter mockRouter;

  setUpAll(() {
    mockPrefs = MockAppPreferences();
    registerFallbackValue(LoginRequest());
    registerFallbackValue(Login());
    registerFallbackValue(TabRoute(pref: mockPrefs));
  });

  setUp(() {
    mockPrefs = MockAppPreferences();
    mockAuth = MockAuthClient();
    mockRouter = MockAppRouter();

    getIt.registerSingleton<AppPreferences>(mockPrefs);
    getIt.registerSingleton<AuthClient>(mockAuth);
    getIt.registerSingleton<AppRouter>(mockRouter);

    // Default stubs
    when(() => mockPrefs.loginCred).thenReturn(null);
    when(() => mockAuth.login(any()))
        .thenAnswer((_) async => Success<Login?, APIError>(Login.mock));
    when(() => mockAuth.getProfile()).thenAnswer(
        (_) async => Success<Profile?, APIError>(Profile(fullName: 'User')));
    when(() => mockRouter.replace(any())).thenAnswer((_) async => null);
  });

  tearDown(() {
    getIt.reset();
  });

  group('LoginBloc', () {
    group('Initialization (Started Event)', () {
      blocTest<LoginBloc, LoginState>(
        'sets empty username and password when no credentials in prefs',
        build: () {
          when(() => mockPrefs.loginCred).thenReturn(null);
          return LoginBloc(mockPrefs, mockAuth);
        },
        act: (bloc) => bloc.add(const LoginEvent.started()),
        expect: () => [
          LoginState.initial().copyWith(username: "", password: ""),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'sets username and password from prefs when they exist',
        build: () {
          when(() => mockPrefs.loginCred).thenReturn(
              LoginRequest(email: 'user@example.com', password: 'pass'));
          return LoginBloc(mockPrefs, mockAuth);
        },
        act: (bloc) => bloc.add(const LoginEvent.started()),
        expect: () => [
          LoginState.initial()
              .copyWith(username: 'user@example.com', password: 'pass'),
        ],
      );
    });

    group('Input Changes', () {
      blocTest<LoginBloc, LoginState>(
        'usernameChanged updates username and clears error',
        build: () => LoginBloc(mockPrefs, mockAuth),
        seed: () =>
            LoginState.initial().copyWith(emailErrorType: EmailErrorType.empty),
        act: (bloc) => bloc.add(const LoginEvent.usernameChanged('newUser')),
        expect: () => [
          LoginState.initial().copyWith(
              username: 'newUser', emailErrorType: EmailErrorType.none),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'passwordChanged updates password and clears error',
        build: () => LoginBloc(mockPrefs, mockAuth),
        seed: () => LoginState.initial().copyWith(passwordError: true),
        act: (bloc) => bloc.add(const LoginEvent.passwordChanged('newPass')),
        expect: () => [
          LoginState.initial()
              .copyWith(password: 'newPass', passwordError: false),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'passwordVisibleChanged toggles visibility',
        build: () => LoginBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const LoginEvent.passwordVisibleChanged(true)),
        expect: () => [
          LoginState.initial().copyWith(passwordVisible: true),
        ],
      );
    });

    group('Validation (didPressLogin)', () {
      blocTest<LoginBloc, LoginState>(
        'emits errors if both username and password empty',
        build: () => LoginBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial().copyWith(
            emailErrorType: EmailErrorType.empty,
            passwordError: true,
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits error if only username is empty',
        build: () => LoginBloc(mockPrefs, mockAuth),
        seed: () => LoginState.initial().copyWith(password: 'somePass'),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial().copyWith(
            emailErrorType: EmailErrorType.empty,
            password: 'somePass',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits error if email format is invalid',
        build: () => LoginBloc(mockPrefs, mockAuth),
        seed: () => LoginState.initial()
            .copyWith(username: "invalid-email", password: "somePassword"),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial().copyWith(
            username: "invalid-email",
            password: "somePassword",
            emailErrorType: EmailErrorType.invalidFormat,
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits error if only password is empty',
        build: () => LoginBloc(mockPrefs, mockAuth),
        seed: () =>
            LoginState.initial().copyWith(username: 'someUser@example.com'),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial()
              .copyWith(passwordError: true, username: 'someUser@example.com'),
        ],
      );
    });

    group('Login API Interaction', () {
      blocTest<LoginBloc, LoginState>(
        'calls AuthClient and updates state on success',
        build: () => LoginBloc(mockPrefs, mockAuth),
        seed: () => LoginState.initial()
            .copyWith(username: 'user@example.com', password: 'pass'),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial().copyWith(
            username: 'user@example.com',
            password: 'pass',
            viewState: ViewState.loading,
            emailErrorType: EmailErrorType.none,
            passwordError: false,
          ),
          LoginState.initial().copyWith(
            username: 'user@example.com',
            password: 'pass',
            viewState: ViewState.loaded,
            navigation: LoginNavigation.tab,
          ),
        ],
        verify: (_) {
          verify(() => mockAuth.login(any())).called(1);
          verify(() => mockAuth.getProfile()).called(1);
          verify(() => mockPrefs.loginCred = any()).called(1);
          verify(() => mockPrefs.userAccessTokens = any()).called(1);
          verify(() => mockPrefs.userProfile = any()).called(1);
          verify(() => mockPrefs.loggedIn = true).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits failHandler on API failure',
        build: () {
          when(() => mockAuth.login(any())).thenAnswer(
            (_) async => Failure<Login?, APIError>(
              const APIError(APIErrorType.httpError),
            ),
          );
          return LoginBloc(mockPrefs, mockAuth);
        },
        seed: () => LoginState.initial()
            .copyWith(username: 'user@example.com', password: 'pass'),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial().copyWith(
            username: 'user@example.com',
            password: 'pass',
            viewState: ViewState.loading,
            emailErrorType: EmailErrorType.none,
            passwordError: false,
          ),
          LoginState.initial().copyWith(
            username: 'user@example.com',
            password: 'pass',
            viewState: WithViewState.failHandler(APIError(APIErrorType.httpError)),
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits unexpectedError when login succeeds but response is null',
        build: () {
          when(() => mockAuth.login(any()))
              .thenAnswer((_) async => Success<Login?, APIError>(null));
          return LoginBloc(mockPrefs, mockAuth);
        },
        seed: () => LoginState.initial()
            .copyWith(username: 'user@example.com', password: 'pass'),
        act: (bloc) => bloc.add(const LoginEvent.didPressLogin()),
        expect: () => [
          LoginState.initial().copyWith(
            username: 'user@example.com',
            password: 'pass',
            viewState: ViewState.loading,
          ),
          LoginState.initial().copyWith(
            username: 'user@example.com',
            password: 'pass',
            viewState: ViewState.unexpectedError,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockPrefs.loggedIn = true);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits navigateToRegister when didPressSignUp is added',
        build: () => LoginBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const LoginEvent.didPressSignUp()),
        expect: () => [
          LoginState.initial().copyWith(navigation: LoginNavigation.register),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits navigateToTab when didPressOnContinueAsGuest is added',
        build: () => LoginBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const LoginEvent.didPressOnContinueAsGuest()),
        expect: () => [
          LoginState.initial().copyWith(navigation: LoginNavigation.tab),
        ],
      );
    });
  });
}
