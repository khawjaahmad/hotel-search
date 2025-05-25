import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/app_locators.dart';

class DashboardPage extends BasePage {
  DashboardPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'dashboard';

  @override
  String get pageKey => AppLocators.dashboardScaffold;

  Future<void> navigateToOverview() async {
    logAction('Navigating to Overview tab');
    await tapElement(AppLocators.overviewTab);
    await waitForLoadingToComplete();
    await takePageScreenshot('overview_selected');
  }

  Future<void> navigateToHotels() async {
    logAction('Navigating to Hotels tab');
    await tapElement(AppLocators.hotelsTab);
    await waitForLoadingToComplete();
    await takePageScreenshot('hotels_selected');
  }

  Future<void> navigateToFavorites() async {
    logAction('Navigating to Favorites tab');
    await tapElement(AppLocators.favoritesTab);
    await waitForLoadingToComplete();
    await takePageScreenshot('favorites_selected');
  }

  Future<void> navigateToAccount() async {
    logAction('Navigating to Account tab');
    await tapElement(AppLocators.accountTab);
    await waitForLoadingToComplete();
    await takePageScreenshot('account_selected');
  }

  void verifyNavigationBarVisible() {
    logAction('Verifying navigation bar is visible');
    verifyElementExists(AppLocators.navigationBar);
  }

  void verifyAllTabsVisible() {
    logAction('Verifying all navigation tabs are visible');
    verifyElementExists(AppLocators.overviewTab);
    verifyElementExists(AppLocators.hotelsTab);
    verifyElementExists(AppLocators.favoritesTab);
    verifyElementExists(AppLocators.accountTab);
  }

  Future<void> verifyDashboardLoaded() async {
    logAction('Verifying dashboard is fully loaded');
    await verifyPageIsLoaded();
    verifyNavigationBarVisible();
    verifyAllTabsVisible();
  }

  Future<void> navigateThroughAllTabs() async {
    logAction('Navigating through all tabs');

    await navigateToOverview();
    await $.pump(const Duration(milliseconds: 500));

    await navigateToHotels();
    await $.pump(const Duration(milliseconds: 500));

    await navigateToFavorites();
    await $.pump(const Duration(milliseconds: 500));

    await navigateToAccount();
    await $.pump(const Duration(milliseconds: 500));
  }

  Future<void> verifyNavigationWorking() async {
    logAction('Verifying navigation is working correctly');

    await navigateToHotels();
    await $.pump(const Duration(seconds: 1));

    await navigateToFavorites();
    await $.pump(const Duration(seconds: 1));

    await navigateToAccount();
    await $.pump(const Duration(seconds: 1));

    await navigateToOverview();
    await $.pump(const Duration(seconds: 1));

    logAction('Navigation verification completed');
  }

  Future<void> takeNavigationScreenshots() async {
    logAction('Taking navigation screenshots');

    await navigateToOverview();
    await takePageScreenshot('overview_tab');

    await navigateToHotels();
    await takePageScreenshot('hotels_tab');

    await navigateToFavorites();
    await takePageScreenshot('favorites_tab');

    await navigateToAccount();
    await takePageScreenshot('account_tab');
  }
}
