import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../locators/app_locators.dart';

void main() {
  group('Overview Feature Integration Tests', () {
    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await TestUtils.initializeAllure();
      await TestHelpers.initializeApp($);
    }

    Future<void> navigateToOverview(PatrolIntegrationTester $) async {
      await TestHelpers.navigateToPage($, 'overview',
          description: 'Navigating to Overview page');
    }

    void verifyOverviewPageElements(PatrolIntegrationTester $) {
      final scaffold = AppLocators.getOverviewScaffold($);
      final title = AppLocators.getOverviewTitle($);
      final icon = AppLocators.getOverviewIcon($);
      final appBar = AppLocators.getOverviewAppBar($);

      expect(AppLocators.elementExists($, scaffold), isTrue,
          reason: 'Overview scaffold should be present');
      expect(AppLocators.elementExists($, title), isTrue,
          reason: 'Overview title should be present');
      expect(AppLocators.elementExists($, icon), isTrue,
          reason: 'Overview icon should be present');
      expect(AppLocators.elementExists($, appBar), isTrue,
          reason: 'Overview app bar should be present');
    }

    void verifyOverviewContent(PatrolIntegrationTester $) {
      expect(find.text('Hotel Booking').evaluate().isNotEmpty, isTrue,
          reason: 'Should display "Hotel Booking" title');
      expect(find.byIcon(Icons.explore_outlined).evaluate().isNotEmpty, isTrue,
          reason: 'Should display explore icon');
    }

    void verifyOverviewPageStructure(PatrolIntegrationTester $) {
      expect(find.byType(Scaffold).evaluate().isNotEmpty, isTrue,
          reason: 'Should have Scaffold structure');
      expect(find.byType(AppBar).evaluate().isNotEmpty, isTrue,
          reason: 'Should have AppBar structure');
      expect(find.byType(Center).evaluate().isNotEmpty, isTrue,
          reason: 'Should have Center layout');
      expect(find.byType(Icon).evaluate().isNotEmpty, isTrue,
          reason: 'Should have Icon widget');
    }

    Future<void> testNavigationFlow(PatrolIntegrationTester $) async {
      final tabs = ['hotels', 'favorites', 'account'];

      for (final tab in tabs) {
        final tabFinder = AppLocators.getNavigationTab($, tab);
        await AppLocators.smartTap($, tabFinder);
        await $.pump(const Duration(milliseconds: 500));
      }

      final overviewTab = AppLocators.getOverviewTab($);
      await AppLocators.smartTap($, overviewTab);
      await $.pump(const Duration(milliseconds: 500));
    }

    Future<void> testOverviewAsDefaultPage(PatrolIntegrationTester $) async {
      await initializeTest($);
      await $.pump(const Duration(seconds: 1));
      verifyOverviewPageElements($);
      verifyOverviewContent($);
    }

    Future<Duration> performNavigationStressTest(
        PatrolIntegrationTester $, int iterations) async {
      final startTime = DateTime.now();

      for (int i = 0; i < iterations; i++) {
        await testNavigationFlow($);
        await $.pump(const Duration(milliseconds: 100));
      }

      final endTime = DateTime.now();
      return endTime.difference(startTime);
    }

    patrolTest(
      'Overview page loads and displays correctly',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Page');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify overview page is loaded');
          await AppLocators.smartWaitFor($, AppLocators.getOverviewScaffold($));
          AllureReporter.reportStep('Overview page loaded',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify page elements');
          verifyOverviewPageElements($);
          AllureReporter.reportStep('Page elements verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Validate navigation');
          await AppLocators.validateNavigation($);
          AllureReporter.reportStep('Navigation validated',
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
      'Overview page displays correct branding content',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Branding');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToOverview($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify branding content');
          verifyOverviewContent($);
          AllureReporter.reportStep('Branding content verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify page title in app bar');
          final titleFinder = AppLocators.getOverviewTitle($);
          await AppLocators.smartWaitFor($, titleFinder);
          AllureReporter.reportStep('Page title verified',
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
      'Overview page layout structure is correct',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Layout');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToOverview($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify page structure');
          verifyOverviewPageStructure($);
          AllureReporter.reportStep('Page structure verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify widget hierarchy');
          expect(find.byType(MaterialApp).evaluate().isNotEmpty, isTrue,
              reason: 'Should have MaterialApp root');
          AllureReporter.reportStep('Widget hierarchy verified',
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
      'Overview page navigation functionality works',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Navigation');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Test navigation flow');
          await testNavigationFlow($);
          AllureReporter.reportStep('Navigation flow completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify return to overview');
          verifyOverviewPageElements($);
          verifyOverviewContent($);
          AllureReporter.reportStep('Return to overview verified',
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
      'Overview page is default page on app launch',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Default');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Test default page behavior');
          await testOverviewAsDefaultPage($);
          AllureReporter.reportStep('Default page behavior verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify no manual navigation needed');
          verifyOverviewPageElements($);
          AllureReporter.reportStep('Automatic navigation verified',
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
      'Overview page performance under navigation stress',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Performance');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform navigation stress test');
          final duration = await performNavigationStressTest($, 5);
          AllureReporter.reportStep(
              'Stress test completed in ${duration.inMilliseconds}ms',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify page stability after stress');
          verifyOverviewPageElements($);
          verifyOverviewContent($);
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
      'Overview page visual consistency and theming',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Overview Visual');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToOverview($);
          AllureReporter.reportStep('App initialized and navigated',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify theme consistency');
          expect(find.byType(MaterialApp).evaluate().isNotEmpty, isTrue,
              reason: 'Should have consistent Material theme');
          expect(find.byType(Scaffold).evaluate().isNotEmpty, isTrue,
              reason: 'Should use Scaffold structure');
          AllureReporter.reportStep('Theme consistency verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify icon and layout positioning');
          verifyOverviewPageStructure($);
          final iconFinder = AppLocators.getOverviewIcon($);
          await AppLocators.smartWaitFor($, iconFinder);
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
