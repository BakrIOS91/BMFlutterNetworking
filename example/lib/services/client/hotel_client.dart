import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/services/requests/hotel_requests.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

@LazySingleton()
class HotelClient {
  Future<Result<Hotels?, APIError>> getPopularHotels(
      PopularHotelsRequest request) {
    return GetPopularHotels(request: request).performResult();
  }

  Future<Result<Hotels?, APIError>> filterHotels(FilterHotelsRequest request) {
    return FilterHotelsBy(request).performResult();
  }

  Future<Result<void, APIError>> toggleFavoriteHotel(String hotelId) {
    return ToggleFavoriteHotel(hotelId: hotelId).performResult();
  }
}
