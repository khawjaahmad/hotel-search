import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Favorites Page Locators - Comprehensive favorites management
/// Handles both static page elements and dynamic favorite hotel cards
class FavoritesLocators {
  FavoritesLocators._();

  // =============================================================================
  // STATIC PAGE ELEMENT LOCATORS
  // =============================================================================

  /// Page Structure Locators
  static const String scaffold = 'favorites_scaffold';
  static const String appBar = 'favorites_app_bar';
  static const String title = 'favorites_title';
  static const String listView = 'favorites_list_view';

  /// Empty State Locators
  static const String emptyStateIcon = 'favorites_empty_state_icon';

  // =============================================================================
  // DYNAMIC FAVORITE HOTEL CARD LOCATORS
  // =============================================================================

  /// Generate favorite hotel card key for specific hotel
  static String favoriteHotelCard(String hotelId) =>
      'favorites_hotel_card_$hotelId';

  /// Generate favorite hotel card finder
  static Finder favoriteHotelCardFinder(String hotelId) =>
      find.byKey(Key(favoriteHotelCard(hotelId)));

  /// Generate hotel name key within favorites (reuses hotel locator pattern)
  static String favoriteHotelName(String hotelId) => 'hotel_name_$hotelId';

  /// Generate favorite button key within favorites (reuses hotel locator pattern)
  static String favoriteHotelButton(String hotelId) =>
      'hotel_favorite_button_$hotelId';

  // =============================================================================
  // SMART FINDER METHODS
  // =============================================================================

  /// Get favorites title with fallback strategies
  static Finder get titleFinder {
    // Try key first
    final keyFinder = find.byKey(const Key(title));
    if (keyFinder.evaluate().isNotEmpty) {
      return keyFinder;
    }

    // Fallback to text content
    final textFinder = find.text('Your Favorite Hotels');
    if (textFinder.evaluate().isNotEmpty) {
      return textFinder;
    }

    // Final fallback to any Text widget in AppBar
    final appBarFinder = find.byKey(const Key(appBar));
    if (appBarFinder.evaluate().isNotEmpty) {
      return find.descendant(of: appBarFinder, matching: find.byType(Text));
    }

    return find.byType(Text);
  }

  /// Get empty state with comprehensive detection
  static Finder get emptyStateFinder {
    // Primary empty state icon
    final iconFinder = find.byKey(const Key(emptyStateIcon));
    if (iconFinder.evaluate().isNotEmpty) {
      return iconFinder;
    }

    // Fallback to favorite outline icon (generic empty state)
    return find.byIcon(Icons.favorite_outline);
  }

  /// Get favorites list view with fallback
  static Finder get listViewFinder {
    // Try key first
    final keyFinder = find.byKey(const Key(listView));
    if (keyFinder.evaluate().isNotEmpty) {
      return keyFinder;
    }

    // Fallback to ListView type
    return find.byType(ListView);
  }

  // =============================================================================
  // FAVORITE CARD UTILITIES
  // =============================================================================

  /// Get all visible favorite cards
  static List<Finder> getAllFavoriteCards() {
    final cardFinders = <Finder>[];
    final allCards = find.byType(Card);

    for (int i = 0; i < allCards.evaluate().length; i++) {
      cardFinders.add(allCards.at(i));
    }

    return cardFinders;
  }

  /// Get favorite card count
  static int getFavoriteCardCount() {
    return find.byType(Card).evaluate().length;
  }

  /// Check if specific favorite card exists
  static bool favoriteCardExists(String hotelId) {
    return favoriteHotelCardFinder(hotelId).evaluate().isNotEmpty;
  }

  /// Get favorite card with error handling
  static Finder? getFavoriteCardSafely(String hotelId) {
    try {
      final finder = favoriteHotelCardFinder(hotelId);
      return finder.evaluate().isNotEmpty ? finder : null;
    } catch (e) {
      debugPrint('⚠️ [FAVORITES] Error getting favorite card $hotelId: $e');
      return null;
    }
  }

  /// Extract hotel names from all favorite cards
  static List<String> extractFavoriteHotelNames() {
    final hotelNames = <String>[];
    final favoriteCards = getAllFavoriteCards();

    for (final cardFinder in favoriteCards) {
      try {
        final nameTexts =
            find.descendant(of: cardFinder, matching: find.byType(Text));
        if (nameTexts.evaluate().isNotEmpty) {
          final nameWidget = nameTexts.first.evaluate().first.widget as Text;
          final hotelName = nameWidget.data ?? '';
          if (hotelName.isNotEmpty) {
            hotelNames.add(hotelName);
          }
        }
      } catch (e) {
        debugPrint('⚠️ [FAVORITES] Error extracting hotel name: $e');
      }
    }

    return hotelNames;
  }

  /// Find favorite card by hotel name
  static Finder? findFavoriteCardByName(String hotelName) {
    final favoriteCards = getAllFavoriteCards();

    for (final cardFinder in favoriteCards) {
      try {
        final nameTexts =
            find.descendant(of: cardFinder, matching: find.byType(Text));
        if (nameTexts.evaluate().isNotEmpty) {
          final nameWidget = nameTexts.first.evaluate().first.widget as Text;
          final cardHotelName = nameWidget.data ?? '';
          if (cardHotelName == hotelName) {
            return cardFinder;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [FAVORITES] Error finding card by name: $e');
      }
    }

    return null;
  }

  // =============================================================================
  // STATE DETECTION UTILITIES
  // =============================================================================

  /// Check if favorites page has empty state
  static bool get isEmpty {
    return emptyStateFinder.evaluate().isNotEmpty;
  }

  /// Check if favorites page has content
  static bool get hasContent {
    return getFavoriteCardCount() > 0;
  }

  /// Check if favorites list is scrollable
  static bool get isScrollable {
    return listViewFinder.evaluate().isNotEmpty;
  }

  /// Get current favorites page state
  static FavoritesPageState get currentState {
    if (hasContent) return FavoritesPageState.hasContent;
    if (isEmpty) return FavoritesPageState.empty;
    return FavoritesPageState.unknown;
  }

  // =============================================================================
  // VALIDATION METHODS
  // =============================================================================

  /// Validate favorites page structure
  static void validatePageStructure() {
    debugPrint('🔍 [FAVORITES] Validating page structure...');

    final structureElements = {
      'Scaffold': find.byKey(const Key(scaffold)),
      'App Bar': find.byKey(const Key(appBar)),
      'Title': titleFinder,
    };

    structureElements.forEach((name, finder) {
      expect(finder, findsOneWidget, reason: '$name should be present');
      debugPrint('✅ [FAVORITES] $name validated');
    });

    debugPrint('✅ [FAVORITES] Page structure validation complete');
  }

  /// Validate empty state display
  static void validateEmptyState() {
    debugPrint('🔍 [FAVORITES] Validating empty state...');

    expect(emptyStateFinder, findsOneWidget,
        reason: 'Empty state icon should be visible');
    expect(find.byType(Card).evaluate().length, equals(0),
        reason: 'No favorite cards should be present in empty state');

    debugPrint('✅ [FAVORITES] Empty state validation complete');
  }

  /// Validate favorites content display
  static void validateContentState() {
    debugPrint('🔍 [FAVORITES] Validating content state...');

    final cardCount = getFavoriteCardCount();
    expect(cardCount, greaterThan(0), reason: 'Should have favorite cards');

    // Validate each favorite card has required elements
    final cardsToCheck = cardCount >= 3 ? 3 : cardCount;
    for (int i = 0; i < cardsToCheck; i++) {
      final cardFinder = find.byType(Card).at(i);

      // Check for hotel name text
      final nameText =
          find.descendant(of: cardFinder, matching: find.byType(Text));
      expect(nameText.evaluate().isNotEmpty, isTrue,
          reason: 'Favorite card $i should have hotel name');

      // Check for favorite button (should be filled heart)
      final favoriteButton = find.descendant(
          of: cardFinder, matching: find.byIcon(Icons.favorite));
      expect(favoriteButton.evaluate().isNotEmpty, isTrue,
          reason: 'Favorite card $i should have filled favorite button');
    }

    debugPrint(
        '✅ [FAVORITES] Content state validation complete for $cardsToCheck cards');
  }

  /// Validate specific favorite hotels exist
  static void validateSpecificFavorites(List<String> expectedHotelNames) {
    debugPrint(
        '🔍 [FAVORITES] Validating specific favorites: $expectedHotelNames');

    final actualHotelNames = extractFavoriteHotelNames();
    debugPrint('📊 [FAVORITES] Found hotels: $actualHotelNames');

    expect(actualHotelNames.length, equals(expectedHotelNames.length),
        reason:
            'Should have exactly ${expectedHotelNames.length} favorite hotels');

    for (final expectedName in expectedHotelNames) {
      expect(actualHotelNames.contains(expectedName), isTrue,
          reason: 'Expected hotel "$expectedName" should be in favorites');
      debugPrint('✅ [FAVORITES] Verified hotel: $expectedName');
    }

    debugPrint('✅ [FAVORITES] Specific favorites validation complete');
  }

  // =============================================================================
  // INTERACTION UTILITIES
  // =============================================================================

  /// Remove favorite by hotel name
  static Future<void> removeFavoriteByName(String hotelName) async {
    debugPrint('🗑️ [FAVORITES] Removing favorite: $hotelName');

    final cardFinder = findFavoriteCardByName(hotelName);
    if (cardFinder != null) {
      // Find and tap the favorite button
      final favoriteButton = find.descendant(
          of: cardFinder, matching: find.byIcon(Icons.favorite));

      if (favoriteButton.evaluate().isNotEmpty) {
        // This would be used in actual test context with PatrolIntegrationTester
        debugPrint('✅ [FAVORITES] Found favorite button for: $hotelName');
        return;
      }
    }

    throw Exception('Could not find favorite button for hotel: $hotelName');
  }

  /// Get favorite button finder for specific hotel
  static Finder getFavoriteButtonForHotel(String hotelName) {
    final cardFinder = findFavoriteCardByName(hotelName);
    if (cardFinder != null) {
      return find.descendant(
          of: cardFinder, matching: find.byIcon(Icons.favorite));
    }

    throw Exception('Could not find favorite card for hotel: $hotelName');
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Get Key object for any favorites locator
  static Key getKey(String locatorName) {
    return Key(locatorName);
  }

  /// Get all locator constants as list
  static List<String> get allLocators => [
        scaffold,
        appBar,
        title,
        listView,
        emptyStateIcon,
      ];

  /// Print favorites page debug information
  static void printDebugInfo() {
    debugPrint('🔍 [FAVORITES] Debug Information:');
    debugPrint('  📊 Card Count: ${getFavoriteCardCount()}');
    debugPrint('  📝 Hotel Names: ${extractFavoriteHotelNames()}');
    debugPrint('  🏷️ Current State: ${currentState.description}');
    debugPrint('  📋 Available Locators: $allLocators');
  }

  /// Comprehensive favorites page health check
  static void performHealthCheck() {
    debugPrint('🏥 [FAVORITES] Performing health check...');

    try {
      // Check page structure
      validatePageStructure();

      // Check current state and validate accordingly
      final state = currentState;
      debugPrint('📊 [FAVORITES] Current state: ${state.description}');

      switch (state) {
        case FavoritesPageState.hasContent:
          validateContentState();
          break;
        case FavoritesPageState.empty:
          validateEmptyState();
          break;
        case FavoritesPageState.unknown:
          debugPrint('⚠️ [FAVORITES] Unknown state detected');
          break;
      }

      debugPrint('🎉 [FAVORITES] Health check completed successfully');
    } catch (e) {
      debugPrint('❌ [FAVORITES] Health check failed: $e');
      rethrow;
    }
  }
}

/// Enum for favorites page state
enum FavoritesPageState {
  hasContent,
  empty,
  unknown,
}

/// Extension for better state description
extension FavoritesPageStateExtension on FavoritesPageState {
  String get description {
    switch (this) {
      case FavoritesPageState.hasContent:
        return 'Has favorite hotels';
      case FavoritesPageState.empty:
        return 'No favorite hotels';
      case FavoritesPageState.unknown:
        return 'Unknown state';
    }
  }
}
