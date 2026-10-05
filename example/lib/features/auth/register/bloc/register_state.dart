part of 'register_bloc.dart';

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default("") String fullName,
    @Default(false) bool fullNameIsError,
    @Default("") String email,
    @Default(EmailErrorType.none) EmailErrorType emailErrorType,
    @Default("") String password,
    @Default(false) bool passwordIsError,
    @Default(false) bool passwordVisible,
    @Default(false) bool successSignedUp,
    @Default(RegisterNavigation.none) RegisterNavigation navigation,
  }) = _RegisterState;
  factory RegisterState.initial() => const RegisterState();
}

enum RegisterNavigation {
  none,
  login,
  tab,
}
