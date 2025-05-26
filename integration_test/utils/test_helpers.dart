import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;
import '../logger/test_logger.dart';
import '../locators/app_locators.dart';

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

    final tabFinder = AppLocators.getNavigationTab($, tabName);
    await AppLocators.smartTap($, tabFinder);
    await $.pump(const Duration(milliseconds: 500));
    await $.pumpAndSettle();
  }

  static Future<ScrollResult> performHotelsScroll(
    PatrolIntegrationTester $, {
    int maxScrolls = 10,
    Duration scrollTimeout = const Duration(seconds: 30),
  }) async {
    TestLogger.log(
        'Starting continuous scroll until pagination loader appears');

    final initialCardCount = find.byType(Card).evaluate().length;
    TestLogger.log('Initial card count: $initialCardCount');

    if (initialCardCount == 0) {
      TestLogger.log('No cards found - cannot scroll');
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

    try {
      final hotelsScrollView = AppLocators.getHotelsScrollView($);
      if (AppLocators.elementExists($, hotelsScrollView)) {
        TestLogger.log('Found hotels_scroll_view, starting continuous scroll');

        bool paginationTriggered = false;

        while (scrollAttempts < maxScrolls && !paginationTriggered) {
          scrollAttempts++;
          TestLogger.log(
              'Continuous scroll attempt $scrollAttempts/$maxScrolls - looking for pagination loader');

          await $.tester.drag(find.byKey(const Key('hotels_scroll_view')),
              const Offset(0, -400));
          await $.pump(const Duration(milliseconds: 500));

          final paginationLoading = AppLocators.getHotelsPaginationLoading($);
          if (AppLocators.elementExists($, paginationLoading)) {
            TestLogger.log(
                'SUCCESS: Pagination loader appeared after $scrollAttempts scrolls!');
            paginationTriggered = true;

            TestLogger.log('Waiting for pagination to complete...');
            int waitAttempts = 0;
            while (AppLocators.elementExists($, paginationLoading) &&
                waitAttempts < 15) {
              await $.pump(const Duration(milliseconds: 500));
              waitAttempts++;
              TestLogger.log('Waiting for pagination... attempt $waitAttempts');
            }

            if (waitAttempts >= 15) {
              TestLogger.log(
                  'Pagination taking too long, but loader was triggered');
            } else {
              TestLogger.log(
                  'Pagination completed after ${waitAttempts * 500}ms');
            }

            await $.pump(const Duration(seconds: 1));
            break;
          }

          final currentCount = find.byType(Card).evaluate().length;
          if (currentCount > initialCardCount) {
            TestLogger.log(
                'New content loaded without seeing loader: $initialCardCount -> $currentCount');
            paginationTriggered = true;
            break;
          }

          TestLogger.log(
              'No pagination loader yet, continuing to scroll down...');
          await $.pump(const Duration(milliseconds: 300));
        }

        final finalCount = find.byType(Card).evaluate().length;

        if (paginationTriggered || finalCount > initialCardCount) {
          TestLogger.log(
              'SUCCESS: Scroll operation completed with new content or loader triggered');
          return ScrollResult(
            success: true,
            initialCount: initialCardCount,
            finalCount: finalCount,
            scrollAttempts: scrollAttempts,
          );
        } else {
          TestLogger.log(
              'Reached max scroll attempts without triggering pagination - likely end of list');
          return ScrollResult(
            success: true,
            initialCount: initialCardCount,
            finalCount: finalCount,
            scrollAttempts: scrollAttempts,
            reachedEnd: true,
          );
        }
      }
    } catch (e) {
      lastError = 'hotels_scroll_view continuous scroll failed: $e';
      TestLogger.log('hotels_scroll_view continuous scroll failed: $e');
    }

    try {
      final customScrollView = find.byType(CustomScrollView);
      if (customScrollView.evaluate().isNotEmpty) {
        TestLogger.log('Found CustomScrollView, starting continuous scroll');

        bool paginationTriggered = false;

        while (scrollAttempts < maxScrolls && !paginationTriggered) {
          scrollAttempts++;
          TestLogger.log(
              'CustomScrollView continuous scroll attempt $scrollAttempts/$maxScrolls');

          await $.tester.drag(customScrollView.first, const Offset(0, -400));
          await $.pump(const Duration(milliseconds: 500));

          final paginationLoading =
              find.byKey(const Key('hotels_pagination_loading'));
          if (paginationLoading.evaluate().isNotEmpty) {
            TestLogger.log(
                'SUCCESS: Pagination loader appeared with CustomScrollView!');
            paginationTriggered = true;

            int waitAttempts = 0;
            while (
                paginationLoading.evaluate().isNotEmpty && waitAttempts < 15) {
              await $.pump(const Duration(milliseconds: 500));
              waitAttempts++;
            }

            await $.pump(const Duration(seconds: 1));
            break;
          }

          final currentCount = find.byType(Card).evaluate().length;
          if (currentCount > initialCardCount) {
            TestLogger.log(
                'New content loaded with CustomScrollView: $initialCardCount -> $currentCount');
            paginationTriggered = true;
            break;
          }

          TestLogger.log('CustomScrollView: No pagination yet, continuing...');
          await $.pump(const Duration(milliseconds: 300));
        }

        final finalCount = find.byType(Card).evaluate().length;

        if (paginationTriggered || finalCount > initialCardCount) {
          return ScrollResult(
            success: true,
            initialCount: initialCardCount,
            finalCount: finalCount,
            scrollAttempts: scrollAttempts,
          );
        } else {
          return ScrollResult(
            success: true,
            initialCount: initialCardCount,
            finalCount: finalCount,
            scrollAttempts: scrollAttempts,
            reachedEnd: true,
          );
        }
      }
    } catch (e) {
      lastError = 'CustomScrollView continuous scroll failed: $e';
      TestLogger.log('CustomScrollView continuous scroll failed: $e');
    }

    try {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        TestLogger.log(
            'Found ${scrollable.evaluate().length} Scrollable widgets, trying continuous scroll');

        for (int scrollableIndex = 0;
            scrollableIndex < scrollable.evaluate().length;
            scrollableIndex++) {
          TestLogger.log(
              'Trying continuous scroll on Scrollable widget $scrollableIndex');

          bool paginationTriggered = false;
          int startAttempts = scrollAttempts;

          try {
            while (scrollAttempts < maxScrolls && !paginationTriggered) {
              scrollAttempts++;
              TestLogger.log(
                  'Scrollable[$scrollableIndex] continuous scroll attempt ${scrollAttempts - startAttempts}');

              await $.tester
                  .drag(scrollable.at(scrollableIndex), const Offset(0, -400));
              await $.pump(const Duration(milliseconds: 500));

              final paginationLoading =
                  find.byKey(const Key('hotels_pagination_loading'));
              if (paginationLoading.evaluate().isNotEmpty) {
                TestLogger.log(
                    'SUCCESS: Pagination loader appeared with Scrollable[$scrollableIndex]!');
                paginationTriggered = true;

                int waitAttempts = 0;
                while (paginationLoading.evaluate().isNotEmpty &&
                    waitAttempts < 15) {
                  await $.pump(const Duration(milliseconds: 500));
                  waitAttempts++;
                }

                await $.pump(const Duration(seconds: 1));
                break;
              }

              final currentCount = find.byType(Card).evaluate().length;
              if (currentCount > initialCardCount) {
                TestLogger.log(
                    'New content loaded with Scrollable[$scrollableIndex]: $initialCardCount -> $currentCount');
                paginationTriggered = true;
                break;
              }

              await $.pump(const Duration(milliseconds: 300));
            }

            if (paginationTriggered) {
              final finalCount = find.byType(Card).evaluate().length;
              return ScrollResult(
                success: true,
                initialCount: initialCardCount,
                finalCount: finalCount,
                scrollAttempts: scrollAttempts,
              );
            }
          } catch (e) {
            TestLogger.log(
                'Scrollable $scrollableIndex continuous scroll failed: $e');
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
      lastError = 'Direct Scrollable continuous scroll failed: $e';
      TestLogger.log('Direct Scrollable continuous scroll failed: $e');
    }

    TestLogger.log('ALL CONTINUOUS SCROLL STRATEGIES FAILED');
    return ScrollResult(
      success: false,
      initialCount: initialCardCount,
      finalCount: initialCardCount,
      scrollAttempts: scrollAttempts,
      error: lastError ?? 'All continuous scroll strategies failed',
    );
  }

  static Future<void> debugScrollState(PatrolIntegrationTester $) async {
    TestLogger.log('DEBUG: Current scroll state analysis');

    final scrollView = AppLocators.getHotelsScrollView($);
    TestLogger.log(
        'hotels_scroll_view found: ${AppLocators.elementExists($, scrollView)}');

    final customScrollView = find.byType(CustomScrollView);
    TestLogger.log(
        'CustomScrollView found: ${customScrollView.evaluate().length}');

    final scrollable = find.byType(Scrollable);
    TestLogger.log('Scrollable widgets found: ${scrollable.evaluate().length}');

    final cards = find.byType(Card);
    TestLogger.log('Card widgets found: ${cards.evaluate().length}');

    final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
    TestLogger.log(
        'Main loading indicator: ${AppLocators.elementExists($, loadingIndicator)}');

    final paginationLoading = AppLocators.getHotelsPaginationLoading($);
    TestLogger.log(
        'Pagination loading indicator: ${AppLocators.elementExists($, paginationLoading)}');
  }

  static void resetAppState() {
    TestLogger.log('Resetting app initialization state');
    _isAppInitialized = false;
  }
}

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
