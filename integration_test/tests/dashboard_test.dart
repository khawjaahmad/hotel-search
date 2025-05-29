import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/dashboard_screen_actions.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    'Dashboard Load Test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Dashboard Load Test');
      await TestHelpers.initializeApp($);

      TestLogger.logValidation($, 'dashboard structure');
      await DashboardScreenActions.verifyDashboardStructure($);

      TestLogger.logTestSuccess($, 'Dashboard loaded successfully');
    },
  );

  patrolTest(
    'Dashboard Navigation Test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Dashboard Navigation Test');
      await TestHelpers.initializeApp($);

      TestLogger.logValidation($, 'dashboard structure');
      await DashboardScreenActions.verifyDashboardStructure($);

      TestLogger.logTestStep($, 'Testing navigation between tabs');
      await TestHelpers.navigateToPage($, 'hotels');
      await TestHelpers.navigateToPage($, 'favorites');
      await TestHelpers.navigateToPage($, 'account');
      await TestHelpers.navigateToPage($, 'overview');

      await DashboardScreenActions.verifyDashboardStructure($);
      TestLogger.logTestSuccess($, 'Navigation test completed');
    },
  );
}
