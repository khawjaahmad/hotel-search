import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../locators/app_locators.dart';

void main() {
  group('Dashboard Feature Integration Tests', () {
    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await TestUtils.initializeAllure();
      await TestHelpers.initializeApp($);
    }

    void verifyDashboardStructure(PatrolIntegrationTester $) {
      final scaffold = AppLocators.getDashboardScaffold($);
      final navigationBar = AppLocators.getNavigationBar($);

      expect(AppLocators.elementExists($, scaffold), isTrue,
          reason: 'Dashboard scaffold should be present');
      expect(AppLocators.elementExists($, navigationBar), isTrue,
          reason: 'Navigation bar should be present');
    }

    void verifyAllNavigationTabs(PatrolIntegrationTester $) {
      final tabs = ['overview', 'hotels', 'favorites', 'account'];

      for (final tab in tabs) {
        final tabFinder = AppLocators.getNavigationTab($, tab);
        expect(AppLocators.elementExists($, tabFinder), isTrue,
            reason: '$tab tab should be present');
      }
    }

    Future<void> performNavigationCycle(PatrolIntegrationTester $) async {
      final navigationSteps = [
        {'tab': 'hotels', 'scaffold': AppLocators.getHotelsScaffold($)},
        {'tab': 'favorites', 'scaffold': AppLocators.getFavoritesScaffold($)},
        {'tab': 'account', 'scaffold': AppLocators.getAccountScaffold($)},
        {'tab': 'overview', 'scaffold': AppLocators.getOverviewScaffold($)},
      ];

      for (final step in navigationSteps) {
        final tabName = step['tab']! as String;
        final scaffoldFinder = step['scaffold']! as PatrolFinder;

        final tabFinder = AppLocators.getNavigationTab($, tabName);
        await AppLocators.smartTap($, tabFinder);
        await $.pumpAndSettle();

        expect(AppLocators.elementExists($, scaffoldFinder), isTrue,
            reason: '$tabName page should be loaded');
      }
    }

    patrolTest(
      'Dashboard loads with navigation tabs',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify dashboard scaffold');
          verifyDashboardStructure($);
          AllureReporter.reportStep('Dashboard structure verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify all navigation tabs');
          verifyAllNavigationTabs($);
          AllureReporter.reportStep('All tabs verified',
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
      'Navigation between tabs works',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard Navigation');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform navigation cycle');
          await performNavigationCycle($);
          AllureReporter.reportStep('Navigation cycle completed',
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
