# Flutter Intern Technical Assessment Report

## Overview
This project is a simple Flutter application built to meet the requirements of the Flutter Intern Technical Assessment. It demonstrates responsive UI design, API integration, state management, testing, and clean code practices.

## State Management Choice
- **Chosen Approach**: Provider
- **Reason**: Provider is a lightweight and simple state management solution provided by the Flutter community. It integrates well with Flutter's widget tree, is easy to set up, and is suitable for small to medium-sized applications like this one. It also supports dependency injection, making it ideal for testing with mocks.

## Testing Strategy
- **Unit Tests** (`test/unit_test.dart`):
  - Test `fetchProducts` in `ProductProvider` to ensure it updates the product list on success and sets an error on failure.
  - Mock `ApiService` to simulate API responses.
- **Widget Tests** (`test/widget_test.dart`):
  - Test `ProductListScreen` to verify:
    - Loading indicator is shown initially.
    - Products are displayed after loading.
    - "Load more" functionality works when scrolling to the bottom.
  - Use `mockito` to mock `ApiService` and control API responses during tests.

## How to Run the Application
1. Clone the repository:
   - git clone <repository-url>
2. Navigate to the project directory:
   - cd project
3. Install dependencies:
   - flutter pub get
4. Run the application:
   - flutter run

## API Used
- **API**: A mock API is used for testing (simulated via `mockito`). In a real scenario, the app can use the **FakeStore API** ([https://fakestoreapi.com/](https://fakestoreapi.com/)) to fetch product data. This API provides a free RESTful interface for e-commerce products, supporting pagination with endpoints like `https://fakestoreapi.com/products?limit={limit}&offset={offset}`.
- **Implementation**: The `ApiService` class handles API requests, and pagination is implemented using `page` and `limit` parameters to simulate "load more" functionality.

## Additional Notes
- The project uses `Key` in `ListTile` to avoid key conflicts when rendering the product list.
- Code is formatted using `flutter format` to ensure consistency.
