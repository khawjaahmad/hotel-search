import 'package:flutter/material.dart';
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

    void verifyTabLabels(PatrolIntegrationTester $) {
      final expectedLabels = ['Overview', 'Hotels', 'Favorites', 'Account'];

      for (final label in expectedLabels) {
        expect(find.text(label).evaluate().isNotEmpty, isTrue,
            reason: '$label text should be visible');
      }
    }

    void verifyTabIcons(PatrolIntegrationTester $) {
      final expectedIcons = [
        Icons.explore_outlined,
        Icons.hotel_outlined,
        Icons.favorite_outline,
        Icons.account_circle_outlined,
      ];

      for (final icon in expectedIcons) {
        expect(find.byIcon(icon).evaluate().isNotEmpty, isTrue,
            reason: 'Icon $icon should be visible');
      }
    }

    Future<void> performNavigationCycle(PatrolIntegrationTester $) async {
      final navigationSteps = [
        {'tab': 'hotels', 'scaffold': 'hotels_scaffold'},
        {'tab': 'favorites', 'scaffold': 'favorites_scaffold'},
        {'tab': 'account', 'scaffold': 'account_scaffold'},
        {'tab': 'overview', 'scaffold': 'overview_scaffold'},
      ];

      for (final step in navigationSteps) {
        final tabName = step['tab']!;
        final scaffoldKey = step['scaffold']!;

        final tabFinder = AppLocators.getNavigationTab($, tabName);
        await AppLocators.smartTap($, tabFinder);
        await $.pumpAndSettle();

        expect(find.byKey(Key(scaffoldKey)).evaluate().isNotEmpty, isTrue,
            reason: '$tabName page should be loaded');
      }
    }

    Future<Duration> performRapidSwitching(
        PatrolIntegrationTester $, int cycles) async {
      final startTime = DateTime.now();

      for (int i = 0; i < cycles; i++) {
        final tabs = ['hotels', 'favorites', 'account', 'overview'];

        for (final tab in tabs) {
          final tabFinder = AppLocators.getNavigationTab($, tab);
          await AppLocators.smartTap($, tabFinder);
          await $.pump(const Duration(milliseconds: 100));
        }
      }

      final endTime = DateTime.now();
      return endTime.difference(startTime);
    }

    void verifyDefaultOverviewPage(PatrolIntegrationTester $) {
      final overviewScaffold = AppLocators.getOverviewScaffold($);
      expect(AppLocators.elementExists($, overviewScaffold), isTrue,
          reason: 'Overview should be default page');
      expect(find.text('Hotel Booking').evaluate().isNotEmpty, isTrue,
          reason: 'Hotel Booking title should be visible');
    }

    Future<void> testNavigationPersistence(PatrolIntegrationTester $) async {
      await performNavigationCycle($);
      verifyDashboardStructure($);
      verifyDefaultOverviewPage($);
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

    patrolTest(
      'Tab labels and icons display correctly',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard UI');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify tab labels');
          verifyTabLabels($);
          AllureReporter.reportStep('Tab labels verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify tab icons');
          verifyTabIcons($);
          AllureReporter.reportStep('Tab icons verified',
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
      'Rapid tab switching stability',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard Performance');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform rapid tab switching');
          final duration = await performRapidSwitching($, 3);
          AllureReporter.reportStep(
              'Rapid switching completed in ${duration.inMilliseconds}ms',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify app stability');
          verifyDashboardStructure($);
          AllureReporter.reportStep('App stability verified',
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
      'Default page is Overview',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard Default State');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify Overview is default page');
          verifyDefaultOverviewPage($);
          AllureReporter.reportStep('Overview default state verified',
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
      'Dashboard persists state during navigation',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard State Management');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Test navigation persistence');
          await testNavigationPersistence($);
          AllureReporter.reportStep('Navigation persistence verified',
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
