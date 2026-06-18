part of 'account_info_bloc.dart';

@freezed
class AccountInfoEvent with _$AccountInfoEvent {
  const factory AccountInfoEvent.started() = _Started;
  const factory AccountInfoEvent.didTapEdit() = _DidTapEdit;
  const factory AccountInfoEvent.loadData() = _LoadData;
  const factory AccountInfoEvent.didTapSave() = _DidTapSave;
  const factory AccountInfoEvent.updateProfileResponse(
      Result<Profile?, APIError> result) = _UpdateProfileResponse;
  const factory AccountInfoEvent.firstNameChanged(String firstName) =
      _FirstNameChanged;
  const factory AccountInfoEvent.lastNameChanged(String lastName) =
      _LastNameChanged;
  const factory AccountInfoEvent.phoneChanged(String phone) = _PhoneChanged;
  const factory AccountInfoEvent.didTapCancel() = _DidTapCancel;
}
