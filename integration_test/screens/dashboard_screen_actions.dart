import 'package:patrol/patrol.dart';

import '../helpers/test_helpers.dart';
import '../locators/app_locators.dart';

class DashboardScreenActions {
  static Future<void> verifyDashboardStructure(
      PatrolIntegrationTester $) async {
    final scaffold = AppLocators.getDashboardScaffold($);
    await scaffold.waitUntilVisible();

    final navigationBar = AppLocators.getNavigationBar($);
    await navigationBar.waitUntilVisible();

    await AppLocators.getOverviewTab($).waitUntilVisible();
    await AppLocators.getHotelsTab($).waitUntilVisible();
    await AppLocators.getFavoritesTab($).waitUntilVisible();
    await AppLocators.getAccountTab($).waitUntilVisible();
  }

  static Future<void> verifyNavigationWorks(PatrolIntegrationTester $) async {
    final tabs = [
      'overview',
      'hotels',
      'favorites',
      'account',
    ];

    for (final tab in tabs) {
      await TestHelpers.navigateToPage($, tab);
      await $.pump(const Duration(milliseconds: 500));
      await $.pumpAndSettle();
    }
  }
}
