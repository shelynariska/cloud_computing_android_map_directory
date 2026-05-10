import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/models/cafe.dart';

class RegionFilter extends StatelessWidget {
  final CafeRegion? selectedRegion;
  final ValueChanged<CafeRegion> onRegionSelected;

  const RegionFilter({
    Key? key,
    required this.selectedRegion,
    required this.onRegionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CafeRegion.values.map((region) {
          final isSelected = selectedRegion == region;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onRegionSelected(region),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.muted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  region.label.split(' - ')[0],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryForeground
                        : AppColors.foreground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}