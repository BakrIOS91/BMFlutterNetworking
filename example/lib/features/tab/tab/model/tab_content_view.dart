import 'package:flutter/material.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/tab/childs/booking/view/booking_view.dart';
import 'package:flutter_example/utilities/constants/app_icons.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/features/tab/childs/home/view/home_view.dart';
import 'package:flutter_example/features/tab/childs/setting/view/settings_view.dart';
import 'package:flutter_example/utilities/reusables/app_icon.dart';

sealed class TabContentView {
  Widget get tabIcon;
  Widget get activeTabIcon;
  String tabTitle(BuildContext context);
  Widget get tabView;

  static final home = HomeTabView();
  static final booking = BookingTabView();
  static final profile = ProfileTabView();

  static final allTabs = [home, booking, profile];
}

final class HomeTabView extends TabContentView {
  @override
  Widget get tabIcon => const AppIcon(asset: AppIcons.home);

  @override
  Widget get activeTabIcon => const AppIcon(asset: AppIcons.homeSelected);

  @override
  String tabTitle(BuildContext context) => context.localization.tab_home_title;

  @override
  Widget get tabView => HomeView(
        pref: getIt<AppPreferences>(),
      );
}

final class BookingTabView extends TabContentView {
  @override
  Widget get tabIcon => const AppIcon(asset: AppIcons.booking);

  @override
  Widget get activeTabIcon => const AppIcon(asset: AppIcons.bookingSelected);

  @override
  String tabTitle(BuildContext context) =>
      context.localization.tab_booking_title;

  @override
  Widget get tabView => BookingView();
}

final class ProfileTabView extends TabContentView {
  @override
  Widget get tabIcon => const AppIcon(asset: AppIcons.profile);

  @override
  Widget get activeTabIcon => const AppIcon(asset: AppIcons.profileSelected);

  @override
  String tabTitle(BuildContext context) =>
      context.localization.tab_profile_title;

  @override
  Widget get tabView => const SettingsView();
}
