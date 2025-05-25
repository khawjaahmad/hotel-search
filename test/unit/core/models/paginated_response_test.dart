// test/unit/core/models/paginated_response_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/core/models/models.dart';

void main() {
  group('PaginatedResponse', () {
    test('should create paginated response with items and next page token', () {
      // Arrange & Act
      const response = PaginatedResponse<String>(
        items: ['item1', 'item2'],
        nextPageToken: 'next_page',
      );

      // Assert
      expect(response.items, equals(['item1', 'item2']));
      expect(response.nextPageToken, equals('next_page'));
    });

    test('should create paginated response with null next page token', () {
      // Arrange & Act
      const response = PaginatedResponse<String>(
        items: ['item1', 'item2'],
        nextPageToken: null,
      );

      // Assert
      expect(response.items, equals(['item1', 'item2']));
      expect(response.nextPageToken, isNull);
    });

    test('should create paginated response with empty items list', () {
      // Arrange & Act
      const response = PaginatedResponse<String>(
        items: [],
        nextPageToken: 'next_page',
      );

      // Assert
      expect(response.items, isEmpty);
      expect(response.nextPageToken, equals('next_page'));
    });

    test('should support equality comparison', () {
      // Arrange
      const response1 = PaginatedResponse<String>(
        items: ['item1', 'item2'],
        nextPageToken: 'next_page',
      );
      const response2 = PaginatedResponse<String>(
        items: ['item1', 'item2'],
        nextPageToken: 'next_page',
      );
      const response3 = PaginatedResponse<String>(
        items: ['item1', 'item3'],
        nextPageToken: 'next_page',
      );

      // Act & Assert
      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
      expect(response1.hashCode, equals(response2.hashCode));
    });

    test('should handle different types', () {
      // Arrange & Act
      const stringResponse = PaginatedResponse<String>(
        items: ['string1', 'string2'],
        nextPageToken: 'token1',
      );
      const intResponse = PaginatedResponse<int>(
        items: [1, 2, 3],
        nextPageToken: 'token2',
      );

      // Assert
      expect(stringResponse.items, isA<List<String>>());
      expect(intResponse.items, isA<List<int>>());
      expect(stringResponse.items.length, equals(2));
      expect(intResponse.items.length, equals(3));
    });

    test('should include both items and nextPageToken in equality check', () {
      // Arrange
      const response1 = PaginatedResponse<String>(
        items: ['item1'],
        nextPageToken: 'token1',
      );
      const response2 = PaginatedResponse<String>(
        items: ['item1'],
        nextPageToken: 'token2',
      );
      const response3 = PaginatedResponse<String>(
        items: ['item2'],
        nextPageToken: 'token1',
      );

      // Act & Assert
      expect(response1, isNot(equals(response2))); // Different tokens
      expect(response1, isNot(equals(response3))); // Different items
    });

    test('should handle null vs non-null next page token in equality', () {
      // Arrange
      const response1 = PaginatedResponse<String>(
        items: ['item1'],
        nextPageToken: null,
      );
      const response2 = PaginatedResponse<String>(
        items: ['item1'],
        nextPageToken: 'token',
      );

      // Act & Assert
      expect(response1, isNot(equals(response2)));
    });
  });
}
