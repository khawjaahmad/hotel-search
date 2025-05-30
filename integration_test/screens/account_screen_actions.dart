import 'package:patrol/patrol.dart';

import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';

class AccountScreenActions {
  static Future<void> verifyAccountPageStructure(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'account page structure');

    final locators = [
      AppLocators.getAccountScaffold($),
      AppLocators.getAccountAppBar($),
      AppLocators.getAccountTitle($).containing('Your Account'),
      AppLocators.getAccountIcon($),
    ];

    for (final locator in locators) {
      await locator.waitUntilExists();
    }

    final appBarElements = AppLocators.getAccountAppBar($).evaluate();
    if (appBarElements.length != 1) {
      throw Exception(
          'Expected exactly 1 app bar, found ${appBarElements.length}');
    }

    TestLogger.logTestSuccess($, 'Account page structure verified');
  }
}
