import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../locators/app_locators.dart';

void main() {
  group('Account Feature Integration Tests', () {
    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await TestUtils.initializeAllure();
      await TestHelpers.initializeApp($);
    }

    Future<void> navigateToAccount(PatrolIntegrationTester $) async {
      await TestHelpers.navigateToPage($, 'account',
          description: 'Navigating to Account page');
    }

    void verifyAccountPageElements(PatrolIntegrationTester $) {
      final scaffold = AppLocators.getAccountScaffold($);
      final appBar = AppLocators.getAccountAppBar($);
      final title = AppLocators.getAccountTitle($);
      final icon = AppLocators.getAccountIcon($);

      expect(AppLocators.elementExists($, scaffold), isTrue,
          reason: 'Account scaffold should be present');
      expect(AppLocators.elementExists($, appBar), isTrue,
          reason: 'Account app bar should be present');
      expect(AppLocators.elementExists($, title), isTrue,
          reason: 'Account title should be present');
      expect(AppLocators.elementExists($, icon), isTrue,
          reason: 'Account icon should be present');
    }

    void verifyAccountContent(PatrolIntegrationTester $) {
      expect(find.text('Your Account').evaluate().isNotEmpty, isTrue,
          reason: 'Should display "Your Account" title');
      expect(find.byIcon(Icons.account_circle_outlined).evaluate().isNotEmpty,
          isTrue,
          reason: 'Should display account icon');
    }

    patrolTest(
      'Account page loads correctly',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Page');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate to Account page');
          await navigateToAccount($);
          AllureReporter.reportStep('Navigation completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify account page elements');
          verifyAccountPageElements($);
          AllureReporter.reportStep('Account page elements verified',
              status: AllureStepStatus.passed);

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason: 'Test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Account page displays correct title and content',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Content');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToAccount($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify account title text');
          verifyAccountContent($);
          AllureReporter.reportStep('Account content verified',
              status: AllureStepStatus.passed);

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason: 'Test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );
  });
}
