import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/utilities/l10n/app_localizations.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/router/app_router.dart';
import 'package:flutter_example/core/theme/theme_factory.dart';
import 'package:flutter_example/features/main_app/bloc/main_app_bloc.dart';
import 'package:flutter_example/utilities/l10n/app_language_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';

class MainAppView extends StatelessWidget {
  final AppLanguageManager _lang;
  final AppRouter _router;
  final ThemeFactory _themeFactory;
  final AppPreferences _pref;

  const MainAppView({
    super.key,
    required AppLanguageManager lang,
    required AppRouter router,
    required ThemeFactory themeFactory,
    required AppPreferences pref,
  })  : _pref = pref,
        _themeFactory = themeFactory,
        _lang = lang,
        _router = router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MainAppBloc>(),
      child: MultiBlocListener(
        listeners: [
          PreferencesListener(
            listenTo: _pref.themeNotifier,
            listener: (context, theme) {
              context.read<MainAppBloc>().add(const MainAppEvent.started());
            },
          ),
          PreferencesListener(
            listenTo: _pref.currentLanguageNotifier,
            listener: (context, theme) {
              _router.replaceAll([SplashRoute()]);
            },
          ),
        ],
        child: BlocBuilder<MainAppBloc, MainAppState>(
          builder: (context, state) {
            return ValueListenableBuilder<String>(
              valueListenable: _pref.currentLanguageNotifier,
              builder: (context, langCode, _) {
                return MaterialApp.router(
                  routerConfig: _router.config(),
                  debugShowCheckedModeBanner: false,
                  theme: _themeFactory.light(context),
                  darkTheme: _themeFactory.dark(context),
                  themeMode: state.mode,
                  supportedLocales: _lang.supportedLocales,
                  locale: Locale(langCode),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: (locale, supportedLocales) {
                    return _lang.resolve(locale);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
