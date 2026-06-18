import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';

@singleton
class AppLanguageManager extends LanguageManager {
  @override
  List<SupportedLocale> get supported => [
        SupportedLocale.en,
        SupportedLocale.ar,
      ];

  @override
  SupportedLocale get fallback => SupportedLocale.en;
}
