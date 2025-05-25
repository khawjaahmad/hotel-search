import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_helper.dart';
import '../locators/app_locators.dart';
import '../page_objects/dashboard_page.dart';
import '../page_objects/favorites_page.dart';
import '../page_objects/hotels_page.dart';

void favoritesTests() {
  group('Favorites Feature Tests', () {
    late DashboardPage dashboardPage;
    late FavoritesPage favoritesPage;
    late HotelsPage hotelsPage;

    const mockHotelIds = [
      '48.8566,2.3522',
      '51.5074,-0.1278',
      '35.6762,139.6503'
    ];
    const mockHotelId = '48.8566,2.3522';

    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await PatrolTestHelper.initializeApp($);
      dashboardPage = DashboardPage($);
      favoritesPage = FavoritesPage($);
      hotelsPage = HotelsPage($);
      await dashboardPage.verifyDashboardLoaded();
    }

    Future<void> navigateToFavorites(PatrolIntegrationTester $) async {
      await dashboardPage.navigateToFavorites();
      await favoritesPage.verifyFavoritesPageLoaded();
    }

    Future<void> navigateToHotels(PatrolIntegrationTester $) async {
      await dashboardPage.navigateToHotels();
      await hotelsPage.verifyHotelsPageLoaded();
    }

    patrolTest(
      'Favorites page loads correctly',
      ($) async {
        await initializeTest($);

        try {
          await navigateToFavorites($);
          await favoritesPage.verifyFavoritesPageLoaded();
          favoritesPage.verifyFavoritesTitle();
          await favoritesPage.verifyFavoritesListFunctionality();
          await PatrolTestHelper.takeScreenshot($, 'favorites_page_loaded');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'favorites_page_failed');
          fail('Favorites page load test failed: $e');
        }
      },
    );

    patrolTest(
      'Empty favorites state is displayed correctly',
      ($) async {
        await initializeTest($);

        try {
          await navigateToFavorites($);

          if (favoritesPage
              .isElementVisible(AppLocators.favoritesEmptyStateIcon)) {
            favoritesPage.verifyEmptyFavoritesState();
            await PatrolTestHelper.takeScreenshot(
                $, 'favorites_empty_verified');
          } else {
            await favoritesPage.clearAllFavorites(mockHotelIds);
            favoritesPage.verifyEmptyFavoritesState();
            await PatrolTestHelper.takeScreenshot(
                $, 'favorites_empty_after_clear');
          }
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'favorites_empty_failed');
          fail('Empty favorites state test failed: $e');
        }
      },
    );

    patrolTest(
      'Adding and removing favorites works correctly',
      ($) async {
        await initializeTest($);

        try {
          await navigateToHotels($);
          await hotelsPage.searchHotels('Paris');
          await hotelsPage.waitForSearchResults();

          if (hotelsPage.isElementVisible(AppLocators.hotelCard(mockHotelId))) {
            await hotelsPage.toggleHotelFavorite(mockHotelId);
            await PatrolTestHelper.takeScreenshot(
                $, 'favorites_added_from_hotels');
          }

          await navigateToFavorites($);

          await favoritesPage.verifyFavoritesListFunctionality();

          if (favoritesPage
              .isElementVisible(AppLocators.favoritesHotelCard(mockHotelId))) {
            await favoritesPage.removeFavoriteHotel(mockHotelId);
            await PatrolTestHelper.takeScreenshot($, 'favorites_removed');
          }
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_management_failed');
          fail('Favorites management test failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites list scrolling works correctly',
      ($) async {
        await initializeTest($);

        try {
          await navigateToFavorites($);
          await favoritesPage.scrollThroughFavorites();
          await favoritesPage.verifyFavoritesListFunctionality();
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_scrolling_tested');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_scrolling_failed');
          fail('Favorites scrolling test failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites persistence across navigation',
      ($) async {
        await initializeTest($);

        try {
          await navigateToHotels($);
          await hotelsPage.searchHotels('Tokyo');
          await hotelsPage.waitForSearchResults();

          if (hotelsPage.isElementVisible(AppLocators.hotelCard(mockHotelId))) {
            await hotelsPage.toggleHotelFavorite(mockHotelId);
          }

          await dashboardPage.navigateToAccount();
          await dashboardPage.navigateToOverview();
          await navigateToFavorites($);

          await favoritesPage.verifyFavoritesListFunctionality();
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
      'Favorites workflow end-to-end',
      ($) async {
        await initializeTest($);

        try {
          await navigateToFavorites($);
          if (!favoritesPage
              .isElementVisible(AppLocators.favoritesEmptyStateIcon)) {
            await favoritesPage.clearAllFavorites(mockHotelIds);
          }
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_workflow_start_empty');

          await navigateToHotels($);
          await hotelsPage.searchHotels('Berlin');
          await hotelsPage.waitForSearchResults();

          for (final hotelId in mockHotelIds) {
            if (hotelsPage.isElementVisible(AppLocators.hotelCard(hotelId))) {
              await hotelsPage.toggleHotelFavorite(hotelId);
              await $.pump(const Duration(milliseconds: 500));
            }
          }
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_workflow_added_multiple');

          await navigateToFavorites($);
          await favoritesPage.verifyFavoritesListFunctionality();
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_workflow_list_populated');

          await favoritesPage.testFavoritesManagement(mockHotelIds);
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_workflow_completed');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'favorites_workflow_failed');
          fail('Favorites workflow test failed: $e');
        }
      },
    );

    patrolTest(
      'Favorites page handles edge cases',
      ($) async {
        await initializeTest($);

        try {
          await navigateToFavorites($);

          for (int i = 0; i < 3; i++) {
            await navigateToHotels($);
            await navigateToFavorites($);
            await $.pump(const Duration(milliseconds: 300));
          }

          await favoritesPage.verifyFavoritesPageLoaded();
          await favoritesPage.scrollThroughFavorites();
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_edge_cases_handled');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'favorites_edge_cases_failed');
          fail('Favorites edge cases test failed: $e');
        }
      },
    );
  });
}

void main() {
  favoritesTests();
}
