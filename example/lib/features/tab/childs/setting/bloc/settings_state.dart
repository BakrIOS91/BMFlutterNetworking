part of 'settings_bloc.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(ThemeMode.system) ThemeMode theme,
    @Default(false) bool isLoggedIn,
    @Default('') String name,
    @Default('') String email,
    @Default(false) bool showLanguagePicker,
    @Default('') String avatarUrl,
    @Default('en') String currentLanguage,
  }) = _SettingsState;
  factory SettingsState.initial() => const SettingsState();
}
