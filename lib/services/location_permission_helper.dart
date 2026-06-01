/// Location permission helper class for requesting and checking permissions
/// 
/// Usage in any Dart file:
/// ```dart
/// final locationHelper = LocationPermissionHelper();
/// 
/// // Request permission
/// final permission = await locationHelper.requestLocationPermission();
/// 
/// // Check current permission
/// final hasPermission = await locationHelper.checkLocationPermission();
/// 
/// // Get user position
/// try {
///   final position = await locationHelper.getCurrentPosition();
///   print('Lat: ${position.latitude}, Lng: ${position.longitude}');
/// } catch (e) {
///   print('Error: $e');
/// }
/// ```

import 'package:geolocator/geolocator.dart';

class LocationPermissionHelper {
  /// Check if location service is enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from user
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if permission is granted (both while in use or always)
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get user's current position with high accuracy
  /// Throws exception if:
  /// - Location service is disabled
  /// - Permission is denied or permanently denied
  Future<Position> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException(
          'Location services are disabled.',
        );
      }

      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Return error if permission permanently denied
      if (permission == LocationPermission.deniedForever) {
        throw PermissionDeniedException(
          'Location permissions are permanently denied.',
        );
      }

      // Get current position with high accuracy
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      throw PermissionDeniedException('Location permission not granted.');
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's current position with optional accuracy
  Future<Position> getCurrentPositionWithAccuracy({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
    );
  }

  /// Request and get location in one call
  Future<Position?> requestAndGetLocation() async {
    try {
      final permission = await requestLocationPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await getCurrentPosition();
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Open app settings for location permission
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

/// Custom exceptions for location operations
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
