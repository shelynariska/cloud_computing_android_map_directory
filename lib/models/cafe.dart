import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      region: CafeRegion.values.firstWhere(
        (e) => e.name == json['region'],
        orElse: () => CafeRegion.centre,
      ),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      operatingHours: json['operatingHours'],
      amenities: List<String>.from(json['amenities'] ?? []),
      coffeeTypes: List<String>.from(json['coffeeTypes'] ?? []),
      priceRange: (json['priceRange'] ?? 1.0).toDouble(),
      wifi: json['wifi'] ?? false,
      parking: json['parking'] ?? false,
      petFriendly: json['petFriendly'] ?? false,
      workspace: json['workspace'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
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