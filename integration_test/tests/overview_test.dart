import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
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
      $.log('Initializing overview test');
      await TestHelpers.initializeApp($);

      $.log('Verifying overview page structure');
      await OverviewScreenActions.verifyOverviewPageStructure($);
    },
  );
}
