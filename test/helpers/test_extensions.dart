
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget and settles animations
  Future<void> pumpAndSettle() async {
    await pump();
    await pumpAndSettle();
  }

  /// Finds widget by key and verifies it exists
  Finder findByKeyAndVerify(Key key) {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    return finder;
  }

  /// Finds text and verifies it exists
  Finder findTextAndVerify(String text) {
    final finder = find.text(text);
    expect(finder, findsOneWidget);
    return finder;
  }

  /// Taps widget and settles
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Enters text and settles
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}

extension FinderExtensions on Finder {
  /// Verifies the finder finds exactly one widget
  void shouldFindOne() {
    expect(this, findsOneWidget);
  }

  /// Verifies the finder finds nothing
  void shouldFindNothing() {
    expect(this, findsNothing);
  }

  /// Verifies the finder finds at least one widget
  void shouldFindAtLeastOne() {
    expect(this, findsAtLeastNWidgets(1));
  }

  /// Verifies the finder finds exactly n widgets
  void shouldFindExactly(int count) {
    expect(this, findsNWidgets(count));
  }
}

