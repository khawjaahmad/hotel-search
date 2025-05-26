import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../helpers/allure_helper.dart';
import '../locators/app_locators.dart';

void main() {
  group('Account Feature Integration Tests', () {
    setUpAll(() async {
      await EnhancedAllureHelper.initialize();
    });

    tearDownAll(() async {
      await EnhancedAllureHelper.finalize();
    });

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
        await EnhancedAllureHelper.startTest(
          'Account page loads correctly',
          description: 'Verify account page loads with all required elements',
          labels: [
            'feature:account',
            'component:page_load',
            'priority:critical'
          ],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);

          EnhancedAllureHelper.reportStep('Navigate to Account page');
          await navigateToAccount($);

          EnhancedAllureHelper.reportStep('Verify account page elements');
          verifyAccountPageElements($);

          await EnhancedAllureHelper.finishTest(
            'Account page loads correctly',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Account page load test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Account page loads correctly',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Account page displays correct title and content',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Account page displays correct title and content',
          description:
              'Verify account page displays correct title and content elements',
          labels: ['feature:account', 'component:content', 'priority:critical'],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);
          await navigateToAccount($);

          EnhancedAllureHelper.reportStep('Verify account title and content');
          verifyAccountContent($);

          await EnhancedAllureHelper.finishTest(
            'Account page displays correct title and content',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Account content verification failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Account page displays correct title and content',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );
  });
}
