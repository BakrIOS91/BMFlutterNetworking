import 'package:flutter_example/core/env/env.dart';
import 'package:flutter_example/services/authorized.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/services/app_targets.dart';

final class GetPopularHotels extends ModelTargetType<Hotels?> with Authorized {
  final PopularHotelsRequest request;
  GetPopularHotels({required this.request}) : super(decoder: Hotels.fromJson);

  @override
  String get baseURL => AppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  Map<String, String> get headers => {"apiKey": Env.apiKey};

  @override
  RequestTask get requestTask => RequestTask.parameters(
        {
          "lang": request.lang,
          "page_index": request.pageIndex,
          "page_size": request.pageSize,
        },
      );
  @override
  String get requestPath => "rpc/get_popular_hotels";
}

final class FilterHotelsBy extends ModelTargetType<Hotels?> with Authorized {
  final FilterHotelsRequest request;

  FilterHotelsBy(this.request) : super(decoder: Hotels.fromJson);

  @override
  String get baseURL => AppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => "rpc/filter_hotels_by";

  @override
  Map<String, String> get headers => {
        "apikey": Env.apiKey,
      };

  @override
  RequestTask get requestTask => RequestTask.encodedBody(request);
}

final class ToggleFavoriteHotel extends SuccessTargetType with Authorized {
  final String hotelId;

  ToggleFavoriteHotel({required this.hotelId});

  @override
  String get baseURL => AppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  Map<String, String> get headers => {
        "apiKey": Env.apiKey,
      };

  @override
  RequestTask get requestTask => RequestTask.encodedBody({
        "hotel_id": int.tryParse(hotelId) ?? 0,
      });

  @override
  String get requestPath => "rpc/update_hotel_favorite";
}
