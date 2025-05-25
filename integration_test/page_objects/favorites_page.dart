import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/app_locators.dart';
import '../locators/favorites_locators.dart';

/// Enhanced Favorites Page Object Model
/// Utilizes advanced locator system with fallback strategies
/// Comprehensive favorites management with detailed error handling
/// Optimized for integration testing scenarios
class FavoritesPage extends BasePage {
  FavoritesPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'favorites';

  @override
  String get pageKey => FavoritesLocators.scaffold;

  // =============================================================================
  // ENHANCED PAGE VERIFICATION METHODS
  // =============================================================================

  /// Comprehensive favorites page verification using enhanced locators
  Future<void> verifyFavoritesPageLoaded() async {
    logAction('Verifying favorites page with comprehensive locator system');

    try {
      await verifyPageIsLoaded();
      await _verifyEssentialPageElements();
      await _verifyPageFunctionality();

      logSuccess('Favorites page fully loaded and verified');
    } catch (e) {
      logError('Favorites page verification failed', e);
      await takeErrorScreenshot('page_verification_failed');
      rethrow;
    }
  }

  /// Verify essential page elements using FavoritesLocators
  Future<void> _verifyEssentialPageElements() async {
    logAction('Verifying essential favorites page elements');

    try {
      // Use FavoritesLocators validation methods
      FavoritesLocators.validatePageStructure();

      // Verify title using smart finder
      final titleFinder = FavoritesLocators.titleFinder;
      expect(titleFinder, findsOneWidget,
          reason: 'Favorites title should be visible');

      logSuccess(
          'All essential page elements verified using enhanced locators');
    } catch (e) {
      logError('Essential page elements verification failed', e);
      await takeErrorScreenshot('essential_elements_failed');
      rethrow;
    }
  }

  /// Verify page functionality based on current state
  Future<void> _verifyPageFunctionality() async {
    logAction('Verifying favorites page functionality');

    try {
      final currentState = FavoritesLocators.currentState;
      logAction('Current favorites state: ${currentState.description}');

      // State-specific verification
      switch (currentState) {
        case FavoritesPageState.hasContent:
          FavoritesLocators.validateContentState();
          break;
        case FavoritesPageState.empty:
          FavoritesLocators.validateEmptyState();
          break;
        case FavoritesPageState.unknown:
          logWarning('Favorites page in unknown state');
          break;
      }

      logSuccess(
          'Page functionality verified for state: ${currentState.description}');
    } catch (e) {
      logError('Page functionality verification failed', e);
      rethrow;
    }
  }

  // =============================================================================
  // ENHANCED STATE VERIFICATION METHODS
  // =============================================================================

  /// Verify empty favorites state using enhanced locators
  void verifyEmptyFavoritesState() {
    logAction('Verifying empty favorites state with enhanced validation');

    try {
      // Use FavoritesLocators for comprehensive validation
      expect(FavoritesLocators.isEmpty, isTrue,
          reason: 'Favorites should be in empty state');

      FavoritesLocators.validateEmptyState();

      // Additional verification
      verifyElementExists(FavoritesLocators.emptyStateIcon,
          description: 'Empty state icon');
      verifyElementNotExists(FavoritesLocators.listView,
          description: 'Favorites list view should not exist when empty');

      logSuccess('Empty favorites state verified');
    } catch (e) {
      logError('Empty favorites state verification failed', e);
      rethrow;
    }
  }

  /// Verify favorites list is visible and populated
  void verifyFavoritesListVisible() {
    logAction('Verifying favorites list visibility with enhanced validation');

    try {
      // Use FavoritesLocators for comprehensive validation
      expect(FavoritesLocators.hasContent, isTrue,
          reason: 'Favorites should have content');

      FavoritesLocators.validateContentState();

      // Additional verification
      verifyElementExists(FavoritesLocators.listView,
          description: 'Favorites list view');
      verifyElementNotExists(FavoritesLocators.emptyStateIcon,
          description:
              'Empty state icon should not exist when list has content');

      final cardCount = FavoritesLocators.getFavoriteCardCount();
      expect(cardCount, greaterThan(0),
          reason: 'Should have at least one favorite card');

      logSuccess('Favorites list visibility verified with $cardCount items');
    } catch (e) {
      logError('Favorites list visibility verification failed', e);
      rethrow;
    }
  }

  /// Verify specific favorite hotel exists using enhanced locators
  void verifyFavoriteHotelExists(String hotelId) {
    logAction('Verifying favorite hotel exists: $hotelId');

    try {
      final hotelCardKey = AppLocators.favoritesHotelCard(hotelId);
      verifyElementExists(hotelCardKey,
          description: 'Favorite hotel card: $hotelId');

      // Use FavoritesLocators to check if card exists
      expect(FavoritesLocators.favoriteCardExists(hotelId), isTrue,
          reason: 'Favorite hotel card should exist: $hotelId');

      logSuccess('Favorite hotel verified: $hotelId');
    } catch (e) {
      logError('Favorite hotel verification failed: $hotelId', e);
      rethrow;
    }
  }

  /// Verify favorite hotel details using enhanced locators
  void verifyFavoriteHotelDetails(String hotelId) {
    logAction('Verifying favorite hotel details: $hotelId');

    try {
      // Verify card exists
      verifyFavoriteHotelExists(hotelId);

      // Verify hotel name and favorite button
      verifyElementExists(AppLocators.hotelName(hotelId),
          description: 'Hotel name: $hotelId');
      verifyElementExists(AppLocators.hotelFavoriteButton(hotelId),
          description: 'Hotel favorite button: $hotelId');

      logSuccess('Favorite hotel details verified: $hotelId');
    } catch (e) {
      logError('Favorite hotel details verification failed: $hotelId', e);
      rethrow;
    }
  }

  // =============================================================================
  // ENHANCED FAVORITES MANAGEMENT OPERATIONS
  // =============================================================================

  /// Remove favorite hotel with comprehensive error handling
  Future<void> removeFavoriteHotel(String hotelId) async {
    logAction('Removing hotel from favorites with enhanced handling: $hotelId');

    try {
      await _ensureFavoriteCardVisible(hotelId);

      final favoriteButtonKey = AppLocators.hotelFavoriteButton(hotelId);

      // Try scrolling approach if list view is visible
      if (isElementVisible(AppLocators.favoritesListView)) {
        await _removeFavoriteWithScroll(hotelId, favoriteButtonKey);
      } else {
        await _removeFavoriteDirectly(favoriteButtonKey);
      }

      // Wait for state change and verify
      await $.pump(const Duration(milliseconds: 800));
      await _verifyHotelRemoved(hotelId);

      await takePageScreenshot('hotel_removed_from_favorites_$hotelId');
      logSuccess('Successfully removed hotel from favorites: $hotelId');
    } catch (e) {
      logError('Failed to remove hotel from favorites: $hotelId', e);
      await takeErrorScreenshot('remove_favorite_failed_$hotelId');
      rethrow;
    }
  }

  /// Ensure favorite card is visible for interaction
  Future<void> _ensureFavoriteCardVisible(String hotelId) async {
    if (!FavoritesLocators.favoriteCardExists(hotelId)) {
      // Try scrolling to find the card
      if (FavoritesLocators.isScrollable) {
        await scrollToElement(
          FavoritesLocators.listView,
          AppLocators.favoritesHotelCard(hotelId),
          maxScrolls: 5,
          description: 'Favorite hotel card: $hotelId',
        );
      }
    }
  }

  /// Remove favorite using scroll approach
  Future<void> _removeFavoriteWithScroll(
      String hotelId, String favoriteButtonKey) async {
    await $(Key(favoriteButtonKey))
        .scrollTo(view: $(Key(AppLocators.favoritesListView)))
        .tap();
  }

  /// Remove favorite directly
  Future<void> _removeFavoriteDirectly(String favoriteButtonKey) async {
    await tapElement(favoriteButtonKey, description: 'Favorite button');
  }

  /// Verify hotel was actually removed
  Future<void> _verifyHotelRemoved(String hotelId) async {
    await $.pump(const Duration(milliseconds: 500));

    // Card should no longer exist
    expect(FavoritesLocators.favoriteCardExists(hotelId), isFalse,
        reason: 'Hotel card should be removed: $hotelId');
  }

  /// Add favorite hotel with comprehensive error handling
  Future<void> addFavoriteHotel(String hotelId) async {
    logAction('Adding hotel to favorites with enhanced handling: $hotelId');

    try {
      final favoriteButtonKey = AppLocators.hotelFavoriteButton(hotelId);

      // Try scrolling approach if list view is visible
      if (isElementVisible(AppLocators.favoritesListView)) {
        await _addFavoriteWithScroll(hotelId, favoriteButtonKey);
      } else {
        await _addFavoriteDirectly(favoriteButtonKey);
      }

      // Wait for state change and verify
      await $.pump(const Duration(milliseconds: 800));
      await _verifyHotelAdded(hotelId);

      await takePageScreenshot('hotel_added_to_favorites_$hotelId');
      logSuccess('Successfully added hotel to favorites: $hotelId');
    } catch (e) {
      logError('Failed to add hotel to favorites: $hotelId', e);
      await takeErrorScreenshot('add_favorite_failed_$hotelId');
      rethrow;
    }
  }

  /// Add favorite using scroll approach
  Future<void> _addFavoriteWithScroll(
      String hotelId, String favoriteButtonKey) async {
    await $(Key(favoriteButtonKey))
        .scrollTo(view: $(Key(AppLocators.favoritesListView)))
        .tap();
  }

  /// Add favorite directly
  Future<void> _addFavoriteDirectly(String favoriteButtonKey) async {
    await tapElement(favoriteButtonKey, description: 'Favorite button');
  }

  /// Verify hotel was actually added
  Future<void> _verifyHotelAdded(String hotelId) async {
    await $.pump(const Duration(milliseconds: 500));

    // Card should now exist
    expect(FavoritesLocators.favoriteCardExists(hotelId), isTrue,
        reason: 'Hotel card should be added: $hotelId');
  }

  // =============================================================================
  // ENHANCED FAVORITES COUNT AND ANALYSIS
  // =============================================================================

  /// Get favorite hotels count with enhanced error handling
  Future<int> getFavoriteHotelsCount() async {
    logAction('Getting favorite hotels count with enhanced validation');

    try {
      final count = FavoritesLocators.getFavoriteCardCount();

      if (count == 0) {
        // Verify empty state is correct
        expect(FavoritesLocators.isEmpty, isTrue,
            reason: 'Should show empty state when count is 0');
        logAction('No favorites list visible, count is 0');
      } else {
        // Verify content state is correct
        expect(FavoritesLocators.hasContent, isTrue,
            reason: 'Should show content when count > 0');
        logAction('Favorites list has $count items');
      }

      await $.pump(const Duration(milliseconds: 500));
      return count;
    } catch (e) {
      logError('Failed to get favorite hotels count', e);
      return 0;
    }
  }

  /// Get detailed favorite hotels information
  Future<FavoritesAnalysis> analyzeFavorites() async {
    logAction('Analyzing favorites with detailed information');

    try {
      final count = await getFavoriteHotelsCount();
      final hotelNames = FavoritesLocators.extractFavoriteHotelNames();
      final currentState = FavoritesLocators.currentState;

      final analysis = FavoritesAnalysis(
        totalCount: count,
        hotelNames: hotelNames,
        state: currentState,
        isScrollable: FavoritesLocators.isScrollable,
      );

      logSuccess('Favorites analysis completed: ${analysis.toString()}');
      return analysis;
    } catch (e) {
      logError('Favorites analysis failed', e);
      return FavoritesAnalysis.empty();
    }
  }

  // =============================================================================
  // ENHANCED SCROLLING AND NAVIGATION
  // =============================================================================

  /// Scroll through favorites with comprehensive validation
  Future<void> scrollThroughFavorites() async {
    logAction('Scrolling through favorites list with enhanced validation');

    try {
      if (!FavoritesLocators.isScrollable) {
        logAction('Favorites list is not scrollable or not visible');
        return;
      }

      // Use enhanced scrolling from base page
      final listViewFinder = FavoritesLocators.listViewFinder;
      if (listViewFinder.evaluate().isNotEmpty) {
        await $(listViewFinder.first).scrollTo(maxScrolls: 3);
        await $.pumpAndSettle();

        logSuccess('Favorites list scrolling completed and functional');
        await takePageScreenshot('favorites_scrolled');
      } else {
        logWarning('Favorites list view not found for scrolling');
      }
    } catch (e) {
      logError('Favorites scrolling failed', e);
      await takeErrorScreenshot('favorites_scroll_failed');
      rethrow;
    }
  }

  // =============================================================================
  // ENHANCED TITLE AND BRANDING VERIFICATION
  // =============================================================================

  /// Verify favorites title using enhanced locators
  void verifyFavoritesTitle() {
    logAction('Verifying favorites page title with enhanced validation');

    try {
      // Use smart title finder from FavoritesLocators
      final titleFinder = FavoritesLocators.titleFinder;
      expect(titleFinder, findsOneWidget,
          reason: 'Favorites title should be visible');

      // Verify specific text content
      verifyTextExists('Your Favorite Hotels',
          description: 'Favorites page title text');

      // Additional validation using locators
      verifyElementExists(FavoritesLocators.title,
          description: 'Favorites title element');

      logSuccess('Favorites title verified successfully');
    } catch (e) {
      logError('Favorites title verification failed', e);
      rethrow;
    }
  }

  // =============================================================================
  // BULK OPERATIONS WITH ENHANCED ERROR HANDLING
  // =============================================================================

  /// Clear all favorites with comprehensive tracking
  Future<void> clearAllFavorites(List<String> hotelIds) async {
    logAction(
        'Clearing all favorites with enhanced tracking: ${hotelIds.length} hotels');

    try {
      int removedCount = 0;
      final initialCount = await getFavoriteHotelsCount();

      for (final hotelId in hotelIds) {
        if (FavoritesLocators.favoriteCardExists(hotelId)) {
          await removeFavoriteHotel(hotelId);
          removedCount++;
          await $.pump(const Duration(milliseconds: 400));

          logAction(
              'Removed favorite $removedCount/${hotelIds.length}: $hotelId');
        } else {
          logWarning('Hotel not found in favorites: $hotelId');
        }
      }

      // Verify final state
      await _verifyFavoritesClearingResult(initialCount, removedCount);

      await takePageScreenshot('all_favorites_cleared');
      logSuccess('Successfully cleared $removedCount favorites');
    } catch (e) {
      logError('Failed to clear all favorites', e);
      await takeErrorScreenshot('clear_favorites_failed');
      rethrow;
    }
  }

  /// Verify favorites clearing result
  Future<void> _verifyFavoritesClearingResult(
      int initialCount, int removedCount) async {
    final finalCount = await getFavoriteHotelsCount();
    final expectedCount = initialCount - removedCount;

    expect(finalCount, equals(expectedCount),
        reason: 'Final count should match expected after clearing');

    if (finalCount == 0) {
      verifyEmptyFavoritesState();
    }
  }

  // =============================================================================
  // COMPREHENSIVE TEST WORKFLOWS
  // =============================================================================

  /// Verify favorites list functionality with comprehensive validation
  Future<void> verifyFavoritesListFunctionality() async {
    logAction(
        'Verifying favorites list functionality with comprehensive checks');

    try {
      await verifyFavoritesPageLoaded();

      final currentState = FavoritesLocators.currentState;
      logAction('Current favorites state: ${currentState.description}');

      switch (currentState) {
        case FavoritesPageState.empty:
          logAction('Favorites list is empty - verifying empty state');
          verifyEmptyFavoritesState();
          break;

        case FavoritesPageState.hasContent:
          logAction('Favorites list has items - verifying content state');
          verifyFavoritesListVisible();
          await scrollThroughFavorites();

          // Perform detailed analysis
          final analysis = await analyzeFavorites();
          logAction('Favorites analysis: ${analysis.toString()}');
          break;

        case FavoritesPageState.unknown:
          logWarning(
              'Favorites in unknown state - attempting basic verification');
          break;
      }

      await takePageScreenshot('favorites_functionality_verified');
      logSuccess('Favorites list functionality verification completed');
    } catch (e) {
      logError('Favorites list functionality verification failed', e);
      await takeErrorScreenshot('favorites_functionality_failed');
      rethrow;
    }
  }

  /// Test favorites management workflow with comprehensive validation
  Future<void> testFavoritesManagement(List<String> hotelIds) async {
    logAction('Testing favorites management workflow with enhanced validation');

    try {
      await verifyFavoritesPageLoaded();

      final initialAnalysis = await analyzeFavorites();
      logAction('Initial state: ${initialAnalysis.toString()}');

      // Remove specified hotels
      int processedCount = 0;
      for (final hotelId in hotelIds) {
        if (FavoritesLocators.favoriteCardExists(hotelId)) {
          await removeFavoriteHotel(hotelId);
          processedCount++;
          await $.pump(const Duration(milliseconds: 600));

          logAction(
              'Processed hotel $processedCount/${hotelIds.length}: $hotelId');
        }
      }

      // Verify final state
      await $.pump(const Duration(seconds: 1));
      final finalAnalysis = await analyzeFavorites();
      logAction('Final state: ${finalAnalysis.toString()}');

      // Validate management workflow result
      expect(finalAnalysis.totalCount,
          equals(initialAnalysis.totalCount - processedCount),
          reason: 'Final count should reflect removed hotels');

      await takePageScreenshot('favorites_management_complete');
      logSuccess('Favorites management workflow completed successfully');
    } catch (e) {
      logError('Favorites management workflow failed', e);
      await takeErrorScreenshot('favorites_management_failed');
      rethrow;
    }
  }

  /// Take comprehensive favorites screenshots with detailed context
  Future<void> takeFavoritesScreenshots() async {
    logAction('Taking comprehensive favorites screenshots with context');

    try {
      await takePageScreenshot('favorites_initial_state');

      final currentState = FavoritesLocators.currentState;

      switch (currentState) {
        case FavoritesPageState.hasContent:
          await scrollThroughFavorites();
          await takePageScreenshot('favorites_with_items');

          // Take detailed analysis screenshot
          final analysis = await analyzeFavorites();
          await takePageScreenshot(
              'favorites_analysis_${analysis.totalCount}_items');
          break;

        case FavoritesPageState.empty:
          await takePageScreenshot('favorites_empty_state');
          break;

        case FavoritesPageState.unknown:
          await takePageScreenshot('favorites_unknown_state');
          break;
      }

      logSuccess('Comprehensive favorites screenshots completed');
    } catch (e) {
      logError('Failed to take comprehensive screenshots', e);
    }
  }

  /// Perform comprehensive favorites health check
  Future<void> performFavoritesHealthCheck() async {
    logAction('Performing comprehensive favorites health check');

    try {
      // Use FavoritesLocators health check
      FavoritesLocators.performHealthCheck();

      // Additional page-specific checks
      await verifyFavoritesPageLoaded();
      await verifyFavoritesListFunctionality();

      // Debug information
      FavoritesLocators.printDebugInfo();

      await takePageScreenshot('favorites_health_check_complete');
      logSuccess('Favorites health check completed successfully');
    } catch (e) {
      logError('Favorites health check failed', e);
      await takeErrorScreenshot('favorites_health_check_failed');
      rethrow;
    }
  }
}

// =============================================================================
// SUPPORTING DATA CLASSES
// =============================================================================

/// Comprehensive favorites analysis result
class FavoritesAnalysis {
  final int totalCount;
  final List<String> hotelNames;
  final FavoritesPageState state;
  final bool isScrollable;

  FavoritesAnalysis({
    required this.totalCount,
    required this.hotelNames,
    required this.state,
    required this.isScrollable,
  });

  FavoritesAnalysis.empty()
      : totalCount = 0,
        hotelNames = [],
        state = FavoritesPageState.empty,
        isScrollable = false;

  bool get hasContent => totalCount > 0;
  bool get isEmpty => totalCount == 0;

  @override
  String toString() {
    return 'FavoritesAnalysis(count: $totalCount, state: ${state.description}, scrollable: $isScrollable, hotels: ${hotelNames.length})';
  }
}
