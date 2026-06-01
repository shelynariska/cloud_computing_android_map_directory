import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum CafeRegion {
  centre('Centre - Pusat Kota'),
  east('East - Timur'),
  west('West - Barat'),
  north('North - Utara'),
  south('South - Selatan');

  const CafeRegion(this.label);
  final String label;
}

class Cafe {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final CafeRegion region;
  final String address;
  final String phone;
  final String? operatingHours;
  final List<String> amenities;
  final List<String> coffeeTypes;
  final double priceRange; // 1-5 in terms of affordability (1=very affordable, 5=expensive)
  final bool wifi;
  final bool parking;
  final bool petFriendly;
  final bool workspace;
  bool isFavorite;

  Cafe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.region,
    required this.address,
    required this.phone,
    this.operatingHours,
    required this.amenities,
    required this.coffeeTypes,
    required this.priceRange,
    required this.wifi,
    required this.parking,
    required this.petFriendly,
    required this.workspace,
    this.isFavorite = false,
  });

  LatLng get location => LatLng(latitude, longitude);

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      rating: _toDouble(json['rating'] ?? 4.0),
      reviewCount: _toInt(json['review_count'] ?? json['reviewCount'] ?? 0),
      // Supabase uses 'lat' and 'lng' instead of 'latitude' and 'longitude'
      // Also handle variations: lat, latitude, lat_value, latitude_value
      latitude: _toDouble(
        json['lat'] ??
            json['latitude'] ??
            json['lat_value'] ??
            json['latitude_value'] ??
            0.0,
      ),
      // Handle longitude variations: lng, longitude, lon, long, long_value, longitude_value, lon_value
      longitude: _toDouble(json['lon'] ?? json['lng'] ?? json['longitude'] ?? json['long'] ?? 0.0),
      region: CafeRegion.values.firstWhere(
        (e) => e.name == (json['region'] ?? 'centre').toString(),
        orElse: () => CafeRegion.centre,
      ),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      operatingHours: json['opening_hours'] != null ? (json['opening_hours']).toString() : (json['operatingHours'] != null ? (json['operatingHours']).toString() : null),
      amenities: _parseList(json['amenities']),
      coffeeTypes: _parseList(json['coffee_types'] ?? json['coffeeTypes']),
      priceRange: _toDouble(json['price_range'] ?? json['priceRange'] ?? 3.0),
      wifi: _toBool(json['has_wifi'] ?? json['wifi'] ?? false),
      parking: _toBool(json['has_parking'] ?? json['parking'] ?? false),
      petFriendly: _toBool(json['pet_friendly'] ?? json['petFriendly'] ?? false),
      workspace: _toBool(json['good_for_working'] ?? json['workspace'] ?? false),
      isFavorite: _toBool(json['isFavorite'] ?? false),
    );
  }

  // Helper methods untuk safe type conversion
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // Helper method untuk parse list dari JSON (bisa string atau list)
  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) {
      // Jika string, split by comma
      return value.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'lat': latitude,
      'lng': longitude,
      'region': region.name,
      'address': address,
      'phone': phone,
      'operatingHours': operatingHours,
      'amenities': amenities,
      'coffeeTypes': coffeeTypes,
      'priceRange': priceRange,
      'wifi': wifi,
      'parking': parking,
      'petFriendly': petFriendly,
      'workspace': workspace,
      'isFavorite': isFavorite,
    };
  }

  Cafe copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    double? latitude,
    double? longitude,
    CafeRegion? region,
    String? address,
    String? phone,
    String? operatingHours,
    List<String>? amenities,
    List<String>? coffeeTypes,
    double? priceRange,
    bool? wifi,
    bool? parking,
    bool? petFriendly,
    bool? workspace,
    bool? isFavorite,
  }) {
    return Cafe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      region: region ?? this.region,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      operatingHours: operatingHours ?? this.operatingHours,
      amenities: amenities ?? this.amenities,
      coffeeTypes: coffeeTypes ?? this.coffeeTypes,
      priceRange: priceRange ?? this.priceRange,
      wifi: wifi ?? this.wifi,
      parking: parking ?? this.parking,
      petFriendly: petFriendly ?? this.petFriendly,
      workspace: workspace ?? this.workspace,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

double getDistance(LatLng userLocation) {
  return Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        latitude,
        longitude,
      ) /
      1000;
}
}