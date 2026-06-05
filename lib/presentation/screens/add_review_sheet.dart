import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';
import 'package:cafescope_sby/app/router/app_router.dart';
import 'package:cafescope_sby/providers/cafe_provider.dart';

/// Bottom sheet untuk menambahkan review ke sebuah cafe.
/// Gunakan: showAddReviewSheet(context, cafeId: '...')
Future<void> showAddReviewSheet(
  BuildContext context, {
  required String cafeId,
  required WidgetRef ref,
}) async {
  final userId = ref.read(userIdProvider);

  // Kalau belum login, arahkan ke login
  if (userId == null) {
    _showLoginPrompt(context);
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _AddReviewSheet(cafeId: cafeId),
    ),
  );
}

void _showLoginPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Perlu Masuk',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
      ),
      content: Text(
        'Kamu harus masuk dulu untuk menulis ulasan.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.mutedForeground,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Batal',
            style: GoogleFonts.inter(color: AppColors.mutedForeground),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.pushNamed(AppRoute.login.name);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Masuk',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AddReviewSheet extends ConsumerStatefulWidget {
  final String cafeId;

  const _AddReviewSheet({required this.cafeId});

  @override
  ConsumerState<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends ConsumerState<_AddReviewSheet> {
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  static const _ratingLabels = [
    '',
    'Sangat Buruk',
    'Buruk',
    'Cukup',
    'Bagus',
    'Sangat Bagus',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih rating dulu ya 😊',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tulis ulasan dulu ya 😊',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(addReviewProvider.notifier).addReview(
            cafeId: widget.cafeId,
            rating: _selectedRating,
            comment: _commentController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ulasan berhasil ditambahkan! ✨',
                style: GoogleFonts.inter(fontSize: 13)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan. Coba lagi.',
                style: GoogleFonts.inter(fontSize: 13)),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Tulis Ulasan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Bagikan pengalamanmu di kafe ini',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 24),

          // Rating Stars
          Text(
            'Rating',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRating = starIndex),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        starIndex <= _selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starIndex <= _selectedRating
                            ? AppColors.ratingGold
                            : AppColors.border,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              if (_selectedRating > 0)
                Text(
                  _ratingLabels[_selectedRating],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Comment Field
          Text(
            'Ulasan',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 300,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalamanmu di sini...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.mutedForeground,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.primary, width: 1.5),
              ),
              counterStyle: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Kirim Ulasan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}