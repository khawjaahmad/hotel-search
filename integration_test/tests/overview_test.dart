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
  group('Overview Feature Integration Tests', () {
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

    patrolTest(
      'Overview page loads and displays correctly',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Overview page loads and displays correctly',
          description:
              'Verify that overview page loads with all required elements',
          labels: ['feature:overview', 'priority:critical', 'component:page'],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);

          EnhancedAllureHelper.reportStep('Verify overview page loaded');
          await AppLocators.smartWaitFor($, AppLocators.getOverviewScaffold($));

          EnhancedAllureHelper.reportStep('Verify page elements present');
          verifyOverviewPageElements($);

          EnhancedAllureHelper.reportStep('Validate navigation system');
          await AppLocators.validateNavigation($);

          await EnhancedAllureHelper.finishTest(
            'Overview page loads and displays correctly',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Test execution failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Overview page loads and displays correctly',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Overview page displays correct branding content',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Overview page displays correct branding content',
          description: 'Verify branding elements and content display correctly',
          labels: [
            'feature:overview',
            'priority:critical',
            'component:branding'
          ],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);
          await navigateToOverview($);

          EnhancedAllureHelper.reportStep('Verify branding content displayed');
          verifyOverviewContent($);

          EnhancedAllureHelper.reportStep('Verify page title in app bar');
          final titleFinder = AppLocators.getOverviewTitle($);
          await AppLocators.smartWaitFor($, titleFinder);

          await EnhancedAllureHelper.finishTest(
            'Overview page displays correct branding content',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Branding verification failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Overview page displays correct branding content',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Overview page navigation functionality works',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Overview page navigation functionality works',
          description:
              'Test navigation flow from overview to other pages and back',
          labels: [
            'feature:overview',
            'priority:critical',
            'component:navigation'
          ],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);

          EnhancedAllureHelper.reportStep('Execute navigation flow test');
          await testNavigationFlow($);

          EnhancedAllureHelper.reportStep('Verify return to overview state');
          verifyOverviewPageElements($);
          verifyOverviewContent($);

          await EnhancedAllureHelper.finishTest(
            'Overview page navigation functionality works',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Navigation flow test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Overview page navigation functionality works',
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
