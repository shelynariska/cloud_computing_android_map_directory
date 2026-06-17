import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/app/router/app_router.dart';
import 'package:cafescope_sby/presentation/widgets/bottom_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body:
          userId == null
              ? _buildGuest(context)
              : _buildLoggedIn(context, ref, user!),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  // Belum login
  Widget _buildGuest(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              'Belum masuk akun',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Login untuk menyimpan favorit dan mengakses fitur lengkap',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRoute.login.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Register
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.goNamed(AppRoute.register.name),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Daftar',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sudah login
  Widget _buildLoggedIn(BuildContext context, WidgetRef ref, User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + info (sama seperti sebelumnya)
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.muted,
                child: Icon(Icons.person, size: 36, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userMetadata?['full_name'] ?? 'Pengguna',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: AppColors.muted),
          const SizedBox(height: 24),

          // Tombol Logout dengan dialog konfirmasi
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // ← Tambah dialog konfirmasi
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        backgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Keluar Akun',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        content: Text(
                          'Kamu yakin ingin keluar?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.poppins(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.destructive,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Keluar',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await Supabase.instance.client.auth.signOut();
                  // Tidak perlu navigate — authStateProvider otomatis rebuild
                }
              },
              icon: Icon(Icons.logout, color: AppColors.destructive),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.destructive,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.destructive),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
