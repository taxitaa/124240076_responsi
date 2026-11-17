class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.description,
    required this.discountPercentage,
    required this.stock,
    required this.thumbnail,
    this.brand,
    this.images = const [],
  });

  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final String description;
  final double discountPercentage;
  final int stock;
  final String thumbnail;
  final String? brand;
  final List<String> images;

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageValues = json['images'];
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Product',
      category: json['category'] as String? ?? 'uncategorized',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      brand: json['brand'] as String?,
      images: imageValues is List
          ? imageValues.whereType<String>().toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'price': price,
    'rating': rating,
    'description': description,
    'discountPercentage': discountPercentage,
    'stock': stock,
    'thumbnail': thumbnail,
    'brand': brand,
    'images': images,
  };
}
