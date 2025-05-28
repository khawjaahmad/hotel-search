import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../screens/account_screen_actions.dart';
import '../strings/test_strings.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    AccountTestStrings.loadTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(AccountTestStrings.initializingTest);
      await TestHelpers.initializeApp($);
      $.log('Navigating to account page');
      await TestHelpers.navigateToPage($, AccountTestStrings.accountTabName);
      await AccountScreenActions.verifyAccountPageStructure($);
    },
  );

  patrolTest(
    AccountTestStrings.navigationTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(AccountTestStrings.initializingTest);
      await TestHelpers.initializeApp($);
      $.log('Navigating to account page');
      await TestHelpers.navigateToPage($, AccountTestStrings.accountTabName);
      await AccountScreenActions.verifyAccountPageStructure($);

      $.log(AccountTestStrings.navigationAway);
      await TestHelpers.navigateToPage($, 'hotels');

      $.log(AccountTestStrings.navigationBack);
      await TestHelpers.navigateToPage($, AccountTestStrings.accountTabName);

      await AccountScreenActions.verifyAccountPageStructure($);
    },
  );

  patrolTest(
    AccountTestStrings.themeTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(AccountTestStrings.initializingTest);

      await TestHelpers.initializeApp($);

      $.log('Navigating to account page');
      await TestHelpers.navigateToPage($, AccountTestStrings.accountTabName);
    },
  );
}
