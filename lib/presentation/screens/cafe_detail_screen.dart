import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';
import 'package:cafescope_sby/presentation/widgets/bottom_nav.dart';

class CafeDetailScreen extends ConsumerWidget {
  final String cafeId;

  const CafeDetailScreen({
    Key? key,
    required this.cafeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cafe = ref.watch(cafeByIdProvider(cafeId));
    final isFavorited = ref.watch(isCafeFavoritedProvider(cafeId));

    if (cafe == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Cafe Detail',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: BackButton(
            color: AppColors.foreground,
          ),
        ),
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Cafe tidak ditemukan',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          cafe.name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(
          color: AppColors.foreground,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: isFavorited ? AppColors.accent : AppColors.primary,
              size: 24,
            ),
            onPressed: () {
              ref
                  .read(toggleFavoriteCafeProvider.notifier)
                  .toggleFavorite(cafeId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.muted,
                image: DecorationImage(
                  image: NetworkImage(cafe.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    '(${cafe.reviewCount} reviews)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
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
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About section
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildAmenityGrid(cafe) {
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
                color:
                    available ? AppColors.success : AppColors.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(cafe) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cafe.address,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  cafe.phone,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            if (cafe.operatingHours != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cafe.operatingHours!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}