// test/unit/features/hotels/domain/entities/location_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

void main() {
  group('Location', () {
    test('should create location with latitude and longitude', () {
      // Arrange & Act
      const location = Location(latitude: 40.7128, longitude: -74.0060);

      // Assert
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
    });

    test('should generate correct decimal degrees string', () {
      // Arrange
      const location = Location(latitude: 40.7128, longitude: -74.0060);

      // Act
      final decimalDegrees = location.decimalDegrees;

      // Assert
      expect(decimalDegrees, '40.7128,-74.006');
    });

    test('should support equality comparison', () {
      // Arrange
      const location1 = Location(latitude: 40.7128, longitude: -74.0060);
      const location2 = Location(latitude: 40.7128, longitude: -74.0060);
      const location3 = Location(latitude: 41.8781, longitude: -87.6298);

      // Act & Assert
      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
      expect(location1.hashCode, equals(location2.hashCode));
    });

    test('should handle negative coordinates', () {
      // Arrange & Act
      const location = Location(latitude: -33.8688, longitude: 151.2093);

      // Assert
      expect(location.latitude, -33.8688);
      expect(location.longitude, 151.2093);
      expect(location.decimalDegrees, '-33.8688,151.2093');
    });
  });
}

