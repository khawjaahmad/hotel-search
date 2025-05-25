// test/unit/features/hotels/domain/entities/search_params_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

void main() {
  group('SearchParams', () {
    final checkInDate = DateTime(2024, 1, 15);
    final checkOutDate = DateTime(2024, 1, 17);

    test('should create search params with valid dates', () {
      // Arrange & Act
      final searchParams = SearchParams(
        query: 'New York',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // Assert
      expect(searchParams.query, 'New York');
      expect(searchParams.checkInDate, checkInDate);
      expect(searchParams.checkOutDate, checkOutDate);
    });

    test(
        'should throw assertion error when check-in date is after check-out date',
        () {
      // Arrange
      final invalidCheckOutDate = DateTime(2024, 1, 14);

      // Act & Assert
      expect(
        () => SearchParams(
          query: 'New York',
          checkInDate: checkInDate,
          checkOutDate: invalidCheckOutDate,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should support equality comparison', () {
      // Arrange
      final searchParams1 = SearchParams(
        query: 'New York',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );
      final searchParams2 = SearchParams(
        query: 'New York',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );
      final searchParams3 = SearchParams(
        query: 'Boston',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // Act & Assert
      expect(searchParams1, equals(searchParams2));
      expect(searchParams1, isNot(equals(searchParams3)));
      expect(searchParams1.hashCode, equals(searchParams2.hashCode));
    });

    test('should create copy with updated query', () {
      // Arrange
      final originalParams = SearchParams(
        query: 'New York',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // Act
      final updatedParams = originalParams.copyWith(query: 'Boston');

      // Assert
      expect(updatedParams.query, 'Boston');
      expect(updatedParams.checkInDate, checkInDate);
      expect(updatedParams.checkOutDate, checkOutDate);
      expect(originalParams.query, 'New York'); // Original unchanged
    });

    test('should handle empty query', () {
      // Arrange & Act
      final searchParams = SearchParams(
        query: '',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // Assert
      expect(searchParams.query, '');
    });
  });
}
