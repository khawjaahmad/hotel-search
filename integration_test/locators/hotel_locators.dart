
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hotels Page Locators - Comprehensive locator management
/// Handles both static page elements and dynamic hotel cards
class HotelsLocators {
  HotelsLocators._();

  // =============================================================================
  // STATIC PAGE ELEMENT LOCATORS
  // =============================================================================

  /// Page Structure Locators
  static const String scaffold = 'hotels_scaffold';
  static const String appBar = 'hotels_app_bar';
  static const String scrollView = 'hotels_scroll_view';
  static const String hotelsList = 'hotels_list';

  /// Search Functionality Locators
  static const String searchField = 'hotels_search_field';
  static const String searchTextField = 'search_text_field';
  static const String searchPrefixIcon = 'search_prefix_icon';
  static const String searchClearButton = 'search_clear_button';
  static const String searchSuffixIcon = 'search_suffix_icon';

  /// Loading State Locators
  static const String loadingIndicator = 'hotels_loading_indicator';
  static const String paginationLoading = 'hotels_pagination_loading';

  /// Empty State Locators
  static const String emptyStateIcon = 'hotels_empty_state_icon';

  /// Error State Locators
  static const String errorColumn = 'hotels_error_column';
  static const String errorMessage = 'hotels_error_message';
  static const String retryButton = 'hotels_retry_button';

  /// Pagination Error Locators
  static const String paginationErrorColumn = 'hotels_pagination_error_column';
  static const String paginationErrorMessage =
      'hotels_pagination_error_message';
  static const String paginationRetryButton = 'hotels_pagination_retry_button';

  // =============================================================================
  // DYNAMIC HOTEL CARD LOCATORS
  // =============================================================================

  /// Generate hotel card key for specific hotel
  static String hotelCard(String hotelId) => 'hotel_card_$hotelId';

  /// Generate hotel name key for specific hotel
  static String hotelName(String hotelId) => 'hotel_name_$hotelId';

  /// Generate hotel description key for specific hotel
  static String hotelDescription(String hotelId) =>
      'hotel_description_$hotelId';

  /// Generate favorite button key for specific hotel
  static String hotelFavoriteButton(String hotelId) =>
      'hotel_favorite_button_$hotelId';

  /// Generate complete hotel card finder
  static Finder hotelCardFinder(String hotelId) =>
      find.byKey(Key(hotelCard(hotelId)));

  /// Generate hotel name finder
  static Finder hotelNameFinder(String hotelId) =>
      find.byKey(Key(hotelName(hotelId)));

  /// Generate favorite button finder
  static Finder hotelFavoriteButtonFinder(String hotelId) =>
      find.byKey(Key(hotelFavoriteButton(hotelId)));

  // =============================================================================
  // SMART FINDER METHODS
  // =============================================================================

  /// Get search field with fallback strategies
  static Finder get searchFieldFinder {
    // Try container key first
    final containerFinder = find.byKey(const Key(searchField));
    if (containerFinder.evaluate().isNotEmpty) {
      return containerFinder;
    }

    // Fallback to actual TextField
    final textFieldFinder = find.byKey(const Key(searchTextField));
    if (textFieldFinder.evaluate().isNotEmpty) {
      return textFieldFinder;
    }

    // Final fallback to widget type
    return find.byType(TextField);
  }

  /// Get loading indicator with multiple fallback options
  static Finder get loadingFinder {
    // Primary loading indicator
    final primaryLoading = find.byKey(const Key(loadingIndicator));
    if (primaryLoading.evaluate().isNotEmpty) {
      return primaryLoading;
    }

    // Pagination loading
    final paginationLoadingFinder = find.byKey(const Key(paginationLoading));
    if (paginationLoadingFinder.evaluate().isNotEmpty) {
      return paginationLoadingFinder;
    }

    // Generic CircularProgressIndicator
    return find.byType(CircularProgressIndicator);
  }

  /// Get error elements with comprehensive detection
  static Map<String, Finder> get errorFinders => {
        'message': find.byKey(const Key(errorMessage)),
        'column': find.byKey(const Key(errorColumn)),
        'retry': find.byKey(const Key(retryButton)),
        'text_message': find.text('Something went wrong'),
        'text_retry': find.text('Try Again'),
      };

  // =============================================================================
  // HOTEL CARD UTILITIES
  // =============================================================================

  /// Extract hotel ID from card key
  static String? extractHotelIdFromKey(String keyString) {
    final match = RegExp(r'hotel_card_([0-9\.\-,]+)').firstMatch(keyString);
    return match?.group(1);
  }

  /// Get all visible hotel cards
  static List<Finder> getAllHotelCards() {
    final cardFinders = <Finder>[];
    final allCards = find.byType(Card);

    for (int i = 0; i < allCards.evaluate().length; i++) {
      cardFinders.add(allCards.at(i));
    }

    return cardFinders;
  }

  /// Get hotel card count
  static int getHotelCardCount() {
    return find.byType(Card).evaluate().length;
  }

  /// Check if specific hotel card exists
  static bool hotelCardExists(String hotelId) {
    return hotelCardFinder(hotelId).evaluate().isNotEmpty;
  }

  /// Get hotel card with error handling
  static Finder? getHotelCardSafely(String hotelId) {
    try {
      final finder = hotelCardFinder(hotelId);
      return finder.evaluate().isNotEmpty ? finder : null;
    } catch (e) {
      debugPrint('⚠️ [HOTELS] Error getting hotel card $hotelId: $e');
      return null;
    }
  }

  // =============================================================================
  // STATE DETECTION UTILITIES
  // =============================================================================

  /// Check if page is in loading state
  static bool get isLoading {
    return loadingFinder.evaluate().isNotEmpty;
  }

  /// Check if page has error state
  static bool get hasError {
    return errorFinders.values.any((finder) => finder.evaluate().isNotEmpty);
  }

  /// Check if page has empty state
  static bool get isEmpty {
    return find.byKey(const Key(emptyStateIcon)).evaluate().isNotEmpty;
  }

  /// Check if page has search results
  static bool get hasResults {
    return getHotelCardCount() > 0;
  }

  /// Get current page state
  static HotelsPageState get currentState {
    if (isLoading) return HotelsPageState.loading;
    if (hasError) return HotelsPageState.error;
    if (hasResults) return HotelsPageState.hasResults;
    if (isEmpty) return HotelsPageState.empty;
    return HotelsPageState.unknown;
  }

  // =============================================================================
  // VALIDATION METHODS
  // =============================================================================

  /// Validate page structure elements
  static void validatePageStructure() {
    debugPrint('🔍 [HOTELS] Validating page structure...');

    final structureElements = {
      'Scaffold': find.byKey(const Key(scaffold)),
      'App Bar': find.byKey(const Key(appBar)),
      'Search Field': searchFieldFinder,
    };

    structureElements.forEach((name, finder) {
      expect(finder, findsOneWidget, reason: '$name should be present');
      debugPrint('✅ [HOTELS] $name validated');
    });

    debugPrint('✅ [HOTELS] Page structure validation complete');
  }

  /// Validate search functionality elements
  static void validateSearchElements() {
    debugPrint('🔍 [HOTELS] Validating search elements...');

    expect(searchFieldFinder, findsOneWidget,
        reason: 'Search field should be present');
    expect(find.byIcon(Icons.search), findsOneWidget,
        reason: 'Search icon should be present');
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget,
        reason: 'Clear button should be present');

    debugPrint('✅ [HOTELS] Search elements validation complete');
  }

  /// Validate hotel cards structure
  static void validateHotelCards() {
    debugPrint('🔍 [HOTELS] Validating hotel cards...');

    final cardCount = getHotelCardCount();
    debugPrint('📊 [HOTELS] Found $cardCount hotel cards');

    if (cardCount > 0) {
      // Validate first few cards have required elements
      final cardsToCheck = cardCount >= 3 ? 3 : cardCount;

      for (int i = 0; i < cardsToCheck; i++) {
        final cardFinder = find.byType(Card).at(i);

        // Check for hotel name text
        final nameText =
            find.descendant(of: cardFinder, matching: find.byType(Text));
        expect(nameText.evaluate().isNotEmpty, isTrue,
            reason: 'Hotel card $i should have name text');

        // Check for favorite button
        final favoriteButton = find.descendant(
            of: cardFinder, matching: find.byIcon(Icons.favorite_outline));
        final filledFavoriteButton = find.descendant(
            of: cardFinder, matching: find.byIcon(Icons.favorite));

        final hasFavoriteButton = favoriteButton.evaluate().isNotEmpty ||
            filledFavoriteButton.evaluate().isNotEmpty;
        expect(hasFavoriteButton, isTrue,
            reason: 'Hotel card $i should have favorite button');
      }

      debugPrint(
          '✅ [HOTELS] Hotel cards validation complete for $cardsToCheck cards');
    } else {
      debugPrint('ℹ️ [HOTELS] No hotel cards to validate');
    }
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Get Key object for any hotels locator
  static Key getKey(String locatorName) {
    return Key(locatorName);
  }

  /// Get all locator constants as list
  static List<String> get allLocators => [
        scaffold,
        appBar,
        scrollView,
        hotelsList,
        searchField,
        searchTextField,
        searchPrefixIcon,
        searchClearButton,
        loadingIndicator,
        paginationLoading,
        emptyStateIcon,
        errorColumn,
        errorMessage,
        retryButton,
        paginationErrorColumn,
        paginationErrorMessage,
        paginationRetryButton,
      ];

  /// Print all available locators (for debugging)
  static void printAllLocators() {
    debugPrint('📋 [HOTELS] Available Locators:');
    for (final locator in allLocators) {
      debugPrint('  - $locator');
    }
  }
}

/// Enum for hotels page state
enum HotelsPageState {
  loading,
  hasResults,
  empty,
  error,
  unknown,
}

/// Extension for better state description
extension HotelsPageStateExtension on HotelsPageState {
  String get description {
    switch (this) {
      case HotelsPageState.loading:
        return 'Loading hotels';
      case HotelsPageState.hasResults:
        return 'Hotels found';
      case HotelsPageState.empty:
        return 'No hotels found';
      case HotelsPageState.error:
        return 'Error occurred';
      case HotelsPageState.unknown:
        return 'Unknown state';
    }
  }
}
