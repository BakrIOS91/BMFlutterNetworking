import 'package:flutter/material.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/core/router/app_router.dart';
import 'package:flutter_example/core/theme/theme_factory.dart';
import 'package:flutter_example/features/main_app/view/main_app_view.dart';
import 'package:flutter_example/services/app_token_refresh_handler.dart';
import 'package:flutter_example/services/models/response_error.dart';
import 'package:flutter_example/utilities/l10n/app_language_manager.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await configureDependencies();

  TokenRefreshRegistry.register(getIt<AppTokenRefreshHandler>());
  FontRegistry.registerFont(FontKey.primary, 'Jost');
  DeviceRegistry.registerReferenceWidth(375);
  APIErrorResponseRegistry.register(ResponseErrorMapper());

  runApp(
    MainAppView(
      lang: getIt<AppLanguageManager>(),
      router: getIt<AppRouter>(),
      pref: getIt<AppPreferences>(),
      themeFactory: getIt<ThemeFactory>(),
    ),
  );
}
