import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cafescope_sby/app/router/app_router.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/models/cafe.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';
import 'package:cafescope_sby/presentation/widgets/bottom_nav.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  Position? currentPosition;
  bool locationPermissionGranted = false;
  bool isLoadingLocation = true;
  Cafe? selectedCafe;
  bool showRoute = false;
  List<LatLng>? routePoints;
  bool isLoadingRoute = false;
  late AnimationController _pulseController;
  double pulseRadius = 0;
  double radiusKm = 2.0; // Default 2km radius

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startPulseAnimation();
  }

  void _startPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController.addListener(() {
      setState(() {
        pulseRadius = _pulseController.value * 30; // Max 30 radius
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan aktifkan Location Service')),
          );
        }
        setState(() => isLoadingLocation = false);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin lokasi ditolak. Buka Pengaturan untuk mengaktifkan.',
              ),
            ),
          );
        }
        setState(() => isLoadingLocation = false);
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (mounted) {
          setState(() {
            currentPosition = position;
            locationPermissionGranted = true;
            isLoadingLocation = false;
          });

          // Animate camera to user location
          mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingLocation = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error mendapatkan lokasi: $e')));
      }
    }
  }

  Color _getCategoryMarkerColor(String categoryId) {
    // Return different colors based on category
    final hash = categoryId.hashCode % 6;
    const colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[hash];
  }

  Future<void> _getRouteFromOSRM(LatLng start, LatLng end) async {
    setState(() => isLoadingRoute = true);
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?steps=true&geometries=geojson';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Route request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;
          final points =
              geometry
                  .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                  .toList();

          setState(() {
            routePoints = points;
            showRoute = true;
          });
        }
      }
    } catch (e) {
      print('❌ OSRM Route Error: $e');
      // Fallback to straight line if OSRM fails
      setState(() {
        routePoints = [start, end];
        showRoute = true;
      });
    } finally {
      setState(() => isLoadingRoute = false);
    }
  }

  String _getDistanceText(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    final cafesAsync = ref.watch(allCafesProvider);

    const surabayaCenter = LatLng(-7.2504, 112.7469);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Peta Kafe'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Radius dropdown
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                value: radiusKm,
                dropdownColor: Colors.brown,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
                items:
                    [0.5, 1.0, 2.0, 5.0].map((km) {
                      return DropdownMenuItem(
                        value: km,
                        child: Text(
                          '${km % 1 == 0 ? km.toInt() : km} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => radiusKm = value);
                },
              ),
            ),
          ),
          // My location button
          if (currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                mapController.move(
                  LatLng(currentPosition!.latitude, currentPosition!.longitude),
                  15.0,
                );
              },
            ),
          if (showRoute && selectedCafe != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Tutup Rute',
              onPressed: () {
                setState(() {
                  showRoute = false;
                  selectedCafe = null;
                  routePoints = null;
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: surabayaCenter,
              initialZoom: 14.0, // Better zoom for seeing markers
              minZoom: 5,
              maxZoom: 19,
            ),
            children: [
              // CartoDB Positron Tile Layer (cleaner, more professional)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.cafescope_sby',
                retinaMode: false,
              ),

              // Circle Marker - Radius around user location with pulse effect
              if (locationPermissionGranted && currentPosition != null)
                CircleLayer(
                  circles: [
                    // Pulse effect circle
                    CircleMarker(
                      point: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),
                      radius: pulseRadius,
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.1),
                      borderColor: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 1,
                    ),
                    // Main radius circle (radiusKm default 2km)
                    CircleMarker(
                      point: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),
                      radius: radiusKm * 1000, // Convert km to meters
                      useRadiusInMeter: true,
                      color: const Color(
                        0x8B451320,
                      ), // Transparent brown (#8B4513)
                      borderColor: const Color(0xFF8B4513), // Brown border
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // Polyline - Route dari user ke selected cafe (dari OSRM)
              if (showRoute &&
                  selectedCafe != null &&
                  routePoints != null &&
                  routePoints!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints!,
                      strokeWidth: 5,
                      color: const Color(0xFFFFA500), // Orange routing line
                      borderStrokeWidth: 1,
                      borderColor: Colors.white,
                    ),
                  ],
                ),

              // Markers Layer
              cafesAsync.when(
                loading: () {
                  return const SizedBox.shrink();
                },
                error: (error, stackTrace) {
                  return const SizedBox.shrink();
                },
                data: (cafes) {
                  final filteredCafes =
                      currentPosition != null
                          ? cafes
                              .where(
                                (c) =>
                                    _calculateDistance(
                                      currentPosition!.latitude,
                                      currentPosition!.longitude,
                                      c.latitude,
                                      c.longitude,
                                    ) <=
                                    radiusKm,
                              )
                              .toList()
                          : cafes;
                  return MarkerLayer(
                    markers: [
                      // User location marker
                      if (locationPermissionGranted && currentPosition != null)
                        Marker(
                          point: LatLng(
                            currentPosition!.latitude,
                            currentPosition!.longitude,
                          ),
                          width: 50,
                          height: 50,
                          child: _buildUserLocationMarker(),
                        ),

                      // Cafe markers
                      ...filteredCafes.map((cafe) {
                        final distance =
                            currentPosition != null
                                ? _calculateDistance(
                                  currentPosition!.latitude,
                                  currentPosition!.longitude,
                                  cafe.latitude,
                                  cafe.longitude,
                                )
                                : null;

                        return Marker(
                          point: LatLng(cafe.latitude, cafe.longitude),
                          width: 45,
                          height: 45,
                          child: GestureDetector(
                            onTap:
                                () => _showCafePopup(context, cafe, distance),
                            child: _buildCafeMarker(
                              cafe.name,
                              _getCategoryMarkerColor(cafe.id),
                              cafe.imageUrl,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ],
          ),

          // Loading indicator
          if (isLoadingLocation)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Mendapatkan lokasi Anda...'),
                  ],
                ),
              ),
            ),

          // Info bar cafes found
          Positioned(
            top: 12,
            left: 12,
            child: cafesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (cafes) {
                final filtered =
                    currentPosition != null
                        ? cafes
                            .where(
                              (c) =>
                                  _calculateDistance(
                                    currentPosition!.latitude,
                                    currentPosition!.longitude,
                                    c.latitude,
                                    c.longitude,
                                  ) <=
                                  radiusKm,
                            )
                            .toList()
                        : cafes;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_cafe,
                        size: 14,
                        color: Colors.brown,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${filtered.length} cafes found (${radiusKm % 1 == 0 ? radiusKm.toInt() : radiusKm} km)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.location_on, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildCafeMarker(String cafeName, Color color, String? imageUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle with shadow
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        // Cafe icon or logo inside
        imageUrl != null && imageUrl.isNotEmpty
            ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_cafe,
                    color: Colors.white,
                    size: 24,
                  );
                },
              ),
            )
            : const Icon(Icons.local_cafe, color: Colors.white, size: 24),
      ],
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _showCafePopup(BuildContext context, Cafe cafe, double? distance) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with cafe name and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cafe.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${cafe.rating} (${cafe.reviewCount} reviews)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Favorit
                            Consumer(
                              builder: (context, ref, _) {
                                final isFavAsync = ref.watch(
                                  isCafeFavoritedProvider(cafe.id),
                                );
                                return isFavAsync.when(
                                  data:
                                      (isFav) => IconButton(
                                        icon: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color:
                                              isFav ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                toggleFavoriteCafeProvider
                                                    .notifier,
                                              )
                                              .toggleFavorite(cafe.id);
                                        },
                                      ),
                                  loading: () => const SizedBox(width: 48),
                                  error: (_, __) => const SizedBox(width: 48),
                                );
                              },
                            ),
                            // Tombol Close
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),

                    // Address and distance
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cafe.address,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Distance
                    if (distance != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.straighten,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Jarak: ${_getDistanceText(distance)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Amenities chips
                    if (cafe.amenities.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            cafe.amenities.take(3).map((amenity) {
                              return Chip(
                                label: Text(
                                  amenity,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                avatar: _getAmenityIcon(amenity),
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Show Route Button
                    if (locationPermissionGranted && currentPosition != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              isLoadingRoute
                                  ? null
                                  : () {
                                    setState(() => selectedCafe = cafe);
                                    Navigator.pop(context);
                                    _getRouteFromOSRM(
                                      LatLng(
                                        currentPosition!.latitude,
                                        currentPosition!.longitude,
                                      ),
                                      LatLng(cafe.latitude, cafe.longitude),
                                    );
                                  },
                          icon:
                              isLoadingRoute
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.directions),
                          label: Text(
                            isLoadingRoute
                                ? 'Menghitung Rute...'
                                : 'Tampilkan Rute di Peta',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                    if (locationPermissionGranted && currentPosition != null)
                      const SizedBox(height: 10),

                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            AppRoute.cafeDetail.name,
                            pathParameters: {'id': cafe.id},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _getAmenityIcon(String amenity) {
    IconData icon = Icons.check_circle;
    switch (amenity.toLowerCase()) {
      case 'wifi':
        icon = Icons.wifi;
        break;
      case 'parking':
        icon = Icons.local_parking;
        break;
      case 'toilet':
        icon = Icons.wc;
        break;
      case 'ac':
        icon = Icons.ac_unit;
        break;
      default:
        icon = Icons.check_circle;
    }
    return Icon(icon, size: 16);
  }
}
