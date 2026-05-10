import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafescope_sby/models/cafe.dart';
import 'package:cafescope_sby/data/mock_cafes.dart';

// List of all cafes
final cafesProvider = StateProvider<List<Cafe>>((ref) {
  return mockCafes;
});

// Filtered cafes based on search and region
final filteredCafesProvider = StateProvider<List<Cafe>>((ref) {
  final allCafes = ref.watch(cafesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedRegion = ref.watch(selectedRegionProvider);

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
    filtered = filtered.where((cafe) => cafe.region == selectedRegion).toList();
  }

  // Sort by rating
  filtered.sort((a, b) => b.rating.compareTo(a.rating));

  return filtered;
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected region filter
final selectedRegionProvider = StateProvider<CafeRegion?>((ref) => null);

// Favorite cafes
final favoriteCafesProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Get cafe by ID
final cafeByIdProvider = StateProvider.family<Cafe?, String>((ref, cafeId) {
  final allCafes = ref.watch(cafesProvider);
  try {
    return allCafes.firstWhere((cafe) => cafe.id == cafeId);
  } catch (e) {
    return null;
  }
});

// Check if cafe is favorited
final isCafeFavoritedProvider = StateProvider.family<bool, String>((ref, cafeId) {
  final favorites = ref.watch(favoriteCafesProvider);
  return favorites.contains(cafeId);
});

// Toggle favorite cafe
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
      final favorites = ref.read(favoriteCafesProvider);
      
      if (favorites.contains(cafeId)) {
        ref.read(favoriteCafesProvider.notifier).state =
            favorites.where((id) => id != cafeId).toList();
      } else {
        ref.read(favoriteCafesProvider.notifier).state = [
          ...favorites,
          cafeId,
        ];
      }
      
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

// Get favorite cafes list
final getFavoriteCafesProvider = Provider<List<Cafe>>((ref) {
  final allCafes = ref.watch(cafesProvider);
  final favorites = ref.watch(favoriteCafesProvider);
  
  return allCafes.where((cafe) => favorites.contains(cafe.id)).toList();
});