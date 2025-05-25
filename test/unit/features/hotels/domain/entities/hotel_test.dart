// test/unit/features/hotels/domain/entities/hotel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

void main() {
  group('Hotel', () {
    const testLocation = Location(latitude: 40.7128, longitude: -74.0060);
    
    test('should create hotel with all required fields', () {
      // Arrange & Act
      const hotel = Hotel(
        name: 'Test Hotel',
        location: testLocation,
        description: 'A test hotel',
      );

      // Assert
      expect(hotel.name, 'Test Hotel');
      expect(hotel.location, testLocation);
      expect(hotel.description, 'A test hotel');
    });

    test('should create hotel without description', () {
      // Arrange & Act
      const hotel = Hotel(
        name: 'Test Hotel',
        location: testLocation,
      );

      // Assert
      expect(hotel.name, 'Test Hotel');
      expect(hotel.location, testLocation);
      expect(hotel.description, isNull);
    });

    test('should support equality comparison', () {
      // Arrange
      const hotel1 = Hotel(
        name: 'Test Hotel',
        location: testLocation,
        description: 'A test hotel',
      );
      const hotel2 = Hotel(
        name: 'Test Hotel',
        location: testLocation,
        description: 'A test hotel',
      );
      const hotel3 = Hotel(
        name: 'Different Hotel',
        location: testLocation,
        description: 'A test hotel',
      );

      // Act & Assert
      expect(hotel1, equals(hotel2));
      expect(hotel1, isNot(equals(hotel3)));
      expect(hotel1.hashCode, equals(hotel2.hashCode));
    });
  });
}

