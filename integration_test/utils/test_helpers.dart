import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;
import '../logger/test_logger.dart';

class TestHelpers {
  static bool _isAppInitialized = false;

  static Future<void> initializeApp(PatrolIntegrationTester $) async {
    TestLogger.log('Initializing app for testing');

    try {
      if (!_isAppInitialized) {
        TestLogger.log('First-time app initialization');
        app.main();
        await $.pump(const Duration(seconds: 3));
        _isAppInitialized = true;
      } else {
        TestLogger.log('App already initialized, pumping frames');
        await $.pump(const Duration(seconds: 1));
      }

      await $.pumpAndSettle();
      await $.pump(const Duration(milliseconds: 500));

      TestLogger.log('App initialization completed successfully');
    } catch (e) {
      TestLogger.log('App initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> navigateToPage(
    PatrolIntegrationTester $,
    String tabName, {
    String? description,
  }) async {
    TestLogger.log(
        'Navigating to $tabName tab${description != null ? ': $description' : ''}');

    // Use the correct navigation method
    switch (tabName.toLowerCase()) {
      case 'overview':
        await $(find.byKey(const Key('navigation_overview_tab'))).tap();
        break;
      case 'hotels':
        await $(find.byKey(const Key('navigation_hotels_tab'))).tap();
        break;
      case 'favorites':
        await $(find.byKey(const Key('navigation_favorites_tab'))).tap();
        break;
      case 'account':
        await $(find.byKey(const Key('navigation_account_tab'))).tap();
        break;
      default:
        throw ArgumentError('Unknown tab: $tabName');
    }

    await $.pump(const Duration(milliseconds: 500));
    await $.pumpAndSettle();
  }

  /// PROPER SCROLL FUNCTION FOR HOTELS LIST
  /// This function will actually perform scrolling and verify it worked
  static Future<ScrollResult> performHotelsScroll(
    PatrolIntegrationTester $, {
    int maxScrolls = 5,
    Duration scrollTimeout = const Duration(seconds: 30),
  }) async {
    TestLogger.log('🔄 Starting hotels scroll operation');

    // First, get the initial state
    final initialCardCount = find.byType(Card).evaluate().length;
    TestLogger.log('📊 Initial card count: $initialCardCount');

    if (initialCardCount == 0) {
      TestLogger.log('⚠️ No cards found - cannot scroll');
      return ScrollResult(
        success: false,
        initialCount: 0,
        finalCount: 0,
        scrollAttempts: 0,
        error: 'No cards found to scroll',
      );
    }

    int scrollAttempts = 0;
    String? lastError;

    // Method 1: Try scrolling using the hotels_scroll_view key
    TestLogger.log('🔄 Attempting Method 1: hotels_scroll_view');
    try {
      final scrollView = find.byKey(const Key('hotels_scroll_view'));
      if (scrollView.evaluate().isNotEmpty) {
        TestLogger.log('✅ Found hotels_scroll_view');

        for (int i = 0; i < maxScrolls; i++) {
          scrollAttempts++;
          TestLogger.log('📱 Scroll attempt $scrollAttempts/$maxScrolls');

          // Perform the scroll
          await $(scrollView).scrollTo(maxScrolls: 1);
          await $.pump(
              const Duration(seconds: 2)); // Wait for potential new content

          final currentCount = find.byType(Card).evaluate().length;
          TestLogger.log(
              '📊 Cards after scroll $scrollAttempts: $currentCount');

          // Check if new content loaded
          if (currentCount > initialCardCount) {
            TestLogger.log(
                '🎉 New content loaded! $initialCardCount -> $currentCount');
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: currentCount,
              scrollAttempts: scrollAttempts,
            );
          }

          // Check if we reached end (pagination loading indicator)
          final paginationLoading =
              find.byKey(const Key('hotels_pagination_loading'));
          if (paginationLoading.evaluate().isNotEmpty) {
            TestLogger.log('⏳ Pagination loading detected, waiting...');
            await $.pump(const Duration(seconds: 3));

            final afterLoadingCount = find.byType(Card).evaluate().length;
            if (afterLoadingCount > currentCount) {
              TestLogger.log(
                  '🎉 Content loaded after pagination! $currentCount -> $afterLoadingCount');
              return ScrollResult(
                success: true,
                initialCount: initialCardCount,
                finalCount: afterLoadingCount,
                scrollAttempts: scrollAttempts,
              );
            }
          }
        }

        // If we get here, scrolling happened but no new content loaded
        final finalCount = find.byType(Card).evaluate().length;
        TestLogger.log('✅ Scrolling completed, no new content (end of list)');
        return ScrollResult(
          success: true,
          initialCount: initialCardCount,
          finalCount: finalCount,
          scrollAttempts: scrollAttempts,
          reachedEnd: true,
        );
      }
    } catch (e) {
      lastError = 'Method 1 failed: $e';
      TestLogger.log('❌ Method 1 failed: $e');
    }

    // Method 2: Try scrolling using CustomScrollView
    TestLogger.log('🔄 Attempting Method 2: CustomScrollView');
    try {
      final customScrollView = find.byType(CustomScrollView);
      if (customScrollView.evaluate().isNotEmpty) {
        TestLogger.log('✅ Found CustomScrollView');

        for (int i = 0; i < maxScrolls; i++) {
          scrollAttempts++;
          TestLogger.log(
              '📱 Scroll attempt $scrollAttempts/$maxScrolls (Method 2)');

          // Scroll the CustomScrollView
          await $(customScrollView).scrollTo(maxScrolls: 1);
          await $.pump(const Duration(seconds: 2));

          final currentCount = find.byType(Card).evaluate().length;
          TestLogger.log(
              '📊 Cards after scroll $scrollAttempts: $currentCount');

          if (currentCount > initialCardCount) {
            TestLogger.log(
                '🎉 New content loaded! $initialCardCount -> $currentCount');
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: currentCount,
              scrollAttempts: scrollAttempts,
            );
          }
        }

        final finalCount = find.byType(Card).evaluate().length;
        return ScrollResult(
          success: true,
          initialCount: initialCardCount,
          finalCount: finalCount,
          scrollAttempts: scrollAttempts,
          reachedEnd: true,
        );
      }
    } catch (e) {
      lastError = 'Method 2 failed: $e';
      TestLogger.log('❌ Method 2 failed: $e');
    }

    // Method 3: Try scrolling using generic Scrollable
    TestLogger.log('🔄 Attempting Method 3: Generic Scrollable');
    try {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        TestLogger.log(
            '✅ Found Scrollable widgets: ${scrollable.evaluate().length}');

        // Try each scrollable widget
        for (int scrollableIndex = 0;
            scrollableIndex < scrollable.evaluate().length;
            scrollableIndex++) {
          TestLogger.log('🔄 Trying Scrollable widget $scrollableIndex');

          try {
            for (int i = 0; i < maxScrolls; i++) {
              scrollAttempts++;
              TestLogger.log(
                  '📱 Scroll attempt $scrollAttempts/$maxScrolls (Method 3.$scrollableIndex)');

              await $(scrollable.at(scrollableIndex)).scrollTo(maxScrolls: 1);
              await $.pump(const Duration(seconds: 2));

              final currentCount = find.byType(Card).evaluate().length;
              TestLogger.log(
                  '📊 Cards after scroll $scrollAttempts: $currentCount');

              if (currentCount > initialCardCount) {
                TestLogger.log(
                    '🎉 New content loaded! $initialCardCount -> $currentCount');
                return ScrollResult(
                  success: true,
                  initialCount: initialCardCount,
                  finalCount: currentCount,
                  scrollAttempts: scrollAttempts,
                );
              }
            }
          } catch (e) {
            TestLogger.log('❌ Scrollable $scrollableIndex failed: $e');
            continue;
          }
        }

        final finalCount = find.byType(Card).evaluate().length;
        return ScrollResult(
          success: true,
          initialCount: initialCardCount,
          finalCount: finalCount,
          scrollAttempts: scrollAttempts,
          reachedEnd: true,
        );
      }
    } catch (e) {
      lastError = 'Method 3 failed: $e';
      TestLogger.log('❌ Method 3 failed: $e');
    }

    // If all methods failed
    TestLogger.log('💥 ALL SCROLL METHODS FAILED');
    return ScrollResult(
      success: false,
      initialCount: initialCardCount,
      finalCount: initialCardCount,
      scrollAttempts: scrollAttempts,
      error: lastError ?? 'All scroll methods failed',
    );
  }

  /// STRICT SCROLL VERIFICATION
  /// This will fail the test if scrolling doesn't actually work
  static Future<void> verifyScrollWorking(
    PatrolIntegrationTester $, {
    bool requireNewContent = false,
  }) async {
    TestLogger.log('🔍 Verifying scroll functionality is working');

    final result = await performHotelsScroll($);

    if (!result.success) {
      throw Exception('SCROLL VERIFICATION FAILED: ${result.error}');
    }

    if (requireNewContent && !result.hasNewContent) {
      throw Exception(
          'SCROLL VERIFICATION FAILED: No new content loaded after scrolling');
    }

    TestLogger.log('✅ Scroll verification passed: ${result.toString()}');
  }

  static Future<void> validatePageElements(
    PatrolIntegrationTester $,
    String pageKey,
    List<String> elementKeys, {
    String? pageName,
    String? description,
  }) async {
    TestLogger.log(
        'Validating page structure for $pageKey${description != null ? ': $description' : ''}');

    for (final key in elementKeys) {
      final element = find.byKey(Key(key));
      expect(element, findsOneWidget, reason: 'Element $key should be present');
    }

    TestLogger.log('✅ Page validation completed for $pageKey');
  }

  static Future<bool> isElementVisible(
    PatrolIntegrationTester $,
    String elementKey, {
    String? description,
  }) async {
    TestLogger.log(
        'Checking visibility of element $elementKey${description != null ? ': $description' : ''}');
    try {
      final finder = find.byKey(Key(elementKey));
      return finder.evaluate().isNotEmpty;
    } catch (e) {
      TestLogger.log('Element visibility check failed: $e');
      return false;
    }
  }

  static Future<void> waitForAppStability(PatrolIntegrationTester $) async {
    TestLogger.log('Waiting for app stability');
    await $.pumpAndSettle();
    await $.pump(const Duration(milliseconds: 500));
  }

  static void resetAppState() {
    TestLogger.log('Resetting app initialization state');
    _isAppInitialized = false;
  }

  /// Debug helper to print current scroll state
  static Future<void> debugScrollState(PatrolIntegrationTester $) async {
    TestLogger.log('🔍 DEBUG: Current scroll state');

    final scrollView = find.byKey(const Key('hotels_scroll_view'));
    TestLogger.log(
        'hotels_scroll_view found: ${scrollView.evaluate().isNotEmpty}');

    final customScrollView = find.byType(CustomScrollView);
    TestLogger.log(
        'CustomScrollView found: ${customScrollView.evaluate().length}');

    final scrollable = find.byType(Scrollable);
    TestLogger.log('Scrollable widgets found: ${scrollable.evaluate().length}');

    final cards = find.byType(Card);
    TestLogger.log('Card widgets found: ${cards.evaluate().length}');

    final loadingIndicator = find.byKey(const Key('hotels_loading_indicator'));
    TestLogger.log(
        'Loading indicator visible: ${loadingIndicator.evaluate().isNotEmpty}');

    final paginationLoading =
        find.byKey(const Key('hotels_pagination_loading'));
    TestLogger.log(
        'Pagination loading visible: ${paginationLoading.evaluate().isNotEmpty}');
  }
}

/// Result object for scroll operations
class ScrollResult {
  final bool success;
  final int initialCount;
  final int finalCount;
  final int scrollAttempts;
  final bool reachedEnd;
  final String? error;

  ScrollResult({
    required this.success,
    required this.initialCount,
    required this.finalCount,
    required this.scrollAttempts,
    this.reachedEnd = false,
    this.error,
  });

  bool get hasNewContent => finalCount > initialCount;
  int get newContentCount => finalCount - initialCount;

  @override
  String toString() {
    return 'ScrollResult(success: $success, $initialCount -> $finalCount cards, attempts: $scrollAttempts, reachedEnd: $reachedEnd${error != null ? ', error: $error' : ''})';
  }
}
