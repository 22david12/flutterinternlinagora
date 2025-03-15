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
