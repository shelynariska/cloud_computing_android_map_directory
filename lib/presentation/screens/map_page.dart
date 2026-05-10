// map_page.dart (Versi Improved)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/app/router/app_router.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';
import 'package:cafescope_sby/presentation/widgets/bottom_nav.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? mapController;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    setState(() => currentPosition = position);

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cafes = ref.watch(cafesProvider);

    final surabayaCenter = LatLng(-7.2504, 112.7469);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Peta Kafe'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: surabayaCenter,
              zoom: 12.5,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: cafes.map((cafe) {
              return Marker(
                markerId: MarkerId(cafe.id),
                position: cafe.location,
                infoWindow: InfoWindow(
                  title: cafe.name,
                  snippet: "${cafe.address} • ${cafe.rating}⭐",
                ),
                onTap: () {
                  context.pushNamed(
                    AppRoute.cafeDetail.name,
                    pathParameters: {'id': cafe.id},
                  );
                },
              );
            }).toSet(),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}