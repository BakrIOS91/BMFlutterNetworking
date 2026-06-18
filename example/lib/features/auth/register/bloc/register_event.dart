part of 'register_bloc.dart';

@freezed
class RegisterEvent with _$RegisterEvent {
  const factory RegisterEvent.started() = _Started;
  const factory RegisterEvent.fullNameChanged(String fullName) =
      _fullNameChanged;
  const factory RegisterEvent.emailChanged(String email) = _emailChanged;
  const factory RegisterEvent.passwordChanged(String password) =
      _PasswordChanged;
  const factory RegisterEvent.passwordVisibleChanged(bool visible) =
      _PasswordVisibleChanged;
  const factory RegisterEvent.didPressSignUp() = _DidPressSignUp;
  const factory RegisterEvent.signupResponse(Result<Login?, APIError> result) =
      _SignupResponse;
  const factory RegisterEvent.updateProfile() = _UpdateProfile;
  const factory RegisterEvent.updateProfileResponse(
      Result<Profile?, APIError> result) = _UpdateProfileResponse;
  const factory RegisterEvent.didPressOnSignIn() = _DidPressOnSignIn;
  const factory RegisterEvent.didPressOnDismiss() = _DidPressOnDismiss;
}
