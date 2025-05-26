import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_helpers.dart';
import '../utils/test_utils.dart';
import '../config/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../helpers/allure_helper.dart';
import '../locators/app_locators.dart';

void main() {
  group('Dashboard Feature Integration Tests', () {
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
        await EnhancedAllureHelper.startTest(
          'Dashboard loads with navigation tabs',
          description:
              'Verify dashboard loads correctly with all navigation tabs',
          labels: [
            'feature:dashboard',
            'component:navigation',
            'priority:critical'
          ],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);

          EnhancedAllureHelper.reportStep(
              'Verify dashboard scaffold structure');
          verifyDashboardStructure($);

          EnhancedAllureHelper.reportStep('Verify all navigation tabs present');
          verifyAllNavigationTabs($);

          await EnhancedAllureHelper.finishTest(
            'Dashboard loads with navigation tabs',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Dashboard load test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Dashboard loads with navigation tabs',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Navigation between tabs works',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Navigation between tabs works',
          description:
              'Verify navigation functionality between all dashboard tabs',
          labels: [
            'feature:dashboard',
            'component:navigation',
            'priority:critical'
          ],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);

          EnhancedAllureHelper.reportStep('Perform complete navigation cycle');
          await performNavigationCycle($);

          await EnhancedAllureHelper.finishTest(
            'Navigation between tabs works',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Navigation cycle test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Navigation between tabs works',
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
