import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sin, asin, sqrt;
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';
import 'package:cafescope_sby/services/navigation_service.dart';
import 'package:cafescope_sby/presentation/widgets/bottom_nav.dart';

class CafeDetailScreen extends ConsumerStatefulWidget {
  final String cafeId;

  const CafeDetailScreen({
    Key? key,
    required this.cafeId,
  }) : super(key: key);

  @override
  ConsumerState<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends ConsumerState<CafeDetailScreen> {
  Position? userPosition;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() => isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() => userPosition = position);
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }

  Future<void> _openNavigation(double lat, double lng, String name) async {
    try {
      await NavigationService.openNavigation(
        destinationLat: lat,
        destinationLng: lng,
        destinationName: name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cafeAsync = ref.watch(cafeByIdProvider(widget.cafeId));
    final isFavoritedAsync = ref.watch(isCafeFavoritedProvider(widget.cafeId));
    final reviewsAsync = ref.watch(cafeReviewsProvider(widget.cafeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: cafeAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
        data: (cafe) {
          if (cafe == null) {
            return _buildNotFoundState();
          }

          final distance = userPosition != null
              ? _calculateDistance(
                  userPosition!.latitude,
                  userPosition!.longitude,
                  cafe.latitude,
                  cafe.longitude,
                )
              : null;

          return CustomScrollView(
            slivers: [
              // Hero Image with AppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: BackButton(color: AppColors.foreground),
                actions: [
                  isFavoritedAsync.when(
                    data: (isFav) => IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_outline,
                        color: isFav ? Colors.red : AppColors.primary,
                        size: 24,
                      ),
                      onPressed: () {
                        final userId = ref.read(userIdProvider);
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login dulu untuk menyimpan favorit')),
                          );
                          return;
                        }
                        ref.read(toggleFavoriteCafeProvider.notifier).toggleFavorite(widget.cafeId);
                      },
                    ),
                    loading: () => const SizedBox(width: 48),
                    error: (_, __) => const SizedBox(width: 48),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        cafe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.muted,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      Container(color: Colors.black.withOpacity(0.2)),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cafe.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: AppColors.ratingGold,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${cafe.rating}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${cafe.reviewCount})',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      cafe.region.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distance and Navigation
                      if (distance != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Jarak: ${_formatDistance(distance)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _openNavigation(
                                  cafe.latitude,
                                  cafe.longitude,
                                  cafe.name,
                                ),
                                icon: const Icon(Icons.directions, color: Colors.white),
                                label: const Text(
                                  'Rute',
                                  style: TextStyle(color: Colors.white), // ← tambah ini
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (distance == null && !isLoadingLocation)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aktifkan lokasi untuk melihat jarak',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // About Section
                      Text(
                        'Tentang',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cafe.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.foreground,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Coffee Types
                      if (cafe.coffeeTypes.isNotEmpty) ...[
                        Text(
                          'Jenis Kopi',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cafe.coffeeTypes
                              .map(
                                (type) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.muted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.foreground,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Amenities
                      Text(
                        'Fasilitas',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAmenityGrid(cafe),
                      const SizedBox(height: 24),

                      // Contact Info
                      Text(
                        'Informasi Kontak',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildContactInfo(cafe),
                      const SizedBox(height: 24),

                      // Reviews Section
                      Text(
                        'Ulasan (${cafe.reviewCount})',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      reviewsAsync.when(
                        loading: () => Container(
                          padding: const EdgeInsets.all(12),
                          child: const CircularProgressIndicator(),
                        ),
                        error: (error, _) => Text(
                          'Error loading reviews',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return Text(
                              'Belum ada ulasan',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                              ),
                            );
                          }
                          return Column(
                            children: reviews.take(3).map((review) {
                              return _buildReviewCard(review);
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Memuat detail cafe...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.foreground),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.foreground),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'Cafe Tidak Ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cafe yang Anda cari tidak tersedia',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityGrid(dynamic cafe) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAmenityItem(Icons.wifi, 'WiFi', cafe.wifi),
            _buildAmenityItem(Icons.local_parking, 'Parkir', cafe.parking),
            _buildAmenityItem(Icons.pets, 'Pet Friendly', cafe.petFriendly),
            _buildAmenityItem(Icons.desk, 'Workspace', cafe.workspace),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityItem(IconData icon, String label, bool available) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: available ? AppColors.muted : AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: available ? AppColors.primary : AppColors.mutedForeground,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color:
                    available ? AppColors.primary : AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              available ? '✓' : '✗',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: available ? AppColors.success : AppColors.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(dynamic cafe) {
    return Card(
      color: AppColors.muted,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactRow(
              Icons.location_on,
              'Alamat',
              cafe.address,
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              Icons.phone,
              'Telepon',
              cafe.phone,
            ),
            if (cafe.operatingHours != null) ...[
              const SizedBox(height: 12),
              _buildContactRow(
                Icons.schedule,
                'Jam Buka',
                cafe.operatingHours ?? '-',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < rating ? Icons.star_rounded : Icons.star_outline,
                  color: AppColors.ratingGold,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$rating/5',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.foreground,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}