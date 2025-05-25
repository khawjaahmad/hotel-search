import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';

void main() {
  group('🏠 Dashboard Feature Integration Tests', () {
    patrolTest(
      'Dashboard loads with navigation tabs',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Dashboard');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify dashboard scaffold');
          expect(find.byKey(const Key('dashboard_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Dashboard scaffold verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify navigation bar');
          expect(find.byKey(const Key('navigation_bar')), findsOneWidget);
          AllureReporter.reportStep('Navigation bar verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify all navigation tabs');
          expect(
              find.byKey(const Key('navigation_overview_tab')), findsOneWidget);
          expect(
              find.byKey(const Key('navigation_hotels_tab')), findsOneWidget);
          expect(find.byKey(const Key('navigation_favorites_tab')),
              findsOneWidget);
          expect(
              find.byKey(const Key('navigation_account_tab')), findsOneWidget);
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate to Hotels tab');
          await $(find.byKey(const Key('navigation_hotels_tab'))).tap();
          await $.pumpAndSettle();
          expect(find.byKey(const Key('hotels_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Hotels tab navigation verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate to Favorites tab');
          await $(find.byKey(const Key('navigation_favorites_tab'))).tap();
          await $.pumpAndSettle();
          expect(find.byKey(const Key('favorites_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Favorites tab navigation verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate to Account tab');
          await $(find.byKey(const Key('navigation_account_tab'))).tap();
          await $.pumpAndSettle();
          expect(find.byKey(const Key('account_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Account tab navigation verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate back to Overview tab');
          await $(find.byKey(const Key('navigation_overview_tab'))).tap();
          await $.pumpAndSettle();
          expect(find.byKey(const Key('overview_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Overview tab navigation verified',
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify tab labels');
          expect(find.text('Overview'), findsOneWidget);
          expect(find.text('Hotels'), findsOneWidget);
          expect(find.text('Favorites'), findsOneWidget);
          expect(find.text('Account'), findsOneWidget);
          AllureReporter.reportStep('Tab labels verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify tab icons');
          expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
          expect(find.byIcon(Icons.hotel_outlined), findsOneWidget);
          expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
          expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform rapid tab switching');
          for (int i = 0; i < 3; i++) {
            await $(find.byKey(const Key('navigation_hotels_tab'))).tap();
            await $.pump(const Duration(milliseconds: 100));

            await $(find.byKey(const Key('navigation_favorites_tab'))).tap();
            await $.pump(const Duration(milliseconds: 100));

            await $(find.byKey(const Key('navigation_account_tab'))).tap();
            await $.pump(const Duration(milliseconds: 100));

            await $(find.byKey(const Key('navigation_overview_tab'))).tap();
            await $.pump(const Duration(milliseconds: 100));
          }
          AllureReporter.reportStep('Rapid switching completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify app stability');
          expect(find.byKey(const Key('dashboard_scaffold')), findsOneWidget);
          expect(find.byKey(const Key('navigation_bar')), findsOneWidget);
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify Overview is default page');
          expect(find.byKey(const Key('overview_scaffold')), findsOneWidget);
          expect(find.text('Hotel Booking'), findsOneWidget);
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate through all tabs and back');
          await $(find.byKey(const Key('navigation_hotels_tab'))).tap();
          await $.pumpAndSettle();
          await $(find.byKey(const Key('navigation_favorites_tab'))).tap();
          await $.pumpAndSettle();
          await $(find.byKey(const Key('navigation_account_tab'))).tap();
          await $.pumpAndSettle();
          await $(find.byKey(const Key('navigation_overview_tab'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Navigation cycle completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify dashboard structure intact');
          expect(find.byKey(const Key('dashboard_scaffold')), findsOneWidget);
          expect(find.byKey(const Key('navigation_bar')), findsOneWidget);
          expect(find.byKey(const Key('overview_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Dashboard structure verified',
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
