// test/widget/components/search_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking/features/hotels/presentation/widgets/search_text_field.dart';

// Test Helper (Self-contained)
Widget createTestApp({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
    theme: ThemeData.light(),
  );
}

void main() {
  group('SearchTextField Widget', () {
    testWidgets('should display search hint text', (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Act
      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Assert
      expect(find.text('Search Hotels'), findsOneWidget);

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should display search icon', (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Act
      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Assert
      expect(find.byKey(const Key('search_prefix_icon')), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should display clear button', (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Act
      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Assert
      expect(find.byKey(const Key('search_clear_button')), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should update controller when text is entered',
        (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();
      const testText = 'New York';

      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Act
      await tester.enterText(find.byType(TextField), testText);

      // Assert
      expect(controller.text, equals(testText));

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should clear text when clear button is tapped',
        (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();
      controller.text = 'Some text';

      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Act
      await tester.tap(find.byKey(const Key('search_clear_button')));
      await tester.pump();

      // Assert
      expect(controller.text, isEmpty);

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should focus when text field is tapped', (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Act
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Assert
      expect(focusNode.hasFocus, isTrue);

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should use correct keys', (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Act
      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Assert
      expect(find.byKey(const Key('search_text_field')), findsOneWidget);
      expect(find.byKey(const Key('search_prefix_icon')), findsOneWidget);
      expect(find.byKey(const Key('search_suffix_icon')), findsOneWidget);

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('should handle text input and clearing correctly',
        (tester) async {
      // Arrange
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(createTestApp(
        child: SearchTextField(
          controller: controller,
          focusNode: focusNode,
        ),
      ));

      // Act 1: Enter text
      await tester.enterText(find.byType(TextField), 'Test Search');
      expect(controller.text, 'Test Search');

      // Act 2: Clear using button
      await tester.tap(find.byKey(const Key('search_clear_button')));
      await tester.pump();
      expect(controller.text, isEmpty);

      // Act 3: Enter new text
      await tester.enterText(find.byType(TextField), 'Another Search');
      expect(controller.text, 'Another Search');

      // Cleanup
      controller.dispose();
      focusNode.dispose();
    });
  });
}
