import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/models/cafe.dart';

class CafeCard extends StatelessWidget {
  final Cafe cafe;

  const CafeCard({
    Key? key,
    required this.cafe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.muted,
                  child: Image.network(
                    cafe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.coffee_outlined,
                          size: 48,
                          color: AppColors.mutedForeground,
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Region badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cafe.region.label.split(' - ')[0],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.ratingGold,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${cafe.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    cafe.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    cafe.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Rating and Reviews
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.ratingGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${cafe.rating}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${cafe.reviewCount} reviews)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Amenities
                  Row(
                    children: [
                      if (cafe.wifi)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildAmenityBadge(Icons.wifi, 'WiFi'),
                        ),
                      if (cafe.parking)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildAmenityBadge(Icons.local_parking, 'Parkir'),
                        ),
                      if (cafe.petFriendly)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildAmenityBadge(Icons.pets, 'Pet'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}