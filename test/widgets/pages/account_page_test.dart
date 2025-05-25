// test/widget/pages/account_page_test.dart  
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/account/presentation/pages/account_page.dart';

// Test Helper (Self-contained)
Widget createTestApp({required Widget child}) {
  return MaterialApp(
    home: child,
    theme: ThemeData.light(),
  );
}

void main() {
  group('AccountPage Widget', () {
    Widget createAccountPage() {
      return createTestApp(child: const AccountPage());
    }

    testWidgets('should display app bar with title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createAccountPage());

      // Assert
      expect(find.byKey(const Key('account_app_bar')), findsOneWidget);
      expect(find.byKey(const Key('account_title')), findsOneWidget);
      expect(find.text('Your Account'), findsOneWidget);
    });

    testWidgets('should display account icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createAccountPage());

      // Assert
      expect(find.byKey(const Key('account_icon')), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('should use correct scaffold key', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createAccountPage());

      // Assert
      expect(find.byKey(const Key('account_scaffold')), findsOneWidget);
    });
  });
}

