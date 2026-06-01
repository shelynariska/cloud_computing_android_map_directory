class Review {
  final String id;
  final String cafeId;
  final String userId;
  final int rating; // 1-5 scale
  final String? comment;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.cafeId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      cafeId: json['cafe_id'] ?? '',
      userId: json['user_id'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'],
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
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? cafeId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      cafeId: cafeId ?? this.cafeId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Review(id: $id, cafeId: $cafeId, rating: $rating, createdAt: $createdAt)';
}
