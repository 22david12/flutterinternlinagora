import 'package:flutter/material.dart';
import '../models/product.dart';

// Displays detailed information about a selected product
class ProductDetailScreen extends StatelessWidget {
  // The product to display details for
  final Product product;

  // Constructor requiring a product parameter
  const ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    // Build a scrollable container with a white background for the product details
    return Container(
      color: Colors.white, // White background for the entire screen
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with a border
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // Margin for spacing around the image
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!, width: 1.0), // Grey border around the image
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for the border
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for the image
                child: Image.network(
                  product.image,
                  height: 700, // Fixed height for the image as specified
                  fit: BoxFit.cover, // Scale the image to cover the container
                  width: double.infinity, // Full width of the parent container
                ),
              ),
            ),
            // Product details section below the image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding for content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product title with bold styling
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Spacing between title and price
                  // Product price displayed in green
                  Text(
                    'Price: \$${product.price}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing between price and description
                  // Product description with standard text styling
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}