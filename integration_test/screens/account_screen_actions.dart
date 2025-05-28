import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';
import '../strings/test_strings.dart';

class AccountScreenActions {
  static Future<void> verifyAccountPageStructure(
      PatrolIntegrationTester $) async {
    $.log(AccountTestStrings.verifyingStructure);

    final locators = [
      AppLocators.getAccountScaffold($),
      AppLocators.getAccountAppBar($),
      AppLocators.getAccountTitle($)
          .containing(AccountTestStrings.accountTitle),
      AppLocators.getAccountIcon($),
    ];

    for (final locator in locators) {
      await locator.waitUntilExists();
    }

    expect(AppLocators.getAccountAppBar($).evaluate(), hasLength(1));
  }
}
