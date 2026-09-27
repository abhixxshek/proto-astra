class ProductModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  int quantity;

  ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    this.originalPrice = 0.0,
    required this.imageUrl,
    this.rating = 4.5,
    this.reviewsCount = 42,
    this.quantity = 1,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Seeds',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 42,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'quantity': quantity,
    };
  }
}
