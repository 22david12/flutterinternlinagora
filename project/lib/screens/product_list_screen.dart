import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

// The main screen displaying a list of products
class ProductListScreen extends StatefulWidget {
  // Constructor with a key parameter for widget identification
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Controller to manage scrolling behavior of the product list
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Delay fetching products until the initial build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
    // Add a listener to detect when the user scrolls to the end and trigger "load more"
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<ProductProvider>(context, listen: false)
            .fetchProducts(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    // Clean up the scroll controller to prevent memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI with a Scaffold containing an AppBar and a dynamic product list layout
    return Scaffold(
      appBar: AppBar(
        // AppBar title styled with white text and bold font
        title: const Text(
          'Product List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: LayoutBuilder(
        // Adapt the layout based on available screen size
        builder: (context, constraints) {
          return OrientationBuilder(
            // Adjust layout based on device orientation
            builder: (context, orientation) {
              // Determine if the screen is wide (tablet) or in landscape mode
              bool isTablet = constraints.maxWidth > 600;
              bool isLandscape = orientation == Orientation.landscape;
              bool showTwoColumnLayout = isTablet || isLandscape;

              // Build a row with a product list and optional detail view
              return Row(
                children: [
                  // Container for the product list
                  Container(
                    width: showTwoColumnLayout
                        ? constraints.maxWidth * 0.3
                        : constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border(
                        right: BorderSide(
                          width: 1.0,
                          color: Colors.grey[400]!,
                        ),
                      ),
                    ),
                    child: Consumer<ProductProvider>(
                      // Rebuild the list when ProductProvider changes
                      builder: (context, provider, child) {
                        // Show loading indicator if data is loading and list is empty
                        if (provider.isLoading && provider.products.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        // Display error message if fetching fails
                        if (provider.error != null) {
                          return Center(child: Text(provider.error!));
                        }
                        // Build the scrollable list of products
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount:
                          provider.products.length + (provider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the end while fetching more products
                            if (index == provider.products.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final product = provider.products[index];
                            // Log rendering details for debugging
                            print('Rendering product $index: ${product.title} with key: ${Key(product.title)}');
                            return ListTile(
                              key: Key(product.title), // Unique key based on product title
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  // Fallback to error icon if image fails to load (e.g., in tests)
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                                ),
                              ),
                              title: Text(product.title,
                                  style: const TextStyle(fontSize: 16)),
                              subtitle: Text('\$${product.price}',
                                  style: const TextStyle(fontSize: 14)),
                              selected: provider.selectedProduct?.id == product.id,
                              onTap: () {
                                // Set the selected product in the provider
                                Provider.of<ProductProvider>(context, listen: false)
                                    .setSelectedProduct(product);
                                // Navigate to detail screen on narrow layouts
                                if (!showTwoColumnLayout) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                            product.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                          backgroundColor: Colors.blue[800],
                                        ),
                                        body: ProductDetailScreen(product: product),
                                      ),
                                    ),
                                  );
                                }
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Show product details in a second column on wide layouts
                  if (showTwoColumnLayout)
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Consumer<ProductProvider>(
                          // Rebuild the detail view when ProductProvider changes
                          builder: (context, provider, child) {
                            return provider.selectedProduct == null
                                ? const Center(
                              child: Text(
                                'Select a product',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                                : ProductDetailScreen(
                              product: provider.selectedProduct!,
                            );
                          },
                        ),
                      ),
                    )
                  // Empty placeholder for narrow layouts
                  else
                    Expanded(
                      child: Container(),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}