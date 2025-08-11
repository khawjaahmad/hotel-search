import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';

/// Base class for page-specific assertions
abstract class PageAssertions {
  final PatrolIntegrationTester tester;
  final dynamic page;
  
  PageAssertions(this.tester, this.page);

  /// Assert element exists with custom message
  Future<void> shouldExist(PatrolFinder finder, {String? message}) async {
    final customMessage = message ?? 'Element should exist';
    if (!finder.exists) {
      throw AssertionError('$customMessage - Element not found');
    }
  }

  /// Assert element does not exist
  Future<void> shouldNotExist(PatrolFinder finder, {String? message}) async {
    final customMessage = message ?? 'Element should not exist';
    if (finder.exists) {
      throw AssertionError('$customMessage - Element found when it should not exist');
    }
  }

  /// Assert element is visible
  Future<void> shouldBeVisible(PatrolFinder finder, {String? message}) async {
    final customMessage = message ?? 'Element should be visible';
    try {
      await finder.waitUntilVisible(timeout: const Duration(seconds: 5));
    } catch (e) {
      throw AssertionError('$customMessage - Element not visible: $e');
    }
  }

  /// Assert text content
  Future<void> shouldHaveText(PatrolFinder finder, String expectedText, {String? message}) async {
    final customMessage = message ?? 'Element should have text "$expectedText"';
    await shouldExist(finder, message: customMessage);
    
    final element = finder.evaluate().first;
    final widget = element.widget;
    
    String? actualText;
    if (widget is Text) {
      actualText = widget.data;
    } else if (widget is TextField) {
      actualText = widget.controller?.text;
    }
    
    if (actualText != expectedText) {
      throw AssertionError('$customMessage - Expected: "$expectedText", Actual: "$actualText"');
    }
  }

  /// Assert element count
  Future<void> shouldHaveCount(PatrolFinder finder, int expectedCount, {String? message}) async {
    final customMessage = message ?? 'Should have $expectedCount elements';
    final actualCount = finder.evaluate().length;
    
    if (actualCount != expectedCount) {
      throw AssertionError('$customMessage - Expected: $expectedCount, Actual: $actualCount');
    }
  }

  /// Assert minimum count
  Future<void> shouldHaveAtLeast(PatrolFinder finder, int minCount, {String? message}) async {
    final customMessage = message ?? 'Should have at least $minCount elements';
    final actualCount = finder.evaluate().length;
    
    if (actualCount < minCount) {
      throw AssertionError('$customMessage - Expected at least: $minCount, Actual: $actualCount');
    }
  }
}

/// Hotels page specific assertions
class HotelsPageAssertions extends PageAssertions {
  HotelsPageAssertions(super.tester, super.page);

  /// Assert hotels are displayed
  Future<void> shouldHaveHotels({int minCount = 1}) async {
    await shouldBeVisible(tester(Card));
    // Additional hotel-specific validations
  }
  
  /// Assert search field is visible
  Future<void> shouldHaveSearchField() async {
    await shouldBeVisible(tester(#search_text_field));
  }

  /// Assert search results are displayed
  Future<void> shouldHaveSearchResults({int? minResults}) async {
    final cards = tester(Card);
    await shouldExist(cards, message: 'Search results should be displayed');
    
    if (minResults != null) {
      await shouldHaveAtLeast(cards, minResults, message: 'Should have at least $minResults search results');
    }
    
    // Validate minimum number of results
    await cards.waitUntilVisible();
  }

  /// Assert no search results
  Future<void> shouldHaveNoResults() async {
    final emptyState = AppLocators.getHotelsEmptyStateIcon(tester);
    await shouldBeVisible(emptyState, message: 'Empty state should be visible when no results');
  }

  /// Assert error message is displayed
  Future<void> shouldShowError({String? expectedMessage}) async {
    final errorElement = AppLocators.getHotelsErrorMessage(tester);
    await shouldBeVisible(errorElement, message: 'Error message should be displayed');
    
    if (expectedMessage != null) {
      await shouldHaveText(errorElement, expectedMessage, message: 'Error message should match expected text');
    }
  }

  /// Assert loading state
  Future<void> shouldShowLoading() async {
    final loadingIndicator = AppLocators.getHotelsLoadingIndicator(tester);
    await shouldBeVisible(loadingIndicator, message: 'Loading indicator should be visible');
  }

  /// Assert loading is complete
  Future<void> shouldNotShowLoading() async {
    final loadingIndicator = AppLocators.getHotelsLoadingIndicator(tester);
    await shouldNotExist(loadingIndicator, message: 'Loading indicator should not be visible');
  }

  /// Assert hotel card details
  Future<void> shouldHaveHotelCard(int index, {
    String? expectedName,
    String? expectedLocation,
    bool? shouldBeFavorite,
  }) async {
    final cards = tester(Card);
    final cardCount = cards.evaluate().length;
    
    if (index >= cardCount) {
      throw AssertionError('Hotel card at index $index does not exist. Total cards: $cardCount');
    }

    final card = cards.at(index);
    await shouldExist(card, message: 'Hotel card at index $index should exist');

    if (expectedName != null) {
      final nameText = tester(Text).containing(expectedName);
      await shouldExist(nameText, message: 'Hotel card should contain name "$expectedName"');
    }

    if (expectedLocation != null) {
      final locationText = tester(Text).containing(expectedLocation);
      await shouldExist(locationText, message: 'Hotel card should contain location "$expectedLocation"');
    }

    if (shouldBeFavorite != null) {
      final favoriteButton = tester(IconButton).at(index);
      await shouldExist(favoriteButton, message: 'Hotel card should have favorite button');
      
      // Additional validation for favorite state could be added here
      // based on icon type or color
    }
  }

  /// Assert pagination is working
  Future<void> shouldSupportPagination() async {
    final initialCardCount = tester(Card).evaluate().length;
    
    // Scroll to trigger pagination
    await tester.scrollUntilVisible(
      finder: AppLocators.getHotelsPaginationLoading(tester),
      view: AppLocators.getHotelsScrollView(tester),
      delta: -300,
      maxScrolls: 3,
    );
    
    // Wait for pagination to complete
    await tester.pump(const Duration(seconds: 2));
    
    final finalCardCount = tester(Card).evaluate().length;
    
    if (finalCardCount <= initialCardCount) {
      throw AssertionError('Pagination should load more results. Initial: $initialCardCount, Final: $finalCardCount');
    }
  }
}

/// Navigation page assertions
class NavigationPageAssertions extends PageAssertions {
  NavigationPageAssertions(super.tester, super.page);

  /// Assert navigation bar is visible
  Future<void> shouldHaveNavigationBar() async {
    final navBar = AppLocators.getNavigationBar(tester);
    await shouldBeVisible(navBar, message: 'Navigation bar should be visible');
  }

  /// Assert specific tab is selected
  Future<void> shouldHaveSelectedTab(String tabName) async {
    final tab = AppLocators.getNavigationTab(tester, tabName);
    await shouldExist(tab, message: 'Tab "$tabName" should exist');
    
    // Additional validation for selected state could be added here
  }
}

/// Favorites page assertions
class FavoritesPageAssertions extends PageAssertions {
  FavoritesPageAssertions(super.tester, super.page);

  /// Assert favorites are displayed
  Future<void> shouldHaveFavorites({int? expectedCount}) async {
    final cards = tester(Card);
    await shouldExist(cards, message: 'Favorite hotels should be displayed');
    
    if (expectedCount != null) {
      await shouldHaveCount(cards, expectedCount, message: 'Should have exactly $expectedCount favorites');
    }
  }

  /// Assert no favorites
  Future<void> shouldHaveNoFavorites() async {
    final cards = tester(Card);
    await shouldHaveCount(cards, 0, message: 'Should have no favorite hotels');
  }

  /// Assert empty state
  Future<void> shouldShowEmptyState() async {
    final emptyState = AppLocators.getFavoritesEmptyState(tester);
    await shouldBeVisible(emptyState, message: 'Empty favorites state should be visible');
  }
}

/// Account page assertions
class AccountPageAssertions extends PageAssertions {
  AccountPageAssertions(super.tester, super.page);

  /// Assert account page is loaded
  Future<void> shouldBeLoaded() async {
    final scaffold = AppLocators.getAccountScaffold(tester);
    await shouldBeVisible(scaffold, message: 'Account page should be loaded');
  }
}

/// Overview page assertions
class OverviewPageAssertions extends PageAssertions {
  OverviewPageAssertions(super.tester, super.page);

  /// Assert overview page is loaded
  Future<void> shouldBeLoaded() async {
    final scaffold = AppLocators.getOverviewScaffold(tester);
    await shouldBeVisible(scaffold, message: 'Overview page should be loaded');
  }
}

/// Performance assertions
class PerformanceAssertions {
  static void shouldCompleteWithin(Duration maxDuration, Duration actualDuration, {String? operation}) {
    final operationName = operation ?? 'Operation';
    if (actualDuration > maxDuration) {
      throw AssertionError(
        '$operationName took ${actualDuration.inMilliseconds}ms, expected max ${maxDuration.inMilliseconds}ms'
      );
    }
  }

  static void shouldHaveFrameRate(double minFps, double actualFps) {
    if (actualFps < minFps) {
      throw AssertionError(
        'Frame rate ${actualFps.toStringAsFixed(1)} FPS is below minimum ${minFps.toStringAsFixed(1)} FPS'
      );
    }
  }
}

/// Custom assertion helpers
class CustomAssertions {
  /// Assert with retry mechanism
  static Future<void> assertWithRetry(
    Future<void> Function() assertion,
    {
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 500),
    String? description,
  }) async {
    Exception? lastException;
    
    for (int i = 0; i <= maxRetries; i++) {
      try {
        await assertion();
        return; // Success
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        if (i < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }
    
    final desc = description ?? 'Assertion';
    throw AssertionError('$desc failed after ${maxRetries + 1} attempts. Last error: $lastException');
  }

  /// Assert multiple conditions
  static Future<void> assertAll(List<Future<void> Function()> assertions, {String? description}) async {
    final errors = <String>[];
    
    for (int i = 0; i < assertions.length; i++) {
      try {
        await assertions[i]();
      } catch (e) {
        errors.add('Assertion ${i + 1}: $e');
      }
    }
    
    if (errors.isNotEmpty) {
      final desc = description ?? 'Multiple assertions';
      throw AssertionError('$desc failed:\n${errors.join('\n')}');
    }
  }
}