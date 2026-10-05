import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/env/env.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:flutter_example/utilities/helpers/validation_helper.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

@Injectable()
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AppPreferences _pref;
  final AuthClient _authClient;
  LoginBloc(
    this._pref,
    this._authClient,
  ) : super(LoginState.initial()) {
    on<LoginEvent>(_onEvent);
  }

  Future<void> _onEvent(
    LoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    event.when(started: () async {
      emit(
        state.copyWith(
          username: _pref.loginCred?.email ?? Env.testEmail,
          password: _pref.loginCred?.password ?? Env.testPassword,
        ),
      );
    }, didPressLogin: () async {
      EmailErrorType emailErrorType = EmailErrorType.none;
      if (state.username.isEmpty) {
        emailErrorType = EmailErrorType.empty;
      } else if (!ValidationHelper.isValidEmail(state.username)) {
        emailErrorType = EmailErrorType.invalidFormat;
      }

      final passwordError = state.password.isEmpty ? true : false;

      if (emailErrorType.isError || passwordError) {
        emit(state.copyWith(
          emailErrorType: emailErrorType,
          passwordError: passwordError,
        ));
        return;
      }

      emit(
        state.copyWith(
          viewState: ViewState.loading,
          emailErrorType: EmailErrorType.none,
          passwordError: false,
        ),
      );

      add(
        LoginEvent.loginResponse(
          await _authClient.login(
            LoginRequest(
              email: state.username,
              password: state.password,
            ),
          ),
        ),
      );
    }, loginResponse: (result) async {
      result.when(
        success: (response) {
          if (response != null) {
            _pref.loginCred = LoginRequest(
              email: state.username,
              password: state.password,
            );
            _pref.userAccessTokens = response;
            _pref.loggedIn = true;
            add(const LoginEvent.getProfile());
          } else {
            emit(state.copyWith(viewState: ViewState.unexpectedError));
          }
        },
        failure: (error) {
          emit(state.copyWith(viewState: WithViewState.failHandler(error)));
        },
      );
    }, usernameChanged: (username) {
      emit(state.copyWith(
        username: username,
        emailErrorType: EmailErrorType.none,
      ));
    }, passwordChanged: (password) {
      emit(state.copyWith(
        password: password,
        passwordError: false,
      ));
    }, passwordVisibleChanged: (visible) {
      emit(state.copyWith(passwordVisible: visible));
    }, didPressSignUp: () {
      emit(state.copyWith(navigation: LoginNavigation.register));
    }, didPressOnContinueAsGuest: () {
      emit(state.copyWith(navigation: LoginNavigation.tab));
    }, getProfile: () async {
      add(
        LoginEvent.getProfileResponse(
          await _authClient.getProfile(),
        ),
      );
    }, getProfileResponse: (result) async {
      result.when(
        success: (response) {
          if (response != null) {
            _pref.userProfile = response;
            emit(state.copyWith(
              viewState: ViewState.loaded,
              navigation: LoginNavigation.tab,
            ));
          } else {
            emit(state.copyWith(viewState: ViewState.unexpectedError));
          }
        },
        failure: (error) {
          emit(state.copyWith(viewState: WithViewState.failHandler(error)));
        },
      );
    });
  }
}
