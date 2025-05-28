import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../screens/dashboard_screen_actions.dart';
import '../strings/test_strings.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    DashboardTestStrings.loadTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(DashboardTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(DashboardTestStrings.verifyingStructure);
      await DashboardScreenActions.verifyDashboardStructure($);
    },
  );

  patrolTest(
    DashboardTestStrings.navigationTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(DashboardTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      // First verify structure
      $.log(DashboardTestStrings.verifyingStructure);
      await DashboardScreenActions.verifyDashboardStructure($);

      // Then test navigation
      $.log(DashboardTestStrings.navigationStarted);
      await TestHelpers.navigateToPage($, 'hotels');
      await TestHelpers.navigateToPage($, 'favorites');
      await TestHelpers.navigateToPage($, 'account');
      await TestHelpers.navigateToPage(
          $, DashboardTestStrings.dashboardTabName);

      // Verify structure again after navigation
      await DashboardScreenActions.verifyDashboardStructure($);
    },
  );
}
