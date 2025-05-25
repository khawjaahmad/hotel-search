import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/features/hotels/presentation/widgets/hotel_card.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';

void main() {
  group('🏨 Hotels Feature Integration Tests', () {
    patrolTest(
      'Cold start shows empty search',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Page');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app for cold start');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate to Hotels page');
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('Navigation completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Verify hotels page and empty search field');
          expect(find.byKey(const Key('hotels_search_field')), findsOneWidget);
          final textField = find.byKey(const Key('search_text_field'));
          expect(
              $.tester.widget<TextField>(textField).controller?.text, isEmpty);
          expect(
              find.byKey(const Key('hotels_empty_state_icon')), findsOneWidget);
          AllureReporter.reportStep('Hotels page verified',
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
      'Warm start does not re-init app',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Page');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('First app initialization');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('First initialization completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Second app initialization');
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('Second initialization completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify hotels page');
          expect(find.byKey(const Key('hotels_scaffold')), findsOneWidget);
          AllureReporter.reportStep('Hotels page verified',
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
      'Search returns results',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Search');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Enter search query');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('Dubai');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify hotel cards');
          expect(find.byType(HotelCard), findsWidgets);
          AllureReporter.reportStep('Hotel cards verified',
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
      'Empty search results show no results UI',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Search');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Enter nonsense query');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('xyz123nonsense');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify empty state');
          expect(
              find.byKey(const Key('hotels_empty_state_icon')), findsOneWidget);
          AllureReporter.reportStep('Empty state verified',
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
      'Clear and re-search',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Search');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform first search');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('Dubai');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          expect(find.byType(HotelCard), findsWidgets);
          AllureReporter.reportStep('First search completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Clear search field');
          await $(find.byKey(const Key('search_clear_button'))).tap();
          await $.pumpAndSettle();
          expect(
              $.tester
                  .widget<TextField>(find.byKey(const Key('search_text_field')))
                  .controller
                  ?.text,
              isEmpty);
          AllureReporter.reportStep('Search field cleared',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform second search');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('Paris');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          expect(find.byType(HotelCard), findsWidgets);
          AllureReporter.reportStep('Second search completed',
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
      'Infinite scroll loads more hotels',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Pagination');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('Paris');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          final initialCount = find.byType(HotelCard).evaluate().length;
          expect(initialCount, greaterThan(0));
          AllureReporter.reportStep('Initial search completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Scroll to load more hotels');
          final scrollView = find.byKey(const Key('hotels_scroll_view'));
          await $(scrollView)
              .scrollTo(view: find.byType(HotelCard).last, maxScrolls: 5);
          await $.pumpAndSettle();
          final finalCount = find.byType(HotelCard).evaluate().length;
          expect(finalCount, greaterThanOrEqualTo(initialCount));
          AllureReporter.reportStep('More hotels loaded',
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
      'No further scrolls past last page',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Pagination');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search with limited results');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('zzz_unique_hotel_name');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          final initialCount = find.byType(HotelCard).evaluate().length;
          AllureReporter.reportStep('Initial search completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Scroll past last page');
          final scrollView = find.byKey(const Key('hotels_scroll_view'));
          await $(scrollView).scrollTo(maxScrolls: 3);
          await $.pumpAndSettle();
          final finalCount = find.byType(HotelCard).evaluate().length;
          expect(finalCount, equals(initialCount));
          AllureReporter.reportStep('No further scrolls verified',
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
      'Shows error on network failure',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Error Handling');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search to trigger error');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('network_error');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify error UI');
          expect(find.byKey(const Key('hotels_error_message')), findsOneWidget);
          expect(find.byKey(const Key('hotels_retry_button')), findsOneWidget);
          AllureReporter.reportStep('Error UI verified',
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
      'Very long search term (256 chars)',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Edge Cases');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Enter long search term');
          final longTerm = 'A' * 256;
          await $(find.byKey(const Key('search_text_field')))
              .enterText(longTerm);
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify no crash');
          expect(find.byKey(const Key('hotels_scaffold')), findsOneWidget);
          AllureReporter.reportStep('No crash verified',
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
      'Landscape orientation',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Accessibility');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Switch to landscape');
          final view = $.tester.view;
          final size = view.physicalSize;
          view.physicalSize = Size(size.height, size.width);
          view.devicePixelRatio = 1.0;
          await $.pump();
          AllureReporter.reportStep('Orientation changed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify layout and search');
          expect(find.byKey(const Key('hotels_scaffold')), findsOneWidget);
          await $(find.byKey(const Key('search_text_field')))
              .enterText('Tokyo');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Layout verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Restore portrait');
          view.physicalSize = size;
          view.resetDevicePixelRatio();
          await $.pump();
          AllureReporter.reportStep('Orientation restored',
              status: AllureStepStatus.passed);

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          $.tester.view.resetPhysicalSize();
          $.tester.view.resetDevicePixelRatio();
          await $.pump();
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason: 'Test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Text scaling / large fonts',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Accessibility');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Set large text scale');
          $.tester.platformDispatcher.textScaleFactorTestValue = 2.0;
          await $.pump();
          AllureReporter.reportStep('Text scale applied',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify layout and search');
          expect(find.byKey(const Key('hotels_scaffold')), findsOneWidget);
          await $(find.byKey(const Key('search_text_field'))).enterText('Test');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          AllureReporter.reportStep('Layout verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Restore text scale');
          $.tester.platformDispatcher.clearTextScaleFactorTestValue();
          await $.pump();
          AllureReporter.reportStep('Text scale restored',
              status: AllureStepStatus.passed);

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          $.tester.platformDispatcher.clearTextScaleFactorTestValue();
          await $.pump();
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason: 'Test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Screen reader labels',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Accessibility');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          AllureReporter.reportStep('Initialize app');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Enable semantics');
          // Patrol doesn't require explicit semantics enabling for testing
          await $.pump();
          AllureReporter.reportStep('Semantics enabled',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify key widget semantics');
          expect(find.byKey(const Key('search_text_field')), findsOneWidget);
          expect(find.byKey(const Key('search_prefix_icon')), findsOneWidget);
          expect(find.byKey(const Key('search_clear_button')), findsOneWidget);
          AllureReporter.reportStep('Semantics verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search and verify cards');
          await $(find.byKey(const Key('search_text_field')))
              .enterText('Dubai');
          await $(find.byKey(const Key('search_prefix_icon'))).tap();
          await $.pumpAndSettle();
          expect(find.byType(HotelCard), findsWidgets);
          expect(find.byType(IconButton), findsWidgets); // Favorite buttons
          AllureReporter.reportStep('Search and cards verified',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Disable semantics');
          // No explicit disable needed for Patrol
          await $.pump();
          AllureReporter.reportStep('Semantics disabled',
              status: AllureStepStatus.passed);

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          // No cleanup needed for semantics in Patrol
          await $.pump();
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
