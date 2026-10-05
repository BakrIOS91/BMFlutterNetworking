import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocationManager {
  Future<String?> getCurrentLocationString() async {
    try {
      if (!await checkServiceEnabled()) return null;
      if (!await checkAndRequestPermission()) return null;

      final position = await getCurrentPosition();
      final place = await getPlacemark(position);

      if (place == null) return null;

      return "${place.locality}, ${place.administrativeArea}";
    } catch (e, st) {
      debugPrint("LocationManager error: $e\n$st");
      return null;
    }
  }

  Future<bool> checkServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark?> getPlacemark(Position position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    return placemarks.isNotEmpty ? placemarks.first : null;
  }
}
