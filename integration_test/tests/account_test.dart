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

    void verifyAccountPageStructure(PatrolIntegrationTester $) {
      expect(find.byType(Scaffold).evaluate().isNotEmpty, isTrue,
          reason: 'Should have Scaffold structure');
      expect(find.byType(AppBar).evaluate().isNotEmpty, isTrue,
          reason: 'Should have AppBar structure');
      expect(find.byType(Center).evaluate().isNotEmpty, isTrue,
          reason: 'Should have Center layout');
      expect(find.byType(Icon).evaluate().isNotEmpty, isTrue,
          reason: 'Should have Icon widget');
    }

    Future<void> performNavigationCycle(
        PatrolIntegrationTester $, int cycles) async {
      for (int i = 0; i < cycles; i++) {
        await navigateToAccount($);
        verifyAccountPageElements($);
        verifyAccountContent($);

        await TestHelpers.navigateToPage($, 'overview',
            description: 'Return to Overview');
        await $.pump(const Duration(milliseconds: 200));
      }
    }

    Future<Duration> performStressTest(
        PatrolIntegrationTester $, int iterations) async {
      final startTime = DateTime.now();

      for (int i = 0; i < iterations; i++) {
        final accountTab = AppLocators.getAccountTab($);
        final overviewTab = AppLocators.getOverviewTab($);

        await AppLocators.smartTap($, accountTab);
        await $.pump(const Duration(milliseconds: 50));
        await AppLocators.smartTap($, overviewTab);
        await $.pump(const Duration(milliseconds: 50));
      }

      final endTime = DateTime.now();
      return endTime.difference(startTime);
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

    patrolTest(
      'Account page layout is correct',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Layout');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToAccount($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify page structure');
          verifyAccountPageStructure($);
          AllureReporter.reportStep('Page structure verified',
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
      'Account page navigation stability',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Navigation');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Multiple navigation to Account page');
          await performNavigationCycle($, 3);
          AllureReporter.reportStep('Multiple navigation cycles completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Final navigation to Account');
          await navigateToAccount($);
          verifyAccountPageElements($);
          AllureReporter.reportStep('Final navigation verified',
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
      'Account page accessibility elements',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Accessibility');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToAccount($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify semantic elements');
          verifyAccountPageElements($);
          AllureReporter.reportStep('Semantic elements verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify text elements for screen readers');
          expect(find.text('Your Account').evaluate().isNotEmpty, isTrue,
              reason: 'Should have page title');
          expect(find.text('Account').evaluate().isNotEmpty, isTrue,
              reason: 'Should have navigation tab label');
          AllureReporter.reportStep('Text elements verified',
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
      'Account page performance under stress',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Performance');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform rapid navigation stress test');
          final duration = await performStressTest($, 10);
          AllureReporter.reportStep(
              'Stress test completed in ${duration.inMilliseconds}ms',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify page stability after stress');
          final accountTab = AppLocators.getAccountTab($);
          await AppLocators.smartTap($, accountTab);
          await $.pumpAndSettle();
          verifyAccountPageElements($);
          verifyAccountContent($);
          AllureReporter.reportStep('Page stability verified',
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
      'Account page visual consistency',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Account Visual');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToAccount($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify consistent theming');
          expect(find.byType(MaterialApp).evaluate().isNotEmpty, isTrue,
              reason: 'Should have MaterialApp theme');
          expect(find.byType(Scaffold).evaluate().isNotEmpty, isTrue,
              reason: 'Should have Scaffold structure');
          AllureReporter.reportStep('Theme consistency verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify icon and text positioning');
          verifyAccountPageStructure($);
          AllureReporter.reportStep('Layout positioning verified',
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
