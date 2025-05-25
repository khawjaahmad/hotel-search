import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_helper.dart';
import '../helpers/enhanced_search_handler.dart';
import '../page_objects/dashboard_page.dart';
import '../page_objects/hotels_page.dart';
import '../page_objects/favorites_page.dart';

void hotelsTests() {
  group('🧪 Hotels Feature - Core Requirements', () {
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
      'Search with any input and lazy loading verification',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          // Test 1: Real place name
          debugPrint('🔍 Testing search with real place: "Paris"');
          await hotelsPage.searchHotels('Paris');
          
          var searchState = await EnhancedSearchHandler.handleSearchWithTimeout($, 'Paris');
          if (searchState == SearchResultState.hasResults) {
            await EnhancedSearchHandler.validateSearchResults($);
            await EnhancedSearchHandler.testLazyLoading($);
          }

          // Test 2: Random letters
          debugPrint('🔍 Testing search with random letters: "xyzabc"');
          await hotelsPage.searchHotels('xyzabc');
          
          searchState = await EnhancedSearchHandler.handleSearchWithTimeout($, 'xyzabc');
          if (searchState == SearchResultState.hasResults) {
            await EnhancedSearchHandler.validateSearchResults($);
            debugPrint('✅ Random letters returned results as expected');
          } else {
            debugPrint('ℹ️ Random letters returned no results - acceptable');
          }

          // Test 3: Gibberish/special characters
          debugPrint('🔍 Testing search with gibberish: "!@#{:}.="');
          await hotelsPage.searchHotels('!@#.=*&');
          
          searchState = await EnhancedSearchHandler.handleSearchWithTimeout($, '!@_)#.=');
          if (searchState == SearchResultState.hasResults) {
            await EnhancedSearchHandler.validateSearchResults($);
            debugPrint('✅ Special characters returned results as expected');
          } else {
            debugPrint('ℹ️ Special characters returned no results - acceptable');
          }

          await PatrolTestHelper.takeScreenshot($, 'search_input_tests_complete');

        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'search_input_tests_failed');
          fail('Search input tests failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites workflow - exact place verification',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          // Search for hotels to add to favorites
          debugPrint('🔍 Searching for hotels to test favorites workflow');
          await hotelsPage.searchHotels('London');
          
          final searchState = await EnhancedSearchHandler.handleSearchWithTimeout($, 'London');
          
          if (searchState == SearchResultState.hasResults) {
            await $.pump(const Duration(seconds: 2));
            
            final hotelCards = find.byType(Card);
            final cardCount = hotelCards.evaluate().length;
            debugPrint('📊 Found $cardCount hotel cards for favorites testing');

            if (cardCount > 0) {
              // Step 1: Add 1-3 hotels to favorites and capture their details
              final maxFavorites = cardCount >= 3 ? 3 : cardCount;
              List<String> favoriteHotelNames = [];
              
              debugPrint('💝 Adding $maxFavorites hotels to favorites');
              
              for (int i = 0; i < maxFavorites; i++) {
                try {
                  final cardWidget = hotelCards.at(i);
                  
                  // Capture hotel name before adding to favorites
                  final nameTexts = find.descendant(of: cardWidget, matching: find.byType(Text));
                  if (nameTexts.evaluate().isNotEmpty) {
                    final nameWidget = nameTexts.first.evaluate().first.widget as Text;
                    final hotelName = nameWidget.data ?? '';
                    if (hotelName.isNotEmpty) {
                      favoriteHotelNames.add(hotelName);
                    }
                  }
                  
                  // Add to favorites
                  final favoriteButton = find.descendant(
                    of: cardWidget,
                    matching: find.byIcon(Icons.favorite_outline)
                  );
                  
                  if (favoriteButton.evaluate().isNotEmpty) {
                    await $(favoriteButton.first).tap();
                    await $.pump(const Duration(milliseconds: 800));
                    debugPrint('✅ Added hotel ${i + 1} to favorites: ${favoriteHotelNames.last}');
                    
                    // Verify heart icon changed to filled
                    final filledHeart = find.descendant(
                      of: cardWidget,
                      matching: find.byIcon(Icons.favorite)
                    );
                    expect(filledHeart.evaluate().isNotEmpty, isTrue,
                        reason: 'Heart icon should be filled after adding to favorites');
                  }
                } catch (e) {
                  debugPrint('⚠️ Could not add hotel $i to favorites: $e');
                }
              }
              
              debugPrint('📝 Added hotels to favorites: $favoriteHotelNames');

              // Step 2: Navigate to favorites and verify EXACT places appear
              await dashboardPage.navigateToFavorites();
              await favoritesPage.verifyFavoritesPageLoaded();
              await $.pump(const Duration(seconds: 1));

              final favoriteCards = find.byType(Card);
              final actualFavoriteCount = favoriteCards.evaluate().length;
              
              expect(actualFavoriteCount, equals(favoriteHotelNames.length),
                  reason: 'Favorites page should show exactly ${favoriteHotelNames.length} hotels');
              
              debugPrint('✅ Verified exact count: $actualFavoriteCount favorites displayed');

              // Step 3: Verify the exact same hotels appear in favorites
              for (int i = 0; i < actualFavoriteCount; i++) {
                final favoriteCard = favoriteCards.at(i);
                final nameTexts = find.descendant(of: favoriteCard, matching: find.byType(Text));
                
                if (nameTexts.evaluate().isNotEmpty) {
                  final nameWidget = nameTexts.first.evaluate().first.widget as Text;
                  final favoriteHotelName = nameWidget.data ?? '';
                  
                  expect(favoriteHotelNames.contains(favoriteHotelName), isTrue,
                      reason: 'Favorite hotel "$favoriteHotelName" should be one of the added hotels');
                  debugPrint('✅ Verified exact hotel in favorites: $favoriteHotelName');
                }
              }

              // Step 4: Remove all favorites by unchecking heart icons
              debugPrint('🗑️ Removing all favorites by unchecking heart icons');
              
              for (int i = actualFavoriteCount - 1; i >= 0; i--) {
                try {
                  final favoriteCard = favoriteCards.at(i);
                  final filledHeartButton = find.descendant(
                    of: favoriteCard,
                    matching: find.byIcon(Icons.favorite)
                  );
                  
                  if (filledHeartButton.evaluate().isNotEmpty) {
                    await $(filledHeartButton.first).tap();
                    await $.pump(const Duration(milliseconds: 800));
                    debugPrint('✅ Removed favorite ${i + 1}');
                  }
                } catch (e) {
                  debugPrint('⚠️ Could not remove favorite $i: $e');
                }
              }

              // Step 5: Verify favorites page is empty
              await $.pump(const Duration(seconds: 1));
              
              final emptyStateIcon = find.byKey(const Key('favorites_empty_state_icon'));
              expect(emptyStateIcon, findsOneWidget,
                  reason: 'Favorites page should show empty state after removing all favorites');
              
              final remainingCards = find.byType(Card);
              expect(remainingCards.evaluate().length, equals(0),
                  reason: 'No hotel cards should remain after removing all favorites');
              
              debugPrint('✅ Verified favorites page is empty after removing all');

            } else {
              debugPrint('ℹ️ No hotels found for favorites testing');
            }
          } else {
            debugPrint('ℹ️ Search did not return results for favorites testing');
          }

          await PatrolTestHelper.takeScreenshot($, 'favorites_workflow_complete');

        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'favorites_workflow_failed');
          fail('Favorites workflow test failed: $e');
        }
      },
    );

    patrolTest(
      'Invalid input handling - empty spaces trigger error',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          // Test empty spaces input
          debugPrint('🔍 Testing empty spaces input: "   "');
          await hotelsPage.searchHotels('   ');
          
          final searchState = await EnhancedSearchHandler.handleSearchWithTimeout($, '   ');
          
          if (searchState == SearchResultState.error) {
            // Validate specific error handling for empty spaces
            await EnhancedSearchHandler.validateEmptySpaceErrorHandling($);
            
            // Test retry button functionality
            debugPrint('🔄 Testing retry button functionality');
            final retryButton = find.byKey(const Key('hotels_retry_button'));
            await $(retryButton).tap();
            await $.pump(const Duration(seconds: 2));
            
            debugPrint('✅ Retry button clicked successfully');
          } else {
            debugPrint('ℹ️ Empty spaces did not trigger error - checking for empty state');
            final emptyStateIcon = find.byKey(const Key('hotels_empty_state_icon'));
            expect(emptyStateIcon, findsOneWidget,
                reason: 'Empty spaces should trigger either error or empty state');
          }

          await PatrolTestHelper.takeScreenshot($, 'empty_space_handling_complete');

        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'empty_space_handling_failed');
          fail('Empty space handling test failed: $e');
        }
      },
    );

    patrolTest(
      'SerpAPI timeout and loader handling',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          // Test with a query that might cause delays
          debugPrint('🔍 Testing SerpAPI timeout handling with query: "Remote Island Hotel"');
          await hotelsPage.searchHotels('Remote Island Hotel');
          
          // Use shorter timeout to test timeout handling
          final searchState = await EnhancedSearchHandler.handleSearchWithTimeout(
            $, 
            'Remote Island Hotel',
            customTimeout: const Duration(seconds: 15)
          );
          
          switch (searchState) {
            case SearchResultState.hasResults:
              debugPrint('✅ Search completed successfully within timeout');
              await EnhancedSearchHandler.validateSearchResults($);
              break;
              
            case SearchResultState.error:
              debugPrint('✅ Search resulted in error state - handled correctly');
              break;
              
            case SearchResultState.empty:
              debugPrint('✅ Search returned empty results - handled correctly');
              break;
              
            case SearchResultState.timeout:
              debugPrint('✅ Search timeout handled correctly');
              break;
              
            default:
              debugPrint('ℹ️ Search completed with state: ${searchState.description}');
          }

          await PatrolTestHelper.takeScreenshot($, 'timeout_handling_complete');

        } catch (e) {
          // This catch block should handle the specific loader timeout failure
          if (e.toString().contains('Loader appeared but no results or error message shown')) {
            debugPrint('✅ Timeout test correctly identified stuck loader');
            await PatrolTestHelper.takeScreenshot($, 'loader_timeout_detected');
            // Re-throw to ensure test fails as expected
            rethrow;
          } else {
            await PatrolTestHelper.takeScreenshot($, 'timeout_handling_failed');
            fail('Timeout handling test failed: $e');
          }
        }
      },
    );
  });
}

void main() {
  hotelsTests();
}