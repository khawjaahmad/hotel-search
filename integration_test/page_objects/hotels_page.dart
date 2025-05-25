import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/hotel_locators.dart';
import '../helpers/search_error_handler.dart';
import '../helpers/enhanced_search_handler.dart';

/// Hotels Page Object Model - Enhanced Integration Testing Focus
/// Handles comprehensive hotel search, listing, favorites, and pagination operations
/// Utilizes new HotelsLocators and enhanced base functionality
/// Optimized for critical integration test scenarios
class HotelsPage extends BasePage {
  HotelsPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'hotels';

  @override
  String get pageKey => HotelsLocators.scaffold;

  // =============================================================================
  // ENHANCED PAGE VERIFICATION METHODS
  // =============================================================================

  /// Comprehensive hotels page verification with new locator system
  Future<void> verifyHotelsPageLoaded() async {
    logAction('Verifying hotels page with comprehensive checks');

    await verifyPageIsLoaded();
    await _verifyEssentialPageElements();
    await _verifySearchFunctionality();

    logSuccess('Hotels page fully loaded and verified');
  }

  /// Verify all critical page elements using HotelsLocators
  Future<void> _verifyEssentialPageElements() async {
    logAction('Verifying essential hotels page elements');

    try {
      // Validate page structure using HotelsLocators
      HotelsLocators.validatePageStructure();

      // Verify search elements
      HotelsLocators.validateSearchElements();

      logSuccess('All essential page elements verified');
    } catch (e) {
      logError('Essential page elements verification failed', e);
      await takeErrorScreenshot('essential_elements_failed');
      rethrow;
    }
  }

  /// Verify search functionality is ready
  Future<void> _verifySearchFunctionality() async {
    logAction('Verifying search functionality readiness');

    try {
      // Use smart finder from HotelsLocators
      final searchField = HotelsLocators.searchFieldFinder;
      expect(searchField, findsOneWidget,
          reason: 'Search field should be accessible');

      // Verify search icons and components
      expect(find.byIcon(Icons.search), findsOneWidget,
          reason: 'Search icon should be visible');
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget,
          reason: 'Clear button should be accessible');

      logSuccess('Search functionality verified');
    } catch (e) {
      logError('Search functionality verification failed', e);
      rethrow;
    }
  }

  /// Quick verification for search field visibility
  void verifySearchFieldVisible() {
    logAction('Quick verification of search field visibility');

    try {
      final searchField = HotelsLocators.searchFieldFinder;
      expect(searchField, findsOneWidget,
          reason: 'Search field should be visible');
      logSuccess('Search field is visible and accessible');
    } catch (e) {
      logError('Search field visibility check failed', e);
      rethrow;
    }
  }

  // =============================================================================
  // ENHANCED SEARCH OPERATIONS
  // =============================================================================

  /// Professional search operation with comprehensive error handling
  Future<void> searchHotels(String query) async {
    logAction('Executing hotel search with query: "$query"');

    try {
      await _prepareSearchEnvironment();
      await _executeSearchQuery(query);
      await _waitForSearchCompletion();

      await takePageScreenshot('search_executed_${query.replaceAll(' ', '_')}');
      logSuccess('Hotel search completed for: "$query"');
    } catch (e) {
      logError('Hotel search failed for query: "$query"', e);
      await takeErrorScreenshot('search_failed_${query.replaceAll(' ', '_')}');
      rethrow;
    }
  }

  /// Prepare search environment for optimal execution
  Future<void> _prepareSearchEnvironment() async {
    logAction('Preparing search environment');

    // Ensure search field is ready
    await waitForElement(HotelsLocators.searchField,
        description: 'Search field container');

    // Clear any existing search if needed
    await _clearSearchIfNeeded();

    // Wait for page stability
    await waitForPageStabilization();
  }

  /// Execute the actual search query
  Future<void> _executeSearchQuery(String query) async {
    logAction('Executing search query: "$query"');

    try {
      // Use TextField directly for reliable text entry
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        await $(textField.first).enterText(query);
        await $
            .pump(const Duration(milliseconds: 800)); // Extended debounce wait
        logSuccess('Search query entered successfully');
      } else {
        throw Exception('TextField not accessible for search query entry');
      }
    } catch (e) {
      logError('Failed to execute search query', e);
      rethrow;
    }
  }

  /// Wait for search completion with intelligent state detection
  Future<void> _waitForSearchCompletion() async {
    logAction('Waiting for search completion');

    await waitForLoadingToComplete();
    await $.pump(const Duration(milliseconds: 500)); // Additional stabilization

    logSuccess('Search completion wait finished');
  }

  /// Enhanced search with comprehensive result handling
  Future<SearchExecutionResult> performSearchTest(String query) async {
    logAction('Performing comprehensive search test for: "$query"');

    final startTime = DateTime.now();

    try {
      // Execute search
      await searchHotels(query);

      // Wait for results with enhanced handler
      final searchState =
          await EnhancedSearchHandler.handleSearchWithTimeout($, query);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Analyze results
      final result = SearchExecutionResult(
        query: query,
        state: searchState,
        duration: duration,
        resultCount: _getCurrentResultCount(),
        wasSuccessful: searchState.isTerminal,
      );

      // Validate results if found
      if (searchState == SearchResultState.hasResults) {
        await EnhancedSearchHandler.validateSearchResults($);
        result.quality = await _analyzeSearchQuality();
      }

      logSuccess('Search test completed: ${result.toString()}');
      return result;
    } catch (e) {
      final endTime = DateTime.now();
      logError('Search test failed for: "$query"', e);

      return SearchExecutionResult(
        query: query,
        state: SearchResultState.error,
        duration: endTime.difference(startTime),
        resultCount: 0,
        wasSuccessful: false,
        error: e.toString(),
      );
    }
  }

  /// Clear search field with multiple strategies
  Future<void> clearSearchField() async {
    logAction('Clearing search field');

    try {
      // Strategy 1: Use clear button
      if (await _tryClearWithButton()) {
        logSuccess('Search cleared using clear button');
        return;
      }

      // Strategy 2: Clear via text entry
      await _clearWithTextEntry();
      logSuccess('Search cleared using text entry');
    } catch (e) {
      logError('Failed to clear search field', e);
      rethrow;
    }
  }

  /// Clear search if content is present
  Future<void> _clearSearchIfNeeded() async {
    // Always attempt to clear for clean state
    await _tryClearWithButton();
    await $.pump(const Duration(milliseconds: 300));
  }

  /// Attempt clear using cancel button
  Future<bool> _tryClearWithButton() async {
    final clearButton = find.byIcon(Icons.cancel_outlined);
    if (clearButton.evaluate().isNotEmpty) {
      await $(clearButton.first).tap();
      await $.pump(const Duration(milliseconds: 300));
      return true;
    }
    return false;
  }

  /// Clear via text entry method
  Future<void> _clearWithTextEntry() async {
    final textField = find.byType(TextField);
    if (textField.evaluate().isNotEmpty) {
      await $(textField.first).enterText('');
      await $.pump(const Duration(milliseconds: 300));
    }
  }

  // =============================================================================
  // SEARCH RESULTS ANALYSIS WITH ENHANCED HANDLERS
  // =============================================================================

  /// Get current result count using HotelsLocators
  int _getCurrentResultCount() {
    return HotelsLocators.getHotelCardCount();
  }

  /// Check if search has results
  bool hasSearchResults() {
    final hasResults = HotelsLocators.hasResults;
    logAction(
        'Search results check: $hasResults (${_getCurrentResultCount()} cards)');
    return hasResults;
  }

  /// Wait for search results with enhanced error handling
  Future<void> waitForSearchResults() async {
    logAction('Waiting for search results with enhanced error handling');

    await SearchErrorHandler.handleSearchResult($, () async {
      await _performSearchResultsWait();
    });
  }

  /// Core logic for waiting for search results
  Future<void> _performSearchResultsWait() async {
    // Initial pump to allow state changes
    await $.pump(const Duration(milliseconds: 500));

    // Wait for loading indicator to disappear if present
    if (isElementVisible(HotelsLocators.loadingIndicator)) {
      await waitForElementToDisappear(HotelsLocators.loadingIndicator);
    }

    await waitForLoadingToComplete();
    logAction('Search results wait completed');
  }

  /// Comprehensive search quality analysis
  Future<SearchQualityMetrics> _analyzeSearchQuality() async {
    logAction('Analyzing search result quality');

    try {
      final cardCount = _getCurrentResultCount();

      if (cardCount == 0) {
        return SearchQualityMetrics.empty();
      }

      int cardsWithFavorites = 0;
      int cardsWithText = 0;
      List<String> extractedIds = [];

      // Analyze each card
      for (int i = 0; i < cardCount; i++) {
        try {
          final cardWidget = find.byType(Card).at(i);

          // Check for favorite button
          if (_cardHasFavoriteButton(cardWidget)) {
            cardsWithFavorites++;
          }

          // Check for text content
          if (_cardHasTextContent(cardWidget)) {
            cardsWithText++;
          }

          // Extract ID if possible
          final cardId = _extractCardIdentifier(i);
          if (cardId.isNotEmpty) {
            extractedIds.add(cardId);
          }
        } catch (e) {
          logWarning('Error analyzing card $i: $e');
        }
      }

      final metrics = SearchQualityMetrics(
        totalCards: cardCount,
        cardsWithFavorites: cardsWithFavorites,
        cardsWithText: cardsWithText,
        extractedIds: extractedIds,
      );

      logSuccess('Search quality analysis: ${metrics.toString()}');
      return metrics;
    } catch (e) {
      logError('Search quality analysis failed', e);
      return SearchQualityMetrics.empty();
    }
  }

  /// Check if card has favorite button functionality
  bool _cardHasFavoriteButton(Finder cardWidget) {
    final outlineButton = find.descendant(
        of: cardWidget, matching: find.byIcon(Icons.favorite_outline));
    final filledButton =
        find.descendant(of: cardWidget, matching: find.byIcon(Icons.favorite));

    return outlineButton.evaluate().isNotEmpty ||
        filledButton.evaluate().isNotEmpty;
  }

  /// Check if card has text content
  bool _cardHasTextContent(Finder cardWidget) {
    final textWidgets =
        find.descendant(of: cardWidget, matching: find.byType(Text));
    return textWidgets.evaluate().isNotEmpty;
  }

  /// Extract card identifier for tracking
  String _extractCardIdentifier(int cardIndex) {
    try {
      final cardElement = find.byType(Card).at(cardIndex).evaluate().first;
      final cardWidget = cardElement.widget;

      final key = cardWidget.key;
      if (key is Key) {
        final keyString = key.toString();
        final match = RegExp(r'hotel_card_([0-9\.\-,]+)').firstMatch(keyString);
        return match?.group(1) ?? '';
      }

      return '';
    } catch (e) {
      logWarning('Could not extract identifier for card $cardIndex: $e');
      return '';
    }
  }

  // =============================================================================
  // STATE VERIFICATION WITH ENHANCED LOCATORS
  // =============================================================================

  /// Verify empty state using HotelsLocators
  void verifyEmptyState() {
    logAction('Verifying empty state display');

    try {
      expect(HotelsLocators.isEmpty, isTrue,
          reason: 'Page should show empty state');
      verifyElementExists(HotelsLocators.emptyStateIcon,
          description: 'Empty state icon');
      logSuccess('Empty state verified');
    } catch (e) {
      logError('Empty state verification failed', e);
      rethrow;
    }
  }

  /// Verify error state using HotelsLocators
  void verifyErrorState() {
    logAction('Verifying error state display');

    try {
      expect(HotelsLocators.hasError, isTrue,
          reason: 'Page should show error state');
      verifyElementExists(HotelsLocators.errorMessage,
          description: 'Error message');
      verifyElementExists(HotelsLocators.retryButton,
          description: 'Retry button');
      logSuccess('Error state verified');
    } catch (e) {
      logError('Error state verification failed', e);
      rethrow;
    }
  }

  /// Check current page state using HotelsLocators
  HotelsPageState getCurrentPageState() {
    final state = HotelsLocators.currentState;
    logAction('Current page state: ${state.description}');
    return state;
  }

  /// Comprehensive state validation
  Future<void> validateCurrentState({String? expectedState}) async {
    logAction('Validating current page state');

    final currentState = getCurrentPageState();

    if (expectedState != null) {
      expect(currentState.name, equals(expectedState),
          reason: 'Page should be in $expectedState state');
    }

    // State-specific validations
    switch (currentState) {
      case HotelsPageState.hasResults:
        HotelsLocators.validateHotelCards();
        break;
      case HotelsPageState.empty:
        verifyEmptyState();
        break;
      case HotelsPageState.error:
        verifyErrorState();
        break;
      case HotelsPageState.loading:
        expect(HotelsLocators.isLoading, isTrue,
            reason: 'Loading indicator should be visible');
        break;
      default:
        logWarning('Unknown state: ${currentState.description}');
    }

    await takePageScreenshot('state_validated_${currentState.name}');
    logSuccess('State validation completed: ${currentState.description}');
  }

  // =============================================================================
  // FAVORITES OPERATIONS WITH ENHANCED TRACKING
  // =============================================================================

  /// Toggle favorite status for hotel with comprehensive error handling
  Future<void> toggleHotelFavorite(String hotelId) async {
    logAction('Toggling favorite for hotel: $hotelId');

    try {
      // Ensure hotel card is visible
      await _ensureHotelCardVisibility(hotelId);

      // Find and interact with favorite button
      final favoriteButton = await _locateFavoriteButton(hotelId);
      await $(favoriteButton).tap();

      // Wait for state change
      await $.pump(const Duration(milliseconds: 600));

      await takePageScreenshot('favorite_toggled_$hotelId');
      logSuccess('Successfully toggled favorite for hotel: $hotelId');
    } catch (e) {
      logError('Failed to toggle favorite for hotel: $hotelId', e);
      await takeErrorScreenshot('favorite_toggle_failed_$hotelId');
      rethrow;
    }
  }

  /// Ensure hotel card is visible on screen
  Future<void> _ensureHotelCardVisibility(String hotelId) async {
    final hotelCardKey = HotelsLocators.hotelCard(hotelId);

    if (!HotelsLocators.hotelCardExists(hotelId)) {
      // Try scrolling to find the card
      await scrollToElement(
        HotelsLocators.scrollView,
        hotelCardKey,
        maxScrolls: 8,
        description: 'Hotel card: $hotelId',
      );
    }
  }

  /// Locate favorite button within hotel card
  Future<Finder> _locateFavoriteButton(String hotelId) async {
    final hotelCardFinder = HotelsLocators.hotelCardFinder(hotelId);

    if (hotelCardFinder.evaluate().isEmpty) {
      throw Exception('Hotel card not found: $hotelId');
    }

    // Try outline button first (not favorited)
    var favoriteButton = find.descendant(
      of: hotelCardFinder,
      matching: find.byIcon(Icons.favorite_outline),
    );

    // Try filled button (already favorited)
    if (favoriteButton.evaluate().isEmpty) {
      favoriteButton = find.descendant(
        of: hotelCardFinder,
        matching: find.byIcon(Icons.favorite),
      );
    }

    if (favoriteButton.evaluate().isEmpty) {
      throw Exception('Favorite button not found in hotel card: $hotelId');
    }

    return favoriteButton.first;
  }

  /// Add multiple hotels to favorites for bulk testing
  Future<List<String>> addMultipleHotelsToFavorites(
      {int maxFavorites = 3}) async {
    logAction('Adding multiple hotels to favorites (max: $maxFavorites)');

    try {
      final currentResults = await _analyzeSearchQuality();
      final availableIds = currentResults.extractedIds;
      final targetCount = availableIds.length >= maxFavorites
          ? maxFavorites
          : availableIds.length;

      List<String> successfullyAdded = [];

      for (int i = 0; i < targetCount && i < availableIds.length; i++) {
        try {
          final hotelId = availableIds[i];
          await toggleHotelFavorite(hotelId);
          successfullyAdded.add(hotelId);
          logSuccess(
              'Added hotel $hotelId to favorites (${successfullyAdded.length}/$targetCount)');
        } catch (e) {
          logWarning('Failed to add hotel to favorites: $e');
        }
      }

      logSuccess(
          'Successfully added ${successfullyAdded.length} hotels to favorites');
      return successfullyAdded;
    } catch (e) {
      logError('Bulk favorite addition failed', e);
      return [];
    }
  }

  // =============================================================================
  // PAGINATION WITH ENHANCED ERROR HANDLING
  // =============================================================================

  /// Test pagination functionality with comprehensive validation
  Future<PaginationTestResult> testPagination() async {
    logAction('Testing pagination functionality');

    try {
      final initialCount = _getCurrentResultCount();
      logAction('Initial card count: $initialCount');

      // Trigger pagination scroll
      await _executePaginationScroll();

      // Wait for pagination processing
      await _waitForPaginationCompletion();

      final finalCount = _getCurrentResultCount();
      logAction('Final card count: $finalCount');

      final result = PaginationTestResult(
        initialCount: initialCount,
        finalCount: finalCount,
        newItemsLoaded: finalCount - initialCount,
        wasSuccessful: finalCount > initialCount,
      );

      await takePageScreenshot('pagination_tested');

      if (result.wasSuccessful) {
        logSuccess(
            'Pagination loaded ${result.newItemsLoaded} additional items');
      } else {
        logAction('No additional items loaded (may be end of results)');
      }

      return result;
    } catch (e) {
      logError('Pagination test failed', e);
      return PaginationTestResult(
        initialCount: 0,
        finalCount: 0,
        newItemsLoaded: 0,
        wasSuccessful: false,
      );
    }
  }

  /// Execute pagination scroll
  Future<void> _executePaginationScroll() async {
    logAction('Executing pagination scroll');

    final scrollView = find.byKey(Key(HotelsLocators.scrollView));
    if (scrollView.evaluate().isNotEmpty) {
      await $(scrollView.first).scrollTo(maxScrolls: 5);
      logSuccess('Pagination scroll executed');
    } else {
      throw Exception('Scroll view not found for pagination');
    }
  }

  /// Wait for pagination to complete
  Future<void> _waitForPaginationCompletion() async {
    logAction('Waiting for pagination completion');

    // Check if pagination loading appears
    if (isElementVisible(HotelsLocators.paginationLoading)) {
      logAction('Pagination loading detected');
      await waitForElementToDisappear(HotelsLocators.paginationLoading,
          timeout: const Duration(seconds: 15));
    }

    await $.pump(const Duration(seconds: 2)); // Allow results to render
    logSuccess('Pagination completion wait finished');
  }

  // =============================================================================
  // ERROR HANDLING AND RECOVERY
  // =============================================================================

  /// Retry failed search operation
  Future<void> retrySearch() async {
    logAction('Retrying failed search operation');

    try {
      await tapElement(HotelsLocators.retryButton,
          description: 'Search retry button');
      await waitForLoadingToComplete();
      await takePageScreenshot('search_retried');
      logSuccess('Search retry executed');
    } catch (e) {
      logError('Search retry failed', e);
      rethrow;
    }
  }

  /// Retry failed pagination
  Future<void> retryPagination() async {
    logAction('Retrying failed pagination operation');

    try {
      await tapElement(HotelsLocators.paginationRetryButton,
          description: 'Pagination retry button');
      await waitForLoadingToComplete();
      await takePageScreenshot('pagination_retried');
      logSuccess('Pagination retry executed');
    } catch (e) {
      logError('Pagination retry failed', e);
      rethrow;
    }
  }

  // =============================================================================
  // COMPREHENSIVE TEST WORKFLOWS
  // =============================================================================

  /// Execute comprehensive search workflow
  Future<SearchWorkflowResult> executeSearchWorkflow(
      List<String> queries) async {
    logAction(
        'Executing comprehensive search workflow with ${queries.length} queries');

    final results = <SearchExecutionResult>[];

    try {
      for (final query in queries) {
        final result = await performSearchTest(query);
        results.add(result);

        // Clear between searches
        await clearSearchField();
        await $.pump(const Duration(seconds: 1));
      }

      final workflow = SearchWorkflowResult(
        totalQueries: queries.length,
        results: results,
        successfulQueries: results.where((r) => r.wasSuccessful).length,
        totalResultsFound: results.fold(0, (sum, r) => sum + r.resultCount),
      );

      logSuccess('Search workflow completed: ${workflow.toString()}');
      return workflow;
    } catch (e) {
      logError('Search workflow failed', e);
      return SearchWorkflowResult(
        totalQueries: queries.length,
        results: results,
        successfulQueries: 0,
        totalResultsFound: 0,
      );
    }
  }

  /// Verify hotels list is scrollable and functional
  Future<void> verifyHotelsListScrollable() async {
    logAction('Verifying hotels list scrollability');

    final scrollView = find.byKey(Key(HotelsLocators.scrollView));
    if (scrollView.evaluate().isNotEmpty) {
      try {
        await $(scrollView.first).scrollTo();
        await $.pumpAndSettle();
        logSuccess('Hotels list is scrollable and functional');
      } catch (e) {
        logError('Error testing scroll functionality: $e');
        throw Exception('Hotels list scroll test failed: $e');
      }
    } else {
      throw Exception('Hotels scroll view not found');
    }
  }

  /// Test multiple search scenarios for comprehensive validation
  Future<List<SearchExecutionResult>> testMultipleSearches(
      List<String> queries) async {
    logAction('Testing multiple search queries: ${queries.join(", ")}');

    List<SearchExecutionResult> results = [];

    for (final query in queries) {
      final result = await performSearchTest(query);
      results.add(result);

      // Clear search between queries
      await clearSearchField();
      await $.pump(const Duration(seconds: 1));
    }

    _logMultipleSearchResults(results);
    return results;
  }

  /// Log summary of multiple search results
  void _logMultipleSearchResults(List<SearchExecutionResult> results) {
    final successful = results.where((r) => r.wasSuccessful).length;
    final failed = results.length - successful;
    final totalResults = results.fold<int>(0, (sum, r) => sum + r.resultCount);

    logAction('Multiple search test summary:');
    logAction('  - Total queries: ${results.length}');
    logAction('  - Successful: $successful');
    logAction('  - Failed: $failed');
    logAction('  - Total results found: $totalResults');
  }
}

// =============================================================================
// SUPPORTING DATA CLASSES FOR ENHANCED TESTING
// =============================================================================

/// Enhanced search execution result
class SearchExecutionResult {
  final String query;
  final SearchResultState state;
  final Duration duration;
  final int resultCount;
  final bool wasSuccessful;
  final String? error;
  SearchQualityMetrics? quality;

  SearchExecutionResult({
    required this.query,
    required this.state,
    required this.duration,
    required this.resultCount,
    required this.wasSuccessful,
    this.error,
    this.quality,
  });

  @override
  String toString() {
    return 'SearchResult(query: "$query", state: ${state.name}, results: $resultCount, duration: ${duration.inMilliseconds}ms, success: $wasSuccessful)';
  }
}

/// Search quality metrics for detailed analysis
class SearchQualityMetrics {
  final int totalCards;
  final int cardsWithFavorites;
  final int cardsWithText;
  final List<String> extractedIds;

  SearchQualityMetrics({
    required this.totalCards,
    required this.cardsWithFavorites,
    required this.cardsWithText,
    required this.extractedIds,
  });

  SearchQualityMetrics.empty()
      : totalCards = 0,
        cardsWithFavorites = 0,
        cardsWithText = 0,
        extractedIds = [];

  bool get hasGoodQuality =>
      totalCards > 0 &&
      cardsWithFavorites == totalCards &&
      cardsWithText == totalCards;

  @override
  String toString() {
    return 'Quality(total: $totalCards, withFavorites: $cardsWithFavorites, withText: $cardsWithText, good: $hasGoodQuality)';
  }
}

/// Pagination test result
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
    return 'Pagination(initial: $initialCount, final: $finalCount, new: $newItemsLoaded, success: $wasSuccessful)';
  }
}

/// Search workflow result for comprehensive testing
class SearchWorkflowResult {
  final int totalQueries;
  final List<SearchExecutionResult> results;
  final int successfulQueries;
  final int totalResultsFound;

  SearchWorkflowResult({
    required this.totalQueries,
    required this.results,
    required this.successfulQueries,
    required this.totalResultsFound,
  });

  double get successRate =>
      totalQueries > 0 ? (successfulQueries / totalQueries) : 0.0;

  @override
  String toString() {
    return 'Workflow(queries: $totalQueries, successful: $successfulQueries, rate: ${(successRate * 100).toStringAsFixed(1)}%, results: $totalResultsFound)';
  }
}
