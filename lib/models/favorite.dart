class Favorite {
  final String id;
  final String cafeId;
  final String userId;
  final DateTime? createdAt;

  const Favorite({
    required this.id,
    required this.cafeId,
    required this.userId,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      cafeId: json['cafe_id'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cafe_id': cafeId,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Favorite copyWith({
    String? id,
    String? cafeId,
    String? userId,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      cafeId: cafeId ?? this.cafeId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Favorite(id: $id, cafeId: $cafeId, userId: $userId, createdAt: $createdAt)';
}
