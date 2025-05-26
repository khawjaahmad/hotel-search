import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../logger/test_logger.dart';
import '../locators/app_locators.dart';

enum SearchState { hasResults, hasError, isEmpty, timeout }

class TestActionsUtils {
  static Future<SearchState> waitForSearchResults(
    PatrolIntegrationTester $, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      await $.pump(const Duration(milliseconds: 500));

      final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
      final paginationLoading = AppLocators.getHotelsPaginationLoading($);
      final circularProgress = find.byType(CircularProgressIndicator);

      final isLoading = AppLocators.elementExists($, loadingIndicator) ||
          AppLocators.elementExists($, paginationLoading) ||
          circularProgress.evaluate().isNotEmpty;

      if (!isLoading) {
        final hasCards = find.byType(Card).evaluate().isNotEmpty;
        final hasError =
            AppLocators.elementExists($, AppLocators.getHotelsErrorMessage($));
        final hasEmpty = AppLocators.elementExists(
            $, AppLocators.getHotelsEmptyStateIcon($));

        if (hasCards) return SearchState.hasResults;
        if (hasError) return SearchState.hasError;
        if (hasEmpty) return SearchState.isEmpty;

        await $.pump(const Duration(milliseconds: 500));
      }
    }

    stopwatch.stop();
    return SearchState.timeout;
  }

  static Future<SearchState> performSearch(
    PatrolIntegrationTester $,
    String query,
  ) async {
    TestLogger.log('Performing search with query: "$query"');

    final searchField = AppLocators.getSearchTextField($);
    await AppLocators.smartWaitFor($, searchField);

    await AppLocators.smartEnterText($, searchField, '');
    await $.pump(const Duration(milliseconds: 300));

    await AppLocators.smartEnterText($, searchField, query, clearFirst: false);
    TestLogger.log('Entered text: "$query"');

    await $.pump(const Duration(milliseconds: 1000));

    return await waitForSearchResults($);
  }

  static Future<void> clearSearchField(PatrolIntegrationTester $) async {
    TestLogger.log('Clearing search field');

    final clearButton = AppLocators.getSearchClearButton($);
    if (AppLocators.elementExists($, clearButton)) {
      await AppLocators.smartTap($, clearButton);
      await $.pump(const Duration(milliseconds: 500));
    }
  }

  static Future<void> addHotelToFavorites(
    PatrolIntegrationTester $,
    int cardIndex,
  ) async {
    TestLogger.log('Adding hotel at index $cardIndex to favorites');

    final cardWidget = find.byType(Card).at(cardIndex);
    final favoriteButton = find.descendant(
      of: cardWidget,
      matching: find.byIcon(Icons.favorite_outline),
    );

    if (favoriteButton.evaluate().isNotEmpty) {
      await $(favoriteButton.first).tap();
      await $.pump(const Duration(milliseconds: 800));
      TestLogger.log('Successfully added hotel to favorites');
    } else {
      throw Exception('Favorite button not found for card at index $cardIndex');
    }
  }

  static Future<void> removeHotelFromFavorites(
    PatrolIntegrationTester $,
    int cardIndex,
  ) async {
    TestLogger.log('Removing hotel at index $cardIndex from favorites');

    final cardWidget = find.byType(Card).at(cardIndex);
    final favoriteButton = find.descendant(
      of: cardWidget,
      matching: find.byIcon(Icons.favorite),
    );

    if (favoriteButton.evaluate().isNotEmpty) {
      await $(favoriteButton.first).tap();
      await $.pump(const Duration(milliseconds: 800));
      TestLogger.log('Successfully removed hotel from favorites');
    } else {
      throw Exception(
          'Filled favorite button not found for card at index $cardIndex');
    }
  }

  static String extractHotelName(int cardIndex) {
    try {
      final cardWidget = find.byType(Card).at(cardIndex);
      final nameTexts =
          find.descendant(of: cardWidget, matching: find.byType(Text));

      if (nameTexts.evaluate().isNotEmpty) {
        final nameWidget = nameTexts.first.evaluate().first.widget as Text;
        return nameWidget.data ?? 'Hotel ${cardIndex + 1}';
      }

      return 'Hotel ${cardIndex + 1}';
    } catch (e) {
      TestLogger.log('Error extracting hotel name for card $cardIndex: $e');
      return 'Hotel ${cardIndex + 1}';
    }
  }

  static void verifySearchFieldState(PatrolIntegrationTester $,
      {bool shouldBeEmpty = false}) {
    final searchField = AppLocators.getSearchTextField($);

    if (shouldBeEmpty) {
      final textFieldFinder = find.byType(TextField);
      if (textFieldFinder.evaluate().isNotEmpty) {
        final controller =
            $.tester.widget<TextField>(textFieldFinder.first).controller;
        expect(controller?.text, isEmpty,
            reason: 'Search field should be empty');
      }
    }

    expect(AppLocators.elementExists($, searchField), isTrue,
        reason: 'Search field should be present');
  }

  static void verifyHotelsPageElements(PatrolIntegrationTester $) {
    final scaffold = AppLocators.getHotelsScaffold($);
    expect(AppLocators.elementExists($, scaffold), isTrue,
        reason: 'Hotels scaffold should be present');

    final searchField = AppLocators.getHotelsSearchField($);
    expect(AppLocators.elementExists($, searchField), isTrue,
        reason: 'Search field container should be present');

    expect(find.byIcon(Icons.search).evaluate().isNotEmpty, isTrue,
        reason: 'Search icon should be present');
    expect(find.byIcon(Icons.cancel_outlined).evaluate().isNotEmpty, isTrue,
        reason: 'Clear button should be present');
  }

  static void verifyErrorState(PatrolIntegrationTester $) {
    final errorMessage = AppLocators.getHotelsErrorMessage($);
    final retryButton = AppLocators.getHotelsRetryButton($);

    expect(AppLocators.elementExists($, errorMessage), isTrue,
        reason: 'Error message should be visible');
    expect(AppLocators.elementExists($, retryButton), isTrue,
        reason: 'Retry button should be visible');
    expect(find.text('Something went wrong').evaluate().isNotEmpty, isTrue,
        reason: 'Should show "Something went wrong" message');
    expect(find.text('Try Again').evaluate().isNotEmpty, isTrue,
        reason: 'Should show "Try Again" button');
  }

  static void verifyEmptyState(PatrolIntegrationTester $) {
    final emptyStateIcon = AppLocators.getHotelsEmptyStateIcon($);
    expect(AppLocators.elementExists($, emptyStateIcon), isTrue,
        reason: 'Empty state icon should be visible');
  }

  static int getHotelCardCount() {
    return find.byType(Card).evaluate().length;
  }

  static void verifyHotelCardStructure(int cardIndex) {
    final cardWidget = find.byType(Card).at(cardIndex);

    final nameText =
        find.descendant(of: cardWidget, matching: find.byType(Text));
    expect(nameText.evaluate().isNotEmpty, isTrue,
        reason: 'Hotel card $cardIndex should have name text');

    final favoriteButton = find.descendant(
        of: cardWidget, matching: find.byIcon(Icons.favorite_outline));
    final filledFavoriteButton =
        find.descendant(of: cardWidget, matching: find.byIcon(Icons.favorite));

    final hasFavoriteButton = favoriteButton.evaluate().isNotEmpty ||
        filledFavoriteButton.evaluate().isNotEmpty;
    expect(hasFavoriteButton, isTrue,
        reason: 'Hotel card $cardIndex should have favorite button');
  }

  static void verifySearchResults(PatrolIntegrationTester $) {
    final cardCount = getHotelCardCount();
    expect(cardCount, greaterThan(0),
        reason: 'Search should return at least one result');

    final cardsToCheck = cardCount >= 3 ? 3 : cardCount;
    for (int i = 0; i < cardsToCheck; i++) {
      verifyHotelCardStructure(i);
    }

    TestLogger.log('Search results verified: $cardCount hotels found');
  }
}
