import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/helpers/test_helper.dart';
import '../integration_test/page_objects/dashboard_page.dart';
import 'account_page.dart';

void accountTests() {
  group('Account Feature Tests', () {
    late DashboardPage dashboardPage;
    late AccountPage accountPage;

    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await PatrolTestHelper.initializeApp($);
      dashboardPage = DashboardPage($);
      accountPage = AccountPage($);
      await dashboardPage.verifyDashboardLoaded();
    }

    patrolTest(
      'Account page loads correctly',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToAccount();
          await accountPage.verifyAccountPageLoaded();

          accountPage.verifyAccountTitle();
          accountPage.verifyAccountIcon();

          await PatrolTestHelper.takeScreenshot($, 'account_page_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'account_page_failed');
          fail('Account page test failed: $e');
        }
      },
    );

    patrolTest(
      'Account page navigation stability',
      ($) async {
        await initializeTest($);

        try {
          await dashboardPage.navigateToHotels();
          await dashboardPage.navigateToAccount();
          await accountPage.verifyAccountPageLoaded();

          accountPage.verifyAccountTitle();
          accountPage.verifyAccountIcon();

          await PatrolTestHelper.takeScreenshot(
              $, 'account_navigation_verified');
        } catch (e) {
          await PatrolTestHelper.takeScreenshot($, 'account_navigation_failed');
          fail('Account navigation test failed: $e');
        }
      },
    );
  });
}

void main() {
  accountTests();
}
