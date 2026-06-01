import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cafescope_sby/models/cafe.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============= CAFES OPERATIONS =============

  /// Fetch all cafes dari database
  Future<List<Cafe>> getAllCafes() async {
    try {
      final response = await _supabase
          .from('cafes')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((cafe) => Cafe.fromJson(cafe as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error fetching cafes: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch cafe by ID untuk detail screen
  Future<Cafe?> getCafeById(String cafeId) async {
    try {
      final response = await _supabase
          .from('cafes')
          .select()
          .eq('id', cafeId)
          .maybeSingle();

      if (response == null) return null;

      return Cafe.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Error fetching cafe: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch cafes berdasarkan category_id
  Future<List<Cafe>> getCafesByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('cafes')
          .select()
          .eq('category_id', categoryId)
          .order('name', ascending: true);

      return (response as List)
          .map((cafe) => Cafe.fromJson(cafe as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error fetching cafes by category: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Search cafes by name / description
  Future<List<Cafe>> searchCafes(String query) async {
    try {
      final response = await _supabase.from('cafes').select().or(
            'name.ilike.%$query%,description.ilike.%$query%',
          );

      return (response as List)
          .map((cafe) => Cafe.fromJson(cafe as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error searching cafes: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get cafes dalam radius tertentu berdasarkan latitude & longitude
  /// Menggunakan PostGIS distance calculation
  Future<List<Cafe>> getCafesNearby(
    double userLat,
    double userLng,
    double radiusKm,
  ) async {
    try {
      final response = await _supabase.from('cafes').select().order(
            'distance',
            ascending: true,
          );

      // Filter by distance di client side (jika PostGIS tidak available)
      // TODO: Implement server-side distance calculation jika PostGIS tersedia
      return (response as List)
          .map((cafe) => Cafe.fromJson(cafe as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error fetching nearby cafes: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============= CATEGORIES OPERATIONS =============

  /// Fetch semua categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response =
          await _supabase.from('categories').select().order('name');

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Error fetching categories: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============= FAVORITES OPERATIONS =============

  /// Add cafe ke favorites
  Future<void> addToFavorites(String cafeId, String userId) async {
    try {
      await _supabase.from('favorites').insert({
        'cafe_id': cafeId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw Exception('Error adding to favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove cafe dari favorites
  Future<void> removeFromFavorites(String cafeId, String userId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('cafe_id', cafeId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error removing from favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Check if cafe ada di favorites
  Future<bool> isFavorite(String cafeId, String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('cafe_id', cafeId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw Exception('Error checking favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get semua favorite cafes untuk user
  Future<List<Cafe>> getFavoriteCafes(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('cafe_id, cafes(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((item) =>
              Cafe.fromJson(item['cafes'] as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error fetching favorite cafes: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============= REVIEWS OPERATIONS =============

  /// Fetch reviews untuk cafe tertentu
  Future<List<Map<String, dynamic>>> getCafeReviews(String cafeId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('cafe_id', cafeId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Error fetching reviews: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get average rating untuk cafe
  Future<double?> getCafeAverageRating(String cafeId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('rating')
          .eq('cafe_id', cafeId);

      if ((response as List).isEmpty) return null;

      final ratings = (response as List)
          .map((item) => (item['rating'] as num).toDouble())
          .toList();
      final average =
          ratings.reduce((a, b) => a + b) / ratings.length;

      return average;
    } on PostgrestException catch (e) {
      throw Exception('Error calculating average rating: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Add review untuk cafe
  Future<void> addReview({
    required String cafeId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'cafe_id': cafeId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw Exception('Error adding review: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============= VISIT STATS OPERATIONS =============

  /// Log visit ketika user membuka cafe detail
  Future<void> logVisit(String cafeId, String userId) async {
    try {
      await _supabase.from('visit_stats').insert({
        'cafe_id': cafeId,
        'user_id': userId,
        'visited_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      // Jika error, just log it tapi jangan throw karena ini optional
      print('Error logging visit: ${e.message}');
    } catch (e) {
      print('Unexpected error logging visit: $e');
    }
  }

  // ============= UTILITY OPERATIONS =============

  /// Test connection ke Supabase
  Future<bool> testConnection() async {
    try {
      final response =
          await _supabase.from('cafes').select().limit(1);
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get Supabase client instance
  SupabaseClient get supabase => _supabase;

  /// Get current user ID (jika authenticated)
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}
