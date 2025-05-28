import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';

class OverviewScreenActions {
  static Future<void> verifyOverviewPageStructure(
      PatrolIntegrationTester $) async {
    for (final locator in [
      AppLocators.getOverviewScaffold($),
      AppLocators.getOverviewAppBar($),
      AppLocators.getOverviewTitle($),
      AppLocators.getOverviewIcon($),
    ]) {
      await locator.waitUntilVisible();
    }
  }
}
