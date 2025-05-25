import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Enhanced search result handler with comprehensive validation logic
/// Addresses SerpAPI intermittent delays and provides clear test feedback
class EnhancedSearchHandler {
  EnhancedSearchHandler._();

  /// Maximum time to wait for search results or error states
  static const Duration maxSearchTimeout = Duration(seconds: 30);

  /// Interval for checking search state changes
  static const Duration checkInterval = Duration(milliseconds: 500);

  /// Handles search results with comprehensive timeout and error detection
  /// Returns SearchResultState indicating what was found
  static Future<SearchResultState> handleSearchWithTimeout(
    PatrolIntegrationTester $,
    String searchQuery, {
    Duration? customTimeout,
  }) async {
    final timeout = customTimeout ?? maxSearchTimeout;
    final startTime = DateTime.now();

    debugPrint(
        '🔍 Handling search for: "$searchQuery" (timeout: ${timeout.inSeconds}s)');

    while (DateTime.now().difference(startTime) < timeout) {
      await $.pump(checkInterval);

      final currentState = await _analyzeSearchState($);

      switch (currentState) {
        case SearchResultState.loading:
          debugPrint('⏳ Search loading...');
          continue;

        case SearchResultState.hasResults:
          final resultCount = find.byType(Card).evaluate().length;
          debugPrint('✅ Search completed: $resultCount hotels found');
          return SearchResultState.hasResults;

        case SearchResultState.empty:
          debugPrint('📭 Search returned empty results');
          return SearchResultState.empty;

        case SearchResultState.error:
          debugPrint('❌ Search error detected');
          return SearchResultState.error;

        case SearchResultState.timeout:
          // This case shouldn't occur in _analyzeSearchState but handled for completeness
          debugPrint('⏰ Timeout detected during analysis');
          continue;

        case SearchResultState.unknown:
          continue;
      }
    }

    // Timeout reached - check if loader is still showing
    final isStillLoading = _isLoadingIndicatorVisible($);
    if (isStillLoading) {
      final message =
          'Loader appeared but no results or error message shown after ${timeout.inSeconds}s for query: "$searchQuery"';
      debugPrint('💥 TIMEOUT FAILURE: $message');
      fail(message);
    }

    debugPrint('⏰ Search timeout reached without clear state');
    return SearchResultState.timeout;
  }

  /// Validates search results are properly rendered
  static Future<void> validateSearchResults(PatrolIntegrationTester $) async {
    debugPrint('🔍 Validating search results rendering');

    final hotelCards = find.byType(Card);
    final cardCount = hotelCards.evaluate().length;

    expect(cardCount, greaterThan(0),
        reason: 'Search should return at least one result');

    // Verify each card has required elements
    for (int i = 0; i < cardCount && i < 3; i++) {
      final cardWidget = hotelCards.at(i);

      // Check for hotel name text
      final nameText =
          find.descendant(of: cardWidget, matching: find.byType(Text));
      expect(nameText.evaluate().isNotEmpty, isTrue,
          reason: 'Hotel card $i should have name text');

      // Check for favorite button
      final favoriteButton = find.descendant(
          of: cardWidget, matching: find.byIcon(Icons.favorite_outline));
      final filledFavoriteButton = find.descendant(
          of: cardWidget, matching: find.byIcon(Icons.favorite));

      final hasFavoriteButton = favoriteButton.evaluate().isNotEmpty ||
          filledFavoriteButton.evaluate().isNotEmpty;
      expect(hasFavoriteButton, isTrue,
          reason: 'Hotel card $i should have favorite button');
    }

    debugPrint('✅ Search results validation passed for $cardCount hotels');
  }

  /// Tests lazy loading functionality by scrolling
  static Future<void> testLazyLoading(PatrolIntegrationTester $) async {
    debugPrint('🔄 Testing lazy loading with scroll');

    final initialCards = find.byType(Card).evaluate().length;
    debugPrint('📊 Initial card count: $initialCards');

    if (initialCards < 5) {
      debugPrint('ℹ️ Not enough cards to test pagination effectively');
      return;
    }

    // Scroll to trigger pagination
    final scrollView = find.byKey(const Key('hotels_scroll_view'));
    if (scrollView.evaluate().isNotEmpty) {
      await $(scrollView.first).scrollTo(maxScrolls: 5);

      // Wait for pagination loading
      await $.pump(const Duration(seconds: 2));

      // Check if pagination loading appeared
      final paginationLoading =
          find.byKey(const Key('hotels_pagination_loading'));
      if (paginationLoading.evaluate().isNotEmpty) {
        debugPrint('⏳ Pagination loading detected');

        // Wait for new results
        await $.pump(const Duration(seconds: 5));

        final finalCards = find.byType(Card).evaluate().length;
        debugPrint('📊 Final card count: $finalCards');

        if (finalCards > initialCards) {
          debugPrint(
              '✅ Lazy loading successful: ${finalCards - initialCards} new hotels loaded');

          // Verify no duplicates by checking unique hotel names
          await _verifyNoDuplicateResults($);
        } else {
          debugPrint('ℹ️ No additional results loaded (might be end of list)');
        }
      } else {
        debugPrint(
            'ℹ️ No pagination loading indicator - might not have enough results');
      }
    }
  }

  /// Validates that empty space input triggers proper error handling
  static Future<void> validateEmptySpaceErrorHandling(
      PatrolIntegrationTester $) async {
    debugPrint('🔍 Testing empty space error handling');

    final errorMessage = find.byKey(const Key('hotels_error_message'));
    final retryButton = find.byKey(const Key('hotels_retry_button'));

    expect(errorMessage, findsOneWidget,
        reason: 'Empty space should trigger error message');
    expect(retryButton, findsOneWidget,
        reason: 'Error state should show retry button');

    // Verify error message text
    final errorText = find.text('Something went wrong');
    expect(errorText, findsOneWidget,
        reason: 'Should show "Something went wrong" message');

    // Verify retry button text
    final retryText = find.text('Try Again');
    expect(retryText, findsOneWidget, reason: 'Should show "Try Again" button');

    debugPrint('✅ Empty space error handling validation passed');
  }

  /// Private helper to analyze current search state
  static Future<SearchResultState> _analyzeSearchState(
      PatrolIntegrationTester $) async {
    // Check for loading states
    if (_isLoadingIndicatorVisible($)) {
      return SearchResultState.loading;
    }

    // Check for error states
    if (_isErrorStateVisible($)) {
      return SearchResultState.error;
    }

    // Check for results
    if (_hasSearchResults($)) {
      return SearchResultState.hasResults;
    }

    // Check for empty state
    if (_isEmptyStateVisible($)) {
      return SearchResultState.empty;
    }

    return SearchResultState.unknown;
  }

  /// Private helper to check loading indicators
  static bool _isLoadingIndicatorVisible(PatrolIntegrationTester $) {
    final mainLoading = find.byKey(const Key('hotels_loading_indicator'));
    final paginationLoading =
        find.byKey(const Key('hotels_pagination_loading'));

    return mainLoading.evaluate().isNotEmpty ||
        paginationLoading.evaluate().isNotEmpty;
  }

  /// Private helper to check error states
  static bool _isErrorStateVisible(PatrolIntegrationTester $) {
    final errorMessage = find.byKey(const Key('hotels_error_message'));
    final errorColumn = find.byKey(const Key('hotels_error_column'));

    return errorMessage.evaluate().isNotEmpty ||
        errorColumn.evaluate().isNotEmpty;
  }

  /// Private helper to check for search results
  static bool _hasSearchResults(PatrolIntegrationTester $) {
    final hotelCards = find.byType(Card);
    return hotelCards.evaluate().isNotEmpty;
  }

  /// Private helper to check empty state
  static bool _isEmptyStateVisible(PatrolIntegrationTester $) {
    final emptyStateIcon = find.byKey(const Key('hotels_empty_state_icon'));
    return emptyStateIcon.evaluate().isNotEmpty;
  }

  /// Private helper to verify no duplicate results
  static Future<void> _verifyNoDuplicateResults(
      PatrolIntegrationTester $) async {
    final hotelCards = find.byType(Card);
    final cardCount = hotelCards.evaluate().length;

    Set<String> hotelNames = {};

    for (int i = 0; i < cardCount; i++) {
      final cardWidget = hotelCards.at(i);
      final textWidgets =
          find.descendant(of: cardWidget, matching: find.byType(Text));

      if (textWidgets.evaluate().isNotEmpty) {
        final firstText = textWidgets.first.evaluate().first.widget as Text;
        final hotelName = firstText.data ?? '';

        if (hotelName.isNotEmpty) {
          if (hotelNames.contains(hotelName)) {
            fail(
                'Duplicate hotel found: "$hotelName" - lazy loading should not create duplicates');
          }
          hotelNames.add(hotelName);
        }
      }
    }

    debugPrint('✅ No duplicates found in ${hotelNames.length} unique hotels');
  }
}

/// Enum representing different search result states
enum SearchResultState {
  loading,
  hasResults,
  empty,
  error,
  timeout,
  unknown,
}

/// Extension for better state handling
extension SearchResultStateExtension on SearchResultState {
  bool get isTerminal =>
      this != SearchResultState.loading && this != SearchResultState.unknown;

  String get description {
    switch (this) {
      case SearchResultState.loading:
        return 'Loading results';
      case SearchResultState.hasResults:
        return 'Results found';
      case SearchResultState.empty:
        return 'No results';
      case SearchResultState.error:
        return 'Error occurred';
      case SearchResultState.timeout:
        return 'Timeout reached';
      case SearchResultState.unknown:
        return 'Unknown state';
    }
  }
}
