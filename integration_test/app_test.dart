import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/test_helper.dart';
import 'locators/app_locators.dart';
import 'page_objects/dashboard_page.dart';
import '../__backup/overview_page.dart';
import 'page_objects/hotels_page.dart';
import 'page_objects/favorites_page.dart';
import '../__backup/account_page.dart';


void main() {
  group('Hotel Booking App - Complete Integration Test Suite', () {
    
    
    late DashboardPage dashboardPage;
    late OverviewPage overviewPage;
    late HotelsPage hotelsPage;
    late FavoritesPage favoritesPage;
    late AccountPage accountPage;

    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await PatrolTestHelper.initializeApp($);
      dashboardPage = DashboardPage($);
      overviewPage = OverviewPage($);
      hotelsPage = HotelsPage($);
      favoritesPage = FavoritesPage($);
      accountPage = AccountPage($);
      await dashboardPage.verifyDashboardLoaded();
    }

    Future<void> navigateToTab(String tabName) async {
      switch (tabName.toLowerCase()) {
        case 'overview':
          await dashboardPage.navigateToOverview();
          await overviewPage.verifyOverviewPageLoaded();
          break;
        case 'hotels':
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();
          break;
        case 'favorites':
          await dashboardPage.navigateToFavorites();
          await favoritesPage.verifyFavoritesPageLoaded();
          break;
        case 'account':
          await dashboardPage.navigateToAccount();
          await accountPage.verifyAccountPageLoaded();
          break;
      }
    }

    group('App Launch Tests', () {
      patrolTest(
        'App launches successfully and shows overview page',
        ($) async {
          await initializeTest($);
          await overviewPage.verifyOverviewPageLoaded();
          await PatrolTestHelper.takeScreenshot($, 'app_launch_success');
        },
      );

      patrolTest(
        'App initializes with correct default state',
        ($) async {
          await initializeTest($);
          overviewPage.verifyOverviewTitle();
          overviewPage.verifyOverviewIcon();
          dashboardPage.verifyNavigationBarVisible();
          await PatrolTestHelper.takeScreenshot($, 'initial_state_verified');
        },
      );
    });

    group('Navigation Tests', () {
      patrolTest(
        'All navigation tabs are accessible and functional',
        ($) async {
          await initializeTest($);
          
          await navigateToTab('hotels');
          hotelsPage.verifySearchFieldVisible();
          
          await navigateToTab('favorites');
          favoritesPage.verifyFavoritesTitle();
          
          await navigateToTab('account');
          accountPage.verifyAccountTitle();
          
          await navigateToTab('overview');
          overviewPage.verifyOverviewTitle();
          
          await PatrolTestHelper.takeScreenshot($, 'navigation_test_complete');
        },
      );

      patrolTest(
        'Rapid navigation between tabs works correctly',
        ($) async {
          await initializeTest($);
          
          final tabs = ['hotels', 'favorites', 'account', 'overview'];
          for (int cycle = 0; cycle < 2; cycle++) {
            for (final tab in tabs) {
              await navigateToTab(tab);
              await $.pump(const Duration(milliseconds: 300));
            }
          }
          
          await overviewPage.verifyOverviewPageLoaded();
          await PatrolTestHelper.takeScreenshot($, 'rapid_navigation_complete');
        },
      );
    });

    group('Overview Feature Tests', () {
      patrolTest(
        'Overview page displays correct branding',
        ($) async {
          await initializeTest($);
          await navigateToTab('overview');
          await overviewPage.verifyOverviewBrandingContent();
          overviewPage.verifyOverviewTitle();
          overviewPage.verifyOverviewIcon();
          await PatrolTestHelper.takeScreenshot($, 'overview_branding_verified');
        },
      );

      patrolTest(
        'Overview page layout is correct',
        ($) async {
          await initializeTest($);
          await navigateToTab('overview');
          await overviewPage.verifyOverviewPageLayout();
          overviewPage.verifyOverviewPageElements();
          await PatrolTestHelper.takeScreenshot($, 'overview_layout_verified');
        },
      );
    });

    group('Hotels Feature Tests', () {
      patrolTest(
        'Hotels page loads correctly with search functionality',
        ($) async {
          await initializeTest($);
          await navigateToTab('hotels');
          await hotelsPage.verifyHotelsPageLoaded();
          hotelsPage.verifySearchFieldVisible();
          hotelsPage.verifyEmptyState();
          await PatrolTestHelper.takeScreenshot($, 'hotels_page_loaded');
        },
      );

      patrolTest(
        'Hotel search functionality works correctly',
        ($) async {
          await initializeTest($);
          await navigateToTab('hotels');
          
          const testQueries = ['New York', 'London', 'Paris'];
          for (final query in testQueries) {
            await hotelsPage.performSearchTest(query);
            await $.pump(const Duration(seconds: 1));
            await hotelsPage.clearSearchField();
            await $.pump(const Duration(milliseconds: 500));
          }
          
          await PatrolTestHelper.takeScreenshot($, 'hotel_search_completed');
        },
      );

      patrolTest(
        'Hotel favorites functionality works',
        ($) async {
          await initializeTest($);
          await navigateToTab('hotels');
          
          await hotelsPage.searchHotels('Paris');
          await hotelsPage.waitForSearchResults();
          
          const mockHotelId = '48.8566,2.3522';
          if (hotelsPage.isElementVisible(AppLocators.hotelCard(mockHotelId))) {
            await hotelsPage.toggleHotelFavorite(mockHotelId);
            await PatrolTestHelper.takeScreenshot($, 'hotel_favorites_toggled');
          }
        },
      );
    });

    group('Favorites Feature Tests', () {
      patrolTest(
        'Favorites page loads correctly',
        ($) async {
          await initializeTest($);
          await navigateToTab('favorites');
          await favoritesPage.verifyFavoritesPageLoaded();
          favoritesPage.verifyFavoritesTitle();
          await favoritesPage.verifyFavoritesListFunctionality();
          await PatrolTestHelper.takeScreenshot($, 'favorites_page_loaded');
        },
      );

      patrolTest(
        'Favorites workflow end-to-end',
        ($) async {
          await initializeTest($);
          
          await navigateToTab('favorites');
          const mockHotelIds = ['48.8566,2.3522', '51.5074,-0.1278'];
          
          if (!favoritesPage.isElementVisible(AppLocators.favoritesEmptyStateIcon)) {
            await favoritesPage.clearAllFavorites(mockHotelIds);
          }
          
          await navigateToTab('hotels');
          await hotelsPage.searchHotels('Berlin');
          await hotelsPage.waitForSearchResults();
          
          await navigateToTab('favorites');
          await favoritesPage.verifyFavoritesListFunctionality();
          await PatrolTestHelper.takeScreenshot($, 'favorites_workflow_completed');
        },
      );
    });

    group('Account Feature Tests', () {
      patrolTest(
        'Account page loads correctly',
        ($) async {
          await initializeTest($);
          await navigateToTab('account');
          await accountPage.verifyAccountPageLoaded();
          accountPage.verifyAccountTitle();
          accountPage.verifyAccountIcon();
          await PatrolTestHelper.takeScreenshot($, 'account_page_loaded');
        },
      );

      patrolTest(
        'Account page layout is correct',
        ($) async {
          await initializeTest($);
          await navigateToTab('account');
          await accountPage.verifyAccountPageLayout();
          accountPage.verifyAccountPageElements();
          await PatrolTestHelper.takeScreenshot($, 'account_layout_verified');
        },
      );
    });

    group('Cross-Feature Integration Tests', () {
      patrolTest(
        'Complete user workflow: Search -> Favorite -> View',
        ($) async {
          await initializeTest($);
          
          await navigateToTab('hotels');
          await hotelsPage.searchHotels('Tokyo');
          await hotelsPage.waitForSearchResults();
          
          const mockHotelId = '35.6762,139.6503';
          if (hotelsPage.isElementVisible(AppLocators.hotelCard(mockHotelId))) {
            await hotelsPage.toggleHotelFavorite(mockHotelId);
          }
          
          await navigateToTab('favorites');
          await favoritesPage.verifyFavoritesListFunctionality();
          
          await navigateToTab('overview');
          await overviewPage.verifyOverviewPageLoaded();
          
          await PatrolTestHelper.takeScreenshot($, 'complete_workflow_finished');
        },
      );
    });

    group('Error Handling Tests', () {
      patrolTest(
        'Search handles edge cases correctly',
        ($) async {
          await initializeTest($);
          await navigateToTab('hotels');
          
          await hotelsPage.searchHotels('');
          await $.pump(const Duration(seconds: 1));
          
          await hotelsPage.searchHotels('!@#\$%');
          await hotelsPage.waitForSearchResults();
          
          await hotelsPage.searchHotels('A');
          await hotelsPage.searchHotels('AB');
          await hotelsPage.searchHotels('ABC');
          await hotelsPage.waitForSearchResults();
          
          await PatrolTestHelper.takeScreenshot($, 'search_edge_cases_handled');
        },
      );
    });
  });
}