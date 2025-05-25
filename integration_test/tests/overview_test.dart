import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_helper.dart';
import '../page_objects/dashboard_page.dart';
import '../page_objects/overview_page.dart';

void overviewTests() {
  group('Overview Feature Tests', () {
    late DashboardPage dashboardPage;
    late OverviewPage overviewPage;

    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await PatrolTestHelper.initializeApp($);
      dashboardPage = DashboardPage($);
      overviewPage = OverviewPage($);
      await dashboardPage.verifyDashboardLoaded();
    }

    patrolTest(
      'Overview page loads as default landing page',
      ($) async {
        await initializeTest($);

        try {
          await overviewPage.verifyOverviewPageLoaded();

          overviewPage.verifyOverviewTitle();
          overviewPage.verifyOverviewIcon();

          await PatrolTestHelper.takeScreenshot($, 'overview_landing_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'overview_landing_failed');
          fail('Overview landing page test failed: $e');
        }
      },
    );

    patrolTest(
      'Overview page navigation integration',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await $.pump(const Duration(milliseconds: 500));

          await dashboardPage.navigateToOverview();
          await overviewPage.verifyOverviewPageLoaded();

          overviewPage.verifyOverviewTitle();
          overviewPage.verifyOverviewIcon();

          await PatrolTestHelper.takeScreenshot(
              $, 'overview_navigation_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot(
              $, 'overview_navigation_failed');
          fail('Overview navigation test failed: $e');
        }
      },
    );
  });
}

void main() {
  overviewTests();
}
