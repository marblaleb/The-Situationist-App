import 'package:geolocator/geolocator.dart';

class LocationService {
  static const defaultLat = 40.4168;
  static const defaultLng = -3.7038;

  Future<(double lat, double lng)> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return (defaultLat, defaultLng);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return (defaultLat, defaultLng);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return (defaultLat, defaultLng);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return (defaultLat, defaultLng);
    }
  }

  Stream<(double lat, double lng)> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).map((p) => (p.latitude, p.longitude));
  }
}
