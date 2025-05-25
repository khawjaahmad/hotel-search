// test/widget/components/hotel_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/hotels/presentation/widgets/hotel_card.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

// Test Data (Self-contained)
const testHotel = Hotel(
  name: 'Test Hotel',
  location: Location(latitude: 40.7128, longitude: -74.0060),
  description: 'A beautiful test hotel',
);

const hotelWithoutDescription = Hotel(
  name: 'Simple Hotel',
  location: Location(latitude: 41.8781, longitude: -87.6298),
);

// Test Helper (Self-contained)
Widget createTestApp({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
    theme: ThemeData.light(),
  );
}

void main() {
  group('HotelCard Widget', () {
    Widget createHotelCard({
      Hotel? hotel,
      bool? isFavorite,
      ValueChanged<bool>? onFavoriteChanged,
    }) {
      return createTestApp(
        child: HotelCard(
          hotel: hotel ?? testHotel,
          isFavorite: isFavorite ?? false,
          onFavoriteChanged: onFavoriteChanged ?? (value) {},
        ),
      );
    }

    testWidgets('should display hotel name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHotelCard());

      // Assert
      expect(find.text(testHotel.name), findsOneWidget);
    });

    testWidgets('should display hotel description when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHotelCard());

      // Assert
      expect(find.text(testHotel.description!), findsOneWidget);
    });

    testWidgets('should not display description when null', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHotelCard(hotel: hotelWithoutDescription));

      // Assert
      expect(find.text(hotelWithoutDescription.name), findsOneWidget);
      expect(find.byType(Text), findsOneWidget); // Only name text
    });

    testWidgets('should show correct favorite icon when not favorite', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHotelCard(isFavorite: false));

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.isSelected, isFalse);
    });

    testWidgets('should show correct favorite icon when favorite', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHotelCard(isFavorite: true));

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.isSelected, isTrue);
    });

    testWidgets('should call onFavoriteChanged when favorite button tapped', (tester) async {
      // Arrange
      bool callbackCalled = false;
      bool callbackValue = false;

      await tester.pumpWidget(createHotelCard(
        isFavorite: false,
        onFavoriteChanged: (value) {
          callbackCalled = true;
          callbackValue = value;
        },
      ));

      // Act
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Assert
      expect(callbackCalled, isTrue);
      expect(callbackValue, isTrue);
    });

    testWidgets('should use correct keys for components', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHotelCard());

      // Assert
      final hotelId = testHotel.location.decimalDegrees;
      expect(find.byKey(Key('hotel_card_$hotelId')), findsOneWidget);
      expect(find.byKey(Key('hotel_name_$hotelId')), findsOneWidget);
      expect(find.byKey(Key('hotel_description_$hotelId')), findsOneWidget);
      expect(find.byKey(Key('hotel_favorite_button_$hotelId')), findsOneWidget);
    });
  });
}

