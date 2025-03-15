import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

// Manages the state of the product list and the selected product
class ProductProvider with ChangeNotifier {
  // List of products fetched from the API
  List<Product> _products = [];

  // Indicates whether data is currently being loaded (true: loading, false: idle)
  bool _isLoading = false;

  // Stores any error message that occurs during data fetching
  String? _error;

  // Current page number for pagination (used in "load more" functionality)
  int _page = 0;

  // Number of products to fetch per request
  final int _limit = 10;

  // The currently selected product for displaying details
  Product? _selectedProduct;

  // API service instance to fetch product data (allows mock injection for testing)
  final ApiService _apiService;

  // Constructor with an optional apiService parameter (defaults to real ApiService)
  ProductProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getter to access the list of products
  List<Product> get products => _products;

  // Getter to check the loading state
  bool get isLoading => _isLoading;

  // Getter to retrieve the error message, if any
  String? get error => _error;

  // Getter to access the selected product
  Product? get selectedProduct => _selectedProduct;

  // Fetches products from the API
  // loadMore: If true, appends products to the existing list; if false, refreshes the list
  Future<void> fetchProducts({bool loadMore = false}) async {
    // Log the fetch request details for debugging
    print('fetchProducts called - loadMore: $loadMore, page: $_page');

    // Prevent multiple concurrent fetch requests
    if (_isLoading) return;

    try {
      // Set loading state to true and notify listeners
      _isLoading = true;
      notifyListeners();

      // Fetch new products from the API using the current limit and page
      final newProducts = await _apiService.fetchProducts(_limit, _page);
      print('Fetched ${newProducts.length} products: ${newProducts.map((p) => p.title).toList()}');

      if (loadMore) {
        // Append only new products that aren't already in the list (based on id)
        _products.addAll(newProducts.where((newP) => !_products.any((p) => p.id == newP.id)));
      } else {
        // Replace the current list with the newly fetched products
        _products = newProducts;
      }

      // Increment the page number only if new products were fetched
      if (newProducts.isNotEmpty) {
        _page++;
      }

      // Clear any previous error
      _error = null;
    } catch (e) {
      // Store the error message if fetching fails
      _error = e.toString();
      print('Error: $_error');
    } finally {
      // Reset loading state and notify listeners of the updated state
      _isLoading = false;
      notifyListeners();
      print('Current products: ${_products.map((p) => p.title).toList()}');
    }
  }

  // Sets the selected product and notifies listeners of the change
  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }
}