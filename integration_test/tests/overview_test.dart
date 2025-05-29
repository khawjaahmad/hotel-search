import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/overview_screen_actions.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    'Overview structure test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Overview Structure Test');
      await TestHelpers.initializeApp($);

      TestLogger.logValidation($, 'overview page structure');
      await OverviewScreenActions.verifyOverviewPageStructure($);
    },
  );
}
