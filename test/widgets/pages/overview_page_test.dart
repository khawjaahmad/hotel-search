// test/widget/pages/overview_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/overview/presentation/pages/overview_page.dart';

// Test Helper (Self-contained)
Widget createTestApp({required Widget child}) {
  return MaterialApp(
    home: child,
    theme: ThemeData.light(),
  );
}

void main() {
  group('OverviewPage Widget', () {
    Widget createOverviewPage() {
      return createTestApp(child: const OverviewPage());
    }

    testWidgets('should display app bar with title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createOverviewPage());

      // Assert
      expect(find.byKey(const Key('overview_app_bar')), findsOneWidget);
      expect(find.byKey(const Key('overview_title')), findsOneWidget);
      expect(find.text('Hotel Booking'), findsOneWidget);
    });

    testWidgets('should display explore icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createOverviewPage());

      // Assert
      expect(find.byKey(const Key('overview_icon')), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    });

    testWidgets('should use correct scaffold key', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createOverviewPage());

      // Assert
      expect(find.byKey(const Key('overview_scaffold')), findsOneWidget);
    });
  });
}

