import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project/models/product.dart';
import 'package:project/providers/product_provider.dart';
import 'package:project/services/api_service.dart';

// Generate mocks for ApiService
@GenerateMocks([ApiService])
import 'unit_test.mocks.dart';

// Entry point for unit tests
void main() {
  // Unit Test: Verify that Product.fromJson parses JSON data correctly
  test('Product.fromJson parses JSON correctly', () {
    // Sample JSON data for a product
    final json = {
      'id': 1,
      'title': 'Test Product',
      'price': 10.0,
      'description': 'A test product',
      'image': 'https://example.com/image.jpg',
    };
    // Parse JSON into a Product object
    final product = Product.fromJson(json);
    // Verify that all fields are correctly parsed
    expect(product.id, 1);
    expect(product.title, 'Test Product');
    expect(product.price, 10.0);
    expect(product.description, 'A test product');
    expect(product.image, 'https://example.com/image.jpg');
  });

  // Group of unit tests for ProductProvider
  group('ProductProvider', () {
    // Mock instance of ApiService for testing
    late MockApiService mockApiService;
    // ProductProvider instance with mocked ApiService
    late ProductProvider productProvider;

    // Setup function to initialize mocks before each test
    setUp(() {
      mockApiService = MockApiService();
      productProvider = ProductProvider(apiService: mockApiService); // Use constructor with mock
    });

    // Test: Verify that fetchProducts updates the product list on successful fetch
    test('fetchProducts updates products list on success', () async {
      // Mock product data for a successful response
      final mockProducts = [
        Product(
          id: 1,
          title: 'Test Product 1',
          price: 10.0,
          description: 'Description 1',
          image: 'https://example.com/image1.jpg',
        ),
        Product(
          id: 2,
          title: 'Test Product 2',
          price: 20.0,
          description: 'Description 2',
          image: 'https://example.com/image2.jpg',
        ),
      ];

      // Mock API to return the predefined products
      when(mockApiService.fetchProducts(any, any))
          .thenAnswer((_) async => mockProducts);

      // Execute the fetchProducts method
      await productProvider.fetchProducts();

      // Verify that the product list is updated correctly
      expect(productProvider.products, mockProducts);
      expect(productProvider.isLoading, false); // Loading should be false after completion
      expect(productProvider.error, null); // No error should be present
    });

    // Test: Verify that fetchProducts sets an error on failure
    test('fetchProducts sets error on failure', () async {
      // Mock API to throw an exception
      when(mockApiService.fetchProducts(any, any))
          .thenThrow(Exception('Failed to load products'));

      // Execute the fetchProducts method
      await productProvider.fetchProducts();

      // Verify that the product list remains empty and error is set
      expect(productProvider.products, isEmpty);
      expect(productProvider.isLoading, false); // Loading should be false after completion
      expect(productProvider.error, 'Exception: Failed to load products'); // Error message should match
    });

    // Test: Verify that setSelectedProduct updates the selected product
    test('setSelectedProduct updates selected product', () {
      // Sample product to set as selected
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 10.0,
        description: 'Description',
        image: 'https://example.com/image.jpg',
      );

      // Set the selected product
      productProvider.setSelectedProduct(product);

      // Verify that the selected product is updated correctly
      expect(productProvider.selectedProduct, product);
    });
  });
}