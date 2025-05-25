import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_helper.dart';
import '../page_objects/dashboard_page.dart';
import '../../__backup/overview_page.dart';
import '../../__backup/account_page.dart';

void simplePagesTests() {
  group('📱 Simple Pages - Basic Functionality', () {
    late DashboardPage dashboardPage;
    late OverviewPage overviewPage;
    late AccountPage accountPage;

    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await PatrolTestHelper.initializeApp($);
      dashboardPage = DashboardPage($);
      overviewPage = OverviewPage($);
      accountPage = AccountPage($);
      await dashboardPage.verifyDashboardLoaded();
    }

    patrolTest(
      'Overview page - loads correctly with proper content',
      ($) async {
        await initializeTest($);

        try {
          // Navigate to overview (should be default but ensure we're there)
          await dashboardPage.navigateToOverview();
          await overviewPage.verifyOverviewPageLoaded();

          // Verify page elements exist
          overviewPage.verifyOverviewPageElements();

          // Verify specific text content - "Hotel Booking" title
          overviewPage.verifyOverviewTitle();
          expect(find.text('Hotel Booking'), findsOneWidget);
          debugPrint('✅ Overview title "Hotel Booking" found');

          // Verify icon is present
          overviewPage.verifyOverviewIcon();
          expect(find.byKey(const Key('overview_icon')), findsOneWidget);
          debugPrint('✅ Overview icon displayed');

          // Verify app bar
          expect(find.byKey(const Key('overview_app_bar')), findsOneWidget);
          debugPrint('✅ Overview app bar present');

          // Verify scaffold structure
          expect(find.byKey(const Key('overview_scaffold')), findsOneWidget);
          debugPrint('✅ Overview page structure verified');

          await PatrolTestHelper.takeScreenshot($, 'overview_page_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'overview_page_failed');
          fail('Overview page test failed: $e');
        }
      },
    );

    patrolTest(
      'Account page - loads correctly with proper content',
      ($) async {
        await initializeTest($);

        try {
          // Navigate to account page
          await dashboardPage.navigateToAccount();
          await accountPage.verifyAccountPageLoaded();

          // Verify page elements exist
          accountPage.verifyAccountPageElements();

          // Verify specific text content - "Your Account" title
          accountPage.verifyAccountTitle();
          expect(find.text('Your Account'), findsOneWidget);
          debugPrint('✅ Account title "Your Account" found');

          // Verify icon is present
          accountPage.verifyAccountIcon();
          expect(find.byKey(const Key('account_icon')), findsOneWidget);
          debugPrint('✅ Account icon displayed');

          // Verify app bar
          expect(find.byKey(const Key('account_app_bar')), findsOneWidget);
          debugPrint('✅ Account app bar present');

          // Verify scaffold structure
          expect(find.byKey(const Key('account_scaffold')), findsOneWidget);
          debugPrint('✅ Account page structure verified');

          await PatrolTestHelper.takeScreenshot($, 'account_page_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'account_page_failed');
          fail('Account page test failed: $e');
        }
      },
    );

    patrolTest(
      'Navigation - all tabs accessible and functional',
      ($) async {
        await initializeTest($);

        try {
          // Verify dashboard loaded and navigation visible
          dashboardPage.verifyNavigationBarVisible();
          dashboardPage.verifyAllTabsVisible();

          // Test each navigation tab
          final tabs = [
            {
              'name': 'Overview',
              'key': 'navigation_overview_tab',
              'text': 'Overview'
            },
            {
              'name': 'Hotels',
              'key': 'navigation_hotels_tab',
              'text': 'Hotels'
            },
            {
              'name': 'Favorites',
              'key': 'navigation_favorites_tab',
              'text': 'Favorites'
            },
            {
              'name': 'Account',
              'key': 'navigation_account_tab',
              'text': 'Account'
            },
          ];

          for (final tab in tabs) {
            debugPrint('🔍 Testing ${tab['name']} tab navigation');

            // Verify tab exists
            final tabFinder = find.byKey(Key(tab['key']!));
            expect(tabFinder, findsOneWidget);
            debugPrint('✅ ${tab['name']} tab found');

            // Verify tab text
            expect(find.text(tab['text']!), findsOneWidget);
            debugPrint('✅ ${tab['name']} tab text "${tab['text']}" verified');

            // Tap the tab
            await $(Key(tab['key']!)).tap();
            await $.pump(const Duration(milliseconds: 500));
            debugPrint('✅ ${tab['name']} tab tapped successfully');
          }

          // Test rapid navigation (ensure no crashes)
          debugPrint('🔄 Testing rapid navigation between tabs');
          for (int i = 0; i < 2; i++) {
            await dashboardPage.navigateToOverview();
            await $.pump(const Duration(milliseconds: 200));

            await dashboardPage.navigateToHotels();
            await $.pump(const Duration(milliseconds: 200));

            await dashboardPage.navigateToFavorites();
            await $.pump(const Duration(milliseconds: 200));

            await dashboardPage.navigateToAccount();
            await $.pump(const Duration(milliseconds: 200));
          }
          debugPrint('✅ Rapid navigation test completed');

          // Return to overview
          await dashboardPage.navigateToOverview();
          await overviewPage.verifyOverviewPageLoaded();

          await PatrolTestHelper.takeScreenshot($, 'navigation_test_complete');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'navigation_test_failed');
          fail('Navigation test failed: $e');
        }
      },
    );

    patrolTest(
      'Cross-page navigation state and consistency',
      ($) async {
        await initializeTest($);

        try {
          // Test navigation flow and verify each page loads correctly
          final navigationFlow = [
            {
              'page': 'Overview',
              'action': () => dashboardPage.navigateToOverview(),
              'verify': () => overviewPage.verifyOverviewPageLoaded()
            },
            {
              'page': 'Hotels',
              'action': () => dashboardPage.navigateToHotels(),
              'verify': () => expect(
                  find.byKey(const Key('hotels_scaffold')), findsOneWidget)
            },
            {
              'page': 'Favorites',
              'action': () => dashboardPage.navigateToFavorites(),
              'verify': () => expect(
                  find.byKey(const Key('favorites_scaffold')), findsOneWidget)
            },
            {
              'page': 'Account',
              'action': () => dashboardPage.navigateToAccount(),
              'verify': () => accountPage.verifyAccountPageLoaded()
            },
          ];

          for (final step in navigationFlow) {
            debugPrint('🔍 Testing navigation to ${step['page']}');

            // Navigate to page
            await (step['action'] as Function)();
            await $.pump(const Duration(milliseconds: 300));

            // Verify page loaded
            (step['verify'] as Function)();
            debugPrint('✅ ${step['page']} page verified');
          }

          // Test navigation consistency - multiple cycles
          debugPrint('🔄 Testing navigation consistency over multiple cycles');
          for (int cycle = 0; cycle < 3; cycle++) {
            await dashboardPage.navigateToOverview();
            await $.pump(const Duration(milliseconds: 100));

            await dashboardPage.navigateToAccount();
            await $.pump(const Duration(milliseconds: 100));

            // Verify both pages still work after multiple navigations
            expect(find.byKey(const Key('account_scaffold')), findsOneWidget);
          }

          debugPrint('✅ Navigation consistency verified over multiple cycles');

          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_consistency_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'navigation_consistency_failed');
          fail('Navigation consistency test failed: $e');
        }
      },
    );

    patrolTest(
      'App performance and stability across simple pages',
      ($) async {
        await initializeTest($);

        try {
          final startTime = DateTime.now();

          // Perform multiple navigation operations
          for (int i = 0; i < 5; i++) {
            await dashboardPage.navigateToOverview();
            await overviewPage.verifyOverviewPageLoaded();

            await dashboardPage.navigateToAccount();
            await accountPage.verifyAccountPageLoaded();

            await dashboardPage.navigateToFavorites();
            await $.pump(const Duration(milliseconds: 200));

            await dashboardPage.navigateToHotels();
            await $.pump(const Duration(milliseconds: 200));
          }

          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);

          // Verify performance is acceptable (under 30 seconds for 20 navigations)
          expect(duration.inSeconds, lessThan(30));
          debugPrint(
              '✅ Navigation performance: ${duration.inMilliseconds}ms for 20 navigations');

          // Verify app is still stable after performance test
          await dashboardPage.verifyDashboardLoaded();
          await dashboardPage.navigateToOverview();
          await overviewPage.verifyOverviewPageLoaded();

          debugPrint('✅ App remains stable after performance test');

          await PatrolTestHelper.takeScreenshot($, 'performance_test_complete');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'performance_test_failed');
          fail('Performance test failed: $e');
        }
      },
    );
  });
}

void main() {
  simplePagesTests();
}
