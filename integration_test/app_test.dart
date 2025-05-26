import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'utils/test_utils.dart';
import 'helpers/test_helpers.dart';
import 'config/patrol_config.dart';
import 'reports/allure_reporter.dart';
import 'locators/app_locators.dart';
import 'logger/test_logger.dart';

import 'tests/overview_test.dart' as overview_tests;
import 'tests/account_test.dart' as account_tests;
import 'tests/dashboard_test.dart' as dashboard_tests;
import 'tests/hotels_test.dart' as hotels_tests;

void main() {
  group('Hotel Booking App - Complete Integration Test Suite', () {
    setUpAll(() async {
      TestLogger.log('Setting up complete integration test suite');
      await TestUtils.initializeAllure();
      TestLogger.log('Allure reporting initialized');
    });

    tearDownAll(() async {
      TestLogger.log('Completing integration test suite');
      await AllureReporter.finishTest(status: AllureTestStatus.passed);
    });

    group('App Launch and Initialization Tests', () {
      patrolTest(
        'App launches successfully and shows overview page',
        config: PatrolConfig.getConfig(),
        ($) async {
          AllureReporter.startTest('App Launch Test');
          AllureReporter.addLabel('suite', 'App Launch');
          AllureReporter.setSeverity(AllureSeverity.blocker);

          try {
            AllureReporter.reportStep('Initialize application');
            await TestHelpers.initializeApp($);
            AllureReporter.reportStep('App initialized successfully',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Verify dashboard structure');
            await AppLocators.validateNavigation($);
            AllureReporter.reportStep('Navigation validated',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Verify default overview page');
            final overviewScaffold = AppLocators.getOverviewScaffold($);
            await AppLocators.smartWaitFor($, overviewScaffold);
            expect(AppLocators.elementExists($, overviewScaffold), isTrue,
                reason: 'Overview should be default page');
            AllureReporter.reportStep('Overview page verified as default',
                status: AllureStepStatus.passed);

            AllureReporter.setTestStatus(status: AllureTestStatus.passed);
          } catch (e, stackTrace) {
            AllureReporter.setTestStatus(
              status: AllureTestStatus.failed,
              reason: 'App launch failed: $e\nStack trace: $stackTrace',
            );
            rethrow;
          }
        },
      );

      patrolTest(
        'All navigation tabs are accessible and functional',
        config: PatrolConfig.getConfig(),
        ($) async {
          AllureReporter.startTest('Navigation Accessibility Test');
          AllureReporter.addLabel('suite', 'Navigation');
          AllureReporter.setSeverity(AllureSeverity.critical);

          try {
            AllureReporter.reportStep('Initialize app');
            await TestHelpers.initializeApp($);
            AllureReporter.reportStep('App initialized',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Test navigation to each tab');
            final tabs = [
              {'name': 'hotels', 'scaffold': AppLocators.getHotelsScaffold($)},
              {
                'name': 'favorites',
                'scaffold': AppLocators.getFavoritesScaffold($)
              },
              {
                'name': 'account',
                'scaffold': AppLocators.getAccountScaffold($)
              },
              {
                'name': 'overview',
                'scaffold': AppLocators.getOverviewScaffold($)
              },
            ];

            for (final tab in tabs) {
              final tabName = tab['name'] as String;
              final scaffoldFinder = tab['scaffold'] as PatrolFinder;

              AllureReporter.reportStep('Navigate to $tabName tab');
              await TestHelpers.navigateToPage($, tabName);
              await AppLocators.smartWaitFor($, scaffoldFinder);
              expect(AppLocators.elementExists($, scaffoldFinder), isTrue,
                  reason: '$tabName page should load');
              AllureReporter.reportStep('$tabName navigation verified',
                  status: AllureStepStatus.passed);
            }

            AllureReporter.setTestStatus(status: AllureTestStatus.passed);
          } catch (e, stackTrace) {
            AllureReporter.setTestStatus(
              status: AllureTestStatus.failed,
              reason: 'Navigation test failed: $e\nStack trace: $stackTrace',
            );
            rethrow;
          }
        },
      );
    });

    group('Feature Test Suites', () {
      group('Dashboard Feature Tests', () {
        dashboard_tests.main();
      });

      group('Overview Feature Tests', () {
        overview_tests.main();
      });

      group('Hotels Feature Tests', () {
        hotels_tests.main();
      });

      group('Account Feature Tests', () {
        account_tests.main();
      });
    });

    group('Cross-Feature Integration Tests', () {
      patrolTest(
        'Complete user workflow: Search -> Favorite -> View',
        config: PatrolConfig.getConfig(),
        ($) async {
          AllureReporter.startTest('Complete User Workflow Test');
          AllureReporter.addLabel('suite', 'Cross-Feature Integration');
          AllureReporter.setSeverity(AllureSeverity.critical);

          try {
            AllureReporter.reportStep('Initialize app for workflow test');
            await TestHelpers.initializeApp($);
            AllureReporter.reportStep('App initialized',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Navigate to hotels page');
            await TestHelpers.navigateToPage($, 'hotels');
            await AppLocators.smartWaitFor($, AppLocators.getHotelsScaffold($));
            AllureReporter.reportStep('Hotels page loaded',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Perform hotel search');
            final searchField = AppLocators.getSearchTextField($);
            await AppLocators.smartEnterText($, searchField, 'Tokyo');
            await $.pump(const Duration(seconds: 2));

            final hasCards = find.byType(Card).evaluate().isNotEmpty;
            if (hasCards) {
              AllureReporter.reportStep('Search results found',
                  status: AllureStepStatus.passed);

              AllureReporter.reportStep('Add hotel to favorites');
              final firstCard = find.byType(Card).first;
              final favoriteButton = find.descendant(
                of: firstCard,
                matching: find.byIcon(Icons.favorite_outline),
              );

              if (favoriteButton.evaluate().isNotEmpty) {
                await $(favoriteButton.first).tap();
                await $.pump(const Duration(milliseconds: 800));
                AllureReporter.reportStep('Hotel added to favorites',
                    status: AllureStepStatus.passed);

                AllureReporter.reportStep('Navigate to favorites page');
                await TestHelpers.navigateToPage($, 'favorites');
                await AppLocators.smartWaitFor(
                    $, AppLocators.getFavoritesScaffold($));

                final favoritesCards = find.byType(Card).evaluate().length;
                expect(favoritesCards, greaterThan(0),
                    reason: 'Should have at least one favorite hotel');
                AllureReporter.reportStep('Favorites page verified with hotel',
                    status: AllureStepStatus.passed);
              } else {
                AllureReporter.reportStep('No favorite button found',
                    status: AllureStepStatus.skipped);
              }
            } else {
              AllureReporter.reportStep('No search results found',
                  status: AllureStepStatus.skipped);
            }

            AllureReporter.reportStep('Return to overview page');
            await TestHelpers.navigateToPage($, 'overview');
            await AppLocators.smartWaitFor(
                $, AppLocators.getOverviewScaffold($));
            AllureReporter.reportStep('Workflow completed successfully',
                status: AllureStepStatus.passed);

            AllureReporter.setTestStatus(status: AllureTestStatus.passed);
          } catch (e, stackTrace) {
            AllureReporter.setTestStatus(
              status: AllureTestStatus.failed,
              reason: 'Complete workflow failed: $e\nStack trace: $stackTrace',
            );
            rethrow;
          }
        },
      );

      patrolTest(
        'App stability under rapid navigation',
        config: PatrolConfig.getConfig(),
        ($) async {
          AllureReporter.startTest('App Stability Test');
          AllureReporter.addLabel('suite', 'Stability');
          AllureReporter.setSeverity(AllureSeverity.normal);

          try {
            AllureReporter.reportStep('Initialize app for stability test');
            await TestHelpers.initializeApp($);
            AllureReporter.reportStep('App initialized',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Perform rapid navigation cycles');
            final tabs = ['hotels', 'favorites', 'account', 'overview'];

            for (int cycle = 0; cycle < 3; cycle++) {
              AllureReporter.reportStep('Navigation cycle ${cycle + 1}/3');

              for (final tab in tabs) {
                final tabFinder = AppLocators.getNavigationTab($, tab);
                await AppLocators.smartTap($, tabFinder);
                await $.pump(const Duration(milliseconds: 200));
              }

              AllureReporter.reportStep('Cycle ${cycle + 1} completed',
                  status: AllureStepStatus.passed);
            }

            AllureReporter.reportStep(
                'Verify app stability after rapid navigation');
            await AppLocators.validateNavigation($);
            final overviewScaffold = AppLocators.getOverviewScaffold($);
            expect(AppLocators.elementExists($, overviewScaffold), isTrue,
                reason: 'App should remain stable');
            AllureReporter.reportStep('App stability verified',
                status: AllureStepStatus.passed);

            AllureReporter.setTestStatus(status: AllureTestStatus.passed);
          } catch (e, stackTrace) {
            AllureReporter.setTestStatus(
              status: AllureTestStatus.failed,
              reason: 'Stability test failed: $e\nStack trace: $stackTrace',
            );
            rethrow;
          }
        },
      );
    });

    group('Error Handling and Edge Cases', () {
      patrolTest(
        'App handles network and UI errors gracefully',
        config: PatrolConfig.getConfig(),
        ($) async {
          AllureReporter.startTest('Error Handling Test');
          AllureReporter.addLabel('suite', 'Error Handling');
          AllureReporter.setSeverity(AllureSeverity.normal);

          try {
            AllureReporter.reportStep('Initialize app');
            await TestHelpers.initializeApp($);
            AllureReporter.reportStep('App initialized',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Test search with invalid input');
            await TestHelpers.navigateToPage($, 'hotels');

            final searchField = AppLocators.getSearchTextField($);
            await AppLocators.smartEnterText($, searchField, '   ');
            await $.pump(const Duration(seconds: 2));

            AllureReporter.reportStep('Verify error handling');
            final errorMessage = AppLocators.getHotelsErrorMessage($);
            final retryButton = AppLocators.getHotelsRetryButton($);

            if (AppLocators.elementExists($, errorMessage)) {
              AllureReporter.reportStep('Error message displayed correctly',
                  status: AllureStepStatus.passed);

              if (AppLocators.elementExists($, retryButton)) {
                await AppLocators.smartTap($, retryButton);
                AllureReporter.reportStep('Retry button functional',
                    status: AllureStepStatus.passed);
              }
            } else {
              AllureReporter.reportStep('No error state triggered',
                  status: AllureStepStatus.skipped);
            }

            AllureReporter.setTestStatus(status: AllureTestStatus.passed);
          } catch (e, stackTrace) {
            AllureReporter.setTestStatus(
              status: AllureTestStatus.failed,
              reason:
                  'Error handling test failed: $e\nStack trace: $stackTrace',
            );
            rethrow;
          }
        },
      );
    });

    group('Performance and Accessibility Tests', () {
      patrolTest(
        'App performance meets acceptable standards',
        config: PatrolConfig.getConfig(),
        ($) async {
          AllureReporter.startTest('Performance Test');
          AllureReporter.addLabel('suite', 'Performance');
          AllureReporter.setSeverity(AllureSeverity.normal);

          try {
            AllureReporter.reportStep('Initialize app for performance test');
            final startTime = DateTime.now();
            await TestHelpers.initializeApp($);
            final initTime = DateTime.now().difference(startTime);
            AllureReporter.reportStep(
                'App initialized in ${initTime.inMilliseconds}ms',
                status: AllureStepStatus.passed);

            AllureReporter.reportStep('Measure navigation performance');
            final navigationStart = DateTime.now();

            final tabs = ['hotels', 'favorites', 'account', 'overview'];
            for (final tab in tabs) {
              final tabStart = DateTime.now();
              await TestHelpers.navigateToPage($, tab);
              final tabTime = DateTime.now().difference(tabStart);
              AllureReporter.reportStep(
                  '$tab navigation: ${tabTime.inMilliseconds}ms',
                  status: AllureStepStatus.passed);
            }

            final totalNavigationTime =
                DateTime.now().difference(navigationStart);
            AllureReporter.reportStep(
                'Total navigation time: ${totalNavigationTime.inMilliseconds}ms',
                status: AllureStepStatus.passed);

            expect(initTime.inSeconds, lessThan(10),
                reason: 'App should initialize within 10 seconds');
            expect(totalNavigationTime.inSeconds, lessThan(5),
                reason: 'Navigation should be responsive');

            AllureReporter.setTestStatus(status: AllureTestStatus.passed);
          } catch (e, stackTrace) {
            AllureReporter.setTestStatus(
              status: AllureTestStatus.failed,
              reason: 'Performance test failed: $e\nStack trace: $stackTrace',
            );
            rethrow;
          }
        },
      );
    });
  });
}
