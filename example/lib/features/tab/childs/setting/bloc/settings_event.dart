part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.started() = _Started;
  const factory SettingsEvent.requestProfile() = _RequestProfile;
  const factory SettingsEvent.profileResponse(
      Result<Profile?, APIError> result) = _ProfileResponse;
  const factory SettingsEvent.didPressOnChangeLanguage() =
      _DidPressOnChangeLanguage;
  const factory SettingsEvent.didPressOnChangeTheme() = _DidPressOnChangeTheme;
  const factory SettingsEvent.didPressLogOut() = _DidPressLogOut;
  const factory SettingsEvent.fetchLookups() = _FetchLookups;
  const factory SettingsEvent.lookupResponse(Result<Lookup?, APIError> result) =
      _LookupResponse;
  const factory SettingsEvent.didSelectLanguage(String languageCode) =
      _DidSelectLanguage;
  const factory SettingsEvent.resetLanguagePicker() = _ResetLanguagePicker;
}
