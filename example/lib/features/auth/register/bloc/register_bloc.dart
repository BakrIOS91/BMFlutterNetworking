import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/helpers/validation_helper.dart';

part 'register_bloc.freezed.dart';
part 'register_event.dart';
part 'register_state.dart';

@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AppPreferences _pref;
  final AuthClient _authClient;

  RegisterBloc(
    this._pref,
    this._authClient,
  ) : super(RegisterState.initial()) {
    on<RegisterEvent>(_onEvent);
  }

  Future<void> _onEvent(
    RegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    await event.map(
      started: (_) async {},
      fullNameChanged: (event) async {
        emit(state.copyWith(fullName: event.fullName));
      },
      emailChanged: (event) async {
        emit(state.copyWith(
          email: event.email,
          emailErrorType: EmailErrorType.none,
        ));
      },
      passwordChanged: (event) async {
        emit(state.copyWith(password: event.password));
      },
      passwordVisibleChanged: (event) async {
        emit(state.copyWith(passwordVisible: event.visible));
      },
      didPressSignUp: (_) async {
        final fullNameError = state.fullName.isEmpty ? true : false;

        EmailErrorType emailErrorType = EmailErrorType.none;
        if (state.email.isEmpty) {
          emailErrorType = EmailErrorType.empty;
        } else if (!ValidationHelper.isValidEmail(state.email)) {
          emailErrorType = EmailErrorType.invalidFormat;
        }

        final passwordError = state.password.isEmpty ? true : false;

        if (fullNameError || emailErrorType.isError || passwordError) {
          emit(state.copyWith(
            fullNameIsError: fullNameError,
            emailErrorType: emailErrorType,
            passwordIsError: passwordError,
          ));
          return;
        }

        emit(
          state.copyWith(
            viewState: ViewState.loading,
            fullNameIsError: false,
            emailErrorType: EmailErrorType.none,
            passwordIsError: false,
          ),
        );

        add(
          RegisterEvent.signupResponse(
            await _authClient.signUp(
              LoginRequest(
                email: state.email,
                password: state.password,
              ),
            ),
          ),
        );
      },
      signupResponse: (event) async {
        event.result.when(success: (response) {
          if (response != null) {
            _pref.loginCred = LoginRequest(
              email: state.email,
              password: state.password,
            );
            _pref.userAccessTokens = response;
            _pref.loggedIn = true;
            add(const RegisterEvent.updateProfile());
          } else {
            emit(state.copyWith(viewState: ViewState.unexpectedError));
          }
        }, failure: (error) {
          emit(state.copyWith(viewState: WithViewState.failHandler(error)));
        });
      },
      didPressOnSignIn: (_) async {
        emit(state.copyWith(navigation: RegisterNavigation.login));
      },
      updateProfile: (_) async {
        add(
          RegisterEvent.updateProfileResponse(
            await _authClient.updateProfile(
              UpdateProfileRequest(
                fullName: state.fullName,
              ),
            ),
          ),
        );
      },
      updateProfileResponse: (event) async {
        event.result.when(
          success: (response) {
            if (response != null) {
              _pref.userProfile = response;
              emit(state.copyWith(
                  viewState: ViewState.loaded, successSignedUp: true));
            } else {
              emit(state.copyWith(viewState: ViewState.unexpectedError));
            }
          },
          failure: (error) {
            emit(state.copyWith(viewState: WithViewState.failHandler(error)));
          },
        );
      },
      didPressOnDismiss: (_) async {
        emit(state.copyWith(
            navigation: RegisterNavigation.tab, successSignedUp: false));
      },
    );
  }
}
