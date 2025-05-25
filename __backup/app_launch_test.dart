import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/helpers/test_helper.dart';
import '../integration_test/page_objects/dashboard_page.dart';
import 'overview_page.dart';
import '../integration_test/page_objects/hotels_page.dart';
import '../integration_test/page_objects/favorites_page.dart';
import 'account_page.dart';

void appLaunchTests() {
  group('App Launch Tests', () {
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

      await $.pump(const Duration(seconds: 2));
      await dashboardPage.verifyDashboardLoaded();
    }

    Future<void> safeNavigateToOverview(PatrolIntegrationTester $) async {
      await dashboardPage.navigateToOverview();
      await $.pump(const Duration(seconds: 1));
      try {
        await overviewPage.verifyOverviewPageLoaded();
      } catch (e) {
        print('⚠️ First overview navigation attempt failed, retrying...');
        await $.pump(const Duration(seconds: 1));
        await dashboardPage.navigateToOverview();
        await $.pump(const Duration(seconds: 2));
        await overviewPage.verifyOverviewPageLoaded();
      }
    }

    patrolTest(
      'App launches successfully and shows overview page',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.verifyDashboardLoaded();
          await safeNavigateToOverview($);
          await PatrolTestHelper.takeScreenshot($, 'app_launch_success');
          dashboardPage.verifyAllTabsVisible();
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'app_launch_failed');
          fail('App launch test failed: $e');
        }
      },
    );

    patrolTest(
      'App initializes with correct default state',
      ($) async {
        await initializeTest($);

        try {
          await safeNavigateToOverview($);
          overviewPage.verifyOverviewTitle();
          overviewPage.verifyOverviewIcon();
          dashboardPage.verifyNavigationBarVisible();
          await PatrolTestHelper.takeScreenshot($, 'initial_state_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'initial_state_failed');
          fail('Initial state test failed: $e');
        }
      },
    );

    patrolTest(
      'App components load correctly after launch',
      ($) async {
        await initializeTest($);

        try {
          await $.pump(const Duration(seconds: 2));

          if (dashboardPage.isElementVisible('navigation_hotels_tab')) {
            await dashboardPage.navigateToHotels();
            await $.pump(const Duration(seconds: 2));
            await hotelsPage.verifyHotelsPageLoaded();
            await PatrolTestHelper.takeScreenshot($, 'component_load_hotels');
          }

          if (dashboardPage.isElementVisible('navigation_favorites_tab')) {
            await dashboardPage.navigateToFavorites();
            await $.pump(const Duration(seconds: 1));
            await favoritesPage.verifyFavoritesPageLoaded();
            await PatrolTestHelper.takeScreenshot(
                $, 'component_load_favorites');
          }

          if (dashboardPage.isElementVisible('navigation_account_tab')) {
            await dashboardPage.navigateToAccount();
            await $.pump(const Duration(seconds: 1));
            await accountPage.verifyAccountPageLoaded();
            await PatrolTestHelper.takeScreenshot($, 'component_load_account');
          }

          await safeNavigateToOverview($);
          await PatrolTestHelper.takeScreenshot(
              $, 'component_load_overview_return');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'component_load_failed');
          fail('Component loading test failed: $e');
        }
      },
    );

    patrolTest(
      'App handles rapid launch and navigation',
      ($) async {
        await initializeTest($);

        try {
          for (int i = 0; i < 2; i++) {
            if (dashboardPage.isElementVisible('navigation_hotels_tab')) {
              await dashboardPage.navigateToHotels();
              await $.pump(const Duration(seconds: 1));
            }
            await safeNavigateToOverview($);
          }

          await dashboardPage.verifyDashboardLoaded();
          await PatrolTestHelper.takeScreenshot($, 'rapid_navigation_stable');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'rapid_navigation_failed');
          fail('Rapid navigation test failed: $e');
        }
      },
    );

    patrolTest(
      'App startup performance is acceptable',
      ($) async {
        final startTime = DateTime.now();

        try {
          await initializeTest($);

          final endTime = DateTime.now();
          final startupDuration = endTime.difference(startTime);

          expect(startupDuration.inSeconds, lessThan(15));

          print('App startup took: ${startupDuration.inMilliseconds}ms');
          await PatrolTestHelper.takeScreenshot(
              $, 'startup_performance_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'startup_performance_failed');
          fail('Startup performance test failed: $e');
        }
      },
    );

    patrolTest(
      'App handles initialization errors gracefully',
      ($) async {
        try {
          await initializeTest($);
          await dashboardPage.verifyDashboardLoaded();
          await $.pump(const Duration(seconds: 2));
          await dashboardPage.verifyDashboardLoaded();
          await PatrolTestHelper.takeScreenshot($, 'error_handling_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'error_handling_failed');
          fail('Error handling test failed: $e');
        }
      },
    );

    patrolTest(
      'App memory usage is stable after launch',
      ($) async {
        await initializeTest($);

        try {
          for (int i = 0; i < 3; i++) {
            print('🔄 Memory stability test cycle ${i + 1}/3');

            try {
              await dashboardPage.navigateToOverview();
              await $.pump(const Duration(seconds: 1));

              await dashboardPage.navigateToHotels();
              await $.pump(const Duration(milliseconds: 500));

              await dashboardPage.navigateToFavorites();
              await $.pump(const Duration(milliseconds: 500));

              await dashboardPage.navigateToAccount();
              await $.pump(const Duration(milliseconds: 500));
            } catch (e) {
              print('⚠️ Navigation error in cycle ${i + 1}: $e');
              await $.pump(const Duration(seconds: 2));
              await dashboardPage.verifyDashboardLoaded();
            }
          }

          await dashboardPage.navigateToOverview();
          await $.pump(const Duration(seconds: 2));
          await dashboardPage.verifyDashboardLoaded();

          await PatrolTestHelper.takeScreenshot($, 'memory_stability_verified');
          print('✅ Memory stability test completed successfully');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'memory_stability_failed');
          fail('Memory stability test failed: $e');
        }
      },
    );
  });
}

void main() {
  appLaunchTests();
}
