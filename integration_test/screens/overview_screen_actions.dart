import 'package:patrol/patrol.dart';

import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';

class OverviewScreenActions {
  static Future<void> verifyOverviewPageStructure(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'overview page structure');

    for (final locator in [
      AppLocators.getOverviewScaffold($),
      AppLocators.getOverviewAppBar($),
      AppLocators.getOverviewTitle($),
      AppLocators.getOverviewIcon($),
    ]) {
      await locator.waitUntilVisible();
    }

    TestLogger.logTestSuccess($, 'Overview page structure verified');
  }
}
