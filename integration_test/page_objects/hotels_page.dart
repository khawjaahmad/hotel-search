import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/app_locators.dart';
import '../helpers/search_error_handler.dart';

/// Hotels Page Object Model
/// Handles hotel search, listing, favorites, and pagination operations
/// Follows best practices for maintainable and reliable test automation
class HotelsPage extends BasePage {
  HotelsPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'hotels';

  @override
  String get pageKey => AppLocators.hotelsScaffold;

  // =============================================================================
  // BASIC VERIFICATION METHODS
  // =============================================================================

  /// Verify that the hotels page is fully loaded and ready for interaction
  Future<void> verifyHotelsPageLoaded() async {
    logAction('Verifying hotels page is loaded');
    await verifyPageIsLoaded();
    await _verifyHotelsPageElements();
  }

  /// Verify all essential page elements are present
  Future<void> _verifyHotelsPageElements() async {
    logAction('Verifying hotels page elements');
    verifyElementExists(AppLocators.hotelsAppBar);
    verifyElementExists(AppLocators.hotelsSearchField);
    _verifySearchFieldComponents();
  }

  /// Verify search field and its components are functional
  void _verifySearchFieldComponents() {
    logAction('Verifying search field components');

    // Verify TextField exists within the search field container
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget,
        reason: 'TextField should be present in search field');

    // Verify search icon exists
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget, reason: 'Search icon should be visible');

    // Verify clear button exists
    final clearButton = find.byIcon(Icons.cancel_outlined);
    expect(clearButton, findsOneWidget,
        reason: 'Clear button should be accessible');
  }

  /// Check if search field is visible and functional
  void verifySearchFieldVisible() {
    logAction('Verifying search field visibility and functionality');
    verifyElementExists(AppLocators.hotelsSearchField);
    _verifySearchFieldComponents();
  }

  // =============================================================================
  // SEARCH OPERATIONS
  // =============================================================================

  /// Perform hotel search with the given query
  /// @param query - The search term to enter
  Future<void> searchHotels(String query) async {
    logAction('Searching for hotels with query: "$query"');

    await _prepareSearchField();
    await _enterSearchQuery(query);
    await _waitForSearchToProcess();

    await takePageScreenshot('search_completed_$query');
  }

  /// Prepare search field for input by clearing any existing content
  Future<void> _prepareSearchField() async {
    await waitForElement(AppLocators.hotelsSearchField);
    await _clearSearchFieldIfNeeded();
  }

  /// Enter the search query into the text field
  Future<void> _enterSearchQuery(String query) async {
    final textField = find.byType(TextField);
    if (textField.evaluate().isNotEmpty) {
      await $(textField.first).enterText(query);
      await $.pump(const Duration(milliseconds: 600)); // Wait for debounce
      logAction('Successfully entered search query: "$query"');
    } else {
      throw Exception('TextField not found in search field container');
    }
  }

  /// Wait for search processing to complete
  Future<void> _waitForSearchToProcess() async {
    await waitForLoadingToComplete();
    await $.pump(const Duration(milliseconds: 300)); // Additional stabilization
  }

  /// Clear search field using the clear button or fallback method
  Future<void> clearSearchField() async {
    logAction('Clearing search field');

    if (await _tryClearWithButton()) {
      await $.pump(const Duration(milliseconds: 300));
      logAction('Search field cleared using clear button');
    } else {
      await _clearWithFallbackMethod();
      logAction('Search field cleared using fallback method');
    }
  }

  /// Attempt to clear using the cancel button
  Future<bool> _tryClearWithButton() async {
    final clearButton = find.byIcon(Icons.cancel_outlined);
    if (clearButton.evaluate().isNotEmpty) {
      await $(clearButton.first).tap();
      return true;
    }
    return false;
  }

  /// Fallback method to clear by entering empty text
  Future<void> _clearWithFallbackMethod() async {
    final textField = find.byType(TextField);
    if (textField.evaluate().isNotEmpty) {
      await $(textField.first).enterText('');
      await $.pump(const Duration(milliseconds: 300));
    }
  }

  /// Clear search field only if it contains text
  Future<void> _clearSearchFieldIfNeeded() async {
    // This is a simplified approach - in a real scenario, you might want to
    // check if the field actually contains text before clearing
    await _tryClearWithButton();
  }

  // =============================================================================
  // SEARCH RESULTS HANDLING
  // =============================================================================

  /// Wait for search results to load with comprehensive error handling
  Future<void> waitForSearchResults() async {
    logAction('Waiting for search results with error handling');

    await SearchErrorHandler.handleSearchResult($, () async {
      await _performSearchResultsWait();
    });
  }

  /// Core logic for waiting for search results
  Future<void> _performSearchResultsWait() async {
    // Initial pump to allow state changes
    await $.pump(const Duration(milliseconds: 500));

    // Wait for loading indicator to disappear if present
    if (isElementVisible(AppLocators.hotelsLoadingIndicator)) {
      await waitForElementToDisappear(AppLocators.hotelsLoadingIndicator);
    }

    await waitForLoadingToComplete();
    logAction('Search results wait completed');
  }

  /// Check if search has returned actual results
  bool hasSearchResults() {
    final hotelCards = find.byType(Card);
    final hasResults = hotelCards.evaluate().isNotEmpty;
    logAction(
        'Search results check: $hasResults (${hotelCards.evaluate().length} cards found)');
    return hasResults;
  }

  /// Count the number of hotel cards currently displayed
  int countHotelCards() {
    final hotelCards = find.byType(Card);
    final count = hotelCards.evaluate().length;
    logAction('Current hotel cards count: $count');
    return count;
  }

  /// Get quality metrics for search results
  SearchResultsQuality verifySearchResultsQuality() {
    logAction('Analyzing search results quality');

    final cardCount = countHotelCards();
    if (cardCount == 0) {
      return SearchResultsQuality.empty();
    }

    int cardsWithFavoriteButtons = 0;
    int cardsWithText = 0;
    List<String> hotelIds = [];

    for (int i = 0; i < cardCount; i++) {
      try {
        final cardWidget = find.byType(Card).at(i);

        // Check for favorite button
        if (_cardHasFavoriteButton(cardWidget)) {
          cardsWithFavoriteButtons++;
        }

        // Check for text content
        if (_cardHasTextContent(cardWidget)) {
          cardsWithText++;
        }

        // Extract hotel ID if possible
        final hotelId = _extractHotelIdFromCard(i);
        if (hotelId.isNotEmpty) {
          hotelIds.add(hotelId);
        }
      } catch (e) {
        logAction('Error analyzing card $i: $e');
      }
    }

    final quality = SearchResultsQuality(
      totalCards: cardCount,
      cardsWithFavoriteButtons: cardsWithFavoriteButtons,
      cardsWithTextContent: cardsWithText,
      hotelIds: hotelIds,
    );

    logAction('Search results quality: ${quality.toString()}');
    return quality;
  }

  /// Check if a card has favorite button
  bool _cardHasFavoriteButton(Finder cardWidget) {
    final favoriteButton = find.descendant(
      of: cardWidget,
      matching: find.byIcon(Icons.favorite_outline),
    );
    final filledFavoriteButton = find.descendant(
      of: cardWidget,
      matching: find.byIcon(Icons.favorite),
    );

    return favoriteButton.evaluate().isNotEmpty ||
        filledFavoriteButton.evaluate().isNotEmpty;
  }

  /// Check if a card has text content
  bool _cardHasTextContent(Finder cardWidget) {
    final textWidgets = find.descendant(
      of: cardWidget,
      matching: find.byType(Text),
    );
    return textWidgets.evaluate().isNotEmpty;
  }

  /// Extract hotel ID from card at specific index
  String _extractHotelIdFromCard(int cardIndex) {
    try {
      final cardElement = find.byType(Card).at(cardIndex).evaluate().first;
      final cardWidget = cardElement.widget;
      return _extractHotelIdFromWidget(cardWidget);
    } catch (e) {
      logAction('Could not extract ID for card at index $cardIndex: $e');
      return '';
    }
  }

  /// Extract hotel ID from widget key
  String _extractHotelIdFromWidget(Widget cardWidget) {
    final key = cardWidget.key;
    if (key is Key) {
      final keyString = key.toString();
      // Extract coordinates from key format: [<'hotel_card_48.8566,2.3522'>]
      final match = RegExp(r'hotel_card_([0-9\.\-,]+)').firstMatch(keyString);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }
    return '';
  }

  // =============================================================================
  // STATE VERIFICATION METHODS
  // =============================================================================

  /// Verify empty state is displayed (when no search query entered)
  void verifyEmptyState() {
    logAction('Verifying empty state display');
    verifyElementExists(AppLocators.hotelsEmptyStateIcon);
    verifyElementNotExists(AppLocators.hotelsList);
  }

  /// Verify error state is displayed with retry option
  void verifyErrorState() {
    logAction('Verifying error state display');
    verifyElementExists(AppLocators.hotelsErrorMessage);
    verifyElementExists(AppLocators.hotelsRetryButton);
  }

  /// Check if search is currently in loading state
  bool isSearchLoading() {
    final loadingIndicator =
        find.byKey(Key(AppLocators.hotelsLoadingIndicator));
    final paginationLoading =
        find.byKey(Key(AppLocators.hotelsPaginationLoading));

    final isLoading = loadingIndicator.evaluate().isNotEmpty ||
        paginationLoading.evaluate().isNotEmpty;
    logAction('Search loading state: $isLoading');
    return isLoading;
  }

  /// Check if search resulted in error
  bool hasSearchError() {
    final errorMessage = find.byKey(Key(AppLocators.hotelsErrorMessage));
    final retryButton = find.byKey(Key(AppLocators.hotelsRetryButton));

    final hasError =
        errorMessage.evaluate().isNotEmpty || retryButton.evaluate().isNotEmpty;
    logAction('Search error state: $hasError');
    return hasError;
  }

  /// Check if search shows empty state
  bool hasEmptySearchState() {
    final emptyStateIcon = find.byKey(Key(AppLocators.hotelsEmptyStateIcon));
    final isEmpty = emptyStateIcon.evaluate().isNotEmpty;
    logAction('Empty search state: $isEmpty');
    return isEmpty;
  }

  // =============================================================================
  // ERROR HANDLING AND RETRY OPERATIONS
  // =============================================================================

  /// Retry a failed search operation
  Future<void> retrySearch() async {
    logAction('Retrying failed search operation');
    await tapElement(AppLocators.hotelsRetryButton);
    await waitForLoadingToComplete();
    await takePageScreenshot('search_retried');
  }

  /// Retry failed pagination operation
  Future<void> retryPagination() async {
    logAction('Retrying failed pagination operation');
    await tapElement(AppLocators.hotelsPaginationRetryButton);
    await waitForLoadingToComplete();
    await takePageScreenshot('pagination_retried');
  }

  // =============================================================================
  // FAVORITES OPERATIONS
  // =============================================================================

  /// Toggle favorite status for a specific hotel by ID
  Future<void> toggleHotelFavorite(String hotelId) async {
    logAction('Toggling favorite status for hotel: $hotelId');

    final hotelCardKey = AppLocators.hotelCard(hotelId);
    await _ensureHotelCardIsVisible(hotelCardKey);

    final favoriteButton = await _findFavoriteButtonInCard(hotelCardKey);
    await $(favoriteButton).tap();

    await $.pump(const Duration(milliseconds: 500));
    await takePageScreenshot('hotel_favorite_toggled_$hotelId');

    logAction('Successfully toggled favorite for hotel: $hotelId');
  }

  /// Ensure hotel card is visible, scroll if necessary
  Future<void> _ensureHotelCardIsVisible(String hotelCardKey) async {
    if (!isElementVisible(hotelCardKey)) {
      await scrollToElement(
        AppLocators.hotelsScrollView,
        hotelCardKey,
        maxScrolls: 5,
      );
    }
  }

  /// Find the favorite button within a hotel card
  Future<Finder> _findFavoriteButtonInCard(String hotelCardKey) async {
    final hotelCard = find.byKey(Key(hotelCardKey));

    if (hotelCard.evaluate().isEmpty) {
      throw Exception('Hotel card not found: $hotelCardKey');
    }

    // Try to find outline favorite button first (not favorited)
    var favoriteButton = find.descendant(
      of: hotelCard,
      matching: find.byIcon(Icons.favorite_outline),
    );

    // If not found, try filled favorite button (already favorited)
    if (favoriteButton.evaluate().isEmpty) {
      favoriteButton = find.descendant(
        of: hotelCard,
        matching: find.byIcon(Icons.favorite),
      );
    }

    if (favoriteButton.evaluate().isEmpty) {
      throw Exception('No favorite button found in hotel card: $hotelCardKey');
    }

    return favoriteButton.first;
  }

  /// Add multiple hotels to favorites for testing purposes
  Future<List<String>> addMultipleHotelsToFavorites(
      {int maxFavorites = 3}) async {
    logAction('Adding multiple hotels to favorites (max: $maxFavorites)');

    final results = await verifySearchResultsQuality();
    final availableHotelIds = results.hotelIds;
    final favoritesToAdd = availableHotelIds.length >= maxFavorites
        ? maxFavorites
        : availableHotelIds.length;

    List<String> successfullyAdded = [];

    for (int i = 0; i < favoritesToAdd && i < availableHotelIds.length; i++) {
      try {
        final hotelId = availableHotelIds[i];
        await toggleHotelFavorite(hotelId);
        successfullyAdded.add(hotelId);
        logAction(
            '✅ Added hotel $hotelId to favorites (${successfullyAdded.length}/$favoritesToAdd)');
      } catch (e) {
        logAction('⚠️ Failed to add hotel to favorites: $e');
      }
    }

    logAction(
        'Successfully added ${successfullyAdded.length} hotels to favorites');
    return successfullyAdded;
  }

  // =============================================================================
  // PAGINATION OPERATIONS
  // =============================================================================

  /// Scroll to load more hotels (trigger pagination)
  Future<void> scrollToLoadMore() async {
    logAction('Scrolling to trigger pagination');

    final scrollView = find.byKey(Key(AppLocators.hotelsScrollView));
    if (scrollView.evaluate().isNotEmpty) {
      await $(scrollView.first).scrollTo(maxScrolls: 3);
      await waitForLoadingToComplete();
      logAction('Pagination scroll completed');
    } else {
      throw Exception('Hotels scroll view not found');
    }
  }

  /// Test pagination functionality by scrolling and verifying results
  Future<PaginationTestResult> testPagination() async {
    logAction('Testing pagination functionality');

    final initialCount = countHotelCards();
    logAction('Initial hotel count before pagination: $initialCount');

    await scrollToLoadMore();

    // Wait for pagination loading to appear and disappear
    if (isElementVisible(AppLocators.hotelsPaginationLoading)) {
      logAction('Pagination loading indicator appeared');
      await waitForElementToDisappear(AppLocators.hotelsPaginationLoading);
    }

    await $.pump(const Duration(seconds: 2)); // Allow results to load

    final finalCount = countHotelCards();
    logAction('Final hotel count after pagination: $finalCount');

    final result = PaginationTestResult(
      initialCount: initialCount,
      finalCount: finalCount,
      newItemsLoaded: finalCount - initialCount,
      wasSuccessful: finalCount > initialCount,
    );

    if (result.wasSuccessful) {
      logAction(
          '✅ Pagination loaded ${result.newItemsLoaded} additional results');
    } else {
      logAction('ℹ️ No additional results loaded (might be end of list)');
    }

    return result;
  }

  /// Verify pagination loading indicator is displayed
  void verifyPaginationLoading() {
    logAction('Verifying pagination loading indicator');
    verifyElementExists(AppLocators.hotelsPaginationLoading);
  }

  /// Verify pagination error state is displayed
  void verifyPaginationError() {
    logAction('Verifying pagination error state');
    verifyElementExists(AppLocators.hotelsPaginationErrorMessage);
    verifyElementExists(AppLocators.hotelsPaginationRetryButton);
  }

  // =============================================================================
  // COMPREHENSIVE TEST METHODS
  // =============================================================================

  /// Perform comprehensive search test for a given query
  Future<SearchTestResult> performComprehensiveSearchTest(String query) async {
    logAction('Performing comprehensive search test for: "$query"');

    final startTime = DateTime.now();

    try {
      await searchHotels(query);
      await waitForSearchResults();

      final quality = verifySearchResultsQuality();
      final endTime = DateTime.now();

      final result = SearchTestResult(
        query: query,
        wasSuccessful: true,
        resultsCount: quality.totalCards,
        duration: endTime.difference(startTime),
        quality: quality,
      );

      // Test pagination if results exist
      if (result.resultsCount > 0) {
        result.paginationResult = await testPagination();
      }

      logAction('✅ Comprehensive search test completed for: "$query"');
      return result;
    } catch (e) {
      final endTime = DateTime.now();
      logAction('❌ Search test failed for "$query": $e');

      return SearchTestResult(
        query: query,
        wasSuccessful: false,
        resultsCount: 0,
        duration: endTime.difference(startTime),
        error: e.toString(),
      );
    }
  }

  /// Test search functionality with multiple queries
  Future<List<SearchTestResult>> testMultipleSearches(
      List<String> queries) async {
    logAction('Testing multiple search queries: ${queries.join(", ")}');

    List<SearchTestResult> results = [];

    for (final query in queries) {
      final result = await performComprehensiveSearchTest(query);
      results.add(result);

      // Clear search between queries
      await clearSearchField();
      await $.pump(const Duration(seconds: 1));
    }

    _logMultipleSearchResults(results);
    return results;
  }

  /// Log summary of multiple search results
  void _logMultipleSearchResults(List<SearchTestResult> results) {
    final successful = results.where((r) => r.wasSuccessful).length;
    final failed = results.length - successful;
    final totalResults = results.fold<int>(0, (sum, r) => sum + r.resultsCount);

    logAction('Multiple search test summary:');
    logAction('  - Total queries: ${results.length}');
    logAction('  - Successful: $successful');
    logAction('  - Failed: $failed');
    logAction('  - Total results found: $totalResults');
  }

  /// Verify hotels list is scrollable and functional
  Future<void> verifyHotelsListScrollable() async {
    logAction('Verifying hotels list scrollability');

    final scrollView = find.byKey(Key(AppLocators.hotelsScrollView));
    if (scrollView.evaluate().isNotEmpty) {
      try {
        await $(scrollView.first).scrollTo();
        await $.pumpAndSettle();
        logAction('✅ Hotels list is scrollable and functional');
      } catch (e) {
        logAction('❌ Error testing scroll functionality: $e');
        throw Exception('Hotels list scroll test failed: $e');
      }
    } else {
      throw Exception('Hotels scroll view not found');
    }
  }
}

// =============================================================================
// SUPPORTING DATA CLASSES
// =============================================================================

/// Represents the quality metrics of search results
class SearchResultsQuality {
  final int totalCards;
  final int cardsWithFavoriteButtons;
  final int cardsWithTextContent;
  final List<String> hotelIds;

  SearchResultsQuality({
    required this.totalCards,
    required this.cardsWithFavoriteButtons,
    required this.cardsWithTextContent,
    required this.hotelIds,
  });

  SearchResultsQuality.empty()
      : totalCards = 0,
        cardsWithFavoriteButtons = 0,
        cardsWithTextContent = 0,
        hotelIds = [];

  bool get hasGoodQuality =>
      totalCards > 0 &&
      cardsWithFavoriteButtons == totalCards &&
      cardsWithTextContent == totalCards;

  @override
  String toString() {
    return 'SearchResultsQuality(total: $totalCards, withFavorites: $cardsWithFavoriteButtons, withText: $cardsWithTextContent, hasGoodQuality: $hasGoodQuality)';
  }
}

/// Represents the result of a pagination test
class PaginationTestResult {
  final int initialCount;
  final int finalCount;
  final int newItemsLoaded;
  final bool wasSuccessful;

  PaginationTestResult({
    required this.initialCount,
    required this.finalCount,
    required this.newItemsLoaded,
    required this.wasSuccessful,
  });

  @override
  String toString() {
    return 'PaginationTestResult(initial: $initialCount, final: $finalCount, new: $newItemsLoaded, successful: $wasSuccessful)';
  }
}

/// Represents the result of a comprehensive search test
class SearchTestResult {
  final String query;
  final bool wasSuccessful;
  final int resultsCount;
  final Duration duration;
  final SearchResultsQuality? quality;
  final String? error;
  PaginationTestResult? paginationResult;

  SearchTestResult({
    required this.query,
    required this.wasSuccessful,
    required this.resultsCount,
    required this.duration,
    this.quality,
    this.error,
    this.paginationResult,
  });

  @override
  String toString() {
    return 'SearchTestResult(query: "$query", successful: $wasSuccessful, results: $resultsCount, duration: ${duration.inMilliseconds}ms)';
  }
}
