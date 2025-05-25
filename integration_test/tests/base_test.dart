import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_helper.dart';
import '../page_objects/dashboard_page.dart';
import '../page_objects/hotels_page.dart';
import '../page_objects/favorites_page.dart';


class BaseTestHelper {
  static late DashboardPage dashboardPage;

  static late HotelsPage hotelsPage;
  static late FavoritesPage favoritesPage;


  static Future<void> initializeTest(PatrolIntegrationTester $) async {
    await PatrolTestHelper.initializeApp($);

    dashboardPage = DashboardPage($);

    hotelsPage = HotelsPage($);
    favoritesPage = FavoritesPage($);
  

    await dashboardPage.verifyDashboardLoaded();
  }

  static Future<void> navigateToTab(
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

  static Future<void> takeTestScreenshot(
      PatrolIntegrationTester $, String testName, String suffix) async {
    await PatrolTestHelper.takeScreenshot($, '${testName}_$suffix');
  }

  static Future<void> waitForStableState(PatrolIntegrationTester $) async {
    await $.pump(const Duration(seconds: 1));
    await PatrolTestHelper.waitForLoadingToComplete($);
  }

  static const List<String> testSearchQueries = [
    'New York',
    'London',
    'Paris',
    'Tokyo'
  ];
  static const String mockHotelId = '48.8566,2.3522';
  static const List<String> mockHotelIds = [
    '48.8566,2.3522',
    '51.5074,-0.1278',
    '40.7128,-74.0060',
  ];

  static Future<void> verifyCleanState(PatrolIntegrationTester $) async {
    await dashboardPage.verifyDashboardLoaded();
    await overviewPage.verifyOverviewPageLoaded();
  }

  static void handleTestFailure(String testName, dynamic error) {
    fail('Test $testName failed: $error');
  }

  static Future<T> executeWithErrorHandling<T>(
    PatrolIntegrationTester $,
    String testName,
    Future<T> Function() testFunction,
  ) async {
    try {
      return await testFunction();
    } catch (e) {
      await PatrolTestHelper.takeScreenshot($, '${testName}_failed');
      handleTestFailure(testName, e);
      rethrow;
    }
  }

  static Future<void> waitForElementsStable(PatrolIntegrationTester $) async {
    await $.pumpAndSettle();
    await $.pump(const Duration(milliseconds: 500));
  }

  static void verifyNavigationAccessible() {
    dashboardPage.verifyNavigationBarVisible();
    dashboardPage.verifyAllTabsVisible();
  }

  static Future<void> commonSetUp(PatrolIntegrationTester $) async {
    await initializeTest($);
    await waitForElementsStable($);
  }

  static Future<void> commonTearDown(
      PatrolIntegrationTester $, String testName) async {
    try {
      await PatrolTestHelper.takeScreenshot($, '${testName}_completed');
    } catch (e) {
      print('Screenshot error during teardown: $e');
    }
  }

  static Future<void> performCompleteWorkflow(PatrolIntegrationTester $) async {
    await navigateToTab($, 'overview');
    await navigateToTab($, 'hotels');
    await navigateToTab($, 'favorites');
    await navigateToTab($, 'account');
    await navigateToTab($, 'overview');

    await verifyCleanState($);
  }

  static bool isValidTestData() {
    return testSearchQueries.isNotEmpty &&
        mockHotelIds.isNotEmpty &&
        mockHotelId.isNotEmpty;
  }

  static Future<Duration> measureNavigationPerformance(
    PatrolIntegrationTester $,
    int cycles,
  ) async {
    final startTime = DateTime.now();

    for (int i = 0; i < cycles; i++) {
      await dashboardPage.navigateToHotels();
      await dashboardPage.navigateToFavorites();
      await dashboardPage.navigateToAccount();
      await dashboardPage.navigateToOverview();
    }

    final endTime = DateTime.now();
    return endTime.difference(startTime);
  }
}
