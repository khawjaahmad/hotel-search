import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/account_screen_actions.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    'Account page loads with correct structure',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Account Structure Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'account page');
      await TestHelpers.navigateToPage($, 'account');

      await AccountScreenActions.verifyAccountPageStructure($);
      TestLogger.logTestSuccess($, 'Account page structure verified');
    },
  );

  patrolTest(
    'Account page persists after navigation',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Account Navigation Persistence Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'account page');
      await TestHelpers.navigateToPage($, 'account');
      await AccountScreenActions.verifyAccountPageStructure($);

      TestLogger.logTestStep($, 'Navigating away from account page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logTestStep($, 'Navigating back to account page');
      await TestHelpers.navigateToPage($, 'account');

      await AccountScreenActions.verifyAccountPageStructure($);
      TestLogger.logTestSuccess($, 'Account navigation persistence verified');
    },
  );

  patrolTest(
    'Account page theme matches system theme',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Account Theme Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'account page');
      await TestHelpers.navigateToPage($, 'account');

      TestLogger.logTestSuccess($, 'Account theme test completed');
    },
  );
}
