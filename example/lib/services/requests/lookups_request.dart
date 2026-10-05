import 'package:flutter_example/core/env/env.dart';
import 'package:flutter_example/services/app_targets.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

final class GetLookups extends ModelTargetType<Lookup?> {
  String lang;

  GetLookups(this.lang) : super(decoder: Lookup.fromJson);

  @override
  String get baseURL => AppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => "rpc/get_lookups";

  @override
  Map<String, String> get headers => {
        "apiKey": Env.apiKey,
      };

  @override
  RequestTask get requestTask => RequestTask.parameters({
        "lang": lang,
      });
}
