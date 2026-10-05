import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart';
import 'package:flutter_example/services/requests/lookups_request.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

@LazySingleton()
class CommonClient {
  final AppPreferences _pref;

  CommonClient(this._pref);

  Future<Result<Lookup?, APIError>> getLookups() =>
      GetLookups(_pref.currentLanguage).performResult();
}
