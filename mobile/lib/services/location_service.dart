import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationService {
  Future<bool> checkLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await checkLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location service is disabled.');
      }

      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10, // Only update if moved 10 meters
          ),
        );
        return position;
      }
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
    return null;
  }

  // Calculate distance between two coordinates (Haversine formula)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Radius in meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  // Check if position is within geofence
  Map<String, dynamic> isWithinGeofence(
    double userLat,
    double userLon,
    double projectLat,
    double projectLon,
    int radiusMeters,
  ) {
    final distance = calculateDistance(userLat, userLon, projectLat, projectLon);
    return {
      'is_within': distance <= radiusMeters,
      'distance': distance.toStringAsFixed(2),
    };
  }
}
