import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/app/router/app_router.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';
import 'package:cafescope_sby/presentation/widgets/cafe_card.dart';
import 'package:cafescope_sby/presentation/widgets/search_bar_widget.dart';
import 'package:cafescope_sby/presentation/widgets/region_filter.dart';
import 'package:cafescope_sby/presentation/widgets/bottom_nav.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCafes = ref.watch(filteredCafesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'CafeScope SBY',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Selamat datang! 👋',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Jelajahi kafe terbaik di Surabaya',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              SearchBar(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 16),

              // Region Filter
              RegionFilter(
                selectedRegion: selectedRegion,
                onRegionSelected: (region) {
                  ref.read(selectedRegionProvider.notifier).state =
                      selectedRegion == region ? null : region;
                },
              ),
              const SizedBox(height: 20),

              // Cafe List
              Text(
                'Rekomendasi untuk Anda',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),

              if (filteredCafes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.coffee_outlined,
                          size: 64,
                          color: AppColors.muted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada kafe yang cocok',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCafes.length,
                  itemBuilder: (context, index) {
                    final cafe = filteredCafes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            AppRoute.cafeDetail.name,
                            pathParameters: {'id': cafe.id},
                          );
                        },
                        child: CafeCard(cafe: cafe),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}