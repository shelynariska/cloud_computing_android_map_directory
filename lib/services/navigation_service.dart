import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class NavigationService {
  /// Open navigation to cafe location
  /// Works on both Android (Google Maps) and iOS (Apple Maps / Google Maps)
  static Future<void> openNavigation({
    required double destinationLat,
    required double destinationLng,
    required String destinationName,
  }) async {
    try {
      String url;

      if (Platform.isAndroid) {
        // Android: Google Maps
        url = 'https://www.google.com/maps/search/'
            '${destinationLat},${destinationLng}/'
            '@${destinationLat},${destinationLng},15z'
            '?entry=mmi&query=${Uri.encodeComponent(destinationName)}';
      } else if (Platform.isIOS) {
        // iOS: Try Apple Maps first, fallback to Google Maps
        url = 'maps://?daddr=${destinationLat},${destinationLng}&q=${Uri.encodeComponent(destinationName)}';
      } else {
        throw UnsupportedError('Platform tidak didukung');
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to Google Maps web version
        final webUrl =
            'https://www.google.com/maps/search/${Uri.encodeComponent(destinationName)}/@${destinationLat},${destinationLng},15z';
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl));
        } else {
          throw 'Tidak bisa membuka aplikasi maps';
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Google Maps URL for web preview/backup
  static String getGoogleMapsUrl({
    required double lat,
    required double lng,
    required String name,
  }) {
    return 'https://www.google.com/maps/search/${Uri.encodeComponent(name)}/@${lat},${lng},15z';
  }

  /// Get navigation intent string for display
  static String getNavigationText(double lat, double lng) {
    return '$lat,$lng';
  }
}
