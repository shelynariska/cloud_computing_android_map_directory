import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafescope_sby/models/cafe.dart';
import 'package:cafescope_sby/services/supabase_service.dart';
import 'package:cafescope_sby/data/mock_cafes.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// ========== CAFES PROVIDERS ==========

/// Fetch all cafes dari Supabase
/// Falls back ke mock data jika connection error
final allCafesProvider = FutureProvider<List<Cafe>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  try {
    // Test connection first
    final isConnected = await supabaseService.testConnection();
    
    if (isConnected) {
      return await supabaseService.getAllCafes();
    } else {
      // Fallback to mock data jika tidak bisa connect
      return mockCafes;
    }
  } catch (e) {
    // Fallback to mock data jika error
    print('Error fetching cafes: $e');
    return mockCafes;
  }
});

/// Get cafe detail by ID
final cafeByIdProvider = FutureProvider.family<Cafe?, String>((ref, cafeId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  try {
    return await supabaseService.getCafeById(cafeId);
  } catch (e) {
    print('Error fetching cafe detail: $e');
    // Fallback to mock data
    try {
      return mockCafes.firstWhere((cafe) => cafe.id == cafeId);
    } catch (_) {
      return null;
    }
  }
});

/// Search cafes
final searchCafesProvider =
    FutureProvider.family<List<Cafe>, String>((ref, query) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  if (query.isEmpty) {
    return [];
  }
  
  try {
    return await supabaseService.searchCafes(query);
  } catch (e) {
    print('Error searching cafes: $e');
    return [];
  }
});

/// Get cafes by category
final cafesByCategoryProvider =
    FutureProvider.family<List<Cafe>, String>((ref, categoryId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  try {
    return await supabaseService.getCafesByCategory(categoryId);
  } catch (e) {
    print('Error fetching cafes by category: $e');
    return [];
  }
});

// ========== CATEGORIES PROVIDERS ==========

/// Fetch all categories
final categoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  try {
    return await supabaseService.getCategories();
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
});

// ========== SEARCH & FILTER PROVIDERS ==========

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected region filter
final selectedRegionProvider = StateProvider<CafeRegion?>((ref) => null);

/// Filtered cafes based on search and region
final filteredCafesProvider = Provider<AsyncValue<List<Cafe>>>((ref) {
  final allCafesAsync = ref.watch(allCafesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedRegion = ref.watch(selectedRegionProvider);

  return allCafesAsync.when(
    data: (allCafes) {
      var filtered = allCafes;

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((cafe) {
          return cafe.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              cafe.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      // Filter by region
      if (selectedRegion != null) {
        filtered = filtered
            .where((cafe) => cafe.region == selectedRegion)
            .toList();
      }

      // Sort by rating
      filtered.sort((a, b) => b.rating.compareTo(a.rating));

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// ========== FAVORITES PROVIDERS ==========

/// Get user ID untuk favorites tracking
final userIdProvider = Provider<String?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getCurrentUserId();
});

/// Fetch favorite cafes untuk user
final favoriteCafesProvider = FutureProvider<List<Cafe>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    return [];
  }
  
  try {
    return await supabaseService.getFavoriteCafes(userId);
  } catch (e) {
    print('Error fetching favorite cafes: $e');
    return [];
  }
});

/// Check if cafe is favorited
final isCafeFavoritedProvider =
    FutureProvider.family<bool, String>((ref, cafeId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    return false;
  }
  
  try {
    return await supabaseService.isFavorite(cafeId, userId);
  } catch (e) {
    print('Error checking favorite: $e');
    return false;
  }
});

/// Toggle favorite cafe
final toggleFavoriteCafeProvider = StateNotifierProvider<
    ToggleFavoriteCafeNotifier,
    AsyncValue<void>>((ref) {
  return ToggleFavoriteCafeNotifier(ref);
});

class ToggleFavoriteCafeNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ToggleFavoriteCafeNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(String cafeId) async {
    state = const AsyncValue.loading();
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final userId = ref.read(userIdProvider);
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final isFav = await supabaseService.isFavorite(cafeId, userId);
      
      if (isFav) {
        await supabaseService.removeFromFavorites(cafeId, userId);
      } else {
        await supabaseService.addToFavorites(cafeId, userId);
      }
      
      // Invalidate favorites provider untuk refresh
      ref.invalidate(favoriteCafesProvider);
      ref.invalidate(isCafeFavoritedProvider);
      
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// ========== REVIEWS PROVIDERS ==========

/// Fetch reviews untuk cafe
final cafeReviewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, cafeId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  try {
    return await supabaseService.getCafeReviews(cafeId);
  } catch (e) {
    print('Error fetching cafe reviews: $e');
    return [];
  }
});

/// Get average rating untuk cafe
final cafeAverageRatingProvider =
    FutureProvider.family<double?, String>((ref, cafeId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  try {
    return await supabaseService.getCafeAverageRating(cafeId);
  } catch (e) {
    print('Error fetching average rating: $e');
    return null;
  }
});

/// Add review untuk cafe
final addReviewProvider = StateNotifierProvider<
    AddReviewNotifier,
    AsyncValue<void>>((ref) {
  return AddReviewNotifier(ref);
});

class AddReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AddReviewNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addReview({
    required String cafeId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final userId = ref.read(userIdProvider);
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      await supabaseService.addReview(
        cafeId: cafeId,
        userId: userId,
        rating: rating,
        comment: comment,
      );
      
      // Invalidate reviews untuk refresh
      ref.invalidate(cafeReviewsProvider);
      ref.invalidate(cafeAverageRatingProvider);
      
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}