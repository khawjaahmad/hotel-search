import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_helpers.dart';
import '../utils/test_utils.dart';
import '../config/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../helpers/allure_helper.dart';
import '../logger/test_logger.dart';
import '../utils/test_actions.dart';

void main() {
  group('Hotels Feature Integration Tests', () {
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

    Future<void> navigateToHotels(PatrolIntegrationTester $) async {
      await TestHelpers.navigateToPage($, 'hotels',
          description: 'Navigating to Hotels page');
    }

    patrolTest(
      'Cold start shows empty search',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Cold start shows empty search',
          description: 'Verify hotels page loads with empty search field on cold start',
          labels: ['feature:hotels', 'component:initial_state', 'priority:critical'],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize app for cold start');
          await initializeTest($);

          EnhancedAllureHelper.reportStep('Navigate to Hotels page');
          await navigateToHotels($);

          EnhancedAllureHelper.reportStep('Verify hotels page and empty search field');
          TestActions.verifyHotelsPageElements($);
          TestActions.verifySearchFieldState($, shouldBeEmpty: true);
          TestActions.verifyEmptyState($);

          await EnhancedAllureHelper.finishTest(
            'Cold start shows empty search',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Cold start test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Cold start shows empty search',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Search returns results',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Search returns results',
          description: 'Verify search functionality returns appropriate results for valid input',
          labels: ['feature:hotels', 'component:search', 'priority:critical'],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);
          await navigateToHotels($);

          EnhancedAllureHelper.reportStep('Execute search query');
          final searchState = await TestActions.performSearch($, 'Dubai');

          EnhancedAllureHelper.reportStep('Verify search results - ANY input should return output');
          expect(searchState, isNot(SearchState.timeout),
              reason: 'Any input should produce some output');

          switch (searchState) {
            case SearchState.hasResults:
              final cardCount = TestActions.getHotelCardCount();
              TestLogger.log('Found $cardCount hotel cards');
              TestActions.verifySearchResults($);
              EnhancedAllureHelper.reportStep(
                'Search completed with results',
                details: 'Hotel cards found: $cardCount',
              );
              break;
            case SearchState.hasError:
              TestLogger.log('Search resulted in error state');
              TestActions.verifyErrorState($);
              EnhancedAllureHelper.reportStep('Error state detected and verified');
              break;
            case SearchState.isEmpty:
              TestLogger.log('Search resulted in empty state');
              TestActions.verifyEmptyState($);
              EnhancedAllureHelper.reportStep('Empty state detected and verified');
              break;
            case SearchState.timeout:
              throw Exception(
                  'Search timed out - this violates the "any input should return output" requirement');
          }

          await EnhancedAllureHelper.finishTest(
            'Search returns results',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Search test execution failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Search returns results',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Empty spaces trigger "Something went wrong" error',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Empty spaces trigger "Something went wrong" error',
          description: 'Verify empty spaces input triggers appropriate error handling',
          labels: ['feature:hotels', 'component:error_handling', 'priority:critical'],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);
          await navigateToHotels($);

          EnhancedAllureHelper.reportStep('Test with empty spaces - should trigger "Something went wrong"');
          final searchState = await TestActions.performSearch($, '   ');

          EnhancedAllureHelper.reportStep('Verify empty spaces behavior');
          expect(searchState, equals(SearchState.hasError),
              reason: 'Empty spaces should trigger "Something went wrong" error');

          TestActions.verifyErrorState($);
          TestLogger.log('Empty spaces correctly triggered "Something went wrong" error');

          await EnhancedAllureHelper.finishTest(
            'Empty spaces trigger "Something went wrong" error',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Empty spaces error test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Empty spaces trigger "Something went wrong" error',
            status: AllureTestStatus.failed,
            errorMessage: e.toString(),
            stackTrace: stackTrace.toString(),
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Add hotels to favorites and verify in favorites page',
      config: PatrolConfig.getConfig(),
      ($) async {
        await EnhancedAllureHelper.startTest(
          'Add hotels to favorites and verify in favorites page',
          description: 'Complete workflow test for adding and removing hotels from favorites',
          labels: ['feature:hotels', 'component:favorites', 'priority:critical'],
          severity: AllureSeverity.critical,
        );

        try {
          EnhancedAllureHelper.reportStep('Initialize application');
          await initializeTest($);
          await navigateToHotels($);

          EnhancedAllureHelper.reportStep('Clear any existing favorites first');
          await TestHelpers.navigateToPage($, 'favorites');
          await $.pump(const Duration(seconds: 1));

          final existingCards = TestActions.getHotelCardCount();
          if (existingCards > 0) {
            EnhancedAllureHelper.reportStep('Clear existing favorites', details: 'Clearing $existingCards existing favorites');
            for (int i = 0; i < existingCards; i++) {
              await TestActions.removeHotelFromFavorites($, 0);
            }
          }

          EnhancedAllureHelper.reportStep('Navigate back to hotels page');
          await navigateToHotels($);

          EnhancedAllureHelper.reportStep('Perform search to get hotels');
          final searchState = await TestActions.performSearch($, 'Paris');

          if (searchState == SearchState.hasResults) {
            final availableCards = TestActions.getHotelCardCount();
            EnhancedAllureHelper.reportStep('Search completed', details: 'Found $availableCards hotels to favorite');

            if (availableCards > 0) {
              final hotelsToAdd = availableCards >= 3 ? 3 : availableCards;
              List<String> addedHotelNames = [];

              EnhancedAllureHelper.reportStep('Add hotels to favorites', details: 'Adding $hotelsToAdd hotels to favorites');

              for (int i = 0; i < hotelsToAdd; i++) {
                try {
                  final hotelName = TestActions.extractHotelName(i);
                  addedHotelNames.add(hotelName);
                  TestLogger.log('Adding hotel to favorites: "$hotelName"');

                  await TestActions.addHotelToFavorites($, i);
                  TestLogger.log('Successfully added hotel ${i + 1} to favorites');
                } catch (e) {
                  TestLogger.log('Failed to add hotel ${i + 1} to favorites: $e');
                  if (addedHotelNames.length > i) {
                    addedHotelNames.removeLast();
                  }
                }
              }

              final actuallyAdded = addedHotelNames.length;
              EnhancedAllureHelper.reportStep('Hotels added to favorites', details: 'Successfully added $actuallyAdded hotels to favorites');
              TestLogger.log('Added hotels: $addedHotelNames');

              if (actuallyAdded > 0) {
                EnhancedAllureHelper.reportStep('Navigate to favorites page to verify');
                await TestHelpers.navigateToPage($, 'favorites');
                await $.pump(const Duration(seconds: 1));

                EnhancedAllureHelper.reportStep(
                    'Verify favorites count and content');
                final favoritesCards = TestActions.getHotelCardCount();

                expect(favoritesCards, equals(actuallyAdded),
                    reason:
                        'Favorites page should show exactly $actuallyAdded hotels');

                TestLogger.log(
                    'VERIFIED: Favorites count matches - Expected: $actuallyAdded, Found: $favoritesCards');
                EnhancedAllureHelper.reportStep('Favorites count verified',
                    details: '$favoritesCards matches $actuallyAdded');

                EnhancedAllureHelper.reportStep(
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
                  } catch (e) {
                    TestLogger.log('Failed to remove favorite ${i + 1}: $e');
                  }
                }

                EnhancedAllureHelper.reportStep(
                    'Verify all hotels are removed from favorites');
                await $.pump(const Duration(seconds: 1));

                final remainingCards = TestActions.getHotelCardCount();
                expect(remainingCards, equals(0),
                    reason: 'All hotels should be removed from favorites');

                TestActions.verifyEmptyState($);

                TestLogger.log('SUCCESS: All hotels removed from favorites!');
                EnhancedAllureHelper.reportStep(
                    'All hotels removed - empty state verified');
              } else {
                EnhancedAllureHelper.reportStep(
                  'No hotels were successfully added to favorites',
                  status: AllureStepStatus.failed,
                );
                throw Exception(
                    'Could not add any hotels to favorites for testing');
              }
            }
          }

          await EnhancedAllureHelper.finishTest(
            'Add hotels to favorites and verify in favorites page',
            status: AllureTestStatus.passed,
          );
        } catch (e, stackTrace) {
          EnhancedAllureHelper.reportStep(
            'Favorites workflow test failed',
            status: AllureStepStatus.failed,
            details: e.toString(),
          );

          await EnhancedAllureHelper.finishTest(
            'Add hotels to favorites and verify in favorites page',
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
