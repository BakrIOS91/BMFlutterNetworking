import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_example/features/tab/tab/model/tab_content_view.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';

part 'app_preferences.pref.g.dart';

@singleton
@GeneratePreferences()
class AppPreferences extends BasePreferences with _$AppPreferences {
  @factoryMethod
  @preResolve
  static Future<AppPreferences> create() async {
    final instance = AppPreferences();
    await instance.init();
    if (instance.isFreshInstalled) {
      await reset(instance);
    }
    return instance;
  }

  @override
  @InApp()
  late final TabContentView _selectedTab = TabContentView.home;

  @override
  @InApp()
  late final Lookup? _lookups = null;


  @override
  @UserDefault('kAppLanguage')
  late final String _currentLanguage = 'en';

  @override
  @UserDefault('kAppTheme')
  late final ThemeMode _theme = ThemeMode.system;

  @override
  @UserDefault('kAppIsFreshInstalled')
  late final bool _isFreshInstalled = true;

  @override
  @UserDefault('kAppNotificationGranted')
  late final bool _notificationGranted = false;

  @override
  @UserDefault('kAppLoggedIn')
  late final bool _loggedIn = false;

  @override
  @Secure('kAppFCMToken')
  late final String? _fcmToken = null;

  @override
  @Secure('kAppLoginCred')
  late final LoginRequest? _loginCred = null;

  @override
  @Secure('kAppUAToken')
  late final Login? _userAccessTokens = null;

  @override
  @Secure('kAppProfile')
  late final Profile? _userProfile = null;

  static Future<void> reset(AppPreferences prefs) async {
    prefs.fcmToken = null;
    prefs.loginCred = null;
    prefs.userAccessTokens = null;
    prefs.notificationGranted = false;
  }
}
