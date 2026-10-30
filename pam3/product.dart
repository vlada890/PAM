class Product {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String imageUrl;
  final String category;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> reviews;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.category,
    required this.description,
    this.rating = 0,
    this.reviewCount = 0,
    this.sizes = const [],
    this.colors = const [],
    this.reviews = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawSizes = json['availableSizes'];
    final rawColors = json['availableColors'];
    final rawReviews = json['reviews'];

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed product',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
      imageUrl: (json['imageUrl'] ?? json['mainImageUrl'] ?? '').toString(),
      category: json['category']?.toString() ?? 'women',
      description:
          json['description']?.toString() ?? 'No description available.',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ??
          (json['ratingCount'] as num?)?.toInt() ??
          0,
      sizes: rawSizes is List
          ? rawSizes.map((item) => item.toString()).toList()
          : const <String>[],
      colors: rawColors is List
          ? rawColors.whereType<Map<String, dynamic>>().toList()
          : const <Map<String, dynamic>>[],
      reviews: rawReviews is List
          ? rawReviews.whereType<Map<String, dynamic>>().toList()
          : const <Map<String, dynamic>>[],
    );
  }
}
