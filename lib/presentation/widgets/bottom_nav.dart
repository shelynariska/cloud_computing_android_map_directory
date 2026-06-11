import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/app/router/app_router.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) {
                    context.goNamed(AppRoute.home.name);
                  }
                },
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Peta',
                isActive: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) {
                    context.goNamed(AppRoute.map.name);
                  }
                },
              ),
              _NavItem(
                icon: Icons.favorite_outline,
                label: 'Favorit',
                isActive: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) {
                    context.goNamed(AppRoute.favorites.name);
                  }
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                isActive: currentIndex == 3,
                onTap: () {
                  if (currentIndex != 3) {
                    context.goNamed(AppRoute.profile.name);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.muted : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.mutedForeground,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color:
                    isActive ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}