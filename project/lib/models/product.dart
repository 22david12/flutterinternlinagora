// Represents a product with its attributes
class Product {
  // Unique identifier for the product
  final int id;

  // Title or name of the product
  final String title;

  // Price of the product
  final double price;

  // Description of the product
  final String description;

  // URL of the product's image
  final String image;

  // Constructor with required fields for creating a Product instance
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
  });

  // Factory constructor to create a Product instance from JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], // Extract product ID from JSON
      title: json['title'], // Extract product title from JSON
      price: json['price'].toDouble(), // Convert price to double from JSON
      description: json['description'], // Extract product description from JSON
      image: json['image'], // Extract product image URL from JSON
    );
  }
}