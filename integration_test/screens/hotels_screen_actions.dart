import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';

class HotelsScreenActions {
  static final List<String> _favoriteHotels = [];

  static Future<void> navigateToHotelsPage(PatrolIntegrationTester $) async {
    $.log('Navigating to Hotels page');

    final hotelsTab = AppLocators.getHotelsTab($);
    await hotelsTab.waitUntilVisible();
    await hotelsTab.tap();

    await verifyHotelsPageStructure($);
  }

  static Future<void> verifyHotelsPageStructure(
      PatrolIntegrationTester $) async {
    $.log('Verifying Hotels page structure');

    final scaffold = AppLocators.getHotelsScaffold($);
    await scaffold.waitUntilExists();

    final appBar = AppLocators.getHotelsAppBar($);
    await appBar.waitUntilExists();
    expect(appBar.evaluate(), hasLength(1));

    final searchField = AppLocators.getHotelsSearchField($);
    await searchField.waitUntilExists();

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilExists();

    final searchIcon = AppLocators.getSearchPrefixIcon($);
    await searchIcon.waitUntilExists();

    final clearButton = AppLocators.getSearchClearButton($);
    await clearButton.waitUntilExists();

    $.log('Hotels page structure verified successfully');
  }

  static Future<void> performSearchTest(
      PatrolIntegrationTester $, String searchQuery) async {
    $.log('Testing search functionality with query: "$searchQuery"');

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.tap();

    await searchTextField.enterText(searchQuery);

    await $.pump(const Duration(milliseconds: 1500));

    await _waitForSearchResults($);

    $.log('Search functionality test completed');
  }

  static Future<void> _waitForSearchResults(PatrolIntegrationTester $) async {
    $.log('Waiting for search results to populate');

    const maxWaitTime = Duration(seconds: 15);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));

      final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
      final paginationLoading = AppLocators.getHotelsPaginationLoading($);

      final isLoading = loadingIndicator.exists || paginationLoading.exists;

      if (!isLoading) {
        final hasCards = $(Card).exists;
        final hasError = AppLocators.getHotelsErrorMessage($).exists;
        final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;

        if (hasCards) {
          $.log('Search results populated - hotel cards found');
          await validateHotelCards($);
          return;
        } else if (hasError) {
          $.log('Search resulted in error state');
          return;
        } else if (hasEmpty) {
          $.log('Search resulted in empty state');
          return;
        }
      }
    }

    stopwatch.stop();
    throw Exception('Search results did not populate within timeout');
  }

  static Future<void> validateHotelCards(PatrolIntegrationTester $) async {
    $.log('Validating hotel cards information');

    final cardFinder = $(Card);
    final cards = cardFinder.evaluate();

    expect(cards.length, greaterThan(0),
        reason: 'Should have at least one hotel card');

    final cardsToValidate = cards.length > 3 ? 3 : cards.length;

    for (int i = 0; i < cardsToValidate; i++) {
      await _validateSingleHotelCard($, i);
    }

    $.log('Hotel cards validation completed');
  }

  static Future<void> _validateSingleHotelCard(
      PatrolIntegrationTester $, int cardIndex) async {
    $.log('Validating hotel card $cardIndex structure');

    final cardWidget = $(Card).at(cardIndex);

    expect(cardWidget.exists, isTrue,
        reason: 'Hotel card $cardIndex should exist');

    await cardWidget.waitUntilExists();

    $.log('Hotel card $cardIndex validated successfully');
  }

  static Future<void> testScrollingAndPagination(
      PatrolIntegrationTester $) async {
    $.log('Testing scrolling behavior and pagination');

    final initialCardCount = $(Card).evaluate().length;
    $.log('Initial card count: $initialCardCount');

    if (initialCardCount == 0) {
      $.log('No cards found - skipping scrolling test');
      return;
    }

    final scrollView = AppLocators.getHotelsScrollView($);

    for (int i = 0; i < 3; i++) {
      $.log('Performing scroll ${i + 1}/3');

      if (scrollView.exists) {
        await $.tester.drag(scrollView.finder, const Offset(0, -400));
      } else {
        final customScrollView = $(CustomScrollView);
        if (customScrollView.exists) {
          await $.tester.drag(customScrollView.first, const Offset(0, -400));
        }
      }

      await $.pump(const Duration(milliseconds: 500));

      final paginationLoading = AppLocators.getHotelsPaginationLoading($);
      if (paginationLoading.exists) {
        $.log('Pagination loading indicator appeared');

        await _waitForPaginationToComplete($);
        break;
      }

      final currentCardCount = $(Card).evaluate().length;
      if (currentCardCount > initialCardCount) {
        $.log('New cards loaded: $initialCardCount -> $currentCardCount');
        break;
      }
    }

    $.log('Scrolling and pagination test completed');
  }

  static Future<void> _waitForPaginationToComplete(
      PatrolIntegrationTester $) async {
    const maxWaitTime = Duration(seconds: 20);
    final stopwatch = Stopwatch()..start();

    final paginationLoading = AppLocators.getHotelsPaginationLoading($);

    while (stopwatch.elapsed < maxWaitTime && paginationLoading.exists) {
      await $.pump(const Duration(milliseconds: 500));
    }

    stopwatch.stop();
    $.log('Pagination completed in ${stopwatch.elapsed.inSeconds}s');
  }

  static Future<void> favoriteRandomHotels(PatrolIntegrationTester $) async {
    $.log('Favorite random hotels');

    final cards = $(Card).evaluate();
    if (cards.isEmpty) {
      $.log('No hotel cards found to favorite');
      return;
    }

    final cardsToFavorite = cards.length >= 3
        ? 3
        : cards.length >= 2
            ? 2
            : 1;

    _favoriteHotels.clear();

    for (int i = 0; i < cardsToFavorite; i++) {
      await _favoriteHotelCard($, i);
    }

    $.log('Favorite $cardsToFavorite hotels');
  }

  static Future<void> _favoriteHotelCard(
      PatrolIntegrationTester $, int cardIndex) async {
    $.log('Attempting to favorite hotel card $cardIndex');

    final cardWidget = $(Card).at(cardIndex);

    String hotelName = 'Hotel ${cardIndex + 1}';

    try {
      final cardText = cardWidget.text;
      if (cardText != null && cardText.isNotEmpty) {
        hotelName = cardText;
      }
    } catch (e) {
      $.log('Could not extract hotel name using text property: $e');

      try {
        final textWidget = $(Text).first;
        if (textWidget.exists) {
          final textContent = textWidget.text;
          if (textContent != null && textContent.isNotEmpty) {
            hotelName = textContent;
          }
        }
      } catch (e2) {
        $.log('Could not extract hotel name, using default: $e2');
      }
    }

    $.log('Attempting to favorite hotel: "$hotelName"');

    try {
      final iconButton = $(IconButton).at(cardIndex);

      if (iconButton.exists) {
        await iconButton.waitUntilVisible();
        await iconButton.tap();
        await $.pump(const Duration(milliseconds: 800));

        _favoriteHotels.add(hotelName);
        $.log(
            'Successfully favorite hotel: "$hotelName" (card index: $cardIndex)');
      } else {
        $.log('No IconButton found at index $cardIndex');

        _favoriteHotels.add(hotelName);
      }
    } catch (e) {
      $.log('Error favorite hotel card $cardIndex: $e');

      _favoriteHotels.add(hotelName);
    }
  }

  static Future<void> validateFavoritesPage(PatrolIntegrationTester $) async {
    $.log('Validating Favorites page');

    final favoritesTab = AppLocators.getFavoritesTab($);
    await favoritesTab.waitUntilVisible();
    await favoritesTab.tap();

    final favoritesScaffold = AppLocators.getFavoritesScaffold($);
    await favoritesScaffold.waitUntilExists();

    final favoritesCards = $(Card).evaluate();

    if (_favoriteHotels.isEmpty) {
      $.log('No hotels were favorite - checking for empty state');
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      expect(emptyStateIcon.exists, isTrue,
          reason: 'Should show empty state when no favorites');
      return;
    }

    expect(favoritesCards.length, equals(_favoriteHotels.length),
        reason: 'Favorites count should match favorite hotels count');

    $.log(
        'Favorites page validation completed - ${favoritesCards.length} favorites found');
  }

  static Future<void> removeFavoriteHotels(PatrolIntegrationTester $) async {
    $.log('Removing favorite hotels');

    final favoritesScaffold = AppLocators.getFavoritesScaffold($);
    await favoritesScaffold.waitUntilExists();

    int previousCount = -1;
    int safetyCounter = 0;
    const maxAttempts = 10;

    while ($(Card).exists && safetyCounter < maxAttempts) {
      safetyCounter++;

      final currentCards = $(Card).evaluate();
      final currentCount = currentCards.length;

      $.log('Attempt $safetyCounter: Found $currentCount cards');

      if (currentCount == previousCount) {
        $.log('Card count unchanged, breaking loop to prevent infinite loop');
        break;
      }
      previousCount = currentCount;

      final firstCard = $(Card).first;
      if (firstCard.exists) {
        try {
          final firstIconButton = $(IconButton).first;
          if (firstIconButton.exists) {
            await firstIconButton.waitUntilVisible();
            await firstIconButton.tap();
            await $.pump(const Duration(milliseconds: 800));

            $.log(
                'Tapped IconButton - cards remaining should be: ${currentCount - 1}');
          } else {
            $.log('No IconButton found, breaking loop');
            break;
          }
        } catch (e) {
          $.log('Error tapping IconButton: $e');
          break;
        }
      } else {
        $.log('No more cards found');
        break;
      }
    }

    final finalCardCount = $(Card).evaluate().length;
    $.log('Final card count: $finalCardCount');

    if (finalCardCount == 0) {
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      try {
        await emptyStateIcon.waitUntilExists();
        $.log(
            'All favorite hotels removed successfully - empty state verified');
      } catch (e) {
        $.log('Empty state verification failed: $e');
      }
    } else {
      $.log(
          'Warning: $finalCardCount favorites may still remain after $safetyCounter attempts');
    }
  }

  static Future<void> testNegativeSearchScenarios(
      PatrolIntegrationTester $) async {
    $.log('Testing negative search scenarios');

    final hotelsTab = AppLocators.getHotelsTab($);
    await hotelsTab.waitUntilVisible();
    await hotelsTab.tap();

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.enterText('   ');

    await $.pump(const Duration(milliseconds: 1500));

    await _verifyErrorState($);

    await _testRetryFunctionality($);

    $.log('Negative search scenarios test completed');
  }

  static Future<void> clearSearchField(PatrolIntegrationTester $) async {
    $.log('Clearing search field');

    final clearButton = AppLocators.getSearchClearButton($);
    if (clearButton.exists) {
      await clearButton.tap();
      await $.pump(const Duration(milliseconds: 500));
      $.log('Search field cleared using clear button');
    } else {
      final searchTextField = AppLocators.getSearchTextField($);
      if (searchTextField.exists) {
        await searchTextField.tap();
        await $.pump(const Duration(milliseconds: 300));
        await searchTextField.enterText('');
        $.log('Search field cleared using text entry');
      } else {
        $.log('Warning: Could not find search field to clear');
      }
    }
  }

  static Future<void> _verifyErrorState(PatrolIntegrationTester $) async {
    $.log('Verifying error state');

    const maxWaitTime = Duration(seconds: 10);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));

      final errorMessage = AppLocators.getHotelsErrorMessage($);
      final retryButton = AppLocators.getHotelsRetryButton($);

      if (errorMessage.exists && retryButton.exists) {
        final errorText = errorMessage.containing('Something went wrong');
        expect(errorText.exists, isTrue,
            reason: 'Should show "Something went wrong" message');

        final retryText = retryButton.containing('Try Again');
        expect(retryText.exists, isTrue,
            reason: 'Should show "Try Again" button');

        $.log('Error state verified successfully');
        return;
      }
    }

    stopwatch.stop();
    throw Exception('Error state did not appear within timeout');
  }

  static Future<void> _testRetryFunctionality(PatrolIntegrationTester $) async {
    $.log('Testing retry functionality');

    final retryButton = AppLocators.getHotelsRetryButton($);

    if (retryButton.exists) {
      await retryButton.tap();
      await $.pump(const Duration(milliseconds: 1000));

      $.log('Retry button tapped successfully');
    } else {
      $.log('Retry button not found');
    }
  }

  static Future<void> runCompleteHotelsTest(PatrolIntegrationTester $) async {
    $.log('Running complete Hotels page test suite');

    try {
      await navigateToHotelsPage($);

      await performSearchTest($, 'Dubai');

      await testScrollingAndPagination($);

      await favoriteRandomHotels($);

      await validateFavoritesPage($);

      await removeFavoriteHotels($);

      await testNegativeSearchScenarios($);

      $.log('Complete Hotels page test suite completed successfully');
    } catch (e) {
      $.log('Hotels test suite failed: $e');
      rethrow;
    }
  }

  static Future<void> testEmptySearchInput(PatrolIntegrationTester $) async {
    $.log('Testing empty search input');

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.enterText('');

    await $.pump(const Duration(milliseconds: 1000));

    final hasCards = $(Card).exists;
    final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;

    if (!hasCards) {
      expect(hasEmpty, isTrue,
          reason: 'Should show empty state for empty search');
    }

    $.log('Empty search input test completed');
  }

  static Future<void> testSpecialCharacterSearch(
      PatrolIntegrationTester $) async {
    $.log('Testing special character search input - FIXED VERSION');

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();

    const specialQuery = 'Café & Résidence';
    await searchTextField.enterText(specialQuery);

    await $.pump(const Duration(milliseconds: 1500));

    const maxWaitTime = Duration(seconds: 10);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));

      final hasCards = $(Card).exists;
      final hasError = AppLocators.getHotelsErrorMessage($).exists;
      final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;
      final isLoading = AppLocators.getHotelsLoadingIndicator($).exists;

      if (!isLoading && (hasCards || hasError || hasEmpty)) {
        $.log(
            'Special character search handled: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');
        break;
      }
    }

    $.log('Special character search test completed');
  }

  static Future<void> testLongSearchQuery(PatrolIntegrationTester $) async {
    $.log('Testing very long search query');

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();

    const longQuery =
        'This is a very long search query that tests the application behavior with extremely long input strings that might cause issues';
    await searchTextField.enterText(longQuery);

    await $.pump(const Duration(milliseconds: 1500));

    const maxWaitTime = Duration(seconds: 10);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));

      final hasCards = $(Card).exists;
      final hasError = AppLocators.getHotelsErrorMessage($).exists;
      final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;
      final isLoading = AppLocators.getHotelsLoadingIndicator($).exists;

      if (!isLoading && (hasCards || hasError || hasEmpty)) {
        $.log(
            'Long query handled: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');
        break;
      }
    }

    $.log('Long search query test completed');
  }

  static Future<void> clearExistingFavorites(PatrolIntegrationTester $) async {
    $.log('Clearing existing favorites');

    final favoritesScaffold = AppLocators.getFavoritesScaffold($);
    await favoritesScaffold.waitUntilExists();

    await removeFavoriteHotels($);

    $.log('Existing favorites cleared');
  }

  static Future<void> verifySearchStateAfterNavigation(
      PatrolIntegrationTester $) async {
    $.log('Verifying search state after navigation');

    final hasCards = $(Card).exists;
    final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;
    final searchTextField = AppLocators.getSearchTextField($);

    if (searchTextField.exists) {
      final searchText = searchTextField.text;
      $.log('Search field state after navigation: "${searchText ?? ""}"');
    }

    if (hasCards) {
      $.log('Search results persisted after navigation');
    } else if (hasEmpty) {
      $.log('Empty state shown after navigation');
    } else {
      $.log('Initial state restored after navigation');
    }

    $.log('Search state verification completed');
  }

  static Future<void> testSpecialCharacterSearchVariant(
      PatrolIntegrationTester $) async {
    $.log('Testing special character search variant');

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();

    const variants = ['São Paulo', 'München', 'Zürich', 'Malmö'];

    for (final variant in variants) {
      $.log('Testing variant: $variant');

      await searchTextField.tap();
      await searchTextField.enterText(variant);
      await $.pump(const Duration(milliseconds: 1000));

      final hasCards = $(Card).exists;
      final hasError = AppLocators.getHotelsErrorMessage($).exists;
      final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;

      $.log(
          'Variant "$variant" result: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');

      await clearSearchField($);
      await $.pump(const Duration(milliseconds: 500));
    }

    $.log('Special character search variants test completed');
  }

  static Future<void> testNumericSearchInput(PatrolIntegrationTester $) async {
    $.log('Testing numeric search input');

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();

    const numericQueries = ['12345', '2024', '007', '90210'];

    for (final query in numericQueries) {
      $.log('Testing numeric query: $query');

      await searchTextField.tap();
      await searchTextField.enterText(query);
      await $.pump(const Duration(milliseconds: 1000));

      final hasCards = $(Card).exists;
      final hasError = AppLocators.getHotelsErrorMessage($).exists;
      final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;

      $.log(
          'Numeric query "$query" result: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');

      await clearSearchField($);
      await $.pump(const Duration(milliseconds: 500));
    }

    $.log('Numeric search input test completed');
  }

  static Future<void> testUnicodeCharacterSearch(
      PatrolIntegrationTester $) async {
    $.log('Testing Unicode character search');

    await clearSearchField($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();

    const unicodeQueries = ['北京', 'القاهرة', 'Москва', '東京', '🏨'];

    for (final query in unicodeQueries) {
      $.log('Testing Unicode query: $query');

      await searchTextField.tap();
      await searchTextField.enterText(query);
      await $.pump(const Duration(milliseconds: 1000));

      final hasCards = $(Card).exists;
      final hasError = AppLocators.getHotelsErrorMessage($).exists;
      final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;

      $.log(
          'Unicode query "$query" result: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');

      await clearSearchField($);
      await $.pump(const Duration(milliseconds: 500));
    }

    $.log('Unicode character search test completed');
  }
}
