import 'dart:developer';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import "package:flutter_example/core/storage_services/hive_storage_client.dart";
import 'package:flutter_example/features/tab/tab/model/tab_content_view.dart';
import 'package:flutter_example/services/client/common_client.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AppPreferences _pref;
  final CommonClient _commonClient;
  final AuthClient _authClient;
  final HiveStorageClient _storage;

  SettingsBloc(this._pref, this._commonClient, this._authClient, this._storage)
      : super(SettingsState.initial()) {
    on<_Started>(_onStarted);
    on<_RequestProfile>(_onRequestProfile);
    on<_ProfileResponse>(_onProfileResponse);
    on<_DidPressLogOut>(_onDidPressLogOut);
    on<_DidPressOnChangeLanguage>(_onDidPressOnChangeLanguage);
    on<_DidPressOnChangeTheme>(_onDidPressOnChangeTheme);
    on<_FetchLookups>(_onFetchLookups);
    on<_LookupResponse>(_onLookupResponse);
    on<_DidSelectLanguage>(_onDidSelectLanguage);
    on<_ResetLanguagePicker>(_onResetLanguagePicker);
  }

  Future<void> _onStarted(_Started event, Emitter<SettingsState> emit) async {
    final profile = _pref.userProfile;
    emit(state.copyWith(
      theme: _pref.theme,
      isLoggedIn: _pref.loggedIn,
      name: profile?.fullName ?? '',
      email: profile?.email ?? '',
      avatarUrl: profile?.avatarUrl ?? '',
      currentLanguage: _pref.currentLanguage,
    ));
    if (_pref.loggedIn) {
      add(const SettingsEvent.requestProfile());
    }
  }

  Future<void> _onRequestProfile(
      _RequestProfile event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(viewState: ViewState.loading));
    add(SettingsEvent.profileResponse(await _authClient.getProfile()));
  }

  Future<void> _onProfileResponse(
      _ProfileResponse event, Emitter<SettingsState> emit) async {
    event.result.when(
      success: (profile) {
        final name = profile?.fullName ?? '';
        final email = profile?.email ?? '';
        final avatarUrl = profile?.avatarUrl ?? '';
        _pref.userProfile = profile;
        emit(state.copyWith(
            viewState: ViewState.loaded,
            isLoggedIn: _pref.loggedIn,
            name: name,
            email: email,
            avatarUrl: avatarUrl));
      },
      failure: (_) {
        emit(state.copyWith(viewState: ViewState.loaded));
      },
    );
  }

  Future<void> _onDidPressLogOut(
      _DidPressLogOut event, Emitter<SettingsState> emit) async {
    _pref.loggedIn = false;
    _pref.userAccessTokens = null;
    _pref.userProfile = null;
    _pref.selectedTab = TabContentView.home;

    // Clear all persisted local data (bookings, etc.)
    await _storage.clearAll();

    emit(state.copyWith(
      isLoggedIn: false,
      name: '',
      email: '',
      avatarUrl: '',
    ));
  }

  Future<void> _onDidPressOnChangeLanguage(
      _DidPressOnChangeLanguage event, Emitter<SettingsState> emit) async {
    if (Platform.isIOS) {
      // For iOS, we can only open the app's settings page
      AppSettings.openAppSettings(type: AppSettingsType.appLocale);
    } else {
      // For Android, we can open the language settings pop up
      emit(state.copyWith(showLanguagePicker: true));
    }
  }

  Future<void> _onDidSelectLanguage(
      _DidSelectLanguage event, Emitter<SettingsState> emit) async {
    _pref.currentLanguage = event.languageCode;
    emit(state.copyWith(
        currentLanguage: event.languageCode, showLanguagePicker: false));
  }

  Future<void> _onResetLanguagePicker(
      _ResetLanguagePicker event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(showLanguagePicker: false));
  }

  Future<void> _onDidPressOnChangeTheme(
      _DidPressOnChangeTheme event, Emitter<SettingsState> emit) async {
    _pref.theme =
        _pref.theme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(theme: _pref.theme));
  }

  Future<void> _onFetchLookups(
      _FetchLookups event, Emitter<SettingsState> emit) async {
    add(SettingsEvent.lookupResponse(await _commonClient.getLookups()));
  }

  Future<void> _onLookupResponse(
      _LookupResponse event, Emitter<SettingsState> emit) async {
    event.result.when(
      success: (response) {
        if (response != null) {
          _pref.lookups = response;
        }
      },
      failure: (error) {
        log('Lookup failure: $error');
      },
    );
  }
}
