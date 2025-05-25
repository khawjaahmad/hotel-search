import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;

/// Streamlined Test Helper - Essential utilities only
/// Focused on core functionality with professional error handling
/// FIXED: Removed non-existent pumpUntilFound method
class PatrolTestHelper {
  PatrolTestHelper._();

  static bool _isAppInitialized = false;
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration shortTimeout = Duration(seconds: 5);

  /// Initialize app for testing - handles first run vs subsequent runs
  static Future<void> initializeApp(PatrolIntegrationTester $) async {
    try {
      if (!_isAppInitialized) {
        debugPrint('🚀 Initializing app for first time...');
        app.main();
        await $.pump(const Duration(seconds: 5));
        _isAppInitialized = true;
        debugPrint('✅ App initialized successfully');
      } else {
        debugPrint('♻️ App already initialized, pumping...');
        await $.pump(const Duration(seconds: 1));
      }
      await _waitForAppStability($);
    } catch (e) {
      debugPrint('❌ App initialization failed: $e');
      rethrow;
    }
  }

  /// Wait for app to reach stable state
  static Future<void> _waitForAppStability(PatrolIntegrationTester $) async {
    await $.pumpAndSettle();
    await $.pump(const Duration(milliseconds: 500));
  }

  /// Smart widget waiting with timeout - PROPER PATROL METHOD
  static Future<void> waitForWidget(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    try {
      debugPrint('🔍 Waiting for widget: ${description ?? finder.toString()}');
      await $(finder).waitUntilVisible(timeout: timeout);
      debugPrint('✅ Widget found: ${description ?? finder.toString()}');
    } on WaitUntilVisibleTimeoutException catch (e) {
      debugPrint(
          '❌ Widget not visible within timeout: ${description ?? finder.toString()} - $e');
      rethrow;
    } on PatrolFinderException catch (e) {
      debugPrint(
          '❌ Widget not found: ${description ?? finder.toString()} - $e');
      rethrow;
    } catch (e) {
      debugPrint(
          '❌ Unexpected error while waiting for widget: ${description ?? finder.toString()} - $e');
      rethrow;
    }
  }

  /// Enhanced tap with automatic waiting and verification
  static Future<void> tapByKey(
    PatrolIntegrationTester $,
    String key, {
    String? description,
    Duration? settleTimeout,
  }) async {
    try {
      final finder = find.byKey(Key(key));
      await waitForWidget($, finder, description: description ?? 'Key: $key');

      await $(Key(key)).tap();

      // Handle settle timeout
      if (settleTimeout != null) {
        await $.pump(settleTimeout);
      } else {
        await $.pumpAndSettle();
      }

      debugPrint('✅ Tapped: ${description ?? key}');
    } catch (e) {
      debugPrint('❌ Failed to tap: ${description ?? key} - $e');
      rethrow;
    }
  }

  /// Enhanced text entry with validation
  static Future<void> enterTextByKey(
    PatrolIntegrationTester $,
    String key,
    String text, {
    String? description,
    Duration? settleTimeout,
  }) async {
    try {
      final finder = find.byKey(Key(key));
      await waitForWidget($, finder,
          description: description ?? 'Text field: $key');

      await $(Key(key)).enterText(text);

      // Handle settle timeout
      if (settleTimeout != null) {
        await $.pump(settleTimeout);
      } else {
        await $.pumpAndSettle();
      }

      debugPrint('✅ Entered text "$text" in: ${description ?? key}');
    } catch (e) {
      debugPrint('❌ Failed to enter text in: ${description ?? key} - $e');
      rethrow;
    }
  }

  /// Professional screenshot with consistent naming
  static Future<void> takeScreenshot(
    PatrolIntegrationTester $,
    String name, {
    String? description,
  }) async {
    try {
      await $.pumpAndSettle();
      debugPrint('📸 Screenshot: ${description ?? name}');
      // Note: Actual screenshot functionality depends on Patrol setup
    } catch (e) {
      debugPrint('❌ Screenshot failed: ${description ?? name} - $e');
    }
  }

  /// Smart loading completion detection
  static Future<void> waitForLoadingToComplete(
    PatrolIntegrationTester $, {
    Duration timeout = defaultTimeout,
  }) async {
    try {
      // Check for common loading indicators
      final loadingIndicators = [
        find.byType(CircularProgressIndicator),
        find.byType(LinearProgressIndicator),
        find.byKey(const Key('hotels_loading_indicator')),
        find.byKey(const Key('hotels_pagination_loading')),
      ];

      for (final indicator in loadingIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          await _waitForWidgetToDisappear($, indicator, timeout: timeout);
        }
      }

      await $.pumpAndSettle();
      debugPrint('✅ Loading completed');
    } catch (e) {
      debugPrint('⚠️ Loading wait timeout: $e');
    }
  }

  /// Widget visibility check
  static bool isWidgetVisible(String key, {String? description}) {
    final isVisible = find.byKey(Key(key)).evaluate().isNotEmpty;
    return isVisible;
  }

  /// Professional assertion with clear error messages
  static void verifyWidgetExists(String key, {String? description}) {
    try {
      expect(find.byKey(Key(key)), findsOneWidget);
      debugPrint('✅ Widget verified: ${description ?? key}');
    } catch (e) {
      debugPrint('❌ Widget missing: ${description ?? key}');
      rethrow;
    }
  }

  /// Verify widget does not exist
  static void verifyWidgetNotExists(String key, {String? description}) {
    try {
      expect(find.byKey(Key(key)), findsNothing);
      debugPrint('✅ Widget absence verified: ${description ?? key}');
    } catch (e) {
      debugPrint('❌ Widget unexpectedly exists: ${description ?? key}');
      rethrow;
    }
  }

  /// Text existence verification
  static void verifyTextExists(String text, {String? description}) {
    try {
      expect(find.text(text), findsOneWidget);
      debugPrint('✅ Text verified: ${description ?? text}');
    } catch (e) {
      debugPrint('❌ Text not found: ${description ?? text}');
      rethrow;
    }
  }

  /// Performance measurement utility
  static Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      debugPrint('⏱️ $operationName: ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '❌ $operationName failed after: ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }

  /// Clear text from element
  static Future<void> clearTextByKey(
    PatrolIntegrationTester $,
    String key, {
    String? description,
  }) async {
    try {
      await $(find.byKey(Key(key))).enterText('');
      await $.pumpAndSettle();
      debugPrint('✅ Cleared text: ${description ?? key}');
    } catch (e) {
      debugPrint('❌ Failed to clear text: ${description ?? key} - $e');
      rethrow;
    }
  }

  /// Verify multiple widgets exist
  static void verifyMultipleWidgetsExist(List<String> keys) {
    for (final key in keys) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
  }

  /// Wait for widget to disappear - PROPER PATROL METHOD
  static Future<void> waitForWidgetToDisappear(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    try {
      // For disappearing widgets, we need to poll since Patrol doesn't have waitUntilNotVisible
      await _waitForWidgetToDisappear($, finder, timeout: timeout);
      debugPrint('✅ Widget disappeared: ${description ?? finder.toString()}');
    } catch (e) {
      debugPrint(
          '❌ Widget did not disappear: ${description ?? finder.toString()} - $e');
      rethrow;
    }
  }

  /// Wait for multiple widgets
  static Future<void> waitForMultipleWidgets(
    PatrolIntegrationTester $,
    List<String> keys, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (final key in keys) {
      await waitForWidget($, find.byKey(Key(key)), timeout: timeout);
    }
  }

  /// Scroll until element is visible - PROPER PATROL METHOD
  static Future<void> scrollUntilVisible(
    PatrolIntegrationTester $,
    String scrollableKey,
    String targetKey, {
    double delta = 100,
    int maxScrolls = 10,
    String? description,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final target = find.byKey(Key(targetKey));

    // Check if target is already visible
    if (await _isWidgetVisible($, target)) {
      debugPrint('✅ Target already visible: ${description ?? targetKey}');
      return;
    }

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < maxScrolls; i++) {
      if (stopwatch.elapsed > timeout) {
        throw Exception(
            'Scroll operation timed out after ${timeout.inSeconds} seconds');
      }

      try {
        await $(target).scrollTo(
          view: $(Key(scrollableKey)),
          maxScrolls: 1,
          timeout: Duration(milliseconds: timeout.inMilliseconds ~/ maxScrolls),
        );

        debugPrint(
            '✅ Target found after scrolling: ${description ?? targetKey}');
        return;
      } on PatrolFinderException catch (e) {
        debugPrint('⚠️ Scroll attempt ${i + 1} - target not found: $e');
        if (i == maxScrolls - 1) {
          throw Exception(
              'Could not make target element visible after $maxScrolls scroll attempts: ${description ?? targetKey}');
        }
      }
    }
  }

  /// Private helper for widget disappearance - FIXED METHOD
  static Future<void> _waitForWidgetToDisappear(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10), // Add default timeout
    String? description,
  }) async {
    final startTime = DateTime.now();
    final elementDescription = description ?? finder.toString();

    debugPrint('🔍 Waiting for widget to disappear: $elementDescription');

    while (finder.evaluate().isNotEmpty &&
        DateTime.now().difference(startTime) < timeout) {
      await $.pump(const Duration(milliseconds: 500));
    }

    if (finder.evaluate().isNotEmpty) {
      throw Exception(
          'Widget did not disappear within ${timeout.inSeconds}s: $elementDescription');
    }

    debugPrint('✅ Widget disappeared: $elementDescription');
  }

  /// Private helper to check widget visibility
  static Future<bool> _isWidgetVisible(
      PatrolIntegrationTester $, Finder finder) async {
    try {
      await $(finder)
          .waitUntilVisible(timeout: const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset initialization state (for testing)
  static void resetAppInitialization() {
    _isAppInitialized = false;
    debugPrint('🔄 App initialization state reset');
  }
}
