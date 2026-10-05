import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/theme/app_text_styles.dart';
import 'package:flutter_example/features/tab/childs/booking/bloc/booking_bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/features/tab/childs/home/bloc/home_bloc.dart';
import 'package:flutter_example/features/tab/childs/setting/bloc/settings_bloc.dart';
import 'package:flutter_example/features/tab/tab/bloc/tab_bloc.dart';
import 'package:flutter_example/features/tab/tab/model/tab_content_view.dart';
import 'package:bm_flutter/core.dart';
import 'package:auto_route/auto_route.dart';

part 'widgets.dart';

@RoutePage()
class TabView extends StatefulWidget implements AutoRouteWrapper {
  final AppPreferences _pref;
  const TabView({super.key, required AppPreferences pref}) : _pref = pref;

  @override
  State<TabView> createState() => _TabViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TabBloc>()),
        BlocProvider(
            create: (_) => getIt<HomeBloc>()..add(const HomeEvent.started())),
        BlocProvider(
            create: (_) =>
                getIt<BookingBloc>()..add(const BookingEvent.started())),
        BlocProvider(
            create: (_) => getIt<SettingsBloc>()..add(SettingsEvent.started())),
      ],
      child: this,
    );
  }
}

class _TabViewState extends State<TabView> {
  final controller = CupertinoTabController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        PreferencesListener(
          listenTo: widget._pref.selectedTabNotifier,
          listener: (context, tab) {
            final index = TabContentView.allTabs.indexOf(tab);
            if (index != -1) {
              context.read<TabBloc>().add(TabEvent.tabChanged(index));
            }
          },
        ),
        PreferencesListener(
          listenTo: widget._pref.loggedInNotifier,
          listener: (context, isLoggedIn) {
            if (!isLoggedIn) {
              context.read<HomeBloc>().add(const HomeEvent.logout());
            } else {
              context.read<SettingsBloc>().add(const SettingsEvent.started());
              context.read<HomeBloc>().add(const HomeEvent.started());
            }
          },
        ),
        BlocListener<TabBloc, TabState>(
          listenWhen: (previous, current) =>
              previous.currentSelectTabIndex != current.currentSelectTabIndex,
          listener: (context, state) {
            if (controller.index != state.currentSelectTabIndex) {
              controller.index = state.currentSelectTabIndex;
            }

            // Refresh booking list when navigating to the booking tab
            if (state.currentSelectTabIndex == 1) {
              context.read<BookingBloc>().add(const BookingEvent.started());
            }
          },
        ),
      ],
      child: BlocBuilder<TabBloc, TabState>(
        builder: (context, state) {
          return AdaptiveTabBottomView(
            cupertinoTabController: controller,
          );
        },
      ),
    );
  }
}
