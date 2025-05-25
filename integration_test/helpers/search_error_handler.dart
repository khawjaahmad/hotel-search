import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

class SearchErrorHandler {
  SearchErrorHandler._();

  static Future<void> handleSearchResult(
    PatrolIntegrationTester $,
    Future<void> Function() testFunction,
  ) async {
    const maxWaitTime = Duration(seconds: 20);
    const checkInterval = Duration(milliseconds: 500);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      await $.pump(checkInterval);

      final currentState = await _analyzeCurrentState($);

      switch (currentState) {
        case SearchState.loading:
          debugPrint('🔄 Search is loading...');
          continue;

        case SearchState.hasResults:
          debugPrint('✅ Search results found - executing test function');
          await testFunction();
          return;

        case SearchState.empty:
          debugPrint('📭 Search returned empty results');
          await testFunction();
          return;

        case SearchState.error:
          debugPrint('❌ Search resulted in error state');
          await testFunction();
          return;

        case SearchState.unknown:
          debugPrint('🔍 Search state unknown, continuing to wait...');
          continue;
      }
    }

    debugPrint('⏰ Search timeout reached - executing test function anyway');
    await testFunction();
  }

  static Future<SearchState> _analyzeCurrentState(
      PatrolIntegrationTester $) async {
    if (_isLoading($)) {
      return SearchState.loading;
    }

    if (_hasError($)) {
      return SearchState.error;
    }

    if (_hasResults($)) {
      return SearchState.hasResults;
    }

    if (_hasEmptyState($)) {
      return SearchState.empty;
    }

    return SearchState.unknown;
  }

  static bool _isLoading(PatrolIntegrationTester $) {
    final mainLoading = find.byKey(const Key('hotels_loading_indicator'));
    if (mainLoading.evaluate().isNotEmpty) return true;

    final paginationLoading =
        find.byKey(const Key('hotels_pagination_loading'));
    if (paginationLoading.evaluate().isNotEmpty) return true;

    final circularProgress = find.byType(CircularProgressIndicator);
    if (circularProgress.evaluate().isNotEmpty) return true;

    return false;
  }

  static bool _hasError(PatrolIntegrationTester $) {
    final errorMessage = find.byKey(const Key('hotels_error_message'));
    if (errorMessage.evaluate().isNotEmpty) return true;

    final errorText = find.text('Something went wrong');
    if (errorText.evaluate().isNotEmpty) return true;

    final retryButton = find.byKey(const Key('hotels_retry_button'));
    if (retryButton.evaluate().isNotEmpty) return true;

    final tryAgainButton = find.text('Try Again');
    if (tryAgainButton.evaluate().isNotEmpty) return true;

    return false;
  }

  static bool _hasResults(PatrolIntegrationTester $) {
    final hotelCards = find.byType(Card);
    return hotelCards.evaluate().isNotEmpty;
  }

  static bool _hasEmptyState(PatrolIntegrationTester $) {
    final emptyStateIcon = find.byKey(const Key('hotels_empty_state_icon'));
    return emptyStateIcon.evaluate().isNotEmpty;
  }

  static Future<bool> waitForState(
    PatrolIntegrationTester $,
    SearchState expectedState, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      await $.pump(const Duration(milliseconds: 500));

      final currentState = await _analyzeCurrentState($);
      if (currentState == expectedState) {
        debugPrint('✅ Reached expected state: $expectedState');
        return true;
      }
    }

    debugPrint('⏰ Timeout waiting for state: $expectedState');
    return false;
  }

  static Future<void> handlePaginationLoading(
    PatrolIntegrationTester $, {
    Duration maxWait = const Duration(seconds: 10),
  }) async {
    debugPrint('🔄 Handling pagination loading...');

    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWait) {
      await $.pump(const Duration(milliseconds: 500));

      final paginationLoading =
          find.byKey(const Key('hotels_pagination_loading'));
      if (paginationLoading.evaluate().isEmpty) {
        debugPrint('✅ Pagination loading completed');
        return;
      }

      debugPrint('⏳ Still waiting for pagination to complete...');
    }

    debugPrint('⏰ Pagination loading timeout');
  }

  static Future<void> handleErrorRecovery(PatrolIntegrationTester $) async {
    debugPrint('🔧 Attempting error recovery...');

    final retryButton = find.byKey(const Key('hotels_retry_button'));
    final tryAgainButton = find.text('Try Again');

    if (retryButton.evaluate().isNotEmpty) {
      debugPrint('🔄 Found retry button, tapping...');
      await $(retryButton.first).tap();
      await $.pump(const Duration(seconds: 2));
      return;
    }

    if (tryAgainButton.evaluate().isNotEmpty) {
      debugPrint('🔄 Found Try Again button, tapping...');
      await $(tryAgainButton.first).tap();
      await $.pump(const Duration(seconds: 2));
      return;
    }

    debugPrint('❌ No recovery option found');
  }

  static Future<Map<String, dynamic>> getSearchStateInfo(
      PatrolIntegrationTester $) async {
    final state = await _analyzeCurrentState($);

    return {
      'state': state,
      'isLoading': _isLoading($),
      'hasError': _hasError($),
      'hasResults': _hasResults($),
      'hasEmptyState': _hasEmptyState($),
      'resultsCount': find.byType(Card).evaluate().length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> logCurrentState(PatrolIntegrationTester $) async {
    final stateInfo = await getSearchStateInfo($);
    debugPrint('🔍 Current Search State: ${stateInfo.toString()}');
  }

  static Future<T> withErrorHandling<T>(
    PatrolIntegrationTester $,
    Future<T> Function() operation, {
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🎯 Attempt $attempt of $maxRetries');
        return await operation();
      } catch (e) {
        debugPrint('❌ Attempt $attempt failed: $e');

        if (attempt < maxRetries) {
          if (_hasError($)) {
            await handleErrorRecovery($);
          }

          await $.pump(retryDelay);
          debugPrint('🔄 Retrying in ${retryDelay.inSeconds} seconds...');
        } else {
          debugPrint('💥 All attempts failed, re-throwing error');
          rethrow;
        }
      }
    }

    throw StateError('This should never be reached');
  }
}

enum SearchState {
  loading,
  hasResults,
  empty,
  error,
  unknown,
}

extension SearchStateExtension on SearchState {
  String get displayName {
    switch (this) {
      case SearchState.loading:
        return 'Loading';
      case SearchState.hasResults:
        return 'Has Results';
      case SearchState.empty:
        return 'Empty';
      case SearchState.error:
        return 'Error';
      case SearchState.unknown:
        return 'Unknown';
    }
  }

  bool get isTerminal {
    return this == SearchState.hasResults ||
        this == SearchState.empty ||
        this == SearchState.error;
  }
}
