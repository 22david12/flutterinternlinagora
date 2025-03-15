import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// Service class to handle API requests for product data
class ApiService {
  // Base URL for the Fake Store API
  static const String baseUrl = 'https://fakestoreapi.com/products';

  // Fetches a paginated list of products from the API
  Future<List<Product>> fetchProducts(int limit, int page) async {
    // Fetch all product data from the API in a single request
    final response = await http.get(Uri.parse(baseUrl));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Decode the JSON response into a list
      List jsonData = json.decode(response.body);
      // Convert JSON data into a list of Product objects
      List<Product> allProducts = jsonData.map((json) => Product.fromJson(json)).toList();

      // Calculate pagination manually based on limit and page
      final startIndex = page * limit;
      final endIndex = startIndex + limit;

      // Return an empty list if the start index exceeds available data
      if (startIndex >= allProducts.length) {
        return [];
      }

      // Return a sublist of products based on pagination parameters
      return allProducts.sublist(
        startIndex,
        endIndex > allProducts.length ? allProducts.length : endIndex,
      );
    } else {
      // Throw an exception if the API request fails
      throw Exception('Failed to load products');
    }
  }
}