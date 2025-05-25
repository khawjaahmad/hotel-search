import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Streamlined Search Error Handler - Essential error handling logic
/// Focused on core search state detection and timeout management
class SearchErrorHandler {
  SearchErrorHandler._();

  /// Handle search result with smart timeout and state detection
  static Future<void> handleSearchResult(
    PatrolIntegrationTester $,
    Future<void> Function() testFunction,
  ) async {
    const maxWaitTime = Duration(seconds: 20);
    const checkInterval = Duration(milliseconds: 500);
    final startTime = DateTime.now();

    // Wait for search to complete or timeout
    while (DateTime.now().difference(startTime) < maxWaitTime) {
      await $.pump(checkInterval);

      final currentState = _analyzeSearchState($);

      switch (currentState) {
        case SearchState.loading:
          debugPrint('🔄 Search loading...');
          continue;

        case SearchState.hasResults:
        case SearchState.empty:
        case SearchState.error:
          debugPrint('✅ Search completed with state: ${currentState.name}');
          await testFunction();
          return;

        case SearchState.unknown:
          continue;
      }
    }

    // Timeout reached - execute test function anyway
    debugPrint('⏰ Search timeout - executing test function');
    await testFunction();
  }

  /// Analyze current search state based on UI elements
  static SearchState _analyzeSearchState(PatrolIntegrationTester $) {
    // Check loading indicators
    if (_hasLoadingIndicator($)) {
      return SearchState.loading;
    }

    // Check error states
    if (_hasErrorState($)) {
      return SearchState.error;
    }

    // Check for results
    if (_hasResults($)) {
      return SearchState.hasResults;
    }

    // Check empty state
    if (_hasEmptyState($)) {
      return SearchState.empty;
    }

    return SearchState.unknown;
  }

  /// Check for loading indicators
  static bool _hasLoadingIndicator(PatrolIntegrationTester $) {
    final indicators = [
      find.byKey(const Key('hotels_loading_indicator')),
      find.byKey(const Key('hotels_pagination_loading')),
      find.byType(CircularProgressIndicator),
    ];

    return indicators.any((indicator) => indicator.evaluate().isNotEmpty);
  }

  /// Check for error states
  static bool _hasErrorState(PatrolIntegrationTester $) {
    final errorElements = [
      find.byKey(const Key('hotels_error_message')),
      find.byKey(const Key('hotels_retry_button')),
      find.text('Something went wrong'),
      find.text('Try Again'),
    ];

    return errorElements.any((element) => element.evaluate().isNotEmpty);
  }

  /// Check for search results
  static bool _hasResults(PatrolIntegrationTester $) {
    return find.byType(Card).evaluate().isNotEmpty;
  }

  /// Check for empty state
  static bool _hasEmptyState(PatrolIntegrationTester $) {
    return find
        .byKey(const Key('hotels_empty_state_icon'))
        .evaluate()
        .isNotEmpty;
  }

  /// Get current search state info for debugging
  static Map<String, dynamic> getSearchStateInfo(PatrolIntegrationTester $) {
    final state = _analyzeSearchState($);
    return {
      'state': state.name,
      'hasLoading': _hasLoadingIndicator($),
      'hasError': _hasErrorState($),
      'hasResults': _hasResults($),
      'hasEmpty': _hasEmptyState($),
      'resultsCount': find.byType(Card).evaluate().length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Simple enum for search states
enum SearchState {
  loading,
  hasResults,
  empty,
  error,
  unknown,
}

/// Extension for better state description
extension SearchStateExtension on SearchState {
  String get description {
    switch (this) {
      case SearchState.loading:
        return 'Loading results';
      case SearchState.hasResults:
        return 'Results found';
      case SearchState.empty:
        return 'No results';
      case SearchState.error:
        return 'Error occurred';
      case SearchState.unknown:
        return 'Unknown state';
    }
  }

  bool get isTerminalState =>
      this != SearchState.loading && this != SearchState.unknown;
}
