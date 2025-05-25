import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/helpers/test_helper.dart';
import '../integration_test/page_objects/dashboard_page.dart';
import 'overview_page.dart';
import '../integration_test/page_objects/hotels_page.dart';
import '../integration_test/page_objects/favorites_page.dart';
import 'account_page.dart';

void navigationTests() {
  group('Navigation Tests', () {
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

    Future<void> navigateToTab(
        PatrolIntegrationTester $, String tabName) async {
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
        default:
          throw ArgumentError('Unknown tab: $tabName');
      }
    }

    patrolTest(
      'All navigation tabs are accessible and functional',
      ($) async {
        await initializeTest($);

        try {
          await navigateToTab($, 'hotels');
          hotelsPage.verifySearchFieldVisible();
          await PatrolTestHelper.takeScreenshot($, 'navigation_hotels_tab');

          await navigateToTab($, 'favorites');
          favoritesPage.verifyFavoritesTitle();
          await PatrolTestHelper.takeScreenshot($, 'navigation_favorites_tab');

          await navigateToTab($, 'account');
          accountPage.verifyAccountTitle();
          await PatrolTestHelper.takeScreenshot($, 'navigation_account_tab');

          await navigateToTab($, 'overview');
          overviewPage.verifyOverviewTitle();
          await PatrolTestHelper.takeScreenshot($, 'navigation_overview_tab');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'navigation_tabs_failed');
          fail('Navigation tabs test failed: $e');
        }
      },
    );

    patrolTest(
      'Navigation maintains state correctly',
      ($) async {
        await initializeTest($);

        try {
          await navigateToTab($, 'hotels');
          await hotelsPage.searchHotels('Tokyo');
          await hotelsPage.waitForSearchResults();

          await navigateToTab($, 'favorites');
          await navigateToTab($, 'hotels');

          await hotelsPage.verifyHotelsPageLoaded();
          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_state_maintained');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'navigation_state_failed');
          fail('Navigation state test failed: $e');
        }
      },
    );

    patrolTest(
      'Rapid navigation between tabs works correctly',
      ($) async {
        await initializeTest($);

        try {
          final tabs = ['hotels', 'favorites', 'account', 'overview'];

          for (int cycle = 0; cycle < 2; cycle++) {
            for (final tab in tabs) {
              await navigateToTab($, tab);
              await $.pump(const Duration(milliseconds: 300));
            }
          }

          await overviewPage.verifyOverviewPageLoaded();
          await PatrolTestHelper.takeScreenshot(
              $, 'rapid_navigation_completed');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'rapid_navigation_failed');
          fail('Rapid navigation test failed: $e');
        }
      },
    );

    patrolTest(
      'Navigation preserves app performance',
      ($) async {
        await initializeTest($);

        try {
          final startTime = DateTime.now();

          for (int i = 0; i < 5; i++) {
            await dashboardPage.navigateToHotels();
            await dashboardPage.navigateToFavorites();
            await dashboardPage.navigateToAccount();
            await dashboardPage.navigateToOverview();
          }

          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);

          expect(duration.inSeconds, lessThan(30));

          await dashboardPage.verifyDashboardLoaded();
          await overviewPage.verifyOverviewPageLoaded();
          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_performance_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_performance_failed');
          fail('Navigation performance test failed: $e');
        }
      },
    );

    patrolTest(
      'Navigation handles edge cases correctly',
      ($) async {
        await initializeTest($);

        try {
          await navigateToTab($, 'hotels');
          await dashboardPage.navigateToHotels();
          await dashboardPage.navigateToHotels();
          await hotelsPage.verifyHotelsPageLoaded();

          await dashboardPage.navigateToFavorites();
          await dashboardPage.navigateToHotels();
          await dashboardPage.navigateToFavorites();
          await favoritesPage.verifyFavoritesPageLoaded();

          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_edge_cases_handled');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_edge_cases_failed');
          fail('Navigation edge cases test failed: $e');
        }
      },
    );
  });
}

void main() {
  navigationTests();
}
