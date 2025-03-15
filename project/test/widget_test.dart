import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:project/main.dart';
import 'package:project/models/product.dart';
import 'package:project/providers/product_provider.dart';
import 'package:project/screens/product_list_screen.dart';
import 'package:project/services/api_service.dart';

// Generate mocks for ApiService
@GenerateMocks([ApiService])
import 'widget_test.mocks.dart';

// Entry point for widget tests
void main() {
  // Mock instance of ApiService for testing
  late MockApiService mockApiService;
  // ProductProvider instance with mocked ApiService
  late ProductProvider productProvider;

  // Setup function to initialize mocks before each test
  setUp(() {
    mockApiService = MockApiService();
    productProvider = ProductProvider(apiService: mockApiService);
  });

  // Test: Verify that ProductListScreen shows a loading indicator initially
  testWidgets('ProductListScreen shows loading indicator initially',
          (WidgetTester tester) async {
        // Mock API to simulate a delayed empty response
        when(mockApiService.fetchProducts(any, any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [];
        });

        // Pump the widget tree with ProductProvider and ProductListScreen
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => productProvider,
            child: const MaterialApp(home: ProductListScreen()),
          ),
        );

        // Trigger a frame to start loading
        await tester.pump();
        // Simulate partial loading time
        await tester.pump(const Duration(milliseconds: 25));

        // Check if the loading indicator is displayed
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for all animations and loading to complete
        await tester.pumpAndSettle();
      });

  // Test: Verify that ProductListScreen displays products after loading
  testWidgets('ProductListScreen displays products after loading',
          (WidgetTester tester) async {
        // Mock product data for the initial load
        final mockProducts = [
          Product(
            id: 1,
            title: 'Initial Product 1',
            price: 10.0,
            description: 'Description 1',
            image: 'https://example.com/image1.jpg',
          ),
          Product(
            id: 2,
            title: 'Initial Product 2',
            price: 20.0,
            description: 'Description 2',
            image: 'https://example.com/image2.jpg',
          ),
        ];

        // Mock API to return the predefined products
        when(mockApiService.fetchProducts(any, any)).thenAnswer((_) async => mockProducts);

        // Pump the widget tree with ProductProvider and ProductListScreen
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => productProvider,
            child: const MaterialApp(home: ProductListScreen()),
          ),
        );

        // Wait for all animations and loading to complete
        await tester.pumpAndSettle();

        // Verify that the products are displayed with their keys and prices
        expect(find.byKey(const Key('Initial Product 1')), findsOneWidget);
        expect(find.byKey(const Key('Initial Product 2')), findsOneWidget);
        expect(find.text('\$10.0'), findsOneWidget);
        expect(find.text('\$20.0'), findsOneWidget);
      });

  // Test: Verify that ProductListScreen loads more products when scrolling
  testWidgets('ProductListScreen loads more products on scroll',
          (WidgetTester tester) async {
        // Set a larger screen size to display more products
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        // Generate initial product list with 20 items
        final initialProducts = List.generate(
          20,
              (index) => Product(
            id: index + 1,
            title: 'Initial Product ${index + 1}',
            price: 10.0 + index,
            description: 'Description ${index + 1}',
            image: 'https://example.com/image${index + 1}.jpg',
          ),
        );

        // Generate additional products for "load more" with 10 items
        final moreProducts = List.generate(
          10,
              (index) => Product(
            id: 20 + index + 1,
            title: 'More Product ${index + 1}',
            price: 20.0 + index,
            description: 'Description ${index + 21}',
            image: 'https://example.com/image${index + 21}.jpg',
          ),
        );

        // Mock API behavior for pagination
        when(mockApiService.fetchProducts(any, any)).thenAnswer((invocation) async {
          final page = invocation.positionalArguments[1] as int;
          if (page == 0) {
            return initialProducts; // Return initial products for page 0
          } else if (page == 1) {
            return moreProducts; // Return additional products for page 1
          } else {
            return []; // Return empty list for subsequent pages to prevent duplicates
          }
        });

        // Log initial product details for debugging
        print('Initial Products: ${initialProducts.length} items');
        print('First product title: ${initialProducts[0].title}');

        // Pump the widget tree with ProductProvider and ProductListScreen
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => productProvider,
            child: const MaterialApp(home: ProductListScreen()),
          ),
        );

        // Ensure initial fetchProducts call from initState completes
        await tester.pumpAndSettle();

        // Log the provider's product list state after initial load
        print('Provider products after pumpAndSettle: ${productProvider.products.map((p) => p.title).toList()}');

        // Verify that the first product is displayed
        expect(
          find.byKey(const Key('Initial Product 1')),
          findsOneWidget,
        );

        // Simulate scrolling to trigger "load more" functionality
        final listFinder = find.byType(ListView);
        await tester.dragUntilVisible(
          find.byKey(const Key('Initial Product 20')), // Scroll to the last initial product
          listFinder,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();

        // Log the updated product list after scrolling
        print('Products in provider after scroll: ${productProvider.products.map((p) => p.title).toList()}');
        // Verify that additional products have been loaded
        expect(productProvider.products.any((p) => p.title == 'More Product 1'), isTrue);

        // Log all widgets with keys after scrolling for debugging
        print('Widgets with key after scroll: ${tester.allWidgets.where((w) => w.key != null).map((w) => 'Key: ${w.key}, Widget: ${w.runtimeType}').toList()}');

        // Find the ListTile for "More Product 1" using its key
        final moreProductFinder = find.byKey(const Key('More Product 1'));

        // Fallback to text search if the key is not found
        if (moreProductFinder.evaluate().isEmpty) {
          print('Key not found, checking by text...');
          final textFinder = find.text('More Product 1');
          expect(textFinder, findsOneWidget);
          await tester.ensureVisible(textFinder);
          await tester.pumpAndSettle();
        }

        // Ensure the "More Product 1" widget is found
        expect(moreProductFinder, findsOneWidget);

        // Scroll to "More Product 1" to ensure it is visible
        await tester.ensureVisible(moreProductFinder);
        await tester.pumpAndSettle();

        // Verify that "More Product 1" remains displayed after scrolling
        expect(
          find.byKey(const Key('More Product 1')),
          findsOneWidget,
        );

        // Reset the screen size to default
        tester.binding.window.clearPhysicalSizeTestValue();
      });
}