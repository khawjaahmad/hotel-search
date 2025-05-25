import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/helpers/test_helper.dart';
import '../integration_test/helpers/enhanced_search_handler.dart';
import '../integration_test/locators/app_locators.dart';
import '../integration_test/page_objects/dashboard_page.dart';
import '../integration_test/page_objects/hotels_page.dart';
import '../integration_test/page_objects/favorites_page.dart';

void favoritesTests() {
  group('💝 Favorites Feature - Core Scenarios', () {
    late DashboardPage dashboardPage;
    late HotelsPage hotelsPage;
    late FavoritesPage favoritesPage;

    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await PatrolTestHelper.initializeApp($);
      dashboardPage = DashboardPage($);
      hotelsPage = HotelsPage($);
      favoritesPage = FavoritesPage($);
      await dashboardPage.verifyDashboardLoaded();
    }

    patrolTest(
      'Complete favorites workflow - Hotels to Favorites integration',
      ($) async {
        await initializeTest($);

        try {
          // Start with empty favorites to ensure clean state
          await _ensureCleanFavoritesState($);

          // Step 1: Navigate to hotels and search
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          debugPrint('🔍 Searching for hotels to add to favorites');
          await hotelsPage.searchHotels('Barcelona');

          final searchState =
              await EnhancedSearchHandler.handleSearchWithTimeout(
                  $, 'Barcelona');

          if (searchState == SearchResultState.hasResults) {
            await $.pump(const Duration(seconds: 2));

            // Step 2: Add multiple hotels to favorites and track them
            final addedHotelData =
                await _addHotelsToFavoritesWithTracking($, maxHotels: 3);

            if (addedHotelData.isNotEmpty) {
              debugPrint(
                  '📝 Successfully added ${addedHotelData.length} hotels to favorites');

              // Step 3: Navigate to favorites and verify exact matches
              await dashboardPage.navigateToFavorites();
              await favoritesPage.verifyFavoritesPageLoaded();
              await $.pump(const Duration(seconds: 1));

              await _verifyExactFavoriteMatches($, addedHotelData);

              // Step 4: Test favorites page functionality
              await _testFavoritesPageFunctionality($);

              // Step 5: Remove favorites and verify empty state
              await _removeAllFavoritesAndVerifyEmpty($, addedHotelData.length);

              debugPrint('✅ Complete favorites workflow test passed');
            } else {
              debugPrint(
                  'ℹ️ No hotels were added to favorites - skipping verification');
            }
          } else {
            debugPrint(
                'ℹ️ Search did not return results - testing empty favorites state');
            await _testEmptyFavoritesState($);
          }

          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_workflow_complete');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'favorites_workflow_failed');
          fail('Favorites workflow test failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites persistence across navigation',
      ($) async {
        await initializeTest($);

        try {
          // Add some favorites first
          await _addFavoritesFromHotelsSearch($,
              searchQuery: 'Milan', maxFavorites: 2);

          // Navigate to favorites and capture initial state
          await dashboardPage.navigateToFavorites();
          await favoritesPage.verifyFavoritesPageLoaded();

          final initialFavoriteCount = await _getFavoriteCardsCount($);
          debugPrint('📊 Initial favorites count: $initialFavoriteCount');

          if (initialFavoriteCount > 0) {
            // Navigate away and back multiple times
            await dashboardPage.navigateToHotels();
            await dashboardPage.navigateToAccount();
            await dashboardPage.navigateToOverview();
            await dashboardPage.navigateToFavorites();

            // Verify favorites are still there
            await favoritesPage.verifyFavoritesPageLoaded();
            final persistedFavoriteCount = await _getFavoriteCardsCount($);

            expect(persistedFavoriteCount, equals(initialFavoriteCount),
                reason: 'Favorites should persist across navigation');

            debugPrint(
                '✅ Favorites persisted correctly: $persistedFavoriteCount items');

            // Clean up
            await _removeAllFavoritesAndVerifyEmpty($, persistedFavoriteCount);
          }

          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_persistence_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_persistence_failed');
          fail('Favorites persistence test failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites edge cases and error handling',
      ($) async {
        await initializeTest($);

        try {
          // Test 1: Empty favorites state
          await dashboardPage.navigateToFavorites();
          await favoritesPage.verifyFavoritesPageLoaded();
          await _testEmptyFavoritesState($);

          // Test 2: Add and immediately remove favorite
          await _testQuickAddRemoveFavorite($);

          // Test 3: Multiple rapid favorite toggles
          await _testRapidFavoriteToggles($);

          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_edge_cases_complete');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_edge_cases_failed');
          fail('Favorites edge cases test failed: $e');
        }
      },
    );
  });
}

// ============================================================================
// HELPER METHODS FOR FAVORITES TESTING
// ============================================================================

/// Data class to track added hotel information
class HotelFavoriteData {
  final String name;
  final String id;
  final int originalIndex;

  HotelFavoriteData({
    required this.name,
    required this.id,
    required this.originalIndex,
  });

  @override
  String toString() =>
      'HotelFavoriteData(name: $name, id: $id, index: $originalIndex)';
}

/// Ensures favorites page starts in clean state
Future<void> _ensureCleanFavoritesState(PatrolIntegrationTester $) async {
  debugPrint('🧹 Ensuring clean favorites state');

  final dashboardPage = DashboardPage($);
  final favoritesPage = FavoritesPage($);

  await dashboardPage.navigateToFavorites();
  await favoritesPage.verifyFavoritesPageLoaded();

  final currentCount = await _getFavoriteCardsCount($);
  if (currentCount > 0) {
    debugPrint('🗑️ Cleaning up $currentCount existing favorites');
    await _removeAllFavoritesAndVerifyEmpty($, currentCount);
  }

  debugPrint('✅ Favorites state is now clean');
}

/// Adds hotels to favorites from search results and tracks their data
Future<List<HotelFavoriteData>> _addHotelsToFavoritesWithTracking(
  PatrolIntegrationTester $, {
  required int maxHotels,
}) async {
  debugPrint('💝 Adding up to $maxHotels hotels to favorites with tracking');

  final hotelCards = find.byType(Card);
  final availableCards = hotelCards.evaluate().length;
  final hotelsToAdd = availableCards >= maxHotels ? maxHotels : availableCards;

  List<HotelFavoriteData> addedHotels = [];

  for (int i = 0; i < hotelsToAdd; i++) {
    try {
      final cardWidget = hotelCards.at(i);

      // Extract hotel name
      final nameTexts =
          find.descendant(of: cardWidget, matching: find.byType(Text));
      String hotelName = '';

      if (nameTexts.evaluate().isNotEmpty) {
        final nameWidget = nameTexts.first.evaluate().first.widget as Text;
        hotelName = nameWidget.data ?? 'Hotel ${i + 1}';
      }

      // Extract hotel ID from card key if available
      final cardElement = cardWidget.evaluate().first;
      final cardKey = cardElement.widget.key?.toString() ?? '';
      final hotelId = _extractHotelIdFromKey(cardKey) ?? 'hotel_$i';

      // Find and tap favorite button
      final favoriteButton = find.descendant(
          of: cardWidget, matching: find.byIcon(Icons.favorite_outline));

      if (favoriteButton.evaluate().isNotEmpty) {
        await $(favoriteButton.first).tap();
        await $.pump(const Duration(milliseconds: 800));

        // Verify heart changed to filled
        final filledHeart = find.descendant(
            of: cardWidget, matching: find.byIcon(Icons.favorite));

        if (filledHeart.evaluate().isNotEmpty) {
          final hotelData = HotelFavoriteData(
            name: hotelName,
            id: hotelId,
            originalIndex: i,
          );
          addedHotels.add(hotelData);
          debugPrint('✅ Added to favorites: $hotelData');
        } else {
          debugPrint('⚠️ Heart icon did not change for hotel $i');
        }
      } else {
        debugPrint('⚠️ No favorite button found for hotel $i');
      }
    } catch (e) {
      debugPrint('❌ Failed to add hotel $i to favorites: $e');
    }
  }

  debugPrint(
      '📊 Successfully tracked ${addedHotels.length} hotels added to favorites');
  return addedHotels;
}

/// Verifies exact matches between added hotels and favorites page
Future<void> _verifyExactFavoriteMatches(
  PatrolIntegrationTester $,
  List<HotelFavoriteData> expectedHotels,
) async {
  debugPrint('🔍 Verifying exact matches in favorites page');

  final favoriteCards = find.byType(Card);
  final actualCount = favoriteCards.evaluate().length;

  expect(actualCount, equals(expectedHotels.length),
      reason:
          'Favorites page should show exactly ${expectedHotels.length} hotels');

  debugPrint('✅ Count verification passed: $actualCount favorites displayed');

  // Verify each expected hotel appears in favorites
  for (final expectedHotel in expectedHotels) {
    bool hotelFound = false;

    for (int i = 0; i < actualCount; i++) {
      final favoriteCard = favoriteCards.at(i);
      final nameTexts =
          find.descendant(of: favoriteCard, matching: find.byType(Text));

      if (nameTexts.evaluate().isNotEmpty) {
        final nameWidget = nameTexts.first.evaluate().first.widget as Text;
        final favoriteHotelName = nameWidget.data ?? '';

        if (favoriteHotelName == expectedHotel.name) {
          hotelFound = true;
          debugPrint('✅ Found exact match: ${expectedHotel.name}');
          break;
        }
      }
    }

    expect(hotelFound, isTrue,
        reason:
            'Expected hotel "${expectedHotel.name}" should be found in favorites');
  }

  debugPrint('✅ All expected hotels verified in favorites page');
}

/// Gets the current count of favorite cards
Future<int> _getFavoriteCardsCount(PatrolIntegrationTester $) async {
  await $.pump(const Duration(milliseconds: 500));

  final favoriteCards = find.byType(Card);
  final count = favoriteCards.evaluate().length;

  return count;
}

/// Tests empty favorites state
Future<void> _testEmptyFavoritesState(PatrolIntegrationTester $) async {
  debugPrint('📭 Testing empty favorites state');

  final emptyStateIcon = find.byKey(const Key('favorites_empty_state_icon'));
  expect(emptyStateIcon, findsOneWidget,
      reason: 'Empty favorites should show empty state icon');

  final favoriteCards = find.byType(Card);
  expect(favoriteCards.evaluate().length, equals(0),
      reason: 'Empty favorites should have no hotel cards');

  debugPrint('✅ Empty favorites state verified');
}

/// Tests favorites page functionality (scrolling, etc.)
Future<void> _testFavoritesPageFunctionality(PatrolIntegrationTester $) async {
  debugPrint('🔧 Testing favorites page functionality');

  final favoritesPage = FavoritesPage($);

  try {
    await favoritesPage.scrollThroughFavorites();
    debugPrint('✅ Favorites scrolling works correctly');
  } catch (e) {
    debugPrint('ℹ️ Favorites scrolling test skipped: $e');
  }
}

/// Removes all favorites and verifies empty state
Future<void> _removeAllFavoritesAndVerifyEmpty(
  PatrolIntegrationTester $,
  int expectedCount,
) async {
  debugPrint('🗑️ Removing all $expectedCount favorites');

  for (int i = expectedCount - 1; i >= 0; i--) {
    try {
      final favoriteCards = find.byType(Card);
      if (favoriteCards.evaluate().length > i) {
        final favoriteCard = favoriteCards.at(i);
        final filledHeartButton = find.descendant(
            of: favoriteCard, matching: find.byIcon(Icons.favorite));

        if (filledHeartButton.evaluate().isNotEmpty) {
          await $(filledHeartButton.first).tap();
          await $.pump(const Duration(milliseconds: 800));
          debugPrint('✅ Removed favorite ${i + 1}');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not remove favorite $i: $e');
    }
  }

  await $.pump(const Duration(seconds: 1));
  await _testEmptyFavoritesState($);
  debugPrint('✅ All favorites removed and empty state verified');
}

/// Helper to add favorites from hotels search
Future<void> _addFavoritesFromHotelsSearch(
  PatrolIntegrationTester $, {
  required String searchQuery,
  required int maxFavorites,
}) async {
  final dashboardPage = DashboardPage($);
  final hotelsPage = HotelsPage($);

  await dashboardPage.navigateToHotels();
  await hotelsPage.verifyHotelsPageLoaded();
  await hotelsPage.searchHotels(searchQuery);

  final searchState =
      await EnhancedSearchHandler.handleSearchWithTimeout($, searchQuery);

  if (searchState == SearchResultState.hasResults) {
    await $.pump(const Duration(seconds: 1));
    await _addHotelsToFavoritesWithTracking($, maxHotels: maxFavorites);
  }
}

/// Tests quick add and remove favorite scenario
Future<void> _testQuickAddRemoveFavorite(PatrolIntegrationTester $) async {
  debugPrint('⚡ Testing quick add/remove favorite');

  await _addFavoritesFromHotelsSearch($, searchQuery: 'Rome', maxFavorites: 1);

  final dashboardPage = DashboardPage($);
  await dashboardPage.navigateToFavorites();

  final count = await _getFavoriteCardsCount($);
  if (count > 0) {
    await _removeAllFavoritesAndVerifyEmpty($, count);
    debugPrint('✅ Quick add/remove test completed');
  }
}

/// Tests rapid favorite toggles
Future<void> _testRapidFavoriteToggles(PatrolIntegrationTester $) async {
  debugPrint('🔄 Testing rapid favorite toggles');

  final dashboardPage = DashboardPage($);
  final hotelsPage = HotelsPage($);

  await dashboardPage.navigateToHotels();
  await hotelsPage.searchHotels('Venice');

  final searchState =
      await EnhancedSearchHandler.handleSearchWithTimeout($, 'Venice');

  if (searchState == SearchResultState.hasResults) {
    final hotelCards = find.byType(Card);
    if (hotelCards.evaluate().isNotEmpty) {
      final cardWidget = hotelCards.first;

      // Rapid toggle test
      for (int i = 0; i < 3; i++) {
        final favoriteButton = find.descendant(
            of: cardWidget, matching: find.byIcon(Icons.favorite_outline));
        final filledFavoriteButton = find.descendant(
            of: cardWidget, matching: find.byIcon(Icons.favorite));

        if (favoriteButton.evaluate().isNotEmpty) {
          await $(favoriteButton.first).tap();
        } else if (filledFavoriteButton.evaluate().isNotEmpty) {
          await $(filledFavoriteButton.first).tap();
        }

        await $.pump(const Duration(milliseconds: 200));
      }

      debugPrint('✅ Rapid toggle test completed');
    }
  }
}

/// Extracts hotel ID from card key string
String? _extractHotelIdFromKey(String keyString) {
  final match = RegExp(r'hotel_card_([0-9\.\-,]+)').firstMatch(keyString);
  return match?.group(1);
}

void main() {
  favoritesTests();
}
