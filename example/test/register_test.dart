import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/features/auth/register/bloc/register_bloc.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/core/router/app_router.dart';
import 'package:flutter_example/services/client/auth_client.dart';
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
    registerFallbackValue(LoginRequest(email: '', password: ''));
    registerFallbackValue(UpdateProfileRequest(fullName: ''));
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
    when(() => mockAuth.signUp(any()))
        .thenAnswer((_) async => Success<Login?, APIError>(Login.mock));
    when(() => mockAuth.updateProfile(any())).thenAnswer((_) async =>
        Success<Profile?, APIError>(Profile(fullName: 'John Doe')));
    when(() => mockRouter.replace(any())).thenAnswer((_) async => null);
  });

  tearDown(() {
    if (getIt.isRegistered<AppPreferences>()) {
      getIt.unregister<AppPreferences>();
    }
    if (getIt.isRegistered<AuthClient>()) {
      getIt.unregister<AuthClient>();
    }
    if (getIt.isRegistered<AppRouter>()) {
      getIt.unregister<AppRouter>();
    }
  });

  group('RegisterBloc', () {
    group('Input Changes', () {
      blocTest<RegisterBloc, RegisterState>(
        'fullNameChanged updates fullName',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        act: (bloc) =>
            bloc.add(const RegisterEvent.fullNameChanged('John Doe')),
        expect: () => [
          RegisterState.initial().copyWith(fullName: 'John Doe'),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'emailChanged updates email and clears error',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        seed: () => RegisterState.initial()
            .copyWith(emailErrorType: EmailErrorType.empty),
        act: (bloc) =>
            bloc.add(const RegisterEvent.emailChanged('test@example.com')),
        expect: () => [
          RegisterState.initial().copyWith(
              email: 'test@example.com', emailErrorType: EmailErrorType.none),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'passwordChanged updates password',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const RegisterEvent.passwordChanged('secret')),
        expect: () => [
          RegisterState.initial().copyWith(password: 'secret'),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'passwordVisibleChanged toggles visibility',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        act: (bloc) =>
            bloc.add(const RegisterEvent.passwordVisibleChanged(true)),
        expect: () => [
          RegisterState.initial().copyWith(passwordVisible: true),
        ],
      );
    });

    group('Validation (didPressSignUp)', () {
      blocTest<RegisterBloc, RegisterState>(
        'emits errors if all fields empty',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const RegisterEvent.didPressSignUp()),
        expect: () => [
          RegisterState.initial().copyWith(
            fullNameIsError: true,
            emailErrorType: EmailErrorType.empty,
            passwordIsError: true,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits error if email format is invalid',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        seed: () => RegisterState.initial().copyWith(
          fullName: 'John Doe',
          email: 'invalid-email',
          password: 'password123',
        ),
        act: (bloc) => bloc.add(const RegisterEvent.didPressSignUp()),
        expect: () => [
          RegisterState.initial().copyWith(
            fullName: 'John Doe',
            email: 'invalid-email',
            password: 'password123',
            emailErrorType: EmailErrorType.invalidFormat,
          ),
        ],
      );
    });

    group('Registration Flow', () {
      blocTest<RegisterBloc, RegisterState>(
        'full registration flow: signup -> updateProfile -> success',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        seed: () => RegisterState.initial().copyWith(
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (bloc) => bloc.add(const RegisterEvent.didPressSignUp()),
        expect: () => [
          RegisterState.initial().copyWith(
            fullName: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
            viewState: ViewState.loading,
          ),
          RegisterState.initial().copyWith(
            fullName: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
            viewState: ViewState.loaded,
            successSignedUp: true,
          ),
        ],
        verify: (_) {
          verify(() => mockAuth.signUp(any())).called(1);
          verify(() => mockAuth.updateProfile(any())).called(1);
          verify(() => mockPrefs.loginCred = any()).called(1);
          verify(() => mockPrefs.userAccessTokens = any()).called(1);
          verify(() => mockPrefs.userProfile = any()).called(1);
          verify(() => mockPrefs.loggedIn = true).called(1);
        },
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits failHandler on signUp failure',
        build: () {
          when(() => mockAuth.signUp(any())).thenAnswer(
            (_) async => Failure<Login?, APIError>(
              const APIError(APIErrorType.httpError),
            ),
          );
          return RegisterBloc(mockPrefs, mockAuth);
        },
        seed: () => RegisterState.initial().copyWith(
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (bloc) => bloc.add(const RegisterEvent.didPressSignUp()),
        expect: () => [
          RegisterState.initial().copyWith(
            fullName: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
            viewState: ViewState.loading,
          ),
          RegisterState.initial().copyWith(
            fullName: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
            viewState:
                WithViewState.failHandler(const APIError(APIErrorType.httpError)),
          ),
        ],
      );
    });

    group('Navigation', () {
      blocTest<RegisterBloc, RegisterState>(
        'didPressOnDismiss emits navigation to Tab',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const RegisterEvent.didPressOnDismiss()),
        expect: () => [
          RegisterState.initial().copyWith(
            navigation: RegisterNavigation.tab,
            successSignedUp: false,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'didPressOnSignIn emits navigation to Login',
        build: () => RegisterBloc(mockPrefs, mockAuth),
        act: (bloc) => bloc.add(const RegisterEvent.didPressOnSignIn()),
        expect: () => [
          RegisterState.initial()
              .copyWith(navigation: RegisterNavigation.login),
        ],
      );
    });
  });
}
