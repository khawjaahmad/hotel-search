import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../locators/app_locators.dart';
import '../utils/test_helpers.dart';
import '../reports/allure_reporter.dart';

void main() {
  patrolTest(
    'Overview page loads and displays correctly',
    config: const PatrolTesterConfig(printLogs: true),
    ($) async {
      // Initialize Allure (now safe)
      await AllureReporter.initialize();
      AllureReporter.startTest('Overview Page Test');
      AllureReporter.setSeverity(AllureSeverity.critical);

      try {
        // Step 1: Initialize the app
        AllureReporter.reportStep('Initialize app');
        await TestHelpers.initializeApp($);

        // Step 2: Navigate to overview (should be default page)
        AllureReporter.reportStep('Verify overview page is loaded');
        await AppLocators.smartWaitFor($, $(AppLocators.getOverviewScaffold($)));

        // Step 3: Verify key elements exist
        AllureReporter.reportStep('Verify page elements');
        expect($(AppLocators.getOverviewTitle($)).exists, isTrue,
            reason: 'Overview title should be visible');
        expect($(AppLocators.getOverviewIcon($)).exists, isTrue,
            reason: 'Overview icon should be visible');
        expect($(AppLocators.getOverviewAppBar($)).exists, isTrue,
            reason: 'Overview app bar should be visible');

        // Step 4: Verify navigation system
        AllureReporter.reportStep('Validate navigation');
        await AppLocators.validateNavigation($);

        // Step 5: Test navigation functionality
        AllureReporter.reportStep('Test tab navigation');
        await AppLocators.smartTap(
            $, AppLocators.getNavigationTab($, 'hotels'));
        await $.pump(const Duration(seconds: 1));

        await AppLocators.smartTap(
            $, AppLocators.getNavigationTab($, 'overview'));
        await $.pump(const Duration(seconds: 1));

        AllureReporter.reportStep('Test completed successfully');
        await AllureReporter.finishTest(status: AllureTestStatus.passed);
      } catch (e, stackTrace) {
        AllureReporter.addAttachment(
            'error_log', 'Error: $e\nStackTrace: $stackTrace');
        await AllureReporter.finishTest(
          status: AllureTestStatus.failed,
          statusDetails: e.toString(),
        );
        fail('Overview page test failed: $e');
      }
    },
  );
}
