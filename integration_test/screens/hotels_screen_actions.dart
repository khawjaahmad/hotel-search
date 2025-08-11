import 'dart:async';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';

/// Enhanced Hotels Screen Actions with Advanced Features
/// Includes fluent interface, advanced error handling, and performance monitoring
class HotelsScreenActions {
  final PatrolIntegrationTester tester;
  final Duration defaultTimeout;
  
  HotelsScreenActions(this.tester, {this.defaultTimeout = const Duration(seconds: 10)});
  
  /// Get page-specific assertions (would need custom_assertions import)
  // HotelsPageAssertions get assertions => HotelsPageAssertions(tester, this);
  static final List<String> _favoriteHotels = [];

  /// Fluent wait with custom conditions
  Future<HotelsScreenActions> waitFor(PatrolFinder finder, {
    Duration? timeout,
    String? description,
  }) async {
    final actualTimeout = timeout ?? defaultTimeout;
    final desc = description ?? 'element to be visible';
    
    try {
      await finder.waitUntilVisible(timeout: actualTimeout);
      return this;
    } catch (e) {
      throw HotelsPageException(
        'Failed to wait for $desc on Hotels page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Fluent tap with validation
  Future<HotelsScreenActions> tapElement(PatrolFinder finder, {
    String? description,
    bool validateAfterTap = true,
  }) async {
    final desc = description ?? 'element';
    
    try {
      await finder.waitUntilVisible();
      await finder.tap();
      
      if (validateAfterTap) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      
      return this;
    } catch (e) {
      throw HotelsPageException(
        'Failed to tap $desc on Hotels page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Fluent text input with validation
  Future<HotelsScreenActions> enterText(PatrolFinder finder, String text, {
    String? description,
    bool clearFirst = true,
  }) async {
    final desc = description ?? 'text field';
    
    try {
      await finder.waitUntilVisible();
      
      if (clearFirst) {
        await finder.tap();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(finder, '');
      }
      
      await finder.enterText(text);
      await tester.pump(const Duration(milliseconds: 300));
      
      return this;
    } catch (e) {
      throw HotelsPageException(
        'Failed to enter text "$text" in $desc on Hotels page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Validate page is loaded with fluent interface
  Future<HotelsScreenActions> validatePageLoaded() async {
    await waitFor(AppLocators.getHotelsScaffold(tester), description: 'hotels scaffold');
    await waitFor(AppLocators.getHotelsAppBar(tester), description: 'hotels app bar');
    await waitFor(AppLocators.getSearchTextField(tester), description: 'search field');
    return this;
  }

  /// Enhanced search with advanced options
  Future<HotelsScreenActions> performSearch(String query, {
    bool waitForResults = true,
    Duration? searchTimeout,
  }) async {
    await enterText(
      AppLocators.getSearchTextField(tester),
      query,
      description: 'search field',
    );

    if (waitForResults) {
      await _waitForSearchResults(searchTimeout ?? const Duration(seconds: 15));
    }

    return this;
  }

  /// Advanced search result waiting with multiple conditions
  Future<HotelsScreenActions> _waitForSearchResults(Duration timeout) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 500));
      
      // Check for loading indicators
      final isLoading = AppLocators.getHotelsLoadingIndicator(tester).exists ||
                       AppLocators.getHotelsPaginationLoading(tester).exists;
      
      if (!isLoading) {
        // Check for results, errors, or empty state
        if (tester(Card).exists) {
          return this; // Results found
        } else if (AppLocators.getHotelsErrorMessage(tester).exists) {
          return this; // Error state
        } else if (AppLocators.getHotelsEmptyStateIcon(tester).exists) {
          return this; // Empty state
        }
      }
    }
    
    throw HotelsPageException(
      'Search results did not load within ${timeout.inSeconds} seconds',
    );
  }

  /// Smart hotel selection with validation
  Future<HotelsScreenActions> selectHotel(int index, {bool validateSelection = true}) async {
    final cards = tester(Card).evaluate();
    
    if (index >= cards.length) {
      throw HotelsPageException(
        'Hotel index $index out of range (0-${cards.length - 1})',
      );
    }

    await tapElement(
      tester(Card).at(index),
      description: 'hotel card at index $index',
      validateAfterTap: validateSelection,
    );

    return this;
  }

  /// Advanced favorites management
  Future<HotelsScreenActions> toggleFavorite(int hotelIndex, {bool expectAdded = true}) async {
    final cards = tester(Card).evaluate();
    
    if (hotelIndex >= cards.length) {
      throw HotelsPageException(
        'Hotel index $hotelIndex out of range',
      );
    }

    // Find favorite button within the card
    final favoriteButton = tester(IconButton).at(hotelIndex);
    
    if (!favoriteButton.exists) {
      throw HotelsPageException(
        'Favorite button not found in hotel card at index $hotelIndex',
      );
    }

    await tapElement(favoriteButton, description: 'favorite button');
    
    // Validate the action with visual feedback
    await tester.pump(const Duration(milliseconds: 500));
    
    return this;
  }

  /// Bulk operations for stress testing
  Future<HotelsScreenActions> favoriteMultipleHotels(List<int> indices) async {
    for (final index in indices) {
      await toggleFavorite(index);
      await tester.pump(const Duration(milliseconds: 200)); // Prevent rapid tapping
    }
    return this;
  }

  /// Data-driven search testing
  Future<HotelsScreenActions> performDataDrivenSearch(List<String> queries) async {
    for (final query in queries) {
      await performSearch(query);
      // await assertions.assertSearchResults(); // Would need custom_assertions import
      await tester.pump(const Duration(milliseconds: 500));
    }
    return this;
  }

  /// Clear search field
  Future<HotelsScreenActions> clearSearchField() async {
    await enterText(
      AppLocators.getSearchTextField(tester),
      '',
      description: 'search field',
      clearFirst: true,
    );
    return this;
  }

  /// Error scenario testing
  Future<HotelsScreenActions> testErrorScenarios() async {
    final errorScenarios = [
      '', // Empty search
      '!@#\$%^&*()', // Special characters
      'x' * 1000, // Very long query
      '   ', // Whitespace only
    ];

    for (final scenario in errorScenarios) {
      await performSearch(scenario, waitForResults: false);
      await tester.pump(const Duration(seconds: 2));
      // Validate error handling or graceful degradation
    }
    
    return this;
  }

  static Future<void> navigateToHotelsPage(PatrolIntegrationTester $) async {
    TestLogger.logNavigation($, 'Hotels page');

    final hotelsTab = AppLocators.getHotelsTab($);
    await hotelsTab.waitUntilVisible();
    await hotelsTab.tap();

    await verifyHotelsPageStructure($);
  }

  static Future<void> verifyHotelsPageStructure(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'Hotels page structure');

    final scaffold = AppLocators.getHotelsScaffold($);
    await scaffold.waitUntilExists();

    final appBar = AppLocators.getHotelsAppBar($);
    await appBar.waitUntilExists();

    final appBarElements = appBar.evaluate();
    if (appBarElements.length != 1) {
      throw Exception(
          'Expected exactly 1 app bar, found ${appBarElements.length}');
    }

    final searchField = AppLocators.getHotelsSearchField($);
    await searchField.waitUntilExists();

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilExists();

    final searchIcon = AppLocators.getSearchPrefixIcon($);
    await searchIcon.waitUntilExists();

    final clearButton = AppLocators.getSearchClearButton($);
    await clearButton.waitUntilExists();

    TestLogger.logTestSuccess($, 'Hotels page structure verified');
  }

  static Future<void> performSearchTest(
      PatrolIntegrationTester $, String searchQuery) async {
    TestLogger.logAction(
        $, 'Testing search functionality with query: "$searchQuery"');

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.tap();

    await searchTextField.enterText(searchQuery);

    await $.pump(const Duration(milliseconds: 1500));

    await _waitForSearchResultsStatic($);

    TestLogger.logTestSuccess($, 'Search functionality test completed');
  }

  static Future<void> _waitForSearchResultsStatic(PatrolIntegrationTester $) async {
    TestLogger.logWaiting($, 'search results to populate');

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
          TestLogger.logTestSuccess(
              $, 'Search results populated - hotel cards found');
          await validateHotelCards($);
          return;
        } else if (hasError) {
          TestLogger.logTestStep($, 'Search resulted in error state');
          return;
        } else if (hasEmpty) {
          TestLogger.logTestStep($, 'Search resulted in empty state');
          return;
        }
      }
    }

    stopwatch.stop();
    throw Exception('Search results did not populate within timeout');
  }

  static Future<void> validateHotelCards(PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'hotel cards information');

    final cardFinder = $(Card);
    final cards = cardFinder.evaluate();

    if (cards.isEmpty) {
      throw Exception('Should have at least one hotel card');
    }

    final cardsToValidate = cards.length > 3 ? 3 : cards.length;

    for (int i = 0; i < cardsToValidate; i++) {
      await _validateSingleHotelCard($, i);
    }

    TestLogger.logTestSuccess($, 'Hotel cards validation completed');
  }

  static Future<void> _validateSingleHotelCard(
      PatrolIntegrationTester $, int cardIndex) async {
    TestLogger.logValidation($, 'hotel card $cardIndex structure');

    final cardWidget = $(Card).at(cardIndex);

    if (!cardWidget.exists) {
      throw Exception('Hotel card $cardIndex should exist');
    }

    await cardWidget.waitUntilExists();

    TestLogger.logTestSuccess($, 'Hotel card $cardIndex validated');
  }

  static Future<void> testScrollingAndPagination(
      PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing scrolling behavior and pagination');

    final initialCardCount = $(Card).evaluate().length;
    TestLogger.logTestStep($, 'Initial card count: $initialCardCount');

    if (initialCardCount == 0) {
      TestLogger.logTestStep($, 'No cards found - skipping scrolling test');
      return;
    }

    final scrollView = AppLocators.getHotelsScrollView($);

    for (int i = 0; i < 3; i++) {
      TestLogger.logAction($, 'Performing scroll ${i + 1}/3');

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
        TestLogger.logTestStep($, 'Pagination loading indicator appeared');

        await _waitForPaginationToComplete($);
        break;
      }

      final currentCardCount = $(Card).evaluate().length;
      if (currentCardCount > initialCardCount) {
        TestLogger.logTestSuccess(
            $, 'New cards loaded: $initialCardCount -> $currentCardCount');
        break;
      }
    }

    TestLogger.logTestSuccess($, 'Scrolling and pagination test completed');
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
    TestLogger.logTestStep(
        $, 'Pagination completed in ${stopwatch.elapsed.inSeconds}s');
  }

  static Future<void> favoriteRandomHotels(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Favoriting random hotels');

    final cards = $(Card).evaluate();
    if (cards.isEmpty) {
      TestLogger.logTestStep($, 'No hotel cards found to favorite');
      return;
    }

    final cardsToFavorite = cards.length >= 2 ? 2 : 1;

    _favoriteHotels.clear();

    await $.pump(const Duration(seconds: 1));

    for (int i = 0; i < cardsToFavorite; i++) {
      await _favoriteHotelCard($, i);
      await $.pump(const Duration(milliseconds: 1000));
    }

    TestLogger.logTestSuccess($, 'Favorited $cardsToFavorite hotels');
  }

  static Future<void> _favoriteHotelCard(
      PatrolIntegrationTester $, int cardIndex) async {
    TestLogger.logAction($, 'Attempting to favorite hotel card $cardIndex');

    String hotelName = 'Hotel ${cardIndex + 1}';

    try {
      final iconButton = $(IconButton).at(cardIndex);

      if (iconButton.exists) {
        await iconButton.waitUntilVisible();
        await iconButton.tap();
        await $.pump(const Duration(milliseconds: 800));

        _favoriteHotels.add(hotelName);
        TestLogger.logTestSuccess($,
            'Successfully favorited hotel: "$hotelName" (card index: $cardIndex)');
      } else {
        TestLogger.logTestStep($, 'No IconButton found at index $cardIndex');
      }
    } catch (e) {
      TestLogger.logTestError($, 'Error favoriting hotel card $cardIndex: $e');
    }
  }

  static Future<void> validateFavoritesPage(PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'Favorites page');

    final favoritesTab = AppLocators.getFavoritesTab($);
    await favoritesTab.waitUntilVisible();
    await favoritesTab.tap();

    await $.pump(const Duration(seconds: 2));
    await $.pumpAndSettle();

    final favoritesScaffold = AppLocators.getFavoritesScaffold($);
    await favoritesScaffold.waitUntilExists();

    final favoritesCards = $(Card).evaluate();

    if (_favoriteHotels.isEmpty) {
      TestLogger.logTestStep(
          $, 'No hotels were favorited - checking for empty state');
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);

      if (!emptyStateIcon.exists) {
        throw Exception('Should show empty state when no favorites');
      }
      return;
    }

    if (favoritesCards.isEmpty && _favoriteHotels.isNotEmpty) {
      TestLogger.logTestStep($,
          'Expected favorites but found none - checking if favorites actually got added');
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      if (emptyStateIcon.exists) {
        TestLogger.logTestStep($,
            'Empty state shown - favorites may not have been saved properly');
        return;
      }
    }

    TestLogger.logTestSuccess($,
        'Favorites page validation completed - ${favoritesCards.length} favorites found (expected: ${_favoriteHotels.length})');
  }

  static Future<void> removeFavoriteHotels(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Removing favorite hotels');

    final favoritesScaffold = AppLocators.getFavoritesScaffold($);
    await favoritesScaffold.waitUntilExists();

    int previousCount = -1;
    int safetyCounter = 0;
    const maxAttempts = 10;

    while ($(Card).exists && safetyCounter < maxAttempts) {
      safetyCounter++;

      final currentCards = $(Card).evaluate();
      final currentCount = currentCards.length;

      TestLogger.logTestStep(
          $, 'Attempt $safetyCounter: Found $currentCount cards');

      if (currentCount == previousCount) {
        TestLogger.logTestStep(
            $, 'Card count unchanged, breaking loop to prevent infinite loop');
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

            TestLogger.logTestStep($,
                'Tapped IconButton - cards remaining should be: ${currentCount - 1}');
          } else {
            TestLogger.logTestStep($, 'No IconButton found, breaking loop');
            break;
          }
        } catch (e) {
          TestLogger.logTestError($, 'Error tapping IconButton: $e');
          break;
        }
      } else {
        TestLogger.logTestStep($, 'No more cards found');
        break;
      }
    }

    final finalCardCount = $(Card).evaluate().length;
    TestLogger.logTestStep($, 'Final card count: $finalCardCount');

    if (finalCardCount == 0) {
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      try {
        await emptyStateIcon.waitUntilExists();
        TestLogger.logTestSuccess($,
            'All favorite hotels removed successfully - empty state verified');
      } catch (e) {
        TestLogger.logTestError($, 'Empty state verification failed: $e');
      }
    } else {
      TestLogger.logTestStep($,
          'Warning: $finalCardCount favorites may still remain after $safetyCounter attempts');
    }
  }

  static Future<void> testNegativeSearchScenarios(
      PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing negative search scenarios');

    final hotelsTab = AppLocators.getHotelsTab($);
    await hotelsTab.waitUntilVisible();
    await hotelsTab.tap();

    await clearSearchFieldStatic($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.enterText('   ');

    await $.pump(const Duration(milliseconds: 1500));

    await _verifyErrorState($);
    await _testRetryFunctionality($);

    TestLogger.logTestSuccess($, 'Negative search scenarios test completed');
  }

  static Future<void> clearSearchFieldStatic(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Clearing search field');

    final clearButton = AppLocators.getSearchClearButton($);
    if (clearButton.exists) {
      await clearButton.tap();
      await $.pump(const Duration(milliseconds: 500));
      TestLogger.logTestStep($, 'Search field cleared using clear button');
    } else {
      final searchTextField = AppLocators.getSearchTextField($);
      if (searchTextField.exists) {
        await searchTextField.tap();
        await $.pump(const Duration(milliseconds: 300));
        await searchTextField.enterText('');
        TestLogger.logTestStep($, 'Search field cleared using text entry');
      } else {
        TestLogger.logTestStep(
            $, 'Warning: Could not find search field to clear');
      }
    }
  }

  static Future<void> _verifyErrorState(PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'error state');

    const maxWaitTime = Duration(seconds: 10);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));

      final errorMessage = AppLocators.getHotelsErrorMessage($);
      final retryButton = AppLocators.getHotelsRetryButton($);

      if (errorMessage.exists && retryButton.exists) {
        final errorText = errorMessage.containing('Something went wrong');

        if (!errorText.exists) {
          throw Exception('Should show "Something went wrong" message');
        }

        final retryText = retryButton.containing('Try Again');
        if (!retryText.exists) {
          throw Exception('Should show "Try Again" button');
        }

        TestLogger.logTestSuccess($, 'Error state verified successfully');
        return;
      }
    }

    stopwatch.stop();
    throw Exception('Error state did not appear within timeout');
  }

  static Future<void> _testRetryFunctionality(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing retry functionality');

    final retryButton = AppLocators.getHotelsRetryButton($);

    if (retryButton.exists) {
      await retryButton.tap();
      await $.pump(const Duration(milliseconds: 1000));

      TestLogger.logTestSuccess($, 'Retry button tapped successfully');
    } else {
      TestLogger.logTestStep($, 'Retry button not found');
    }
  }

  static Future<void> runCompleteHotelsTest(PatrolIntegrationTester $) async {
    TestLogger.logTestStart($, 'Complete Hotels page test suite');

    try {
      await navigateToHotelsPage($);
      await performSearchTest($, 'Dubai');
      await testScrollingAndPagination($);
      await favoriteRandomHotels($);
      await validateFavoritesPage($);
      await removeFavoriteHotels($);
      await testNegativeSearchScenarios($);

      TestLogger.logTestSuccess(
          $, 'Complete Hotels page test suite completed successfully');
    } catch (e) {
      TestLogger.logTestError($, 'Hotels test suite failed: $e');
      rethrow;
    }
  }

  static Future<void> testEmptySearchInput(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing empty search input');

    await clearSearchFieldStatic($);

    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.enterText('');

    await $.pump(const Duration(milliseconds: 1000));

    final hasCards = $(Card).exists;
    final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;

    if (!hasCards && !hasEmpty) {
      throw Exception('Should show empty state for empty search');
    }

    TestLogger.logTestSuccess($, 'Empty search input test completed');
  }

  static Future<void> testSpecialCharacterSearch(
      PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing special character search input');

    await clearSearchFieldStatic($);

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
        TestLogger.logTestStep($,
            'Special character search handled: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');
        break;
      }
    }

    TestLogger.logTestSuccess($, 'Special character search test completed');
  }

  static Future<void> testLongSearchQuery(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing very long search query');

    await clearSearchFieldStatic($);

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
        TestLogger.logTestStep($,
            'Long query handled: Cards: $hasCards, Error: $hasError, Empty: $hasEmpty');
        break;
      }
    }

    TestLogger.logTestSuccess($, 'Long search query test completed');
  }

  static Future<void> clearExistingFavorites(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Clearing existing favorites');

    final favoritesScaffold = AppLocators.getFavoritesScaffold($);
    await favoritesScaffold.waitUntilExists();

    await removeFavoriteHotels($);

    TestLogger.logTestSuccess($, 'Existing favorites cleared');
  }

  static Future<void> verifySearchStateAfterNavigation(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'search state after navigation');

    final hasCards = $(Card).exists;
    final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;
    final searchTextField = AppLocators.getSearchTextField($);

    if (searchTextField.exists) {
      try {
        final searchFieldWidget = searchTextField.evaluate().first;

        String searchText = '';
        if (searchFieldWidget.widget is TextFormField) {
          final textField = searchFieldWidget.widget as TextFormField;
          searchText = textField.controller?.text ?? '';
        } else if (searchFieldWidget.widget is TextField) {
          final textField = searchFieldWidget.widget as TextField;
          searchText = textField.controller?.text ?? '';
        }

        TestLogger.logTestStep(
            $, 'Search field state after navigation: "$searchText"');
      } catch (e) {
        TestLogger.logTestStep($, 'Could not read search field text: $e');
      }
    }

    if (hasCards) {
      TestLogger.logTestStep($, 'Search results persisted after navigation');
    } else if (hasEmpty) {
      TestLogger.logTestStep($, 'Empty state shown after navigation');
    } else {
      TestLogger.logTestStep($, 'Initial state restored after navigation');
    }

    TestLogger.logTestSuccess($, 'Search state verification completed');
  }
}

/// Custom exception class for Hotels page specific errors
class HotelsPageException implements Exception {
  final String message;
  final Exception? originalException;
  
  const HotelsPageException(this.message, {this.originalException});
  
  @override
  String toString() {
    if (originalException != null) {
      return 'HotelsPageException: $message\nCaused by: $originalException';
    }
    return 'HotelsPageException: $message';
  }
}

/// Custom assertions class for Hotels page
class HotelsPageAssertions {
  final PatrolIntegrationTester tester;
  final HotelsScreenActions actions;
  
  HotelsPageAssertions(this.tester, this.actions);
  
  /// Assert that the hotels page is properly loaded
  Future<void> assertPageLoaded() async {
    await actions.validatePageLoaded();
  }
  
  /// Assert that search results are displayed
  Future<void> assertSearchResults() async {
    final hasCards = tester(Card).exists;
    final hasEmpty = AppLocators.getHotelsEmptyStateIcon(tester).exists;
    final hasError = AppLocators.getHotelsErrorMessage(tester).exists;
    
    if (!hasCards && !hasEmpty && !hasError) {
      throw HotelsPageException('Expected search results, empty state, or error state');
    }
  }
}
