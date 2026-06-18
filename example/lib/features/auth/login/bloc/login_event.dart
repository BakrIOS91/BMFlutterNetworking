part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.started() = _Started;
  const factory LoginEvent.didPressLogin() = _DidPressLogin;
  const factory LoginEvent.loginResponse(Result<Login?, APIError> result) =
      _LoginResponse;
  const factory LoginEvent.usernameChanged(String username) = _UsernameChanged;
  const factory LoginEvent.passwordChanged(String password) = _PasswordChanged;
  const factory LoginEvent.passwordVisibleChanged(bool visible) =
      _PasswordVisibleChanged;
  const factory LoginEvent.didPressSignUp() = _DidPressSignUp;
  const factory LoginEvent.didPressOnContinueAsGuest() =
      _DidPressOnContinueAsGuest;
  const factory LoginEvent.getProfile() = _GetProfile;
  const factory LoginEvent.getProfileResponse(Result<Profile?, APIError> result) =
      _GetProfileResponse;
}
