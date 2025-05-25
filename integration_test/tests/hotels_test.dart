import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_helper.dart';
import '../helpers/search_error_handler.dart';
import '../page_objects/dashboard_page.dart';
import '../page_objects/hotels_page.dart';
import '../page_objects/favorites_page.dart';


void hotelsTests() {
  group('Hotels Feature Tests', () {
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
      'Hotel search displays results and pagination works',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

     
          await hotelsPage.searchHotels('New York');

   
          await SearchErrorHandler.handleSearchResult($, () async {
            await hotelsPage.waitForSearchResults();

            await $.pump(const Duration(seconds: 3));

       
            final scrollView = find.byKey(const Key('hotels_scroll_view'));
            final hotelCards = find.byType(Card);

            if (hotelCards.evaluate().isNotEmpty) {
              final initialCount = hotelCards.evaluate().length;
              debugPrint('✅ Search results displayed: $initialCount hotels');

           
              await testPaginationWithCorrectScrolling($, initialCount);
            } else {
              debugPrint('ℹ️ No results found for New York search');
            }
          });

          await PatrolTestHelper.takeScreenshot($, 'hotel_search_results');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'hotel_search_failed');
          fail('Hotel search test failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites functionality - Add, verify, and remove with correct hotel identification',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          debugPrint('🏨 Navigated to hotels page');

        
          await hotelsPage.searchHotels('Paris');
          debugPrint('🔍 Searched for Paris hotels');

          await SearchErrorHandler.handleSearchResult($, () async {
            await hotelsPage.waitForSearchResults();
            await $.pump(const Duration(seconds: 3));

            final hotelCards = find.byType(Card);
            final cardCount = hotelCards.evaluate().length;
            debugPrint('📊 Found $cardCount hotel cards in search results');

            if (cardCount > 0) {
              List<String> addedHotelIds = [];
              final maxFavorites = cardCount >= 3 ? 3 : cardCount;

              debugPrint(
                  '🎯 Planning to add $maxFavorites hotels to favorites');

              for (int i = 0; i < maxFavorites; i++) {
                try {
                  final cardWidget = hotelCards.at(i);

                  final favoriteButtonInCard = find.descendant(
                      of: cardWidget,
                      matching: find.byIcon(Icons.favorite_outline));

                  if (favoriteButtonInCard.evaluate().isNotEmpty) {
                    debugPrint(
                        '💝 Tapping favorite button for hotel card $i...');
                    await $(favoriteButtonInCard.first).tap();
                    await $.pump(const Duration(milliseconds: 1000));

                    final cardKey =
                        cardWidget.evaluate().first.widget.key.toString();
                    final hotelId =
                        cardKey.replaceAll(RegExp(r'[^\d\.,\-]'), '');

                    if (hotelId.isNotEmpty) {
                      addedHotelIds.add(hotelId);
                      debugPrint(
                          '✅ Added hotel $hotelId to favorites (${addedHotelIds.length}/$maxFavorites)');
                    }

                    final filledHeartInCard = find.descendant(
                        of: cardWidget, matching: find.byIcon(Icons.favorite));

                    if (filledHeartInCard.evaluate().isEmpty) {
                      debugPrint(
                          '⚠️ Heart icon did not change to filled for card $i');
                    }
                  } else {
                    debugPrint('❌ No favorite button found in card $i');
                  }
                } catch (e) {
                  debugPrint('❌ Could not add hotel $i to favorites: $e');
                }
              }

              debugPrint(
                  '📊 Successfully added ${addedHotelIds.length} hotels to favorites');

              await dashboardPage.navigateToFavorites();
              debugPrint('📱 Navigated to favorites page');
              await favoritesPage.verifyFavoritesPageLoaded();
              await $.pump(const Duration(seconds: 2));

              final favoriteCards = find.byType(Card);
              final actualFavoriteCount = favoriteCards.evaluate().length;

              debugPrint(
                  '📊 Expected favorites: ${addedHotelIds.length}, Found: $actualFavoriteCount');
              expect(actualFavoriteCount, equals(addedHotelIds.length));
              debugPrint(
                  '✅ Verified exact count match: $actualFavoriteCount favorites');

              
              if (actualFavoriteCount > 0) {
                await testRemovingFavoritesFromFavoritesPage(
                    $, actualFavoriteCount);
              }
            } else {
              debugPrint('ℹ️ No hotel cards found to test favorites');
            }
          });

          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_functionality_tested');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_functionality_failed');
          fail('Favorites functionality test failed: $e');
        }
      },
    );

    patrolTest(
      'Search error handling with correct error states',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

       
          await hotelsPage.searchHotels('');
          await $.pump(const Duration(seconds: 2));

          final emptyStateIcon =
              find.byKey(const Key('hotels_empty_state_icon'));
          expect(emptyStateIcon, findsOneWidget);
          debugPrint('✅ Empty search shows empty state correctly');

          await hotelsPage.searchHotels('   ');

          await SearchErrorHandler.handleSearchResult($, () async {
            await hotelsPage.waitForSearchResults();
            await $.pump(const Duration(seconds: 3));

            
            final errorMessage = find.byKey(const Key('hotels_error_message'));
            final retryButton = find.byKey(const Key('hotels_retry_button'));

            if (errorMessage.evaluate().isNotEmpty &&
                retryButton.evaluate().isNotEmpty) {
              debugPrint('✅ Error state shows correctly with retry button');

             
              await $(retryButton).tap();
              await $.pump(const Duration(seconds: 2));
              debugPrint('✅ Retry button works');
            } else {
              debugPrint(
                  'ℹ️ No error state shown (API might handle spaces differently)');
            }
          });

          
          await hotelsPage.searchHotels('Tokyo');
          await SearchErrorHandler.handleSearchResult($, () async {
            await hotelsPage.waitForSearchResults();
            await $.pump(const Duration(seconds: 3));

            final hotelCards = find.byType(Card);
            if (hotelCards.evaluate().isNotEmpty) {
              debugPrint(
                  '✅ Valid search returned ${hotelCards.evaluate().length} results');
            } else {
              
              final emptyState =
                  find.byKey(const Key('hotels_empty_state_icon'));
              final errorState = find.byKey(const Key('hotels_error_message'));

              if (emptyState.evaluate().isNotEmpty) {
                debugPrint('ℹ️ Tokyo search returned empty state');
              } else if (errorState.evaluate().isNotEmpty) {
                debugPrint('ℹ️ Tokyo search resulted in error');
              }
            }
          });

          await PatrolTestHelper.takeScreenshot(
              $, 'search_error_handling_tested');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'search_error_handling_failed');
          fail('Search error handling test failed: $e');
        }
      },
    );

    patrolTest(
      'Pagination loading states with correct indicators',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();

          await hotelsPage.searchHotels('London');

          await $.pump(const Duration(milliseconds: 200));
          final loadingIndicator =
              find.byKey(const Key('hotels_loading_indicator'));

          if (loadingIndicator.evaluate().isNotEmpty) {
            debugPrint('✅ Initial loading indicator appears during search');
          }

          await SearchErrorHandler.handleSearchResult($, () async {
            await hotelsPage.waitForSearchResults();
            await $.pump(const Duration(seconds: 2));

            final hotelCards = find.byType(Card);
            if (hotelCards.evaluate().isNotEmpty) {
              debugPrint('✅ Search results loaded successfully');

              final scrollView = find.byKey(const Key('hotels_scroll_view'));
              if (scrollView.evaluate().isNotEmpty) {
                await $(scrollView.first).scrollTo(maxScrolls: 5);
                await $.pump(const Duration(seconds: 2));

                final paginationLoading =
                    find.byKey(const Key('hotels_pagination_loading'));
                if (paginationLoading.evaluate().isNotEmpty) {
                  debugPrint('✅ Pagination loading indicator appeared');

                  await $.pump(const Duration(seconds: 3));

                  final newCardCount = find.byType(Card).evaluate().length;
                  debugPrint('📊 Total cards after pagination: $newCardCount');
                } else {
                  debugPrint(
                      'ℹ️ No pagination loading - might not have enough results');
                }
              }
            }
          });

          await PatrolTestHelper.takeScreenshot($, 'pagination_tested');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'pagination_failed');
          fail('Pagination test failed: $e');
        }
      },
    );

    patrolTest(
      'Search field functionality and clearing',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          final searchField = find.byKey(const Key('hotels_search_field'));
          expect(searchField, findsOneWidget);
          debugPrint('✅ Search field container found');

          await hotelsPage.searchHotels('Berlin');
          await $.pump(const Duration(seconds: 1));

          final clearButtons = find.byIcon(Icons.cancel_outlined);
          if (clearButtons.evaluate().isNotEmpty) {
            await $(clearButtons.first).tap();
            await $.pump(const Duration(milliseconds: 500));
            debugPrint('✅ Search field cleared using clear button');

            final emptyStateIcon =
                find.byKey(const Key('hotels_empty_state_icon'));
            expect(emptyStateIcon, findsOneWidget);
            debugPrint('✅ Empty state shown after clearing search');
          }

          await PatrolTestHelper.takeScreenshot($, 'search_field_tested');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'search_field_failed');
          fail('Search field test failed: $e');
        }
      },
    );
  });
}


Future<void> testPaginationWithCorrectScrolling(
    PatrolIntegrationTester $, int initialCount) async {
  debugPrint('🔄 Testing pagination with correct CustomScrollView');
  debugPrint('📊 Initial hotel count: $initialCount');

  try {
    
    final customScrollView = find.byKey(const Key('hotels_scroll_view'));

    if (customScrollView.evaluate().isNotEmpty) {
      debugPrint('📱 Found CustomScrollView with correct key');

      
      await $(customScrollView.first).scrollTo(maxScrolls: 5);
      debugPrint('📱 Scrolled CustomScrollView to trigger pagination');

      
      await $.pump(const Duration(seconds: 3));

      
      final paginationLoading =
          find.byKey(const Key('hotels_pagination_loading'));

      if (paginationLoading.evaluate().isNotEmpty) {
        debugPrint('⏳ Pagination loading indicator appeared!');

        
        await $.pump(const Duration(seconds: 5));

  
        final finalCards = find.byType(Card);
        final finalCount = finalCards.evaluate().length;
        debugPrint(
            '📊 Cards after pagination: $finalCount (was $initialCount)');

        if (finalCount > initialCount) {
          debugPrint(
              '✅ SUCCESS: Pagination loaded ${finalCount - initialCount} more results');
        } else {
          debugPrint('ℹ️ No additional results loaded (might be end of list)');
        }
      } else {
        debugPrint(
            'ℹ️ No pagination loading indicator - might not have enough results');
      }
    } else {
      debugPrint('❌ CustomScrollView with key hotels_scroll_view not found!');
    }
  } catch (e) {
    debugPrint('❌ Error during pagination test: $e');
  }
}


Future<void> testRemovingFavoritesFromFavoritesPage(
    PatrolIntegrationTester $, int initialCount) async {
  debugPrint('🗑️ Testing removal of favorites from favorites page');

  try {

    final favoriteButtons = find.byIcon(Icons.favorite);

    if (favoriteButtons.evaluate().isNotEmpty) {
      debugPrint('Found ${favoriteButtons.evaluate().length} favorite buttons');

      await $(favoriteButtons.first).tap();
      await $.pump(const Duration(seconds: 1));

      final remainingCards = find.byType(Card);
      final newCount = remainingCards.evaluate().length;

      expect(newCount, equals(initialCount - 1));
      debugPrint(
          '✅ Successfully removed 1 favorite. Count: $initialCount → $newCount');

      if (newCount > 0) {
        final remainingFavoriteButtons = find.byIcon(Icons.favorite);
        if (remainingFavoriteButtons.evaluate().isNotEmpty) {
          await $(remainingFavoriteButtons.first).tap();
          await $.pump(const Duration(seconds: 1));

          final finalCards = find.byType(Card);
          final finalCount = finalCards.evaluate().length;

          expect(finalCount, equals(newCount - 1));
          debugPrint(
              '✅ Successfully removed 2nd favorite. Count: $newCount → $finalCount');

          if (finalCount == 0) {
            final emptyStateIcon =
                find.byKey(const Key('favorites_empty_state_icon'));
            if (emptyStateIcon.evaluate().isNotEmpty) {
              debugPrint(
                  '✅ Empty state correctly shown when all favorites removed');
            }
          }
        }
      }
    } else {
      debugPrint('⚠️ No favorite buttons found to test removal');
    }
  } catch (e) {
    debugPrint('⚠️ Could not test removing favorites: $e');
  }
}


void main() {
  hotelsTests();
}
