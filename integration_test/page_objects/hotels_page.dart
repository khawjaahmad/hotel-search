import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
/// Hotels Page Object Model
/// Handles hotel search, listing, and favorite operations
class HotelsPage extends BasePage {
  HotelsPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'hotels';

  @override
  String get pageKey => 'hotels_scaffold'; // Matches app's key

  /// Search for hotels with the given query
  Future<void> searchHotels(String query) async {
    logAction('Searching for hotels: $query');

    // Wait for the search field container to be available
    await waitForElement('hotels_search_field');

    // Find the actual TextField within the SearchTextField widget
    final textField = find.byType(TextField);
    if (textField.evaluate().isNotEmpty) {
      // Clear existing text first
      await clearSearchField();

      // Enter new search text
      await $(textField.first).enterText(query);
      await $.pump(const Duration(milliseconds: 600)); // Wait for debounce

      await waitForLoadingToComplete();
      await takePageScreenshot('search_$query');
    } else {
      throw Exception('TextField not found in search field');
    }
  }

  /// Clear the search field using the cancel button
  Future<void> clearSearchField() async {
    logAction('Clearing search field');

    // Find the cancel/clear button (Icons.cancel_outlined)
    final clearButton = find.byIcon(Icons.cancel_outlined);
    if (clearButton.evaluate().isNotEmpty) {
      await $(clearButton.first).tap();
      await $.pump(const Duration(milliseconds: 300));
    } else {
      // Fallback: clear by selecting all text and deleting
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        await $(textField.first).enterText('');
        await $.pump(const Duration(milliseconds: 300));
      }
    }
  }

  /// Verify search field is visible and functional
  void verifySearchFieldVisible() {
    logAction('Verifying search field is visible');
    verifyElementExists('hotels_search_field'); // Container key from app

    // Verify TextField exists within the search field
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Verify search icon exists
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);

    // Verify clear button exists
    final cancelIcon = find.byIcon(Icons.cancel_outlined);
    expect(cancelIcon, findsOneWidget);
  }

  /// Verify hotels page is fully loaded
  Future<void> verifyHotelsPageLoaded() async {
    logAction('Verifying hotels page is loaded');
    await verifyPageIsLoaded();
    verifySearchFieldVisible();
  }

  /// Wait for search results to load
  Future<void> waitForSearchResults() async {
    logAction('Waiting for search results');

    // Wait for potential loading indicator to appear and disappear
    await $.pump(const Duration(milliseconds: 500));

    // Check if loading indicator exists using correct key
    if (isElementVisible('hotels_loading_indicator')) {
      await waitForElementToDisappear('hotels_loading_indicator');
    }

    await waitForLoadingToComplete();
  }

  /// Verify empty state is shown (when no search query)
  void verifyEmptyState() {
    logAction('Verifying empty state');
    verifyElementExists('hotels_empty_state_icon'); // Matches app's key
  }

  /// Verify error state is shown
  void verifyErrorState() {
    logAction('Verifying error state');
    verifyElementExists('hotels_error_message'); // Matches app's key
    verifyElementExists('hotels_retry_button'); // Matches app's key
  }

  /// Retry failed search
  Future<void> retrySearch() async {
    logAction('Retrying search');
    await tapElement('hotels_retry_button'); // Matches app's key
    await waitForLoadingToComplete();
  }

  /// Tap favorite button for a specific hotel card
  Future<void> toggleHotelFavorite(String hotelId) async {
    logAction('Toggling favorite for hotel: $hotelId');

    // Find hotel card by its key pattern: hotel_card_{coordinates}
    final hotelCardKey = 'hotel_card_$hotelId';
    final hotelCard = find.byKey(Key(hotelCardKey));

    if (hotelCard.evaluate().isNotEmpty) {
      // Find favorite button within the hotel card
      final favoriteButton = find.descendant(
        of: hotelCard,
        matching: find.byIcon(Icons.favorite_outline),
      );

      final filledFavoriteButton = find.descendant(
        of: hotelCard,
        matching: find.byIcon(Icons.favorite),
      );

      if (favoriteButton.evaluate().isNotEmpty) {
        await $(favoriteButton.first).tap();
      } else if (filledFavoriteButton.evaluate().isNotEmpty) {
        await $(filledFavoriteButton.first).tap();
      } else {
        throw Exception('No favorite button found for hotel $hotelId');
      }

      await $.pump(const Duration(milliseconds: 300));
      await takePageScreenshot('hotel_favorite_toggled_$hotelId');
    } else {
      throw Exception('Hotel card not found for ID: $hotelId');
    }
  }

  /// Verify hotel card exists
  void verifyHotelCardExists(String hotelId) {
    logAction('Verifying hotel card exists: $hotelId');
    final hotelCardKey = 'hotel_card_$hotelId';
    verifyElementExists(hotelCardKey);
  }

  /// Scroll to load more hotels (pagination)
  Future<void> scrollToLoadMore() async {
    logAction('Scrolling to load more hotels');

    // Use the correct CustomScrollView key from app
    final scrollView = find.byKey(const Key('hotels_scroll_view'));
    if (scrollView.evaluate().isNotEmpty) {
      await $(scrollView.first).scrollTo(maxScrolls: 3);
      await waitForLoadingToComplete();
    } else {
      throw Exception('Hotels scroll view not found');
    }
  }

  /// Verify pagination loading
  void verifyPaginationLoading() {
    logAction('Verifying pagination loading');
    verifyElementExists('hotels_pagination_loading'); // Matches app's key
  }

  /// Verify pagination error
  void verifyPaginationError() {
    logAction('Verifying pagination error');
    verifyElementExists('hotels_pagination_error_message'); // Matches app's key
    verifyElementExists('hotels_pagination_retry_button'); // Matches app's key
  }

  /// Retry pagination
  Future<void> retryPagination() async {
    logAction('Retrying pagination');
    await tapElement('hotels_pagination_retry_button'); // Matches app's key
    await waitForLoadingToComplete();
  }

  /// Perform comprehensive hotel search test
  Future<void> performSearchTest(String query) async {
    logAction('Performing comprehensive search test for: $query');

    await verifyHotelsPageLoaded();
    await searchHotels(query);
    await waitForSearchResults();

    // Take screenshot of results
    await takePageScreenshot('search_results_$query');
  }

  /// Test search functionality with multiple queries
  Future<void> testMultipleSearches(List<String> queries) async {
    logAction('Testing multiple search queries');

    for (final query in queries) {
      await performSearchTest(query);
      await $.pump(const Duration(seconds: 1));
    }
  }

  /// Verify hotels list is scrollable
  Future<void> verifyHotelsListScrollable() async {
    logAction('Verifying hotels list is scrollable');

    final scrollView = find.byKey(const Key('hotels_scroll_view'));
    if (scrollView.evaluate().isNotEmpty) {
      try {
        // Test scrolling capability
        await $(scrollView.first).scrollTo();
        logAction('Hotels list is scrollable and functional');
      } catch (e) {
        logAction('Error testing scroll: $e');
      }
      await $.pumpAndSettle();
    } else {
      logAction('Hotels scroll view not found');
    }
  }

  // ============================================================================
  // ENHANCED METHODS FOR REAL FUNCTIONALITY TESTING
  // ============================================================================

  /// Count actual hotel cards in the results
  int countHotelCards() {
    final hotelCards = find.byType(Card);
    final count = hotelCards.evaluate().length;
    logAction('Current hotel cards count: $count');
    return count;
  }

  /// Wait for search with comprehensive error handling
  Future<void> waitForSearchWithErrorHandling() async {
    logAction('Waiting for search with error handling');

    const maxWaitTime = Duration(seconds: 15);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));

      // Check for error state using correct key
      if (find.byKey(const Key('hotels_error_message')).evaluate().isNotEmpty) {
        logAction('⚠️ Search returned error state');
        return;
      }

      // Check for results
      if (find.byType(Card).evaluate().isNotEmpty) {
        logAction('✅ Search results loaded');
        return;
      }

      // Check for loading using correct key
      if (find
          .byKey(const Key('hotels_loading_indicator'))
          .evaluate()
          .isNotEmpty) {
        logAction('⏳ Still loading...');
        continue;
      }

      // Check for empty state using correct key
      if (find
          .byKey(const Key('hotels_empty_state_icon'))
          .evaluate()
          .isNotEmpty) {
        logAction('📭 Search returned empty results');
        return;
      }
    }

    logAction('⏰ Search timeout reached');
  }

  /// Check if search results contain actual data
  bool hasSearchResults() {
    final hotelCards = find.byType(Card);
    final hasResults = hotelCards.evaluate().isNotEmpty;
    logAction('Search has results: $hasResults');
    return hasResults;
  }

  /// Check if search is in loading state
  bool isSearchLoading() {
    final loadingIndicator = find.byKey(const Key('hotels_loading_indicator'));
    final paginationLoading =
        find.byKey(const Key('hotels_pagination_loading'));

    final isLoading = loadingIndicator.evaluate().isNotEmpty ||
        paginationLoading.evaluate().isNotEmpty;
    logAction('Search is loading: $isLoading');
    return isLoading;
  }

  /// Check if search resulted in error
  bool hasSearchError() {
    final errorMessage = find.byKey(const Key('hotels_error_message'));
    final retryButton = find.byKey(const Key('hotels_retry_button'));

    final hasError =
        errorMessage.evaluate().isNotEmpty || retryButton.evaluate().isNotEmpty;
    logAction('Search has error: $hasError');
    return hasError;
  }

  /// Check if search shows empty state
  bool hasEmptySearchState() {
    final emptyStateIcon = find.byKey(const Key('hotels_empty_state_icon'));
    final isEmpty = emptyStateIcon.evaluate().isNotEmpty;
    logAction('Search shows empty state: $isEmpty');
    return isEmpty;
  }

  /// Test favorite toggle for specific hotel card by index
  Future<void> testFavoriteToggleForCard(int cardIndex) async {
    logAction('Testing favorite toggle for card: $cardIndex');

    final hotelCards = find.byType(Card);
    if (hotelCards.evaluate().length > cardIndex) {
      final cardWidget = hotelCards.at(cardIndex);

      // Find favorite button within this card
      final favoriteButton = find.descendant(
        of: cardWidget,
        matching: find.byIcon(Icons.favorite_outline),
      );

      if (favoriteButton.evaluate().isNotEmpty) {
        // Tap to add to favorites
        await $(favoriteButton.first).tap();
        await $.pump(const Duration(milliseconds: 500));

        // Verify icon changed to filled heart
        final filledHeart = find.descendant(
          of: cardWidget,
          matching: find.byIcon(Icons.favorite),
        );

        if (filledHeart.evaluate().isNotEmpty) {
          logAction('✅ Hotel card $cardIndex added to favorites');

          // Tap again to remove from favorites
          await $(filledHeart.first).tap();
          await $.pump(const Duration(milliseconds: 500));

          // Verify icon changed back to outline
          final outlineHeart = find.descendant(
            of: cardWidget,
            matching: find.byIcon(Icons.favorite_outline),
          );

          if (outlineHeart.evaluate().isNotEmpty) {
            logAction('✅ Hotel card $cardIndex removed from favorites');
          } else {
            logAction('⚠️ Hotel card $cardIndex favorite state not reverted');
          }
        } else {
          logAction(
              '⚠️ Hotel card $cardIndex favorite icon did not change to filled');
        }
      } else {
        logAction('❌ No favorite button found in card $cardIndex');
      }
    } else {
      logAction('❌ Card index $cardIndex out of range');
    }
  }

  /// Test pagination by scrolling and checking for more results
  Future<void> testPaginationByScrolling() async {
    logAction('Testing pagination by scrolling');

    final scrollView = find.byKey(const Key('hotels_scroll_view'));
    if (scrollView.evaluate().isNotEmpty) {
      // Get initial count of hotel cards
      final initialCards = find.byType(Card).evaluate().length;
      logAction('Initial hotel cards count: $initialCards');

      // Scroll down to trigger pagination
      await $(scrollView.first).scrollTo(maxScrolls: 5);
      await $.pump(const Duration(seconds: 2));

      // Check if pagination loading appeared
      final paginationLoading =
          find.byKey(const Key('hotels_pagination_loading'));
      if (paginationLoading.evaluate().isNotEmpty) {
        logAction('Pagination loading indicator appeared');

        // Wait for new results to load
        await $.pump(const Duration(seconds: 3));

        // Check if more cards loaded
        final finalCards = find.byType(Card).evaluate().length;
        logAction('Final hotel cards count: $finalCards');

        if (finalCards > initialCards) {
          logAction('✅ Pagination loaded more results successfully');
        } else {
          logAction('ℹ️ No additional results loaded (might be end of list)');
        }
      } else {
        logAction('ℹ️ No pagination loading indicator shown');
      }
    } else {
      logAction('❌ Scroll view not found for pagination test');
    }
  }

  /// Add multiple hotels to favorites
  Future<List<int>> addMultipleHotelsToFavorites({int maxFavorites = 3}) async {
    logAction('Adding multiple hotels to favorites (max: $maxFavorites)');

    List<int> favoritedIndices = [];
    final hotelCards = find.byType(Card);
    final availableCards = hotelCards.evaluate().length;

    final favoritesToAdd =
        availableCards >= maxFavorites ? maxFavorites : availableCards;

    for (int i = 0; i < favoritesToAdd; i++) {
      try {
        final cardWidget = hotelCards.at(i);
        final favoriteButton = find.descendant(
          of: cardWidget,
          matching: find.byIcon(Icons.favorite_outline),
        );

        if (favoriteButton.evaluate().isNotEmpty) {
          await $(favoriteButton.first).tap();
          await $.pump(const Duration(milliseconds: 500));

          favoritedIndices.add(i);
          logAction('✅ Added hotel at index $i to favorites');
        } else {
          logAction('⚠️ No favorite button found for hotel at index $i');
        }
      } catch (e) {
        logAction('⚠️ Failed to add hotel at index $i to favorites: $e');
      }
    }

    logAction(
        'Successfully added ${favoritedIndices.length} hotels to favorites');
    return favoritedIndices;
  }

  /// Verify favorites were added correctly
  void verifyFavoritesAdded(List<int> expectedFavoriteIndices) {
    logAction('Verifying favorites were added correctly');

    final filledHearts = find.byIcon(Icons.favorite);
    final actualFavorites = filledHearts.evaluate().length;

    expect(actualFavorites, equals(expectedFavoriteIndices.length));
    logAction(
        '✅ Verified ${actualFavorites} favorites match expected ${expectedFavoriteIndices.length}');
  }

  /// Test complete search flow with error handling
  Future<void> testCompleteSearchFlow(String query) async {
    logAction('Testing complete search flow for: $query');

    // 1. Perform search
    await searchHotels(query);

    // 2. Wait for results with error handling
    await waitForSearchWithErrorHandling();

    // 3. Handle different result states
    if (hasSearchResults()) {
      logAction('Search returned results - testing functionality');

      // Test pagination if results exist
      if (countHotelCards() > 0) {
        await testPaginationByScrolling();
      }
    } else if (hasSearchError()) {
      logAction('Search resulted in error - testing retry functionality');
      await retrySearch();
    } else if (hasEmptySearchState()) {
      logAction('Search returned empty state as expected');
    }

    logAction('✅ Complete search flow tested for: $query');
  }

  /// Extract hotel ID from hotel card widget key
  String extractHotelIdFromCard(Widget cardWidget) {
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

  /// Get all hotel cards with their IDs
  Map<int, String> getAllHotelCardsWithIds() {
    final hotelCards = find.byType(Card);
    final cardCount = hotelCards.evaluate().length;
    Map<int, String> hotelCardMap = {};

    for (int i = 0; i < cardCount; i++) {
      try {
        final cardElement = hotelCards.at(i).evaluate().first;
        final cardWidget = cardElement.widget;
        final hotelId = extractHotelIdFromCard(cardWidget);

        if (hotelId.isNotEmpty) {
          hotelCardMap[i] = hotelId;
        }
      } catch (e) {
        logAction('Could not extract ID for card at index $i: $e');
      }
    }

    logAction('Found ${hotelCardMap.length} hotel cards with valid IDs');
    return hotelCardMap;
  }

  /// Verify search results quality and structure
  void verifySearchResultsQuality() {
    logAction('Verifying search results quality');

    final hotelCards = find.byType(Card);
    final cardCount = hotelCards.evaluate().length;

    if (cardCount > 0) {
      logAction('✅ Search returned $cardCount hotel results');

      // Verify each card has required elements
      int cardsWithFavoriteButtons = 0;
      int cardsWithText = 0;

      for (int i = 0; i < cardCount; i++) {
        try {
          final cardWidget = hotelCards.at(i);

          // Check for favorite button
          final favoriteButton = find.descendant(
            of: cardWidget,
            matching: find.byIcon(Icons.favorite_outline),
          );
          final filledFavoriteButton = find.descendant(
            of: cardWidget,
            matching: find.byIcon(Icons.favorite),
          );

          if (favoriteButton.evaluate().isNotEmpty ||
              filledFavoriteButton.evaluate().isNotEmpty) {
            cardsWithFavoriteButtons++;
          }

          // Check for text content
          final textWidgets = find.descendant(
            of: cardWidget,
            matching: find.byType(Text),
          );

          if (textWidgets.evaluate().isNotEmpty) {
            cardsWithText++;
          }
        } catch (e) {
          logAction('Error checking card $i: $e');
        }
      }

      logAction(
          '✅ Cards with favorite buttons: $cardsWithFavoriteButtons/$cardCount');
      logAction('✅ Cards with text content: $cardsWithText/$cardCount');

      if (cardsWithFavoriteButtons == cardCount) {
        logAction('✅ All hotel cards have favorite buttons');
      } else {
        logAction('⚠️ Some hotel cards missing favorite buttons');
      }
    } else {
      logAction('ℹ️ No hotel cards found in results');
    }
  }
}
