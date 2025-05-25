import '../helpers/test_helper.dart';
import '../locators/app_locators.dart';
import '../page_objects/dashboard_page.dart';
import '../page_objects/hotels_page.dart';
import '../page_objects/favorites_page.dart';
void dashboardTests() {
group('🏠 Dashboard - Navigation & Core Functionality', () {
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

patrolTest(
  'Dashboard loads correctly with all navigation elements',
  ($) async {
    await initializeTest($);

    try {
      // Verify dashboard structure using enhanced locators
      dashboardPage.verifyNavigationBarVisible();
      dashboardPage.verifyAllTabsVisible();
      
      // Use AppLocators fallback demonstration
      AppLocators.validateDashboard();
      
      // Verify each tab is accessible
      final tabs = ['overview', 'hotels', 'favorites', 'account'];
      for (final tab in tabs) {
        final tabFinder = AppLocators.getNavigationTab(tab);
        expect(tabFinder, findsOneWidget, 
            reason: '$tab navigation tab should be visible');
        debugPrint('✅ $tab navigation tab verified');
      }

      // Verify default state (Overview should be selected)
      await overviewPage.verifyOverviewPageLoaded();
      
      await PatrolTestHelper.takeScreenshot($, 'dashboard_loaded_successfully');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'dashboard_load_failed');
      fail('Dashboard load test failed: $e');
    }
  },
);

patrolTest(
  'Navigation between all tabs works correctly',
  ($) async {
    await initializeTest($);

    try {
      // Test navigation to each tab with verification
      debugPrint('🔄 Testing complete navigation flow');

      // Navigate to Hotels
      await dashboardPage.navigateToHotels();
      await hotelsPage.verifyHotelsPageLoaded();
      hotelsPage.verifySearchFieldVisible();
      await PatrolTestHelper.takeScreenshot($, 'navigated_to_hotels');

      // Navigate to Favorites  
      await dashboardPage.navigateToFavorites();
      await favoritesPage.verifyFavoritesPageLoaded();
      favoritesPage.verifyFavoritesTitle();
      await PatrolTestHelper.takeScreenshot($, 'navigated_to_favorites');

      // Navigate to Account
      await dashboardPage.navigateToAccount();
      await accountPage.verifyAccountPageLoaded();
      accountPage.verifyAccountTitle();
      await PatrolTestHelper.takeScreenshot($, 'navigated_to_account');

      // Navigate back to Overview
      await dashboardPage.navigateToOverview();
      await overviewPage.verifyOverviewPageLoaded();
      overviewPage.verifyOverviewTitle();
      await PatrolTestHelper.takeScreenshot($, 'navigated_to_overview');

      debugPrint('✅ Complete navigation flow verified');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'navigation_flow_failed');
      fail('Navigation flow test failed: $e');
    }
  },
);

patrolTest(
  'Rapid navigation stress test - performance and stability',
  ($) async {
    await initializeTest($);

    try {
      debugPrint('🚀 Starting rapid navigation stress test');
      
      final startTime = DateTime.now();
      const cycles = 5;
      
      for (int cycle = 0; cycle < cycles; cycle++) {
        debugPrint('🔄 Navigation cycle ${cycle + 1}/$cycles');
        
        // Rapid navigation sequence
        await dashboardPage.navigateToHotels();
        await $.pump(const Duration(milliseconds: 100));
        
        await dashboardPage.navigateToFavorites();
        await $.pump(const Duration(milliseconds: 100));
        
        await dashboardPage.navigateToAccount();
        await $.pump(const Duration(milliseconds: 100));
        
        await dashboardPage.navigateToOverview();
        await $.pump(const Duration(milliseconds: 100));
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Performance verification
      expect(duration.inSeconds, lessThan(30), 
          reason: 'Navigation should complete within 30 seconds');
      
      debugPrint('✅ Rapid navigation completed in ${duration.inMilliseconds}ms');
      
      // Verify app stability after stress test
      await dashboardPage.verifyDashboardLoaded();
      await overviewPage.verifyOverviewPageLoaded();
      
      await PatrolTestHelper.takeScreenshot($, 'stress_test_completed');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'stress_test_failed');
      fail('Rapid navigation stress test failed: $e');
    }
  },
);

patrolTest(
  'Navigation state persistence across app lifecycle',
  ($) async {
    await initializeTest($);

    try {
      // Navigate to a specific tab
      await dashboardPage.navigateToHotels();
      await hotelsPage.verifyHotelsPageLoaded();
      
      // Simulate app state changes (navigation within hotels)
      await hotelsPage.searchHotels('Test Query');
      await $.pump(const Duration(seconds: 1));
      
      // Navigate away and back
      await dashboardPage.navigateToFavorites();
      await favoritesPage.verifyFavoritesPageLoaded();
      
      await dashboardPage.navigateToHotels();
      await hotelsPage.verifyHotelsPageLoaded();
      
      // Verify hotels page maintained its state
      hotelsPage.verifySearchFieldVisible();
      
      // Test multiple tab switches to verify persistence
      for (int i = 0; i < 3; i++) {
        await dashboardPage.navigateToAccount();
        await accountPage.verifyAccountPageLoaded();
        
        await dashboardPage.navigateToHotels();
        await hotelsPage.verifyHotelsPageLoaded();
        
        await $.pump(const Duration(milliseconds: 200));
      }
      
      debugPrint('✅ Navigation state persistence verified');
      await PatrolTestHelper.takeScreenshot($, 'state_persistence_verified');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'state_persistence_failed');
      fail('Navigation state persistence test failed: $e');
    }
  },
);

patrolTest(
  'Dashboard handles edge cases and error scenarios',
  ($) async {
    await initializeTest($);

    try {
      // Test multiple rapid taps on same tab
      debugPrint('🔧 Testing edge case: Multiple rapid taps on same tab');
      for (int i = 0; i < 5; i++) {
        await $(AppLocators.getNavigationTab('hotels')).tap();
        await $.pump(const Duration(milliseconds: 50));
      }
      await hotelsPage.verifyHotelsPageLoaded();
      
      // Test navigation during page transitions
      debugPrint('🔧 Testing edge case: Navigation during transitions');
      await $(AppLocators.getNavigationTab('favorites')).tap();
      await $(AppLocators.getNavigationTab('account')).tap();
      await $.pump(const Duration(milliseconds: 500));
      await accountPage.verifyAccountPageLoaded();
      
      // Test very rapid successive navigation
      debugPrint('🔧 Testing edge case: Very rapid successive navigation');
      const rapidTabs = ['overview', 'hotels', 'favorites', 'account'];
      for (final tab in rapidTabs) {
        await $(AppLocators.getNavigationTab(tab)).tap();
        await $.pump(const Duration(milliseconds: 10));
      }
      
      // Give time to settle and verify final state
      await $.pump(const Duration(seconds: 1));
      await accountPage.verifyAccountPageLoaded();
      
      // Verify dashboard is still functional after stress
      await dashboardPage.verifyDashboardLoaded();
      dashboardPage.verifyNavigationBarVisible();
      
      debugPrint('✅ Edge cases handled successfully');
      await PatrolTestHelper.takeScreenshot($, 'edge_cases_handled');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'edge_cases_failed');
      fail('Dashboard edge cases test failed: $e');
    }
  },
);

patrolTest(
  'Dashboard accessibility and usability verification',
  ($) async {
    await initializeTest($);

    try {
      // Verify all navigation elements have proper labels
      final navigationElements = [
        {'tab': 'overview', 'expectedText': 'Overview'},
        {'tab': 'hotels', 'expectedText': 'Hotels'},
        {'tab': 'favorites', 'expectedText': 'Favorites'},
        {'tab': 'account', 'expectedText': 'Account'},
      ];

      for (final element in navigationElements) {
        final tabFinder = AppLocators.getNavigationTab(element['tab']!);
        expect(tabFinder, findsOneWidget);
        
        // Verify tab has readable text
        expect(find.text(element['expectedText']!), findsOneWidget,
            reason: '${element['tab']} tab should have "${element['expectedText']}" text');
        
        debugPrint('✅ ${element['tab']} tab accessibility verified');
      }

      // Test keyboard/focus navigation (simulate tab traversal)
      debugPrint('🔧 Testing navigation accessibility');
      
      // Navigate through each tab to ensure they're all focusable/tappable
      for (final element in navigationElements) {
        await $(AppLocators.getNavigationTab(element['tab']!)).tap();
        await $.pump(const Duration(milliseconds: 300));
        
        // Verify the corresponding page loads
        switch (element['tab']) {
          case 'overview':
            await overviewPage.verifyOverviewPageLoaded();
            break;
          case 'hotels':
            await hotelsPage.verifyHotelsPageLoaded();
            break;
          case 'favorites':
            await favoritesPage.verifyFavoritesPageLoaded();
            break;
          case 'account':
            await accountPage.verifyAccountPageLoaded();
            break;
        }
        
        debugPrint('✅ ${element['tab']} navigation accessibility verified');
      }

      // Verify visual feedback for selected tab
      await dashboardPage.navigateToHotels();
      // The selected state should be visually indicated (handled by Flutter's NavigationBar)
      
      await PatrolTestHelper.takeScreenshot($, 'accessibility_verified');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'accessibility_failed');
      fail('Dashboard accessibility test failed: $e');
    }
  },
);

patrolTest(
  'Dashboard comprehensive health check with fallback locators',
  ($) async {
    await initializeTest($);

    try {
      debugPrint('🏥 Starting comprehensive dashboard health check');
      
      // Use AppLocators comprehensive validation
      AppLocators.performComprehensiveHealthCheck();
      
      // Demonstrate fallback strategies
      AppLocators.demonstrateFallbackStrategies();
      
      // Validate navigation system
      AppLocators.validateNavigation();
      
      // Test each page's health
      final pageTests = [
        {
          'name': 'Overview',
          'navigate': () => dashboardPage.navigateToOverview(),
          'verify': () => overviewPage.verifyOverviewPageLoaded(),
          'health': () => AppLocators.validateOverviewPage(),
        },
        {
          'name': 'Hotels',
          'navigate': () => dashboardPage.navigateToHotels(),
          'verify': () => hotelsPage.verifyHotelsPageLoaded(),
          'health': () => hotelsPage.verifySearchFieldVisible(),
        },
        {
          'name': 'Favorites',
          'navigate': () => dashboardPage.navigateToFavorites(),
          'verify': () => favoritesPage.verifyFavoritesPageLoaded(),
          'health': () => favoritesPage.verifyFavoritesTitle(),
        },
        {
          'name': 'Account',
          'navigate': () => dashboardPage.navigateToAccount(),
          'verify': () => accountPage.verifyAccountPageLoaded(),
          'health': () => accountPage.verifyAccountTitle(),
        },
      ];

      for (final pageTest in pageTests) {
        debugPrint('🔍 Health check: ${pageTest['name']} page');
        
        await (pageTest['navigate'] as Future<void> Function())();
        await (pageTest['verify'] as Future<void> Function())();
        (pageTest['health'] as void Function())();
        
        debugPrint('✅ ${pageTest['name']} page health check passed');
      }

      // Print comprehensive locator summary
      AppLocators.printLocatorSummary();
      
      // Final dashboard verification
      await dashboardPage.verifyDashboardLoaded();
      
      debugPrint('🎉 Comprehensive dashboard health check completed');
      await PatrolTestHelper.takeScreenshot($, 'comprehensive_health_check_passed');
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, 'comprehensive_health_check_failed');
      fail('Comprehensive dashboard health check failed: $e');
    }
  },
);

});
}
void main() {
dashboardTests();