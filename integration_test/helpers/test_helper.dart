import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;

/// Streamlined Test Helper - Essential utilities only
/// Focused on core functionality with professional error handling
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

  /// Smart widget finder with timeout and retry logic
  static Future<void> waitForWidget(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    try {
      await $.pumpUntilFound(finder, timeout: timeout);
      debugPrint('✅ Widget found: ${description ?? finder.toString()}');
    } catch (e) {
      debugPrint(
          '❌ Widget not found: ${description ?? finder.toString()} - $e');
      rethrow;
    }
  }

  /// Enhanced tap with automatic waiting and verification
  static Future<void> tapByKey(
    PatrolIntegrationTester $,
    String key, {
    String? description,
  }) async {
    try {
      final finder = find.byKey(Key(key));
      await waitForWidget($, finder, description: description ?? 'Key: $key');
      await $(Key(key)).tap();
      await $.pumpAndSettle();
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
  }) async {
    try {
      final finder = find.byKey(Key(key));
      await waitForWidget($, finder,
          description: description ?? 'Text field: $key');
      await $(Key(key)).enterText(text);
      await $.pumpAndSettle();
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
  static bool isWidgetVisible(String key) {
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

  /// Private helper for widget disappearance
  static Future<void> _waitForWidgetToDisappear(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    final startTime = DateTime.now();
    while (finder.evaluate().isNotEmpty &&
        DateTime.now().difference(startTime) < timeout) {
      await $.pump(const Duration(milliseconds: 500));
    }
  }

  /// Reset initialization state (for testing)
  static void resetAppInitialization() {
    _isAppInitialized = false;
    debugPrint('🔄 App initialization state reset');
  }

  static Future<void> clearTextByKey(PatrolIntegrationTester $, String key, {String? description}) async {
    await $(find.byKey(Key(key))).enterText('');
  }

  static void verifyWidgetNotExists(String key, {String? description}) {
    expect(find.byKey(Key(key)), findsNothing);
  }

  static void verifyMultipleWidgetsExist(List<String> keys) {
    for (final key in keys) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
  }

  static Future<void> waitForWidgetToDisappear(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    bool isFound = true;
    final stopwatch = Stopwatch()..start();

    while (isFound && stopwatch.elapsed < timeout) {
      await $.pump(const Duration(milliseconds: 100));
      try {
        await $(finder).waitUntilVisible();
        isFound = true;
      } catch (e) {
        isFound = false;
      }
    }

    if (isFound) {
      throw Exception('Widget ${description ?? finder.toString()} did not disappear within $timeout');
    }
  }

  static Future<void> waitForMultipleWidgets(
    PatrolIntegrationTester $,
    List<String> keys, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (final key in keys) {
      await waitForWidget($, find.byKey(Key(key)), timeout: timeout);
    }
  }

  static Future<void> scrollUntilVisible(
    PatrolIntegrationTester $,
    String scrollableKey,
    String targetKey, {
    double delta = 100,
    int maxScrolls = 10,
    String? description,
  }) async {
    final scrollable = find.byKey(Key(scrollableKey));
    final target = find.byKey(Key(targetKey));
    
    for (int i = 0; i < maxScrolls; i++) {
      if (await isWidgetVisible(targetKey)) {
        return;
      }
      
      // Use drag instead of scroll
      await $(scrollable).dragTo(
        dy: -delta, // Negative for upward scroll
        duration: const Duration(milliseconds: 300),
      );
      await $.pump(const Duration(milliseconds: 300));
    }
    
    throw Exception('Could not make target element visible after $maxScrolls scrolls');
  }
}
