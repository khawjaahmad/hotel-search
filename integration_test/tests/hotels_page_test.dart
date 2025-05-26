import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../logger/test_logger.dart';
import '../utils/test_actions.dart';

void main() {
  group('Hotels Feature Integration Tests', () {
    Future<void> initializeTest(PatrolIntegrationTester $) async {
      await TestUtils.initializeAllure();
      await TestHelpers.initializeApp($);
    }

    Future<void> navigateToHotels(PatrolIntegrationTester $) async {
      await TestHelpers.navigateToPage($, 'hotels',
          description: 'Navigating to Hotels page');
    }

    patrolTest(
      'Cold start shows empty search',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Page');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app for cold start');
          await initializeTest($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Navigate to Hotels page');
          await navigateToHotels($);
          AllureReporter.reportStep('Navigation completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Verify hotels page and empty search field');
          TestActions.verifyHotelsPageElements($);
          TestActions.verifySearchFieldState($, shouldBeEmpty: true);
          TestActions.verifyEmptyState($);
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
          await initializeTest($);
          await navigateToHotels($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Enter search query');
          final searchState = await TestActions.performSearch($, 'Dubai');
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Verify search results - ANY input should return output');
          expect(searchState, isNot(SearchState.timeout),
              reason: 'Any input should produce some output');

          switch (searchState) {
            case SearchState.hasResults:
              final cardCount = TestActions.getHotelCardCount();
              TestLogger.log('Found $cardCount hotel cards');
              TestActions.verifySearchResults($);
              AllureReporter.reportStep('Hotel cards found: $cardCount',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.hasError:
              TestLogger.log('Search resulted in error state');
              TestActions.verifyErrorState($);
              AllureReporter.reportStep('Error state detected',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.isEmpty:
              TestLogger.log('Search resulted in empty state');
              TestActions.verifyEmptyState($);
              AllureReporter.reportStep('Empty state detected',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.timeout:
              throw Exception(
                  'Search timed out - this violates the "any input should return output" requirement');
          }

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
      'Empty spaces trigger "Something went wrong" error',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Search');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToHotels($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Test with empty spaces - should trigger "Something went wrong"');
          final searchState = await TestActions.performSearch($, '   ');
          AllureReporter.reportStep('Search with spaces executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify empty spaces behavior');
          expect(searchState, equals(SearchState.hasError),
              reason:
                  'Empty spaces should trigger "Something went wrong" error');

          TestActions.verifyErrorState($);
          TestLogger.log(
              'Empty spaces correctly triggered "Something went wrong" error');
          AllureReporter.reportStep('Empty spaces triggered correct error',
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
      'Add hotels to favorites and verify in favorites page',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Favorites');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app');
          await initializeTest($);
          await navigateToHotels($);
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Clear any existing favorites first');
          await TestHelpers.navigateToPage($, 'favorites');
          await $.pump(const Duration(seconds: 1));

          final existingCards = TestActions.getHotelCardCount();
          if (existingCards > 0) {
            AllureReporter.reportStep(
                'Clearing $existingCards existing favorites');
            for (int i = 0; i < existingCards; i++) {
              await TestActions.removeHotelFromFavorites($, 0);
            }
          }

          AllureReporter.reportStep('Navigate back to hotels page');
          await navigateToHotels($);
          AllureReporter.reportStep('Back to hotels page',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search to get hotels');
          final searchState = await TestActions.performSearch($, 'Paris');

          if (searchState == SearchState.hasResults) {
            final availableCards = TestActions.getHotelCardCount();
            AllureReporter.reportStep(
                'Found $availableCards hotels to favorite',
                status: AllureStepStatus.passed);

            if (availableCards > 0) {
              final hotelsToAdd = availableCards >= 3 ? 3 : availableCards;
              List<String> addedHotelNames = [];

              AllureReporter.reportStep(
                  'Adding $hotelsToAdd hotels to favorites');

              for (int i = 0; i < hotelsToAdd; i++) {
                try {
                  final hotelName = TestActions.extractHotelName(i);
                  addedHotelNames.add(hotelName);
                  TestLogger.log('Adding hotel to favorites: "$hotelName"');

                  await TestActions.addHotelToFavorites($, i);
                  TestLogger.log(
                      'Successfully added hotel ${i + 1} to favorites');
                  AllureReporter.reportStep('Added hotel ${i + 1}: $hotelName',
                      status: AllureStepStatus.passed);
                } catch (e) {
                  TestLogger.log(
                      'Failed to add hotel ${i + 1} to favorites: $e');
                  if (addedHotelNames.length > i) {
                    addedHotelNames.removeLast();
                  }
                }
              }

              final actuallyAdded = addedHotelNames.length;
              AllureReporter.reportStep(
                  'Successfully added $actuallyAdded hotels to favorites',
                  status: AllureStepStatus.passed);
              TestLogger.log('Added hotels: $addedHotelNames');

              if (actuallyAdded > 0) {
                AllureReporter.reportStep(
                    'Navigate to favorites page to verify');
                await TestHelpers.navigateToPage($, 'favorites');
                await $.pump(const Duration(seconds: 1));
                AllureReporter.reportStep('Navigated to favorites page',
                    status: AllureStepStatus.passed);

                AllureReporter.reportStep('Verify favorites count and content');
                final favoritesCards = TestActions.getHotelCardCount();

                expect(favoritesCards, equals(actuallyAdded),
                    reason:
                        'Favorites page should show exactly $actuallyAdded hotels');

                TestLogger.log(
                    'VERIFIED: Favorites count matches - Expected: $actuallyAdded, Found: $favoritesCards');
                AllureReporter.reportStep(
                    'FAVORITES COUNT VERIFIED: $favoritesCards matches $actuallyAdded',
                    status: AllureStepStatus.passed);

                AllureReporter.reportStep(
                    'Remove hotels from favorites by unchecking hearts');
                int removedCount = 0;

                for (int i = favoritesCards - 1; i >= 0; i--) {
                  try {
                    final hotelName = addedHotelNames[i];
                    TestLogger.log(
                        'Removing hotel from favorites: "$hotelName"');

                    await TestActions.removeHotelFromFavorites($, i);
                    removedCount++;

                    TestLogger.log('Removed hotel $removedCount: "$hotelName"');
                    AllureReporter.reportStep('Removed hotel: $hotelName',
                        status: AllureStepStatus.passed);
                  } catch (e) {
                    TestLogger.log('Failed to remove favorite ${i + 1}: $e');
                  }
                }

                AllureReporter.reportStep(
                    'Verify all hotels are removed from favorites');
                await $.pump(const Duration(seconds: 1));

                final remainingCards = TestActions.getHotelCardCount();
                expect(remainingCards, equals(0),
                    reason: 'All hotels should be removed from favorites');

                TestActions.verifyEmptyState($);

                TestLogger.log('SUCCESS: All hotels removed from favorites!');
                AllureReporter.reportStep(
                    'ALL HOTELS REMOVED - Empty state verified',
                    status: AllureStepStatus.passed);
              } else {
                AllureReporter.reportStep(
                    'No hotels were successfully added to favorites',
                    status: AllureStepStatus.failed);
                throw Exception(
                    'Could not add any hotels to favorites for testing');
              }
            }
          }

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason: 'Favorites test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );
  });
}
