import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/auth/account-info/bloc/account_info_bloc.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferences extends Mock implements AppPreferences {}

class MockAuthClient extends Mock implements AuthClient {}

void main() {
  late MockAppPreferences mockPrefs;
  late MockAuthClient mockAuthClient;

  setUpAll(() {
    registerFallbackValue(UpdateProfileRequest(fullName: '', phone: ''));
    registerFallbackValue(Profile(fullName: '', email: '', phone: ''));
  });

  setUp(() {
    mockPrefs = MockAppPreferences();
    mockAuthClient = MockAuthClient();
  });

  group('AccountInfoBloc', () {
    final mockProfile = Profile(
        fullName: 'John Doe', email: 'john@example.com', phone: '01012345678');

    test('initial state is correct', () {
      final bloc = AccountInfoBloc(mockPrefs, mockAuthClient);
      // AccountInfoState.initial() uses ViewState.loaded as default
      expect(bloc.state.viewState, equals(ViewState.loaded));
      expect(bloc.state.isEditing, isFalse);
      bloc.close();
    });

    blocTest<AccountInfoBloc, AccountInfoState>(
      'loadData emits loaded state when profile exists',
      build: () {
        when(() => mockPrefs.userProfile).thenReturn(mockProfile);
        return AccountInfoBloc(mockPrefs, mockAuthClient);
      },
      act: (bloc) => bloc.add(const AccountInfoEvent.loadData()),
      expect: () => [
        isA<AccountInfoState>()
            .having((s) => s.viewState, 'viewState', ViewState.loading),
        isA<AccountInfoState>()
            .having((s) => s.viewState, 'viewState', ViewState.loaded)
            .having((s) => s.firstName, 'firstName', 'John')
            .having((s) => s.lastName, 'lastName', 'Doe')
            .having((s) => s.email, 'email', 'john@example.com'),
      ],
    );

    blocTest<AccountInfoBloc, AccountInfoState>(
      'didTapEdit toggles isEditing',
      build: () => AccountInfoBloc(mockPrefs, mockAuthClient),
      act: (bloc) => bloc.add(const AccountInfoEvent.didTapEdit()),
      expect: () => [
        isA<AccountInfoState>().having((s) => s.isEditing, 'isEditing', true),
      ],
    );

    blocTest<AccountInfoBloc, AccountInfoState>(
      'updates firstName and validates it',
      build: () => AccountInfoBloc(mockPrefs, mockAuthClient),
      act: (bloc) => bloc.add(const AccountInfoEvent.firstNameChanged('New')),
      expect: () => [
        isA<AccountInfoState>()
            .having((s) => s.firstName, 'firstName', 'New')
            .having((s) => s.firstNameError, 'firstNameError', false),
      ],
    );

    blocTest<AccountInfoBloc, AccountInfoState>(
      'firstNameChanged marks error if name too short',
      build: () => AccountInfoBloc(mockPrefs, mockAuthClient),
      act: (bloc) => bloc.add(const AccountInfoEvent.firstNameChanged('Ab')),
      expect: () => [
        isA<AccountInfoState>()
            .having((s) => s.firstName, 'firstName', 'Ab')
            .having((s) => s.firstNameError, 'firstNameError', true),
      ],
    );

    blocTest<AccountInfoBloc, AccountInfoState>(
      'didTapSave calls updateProfile and handles success',
      build: () {
        when(() => mockAuthClient.updateProfile(any()))
            .thenAnswer((_) async => Success<Profile?, APIError>(mockProfile));
        when(() => mockPrefs.userProfile = any()).thenReturn(null);
        return AccountInfoBloc(mockPrefs, mockAuthClient);
      },
      seed: () => const AccountInfoState(
        firstName: 'John',
        lastName: 'Doe',
        phone: '01012345678',
      ),
      act: (bloc) => bloc.add(const AccountInfoEvent.didTapSave()),
      expect: () => [
        isA<AccountInfoState>()
            .having((s) => s.viewState, 'viewState', ViewState.loading),
        isA<AccountInfoState>()
            .having((s) => s.viewState, 'viewState', ViewState.loaded)
            .having((s) => s.isEditing, 'isEditing', false),
      ],
      verify: (_) {
        verify(() => mockAuthClient.updateProfile(any())).called(1);
        verify(() => mockPrefs.userProfile = any()).called(1);
      },
    );

    blocTest<AccountInfoBloc, AccountInfoState>(
      'didTapSave emits errors when inputs are invalid',
      build: () => AccountInfoBloc(mockPrefs, mockAuthClient),
      seed: () => const AccountInfoState(
        firstName: 'Jo',
        lastName: 'Do',
        phone: '123',
      ),
      act: (bloc) => bloc.add(const AccountInfoEvent.didTapSave()),
      expect: () => [
        isA<AccountInfoState>()
            .having((s) => s.firstNameError, 'firstNameError', true)
            .having((s) => s.lastNameError, 'lastNameError', true)
            .having((s) => s.phoneError, 'phoneError', true),
      ],
      verify: (_) {
        verifyNever(() => mockAuthClient.updateProfile(any()));
      },
    );
  });
}
