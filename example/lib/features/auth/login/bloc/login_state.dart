part of 'login_bloc.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default("") String username,
    @Default("") String password,
    @Default(EmailErrorType.none) EmailErrorType emailErrorType,
    @Default(false) bool passwordError,
    @Default(false) bool passwordVisible,
    @Default(LoginNavigation.none) LoginNavigation navigation,
  }) = _LoginState;

  factory LoginState.initial() => const LoginState();
}

enum LoginNavigation {
  none,
  register,
  tab,
}
