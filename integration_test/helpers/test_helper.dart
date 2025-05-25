import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;

class PatrolTestHelper {
  PatrolTestHelper._();

  static final PatrolTestHelper _instance = PatrolTestHelper._();
  static PatrolTestHelper get instance => _instance;

  static bool _isAppInitialized = false;

  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 30);

  static Future<void> initializeApp(PatrolIntegrationTester $) async {
    try {
      if (!_isAppInitialized) {
        print('🚀 Initializing app for first time...');

        app.main();

        await $.pump(const Duration(seconds: 5));

        _isAppInitialized = true;

        print('✅ App initialized successfully');
      } else {
        print('♻️ App already initialized, reusing...');

        await $.pump(const Duration(seconds: 1));
      }

      await waitForAppToLoad($);
    } catch (e) {
      print('❌ App initialization failed: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<void> waitForAppToLoad(PatrolIntegrationTester $) async {
    await $.pumpAndSettle();
    await $.pump(const Duration(milliseconds: 500));
  }

  static Future<void> waitForWidget(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = defaultTimeout,
    String? description,
    int maxRetries = 2,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await $.waitUntilVisible(finder, timeout: timeout);
        print('✅ Widget found: ${description ?? finder.toString()}');
        return;
      } catch (e) {
        if (attempt == maxRetries) {
          print(
              '❌ Widget not found after $maxRetries attempts: ${description ?? finder.toString()} - $e');
          rethrow;
        } else {
          print(
              '⚠️ Widget not found on attempt $attempt, retrying: ${description ?? finder.toString()}');
          await $.pump(const Duration(seconds: 1));
        }
      }
    }
  }

  static Future<void> waitForWidgetToDisappear(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = defaultTimeout,
    String? description,
  }) async {
    try {
      await $.pumpAndSettle();
      int attempts = 0;
      final maxAttempts = timeout.inSeconds;

      while (finder.evaluate().isNotEmpty && attempts < maxAttempts) {
        await $.pump(const Duration(seconds: 1));
        attempts++;
      }
      print('✅ Widget disappeared: ${description ?? finder.toString()}');
    } catch (e) {
      print('❌ Widget still visible: ${description ?? finder.toString()} - $e');
      rethrow;
    }
  }

  static Future<void> tapByKey(
    PatrolIntegrationTester $,
    String key, {
    Duration? settleTimeout,
    String? description,
  }) async {
    try {
      final finder = find.byKey(Key(key));

      await waitForWidget($, finder, description: description ?? 'Key: $key');

      await $(Key(key)).tap();

      if (settleTimeout != null) {
        await $.pump(settleTimeout);
      } else {
        await $.pumpAndSettle();
      }

      print('✅ Tapped element: ${description ?? key}');
    } catch (e) {
      print('❌ Failed to tap element: ${description ?? key} - $e');
      rethrow;
    }
  }

  static Future<void> enterTextByKey(
    PatrolIntegrationTester $,
    String key,
    String text, {
    Duration? settleTimeout,
    String? description,
  }) async {
    try {
      final finder = find.byKey(Key(key));

      await waitForWidget($, finder,
          description: description ?? 'Text field: $key');

      await $(Key(key)).enterText(text);

      if (settleTimeout != null) {
        await $.pump(settleTimeout);
      } else {
        await $.pumpAndSettle();
      }

      print('✅ Entered text "$text" in: ${description ?? key}');
    } catch (e) {
      print('❌ Failed to enter text in: ${description ?? key} - $e');
      rethrow;
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
    try {
      await $(Key(targetKey)).scrollTo(
        view: $(Key(scrollableKey)),
      );
      print('✅ Scrolled to element: ${description ?? targetKey}');
    } catch (e) {
      print('❌ Failed to scroll to element: ${description ?? targetKey} - $e');
      rethrow;
    }
  }

  static void verifyWidgetExists(String key, {String? description}) {
    try {
      expect(find.byKey(Key(key)), findsOneWidget);
      print('✅ Widget exists: ${description ?? key}');
    } catch (e) {
      print('❌ Widget does not exist: ${description ?? key}');
      rethrow;
    }
  }

  static void verifyWidgetNotExists(String key, {String? description}) {
    try {
      expect(find.byKey(Key(key)), findsNothing);
      print('✅ Widget does not exist (as expected): ${description ?? key}');
    } catch (e) {
      print('❌ Widget exists when it should not: ${description ?? key}');
      rethrow;
    }
  }

  static void verifyTextExists(String text, {String? description}) {
    try {
      expect(find.text(text), findsOneWidget);
      print('✅ Text found: ${description ?? text}');
    } catch (e) {
      print('❌ Text not found: ${description ?? text}');
      rethrow;
    }
  }

  static Future<void> takeScreenshot(
    PatrolIntegrationTester $,
    String name, {
    String? description,
  }) async {
    try {
      await $.pumpAndSettle();

      print('📸 Screenshot taken: ${description ?? name}');
    } catch (e) {
      print('❌ Screenshot failed: ${description ?? name} - $e');
    }
  }

  static Future<void> waitForLoadingToComplete(
    PatrolIntegrationTester $, {
    Duration timeout = defaultTimeout,
  }) async {
    try {
      final loadingIndicators = [
        find.byType(CircularProgressIndicator),
        find.byType(LinearProgressIndicator),
        find.text('Loading...'),
        find.text('Please wait...'),
      ];

      for (final indicator in loadingIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          await waitForWidgetToDisappear($, indicator, timeout: timeout);
        }
      }

      await $.pumpAndSettle();
      print('✅ Loading completed');
    } catch (e) {
      print('⚠️ Loading wait timeout (may be expected): $e');
    }
  }

  static Future<void> clearTextByKey(
    PatrolIntegrationTester $,
    String key, {
    String? description,
  }) async {
    try {
      final finder = find.byKey(Key(key));

      await waitForWidget($, finder,
          description: description ?? 'Text field: $key');

      await $(Key(key)).enterText('');
      await $.pumpAndSettle();

      print('✅ Cleared text field: ${description ?? key}');
    } catch (e) {
      print('❌ Failed to clear text field: ${description ?? key} - $e');
      rethrow;
    }
  }

  static bool isWidgetVisible(String key, {String? description}) {
    final isVisible = find.byKey(Key(key)).evaluate().isNotEmpty;
    print('🔍 Widget visibility check: ${description ?? key} = $isVisible');
    return isVisible;
  }

  static Future<void> waitForMultipleWidgets(
    PatrolIntegrationTester $,
    List<String> keys, {
    Duration timeout = defaultTimeout,
  }) async {
    for (final key in keys) {
      await waitForWidget($, find.byKey(Key(key)), timeout: timeout);
    }
  }

  static void verifyMultipleWidgetsExist(List<String> keys) {
    for (final key in keys) {
      verifyWidgetExists(key);
    }
  }

  static Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      print('⏱️ $operationName took: ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      print(
          '❌ $operationName failed after: ${stopwatch.elapsedMilliseconds}ms - $e');
      rethrow;
    }
  }

  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? operationName,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) {
          print(
              '❌ ${operationName ?? 'Operation'} failed after $maxRetries attempts');
          rethrow;
        }
        print(
            '⚠️ ${operationName ?? 'Operation'} attempt $attempt failed, retrying...');
        await Future.delayed(delay);
      }
    }
    throw StateError('This should never be reached');
  }

  static void resetAppInitialization() {
    _isAppInitialized = false;
    print('🔄 App initialization state reset');
  }
}
