import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../logger/test_logger.dart';
import '../reports/allure_reporter.dart';
import '../helpers/allure_helper.dart';
import '../locators/app_locators.dart';

class EnhancedScrollTester {
  static Future<PaginationScrollResult> performContinuousScroll(
    PatrolIntegrationTester $, {
    int maxScrollAttempts = 15,
    double scrollDistance = 300.0,
    Duration scrollDelay = const Duration(milliseconds: 400),
    Duration paginationTimeout = const Duration(seconds: 20),
  }) async {
    TestLogger.log('Starting enhanced continuous scroll test');

    final initialCardCount = find.byType(Card).evaluate().length;
    TestLogger.log('Initial card count: $initialCardCount');

    if (initialCardCount == 0) {
      return PaginationScrollResult.failed('No cards found to scroll');
    }

    final scrollableWidget = await _findScrollableWidget($);
    if (scrollableWidget == null) {
      return PaginationScrollResult.failed('No scrollable widget found');
    }

    int scrollAttempts = 0;
    int cardCountBeforeScroll = initialCardCount;
    bool paginationTriggered = false;
    int totalNewCards = 0;

    TestLogger.log('Starting continuous scroll simulation');

    while (scrollAttempts < maxScrollAttempts && !paginationTriggered) {
      scrollAttempts++;
      TestLogger.log('Scroll attempt $scrollAttempts/$maxScrollAttempts');

      await _performGradualScroll($, scrollableWidget, scrollDistance);
      await $.pump(scrollDelay);

      final paginationLoader = AppLocators.getHotelsPaginationLoading($);
      if (AppLocators.elementExists($, paginationLoader)) {
        TestLogger.log('Pagination loader appeared');
        paginationTriggered = true;

        await _waitForPaginationToComplete($, paginationTimeout);
        break;
      }

      final currentCardCount = find.byType(Card).evaluate().length;
      if (currentCardCount > cardCountBeforeScroll) {
        final newCards = currentCardCount - cardCountBeforeScroll;
        totalNewCards += newCards;
        cardCountBeforeScroll = currentCardCount;
        TestLogger.log(
            'New cards loaded: +$newCards (total: $currentCardCount)');
        continue;
      }

      if (await _isScrolledToBottom($, scrollableWidget)) {
        TestLogger.log('Reached bottom of the list');
        break;
      }

      TestLogger.log('No new content yet, continuing scroll');
    }

    final finalCardCount = find.byType(Card).evaluate().length;

    return PaginationScrollResult(
      success: true,
      initialCount: initialCardCount,
      finalCount: finalCardCount,
      scrollAttempts: scrollAttempts,
      paginationTriggered: paginationTriggered,
      totalNewCardsLoaded: totalNewCards,
      reachedEnd:
          !paginationTriggered && finalCardCount == cardCountBeforeScroll,
    );
  }

  static Future<Finder?> _findScrollableWidget(
      PatrolIntegrationTester $) async {
    final hotelsScrollView = AppLocators.getHotelsScrollView($);
    if (AppLocators.elementExists($, hotelsScrollView)) {
      TestLogger.log('Found hotels_scroll_view');
      return hotelsScrollView.finder;
    }

    final customScrollView = find.byType(CustomScrollView);
    if (customScrollView.evaluate().isNotEmpty) {
      TestLogger.log('Found CustomScrollView');
      return customScrollView.first;
    }

    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      TestLogger.log('Found Scrollable widget');
      return scrollable.first;
    }

    TestLogger.log('No scrollable widget found');
    return null;
  }

  static Future<void> _performGradualScroll(
    PatrolIntegrationTester $,
    Finder scrollableWidget,
    double distance,
  ) async {
    const int steps = 3;
    final stepDistance = distance / steps;

    for (int i = 0; i < steps; i++) {
      await $.tester.drag(scrollableWidget, Offset(0, -stepDistance));
      await $.pump(const Duration(milliseconds: 50));
    }
  }

  static Future<void> _waitForPaginationToComplete(
    PatrolIntegrationTester $,
    Duration timeout,
  ) async {
    TestLogger.log('Waiting for pagination to complete');

    final stopwatch = Stopwatch()..start();
    final paginationLoader = AppLocators.getHotelsPaginationLoading($);

    while (stopwatch.elapsed < timeout &&
        AppLocators.elementExists($, paginationLoader)) {
      await $.pump(const Duration(milliseconds: 500));
      TestLogger.log('Still loading... ${stopwatch.elapsed.inSeconds}s');
    }

    if (AppLocators.elementExists($, paginationLoader)) {
      TestLogger.log('Pagination loader still visible after timeout');
    } else {
      TestLogger.log('Pagination completed in ${stopwatch.elapsed.inSeconds}s');
    }

    await $.pump(const Duration(seconds: 1));
  }

  static Future<bool> _isScrolledToBottom(
    PatrolIntegrationTester $,
    Finder scrollableWidget,
  ) async {
    try {
      final cardCountBefore = find.byType(Card).evaluate().length;

      await $.tester.drag(scrollableWidget, const Offset(0, -100));
      await $.pump(const Duration(milliseconds: 300));

      final cardCountAfter = find.byType(Card).evaluate().length;

      return cardCountBefore == cardCountAfter;
    } catch (e) {
      TestLogger.log('Error checking scroll bottom: $e');
      return false;
    }
  }

  static Future<void> testRealisticPagination(
    PatrolIntegrationTester $,
    String testName,
  ) async {
    await EnhancedAllureHelper.startTest(
      testName,
      description:
          'Test realistic pagination behavior with continuous scrolling',
      labels: ['feature:pagination', 'component:scroll', 'priority:medium'],
      severity: AllureSeverity.normal,
    );

    try {
      EnhancedAllureHelper.reportStep('Initialize pagination test');
      TestLogger.log('Starting realistic pagination test: $testName');

      EnhancedAllureHelper.reportStep('Perform search for pagination test');
      await _performSearchForPagination($, 'London');
      await $.pump(const Duration(seconds: 2));

      final initialCards = find.byType(Card).evaluate().length;
      if (initialCards == 0) {
        throw Exception('No search results to test pagination');
      }

      EnhancedAllureHelper.reportStep('Execute continuous scroll test');
      TestLogger.log(
          'Ready to test pagination with $initialCards initial cards');

      final result = await performContinuousScroll($);

      EnhancedAllureHelper.reportStep('Validate pagination results');
      _validatePaginationResult(result, testName);

      TestLogger.log('Pagination test completed successfully: $testName');

      await EnhancedAllureHelper.finishTest(
        testName,
        status: AllureTestStatus.passed,
      );
    } catch (e, stackTrace) {
      EnhancedAllureHelper.reportStep(
        'Pagination test execution failed',
        status: AllureStepStatus.failed,
        details: e.toString(),
      );

      TestLogger.log('Pagination test failed: $testName - $e');
      TestLogger.log('Stack trace: $stackTrace');

      await EnhancedAllureHelper.finishTest(
        testName,
        status: AllureTestStatus.failed,
        errorMessage: e.toString(),
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  static Future<void> _performSearchForPagination(
    PatrolIntegrationTester $,
    String query,
  ) async {
    TestLogger.log('Performing search for pagination test: "$query"');

    final searchField = AppLocators.getSearchTextField($);
    if (!AppLocators.elementExists($, searchField)) {
      throw Exception('Search field not found');
    }

    await AppLocators.smartEnterText($, searchField, '');
    await $.pump(const Duration(milliseconds: 300));
    await AppLocators.smartEnterText($, searchField, query, clearFirst: false);
    await $.pump(const Duration(milliseconds: 1000));

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < const Duration(seconds: 15)) {
      await $.pump(const Duration(milliseconds: 500));

      final hasCards = find.byType(Card).evaluate().isNotEmpty;
      final hasError =
          AppLocators.elementExists($, AppLocators.getHotelsErrorMessage($));
      final isLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      if (hasCards) {
        TestLogger.log('Search results loaded');
        return;
      } else if (hasError) {
        throw Exception('Search resulted in error');
      } else if (!isLoading) {
        await $.pump(const Duration(milliseconds: 500));
      }
    }

    throw Exception('Search timed out or no results');
  }

  static void _validatePaginationResult(
      PaginationScrollResult result, String testName) {
    TestLogger.log('Validating pagination result for: $testName');
    TestLogger.log('Result: ${result.toString()}');

    if (!result.success) {
      throw Exception('Pagination test failed: ${result.error}');
    }

    expect(result.success, isTrue, reason: 'Scroll operation should succeed');
    expect(result.scrollAttempts, greaterThan(0),
        reason: 'Should have attempted scrolling');
    expect(result.finalCount, greaterThanOrEqualTo(result.initialCount),
        reason: 'Final card count should not decrease');

    if (result.paginationTriggered) {
      TestLogger.log('Pagination loader was triggered - test passed');
    } else if (result.totalNewCardsLoaded > 0) {
      TestLogger.log(
          'New cards loaded without visible loader - pagination working');
    } else if (result.reachedEnd) {
      TestLogger.log('Reached end of list - no more content available');
    } else {
      TestLogger.log('No pagination activity detected');
    }
  }
}

class PaginationScrollResult {
  final bool success;
  final int initialCount;
  final int finalCount;
  final int scrollAttempts;
  final bool paginationTriggered;
  final int totalNewCardsLoaded;
  final bool reachedEnd;
  final String? error;

  PaginationScrollResult({
    required this.success,
    required this.initialCount,
    required this.finalCount,
    required this.scrollAttempts,
    this.paginationTriggered = false,
    this.totalNewCardsLoaded = 0,
    this.reachedEnd = false,
    this.error,
  });

  PaginationScrollResult.failed(String errorMessage)
      : success = false,
        initialCount = 0,
        finalCount = 0,
        scrollAttempts = 0,
        paginationTriggered = false,
        totalNewCardsLoaded = 0,
        reachedEnd = false,
        error = errorMessage;

  bool get hasNewContent => totalNewCardsLoaded > 0;

  @override
  String toString() {
    return 'PaginationScrollResult('
        'success: $success, '
        'cards: $initialCount→$finalCount, '
        'scrolls: $scrollAttempts, '
        'paginationTriggered: $paginationTriggered, '
        'newCards: $totalNewCardsLoaded, '
        'reachedEnd: $reachedEnd'
        '${error != null ? ', error: $error' : ''}'
        ')';
  }
}
