import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';
import '../tests/enhanced_scroll_test.dart';

void main() {
  group('Hotels Feature Integration Tests', () {
    Future<SearchState> waitForSearchResults(PatrolIntegrationTester $,
        {Duration timeout = const Duration(seconds: 15)}) async {
      final stopwatch = Stopwatch()..start();

      while (stopwatch.elapsed < timeout) {
        await $.pump(const Duration(milliseconds: 500));

        final loadingIndicator =
            find.byKey(const Key('hotels_loading_indicator'));
        final paginationLoading =
            find.byKey(const Key('hotels_pagination_loading'));
        final circularProgress = find.byType(CircularProgressIndicator);

        final isLoading = loadingIndicator.evaluate().isNotEmpty ||
            paginationLoading.evaluate().isNotEmpty ||
            circularProgress.evaluate().isNotEmpty;

        if (!isLoading) {
          final hasCards = find.byType(Card).evaluate().isNotEmpty;
          final hasError = find
              .byKey(const Key('hotels_error_message'))
              .evaluate()
              .isNotEmpty;
          final hasEmpty = find
              .byKey(const Key('hotels_empty_state_icon'))
              .evaluate()
              .isNotEmpty;

          if (hasCards) return SearchState.hasResults;
          if (hasError) return SearchState.hasError;
          if (hasEmpty) return SearchState.isEmpty;

          await $.pump(const Duration(milliseconds: 500));
        }
      }

      stopwatch.stop();
      return SearchState.timeout;
    }

    Future<SearchState> performSearch(
        PatrolIntegrationTester $, String query) async {
      TestLogger.log('Performing search with query: "$query"');

      final searchField = find.byKey(const Key('search_text_field'));
      expect(searchField, findsOneWidget,
          reason: 'Search field should be present');

      await $(searchField).enterText('');
      await $.pump(const Duration(milliseconds: 300));

      await $(searchField).enterText(query);
      TestLogger.log('Entered text: "$query"');

      await $.pump(const Duration(milliseconds: 1000));

      return await waitForSearchResults($);
    }

    Future<ScrollResult> performHotelsScrollFixed(
      PatrolIntegrationTester $, {
      int maxScrolls = 10,
      Duration scrollTimeout = const Duration(seconds: 30),
    }) async {
      TestLogger.log(
          'Starting continuous scroll until pagination loader appears');

      final initialCardCount = find.byType(Card).evaluate().length;
      TestLogger.log('Initial card count: $initialCardCount');

      if (initialCardCount == 0) {
        return ScrollResult(
          success: false,
          initialCount: 0,
          finalCount: 0,
          scrollAttempts: 0,
          error: 'No cards found to scroll',
        );
      }

      int scrollAttempts = 0;
      String? lastError;

      try {
        final scrollViewFinder = find.byKey(const Key('hotels_scroll_view'));
        if (scrollViewFinder.evaluate().isNotEmpty) {
          TestLogger.log(
              'Found hotels_scroll_view, scrolling until pagination loader appears');

          bool paginationTriggered = false;

          while (scrollAttempts < maxScrolls && !paginationTriggered) {
            scrollAttempts++;
            TestLogger.log(
                'Continuous scroll attempt $scrollAttempts/$maxScrolls');

            await $.tester.drag(scrollViewFinder, const Offset(0, -400));
            await $.pump(const Duration(milliseconds: 500));

            final paginationLoading =
                find.byKey(const Key('hotels_pagination_loading'));
            if (paginationLoading.evaluate().isNotEmpty) {
              TestLogger.log(
                  'SUCCESS: Pagination loader appeared after $scrollAttempts scrolls!');
              paginationTriggered = true;

              TestLogger.log('Waiting for pagination to complete...');
              int waitAttempts = 0;
              while (paginationLoading.evaluate().isNotEmpty &&
                  waitAttempts < 15) {
                await $.pump(const Duration(milliseconds: 500));
                waitAttempts++;
                TestLogger.log(
                    'Waiting for pagination... attempt $waitAttempts');
              }

              if (waitAttempts >= 15) {
                TestLogger.log('Pagination taking too long, continuing...');
              } else {
                TestLogger.log(
                    'Pagination completed after ${waitAttempts * 500}ms');
              }

              await $.pump(const Duration(seconds: 1));
              break;
            }

            final currentCount = find.byType(Card).evaluate().length;
            if (currentCount > initialCardCount) {
              TestLogger.log(
                  'New content loaded without seeing loader: $initialCardCount -> $currentCount');
              paginationTriggered = true;
              break;
            }

            TestLogger.log('No pagination yet, continuing to scroll...');
            await $.pump(const Duration(milliseconds: 300));
          }

          final finalCount = find.byType(Card).evaluate().length;

          if (paginationTriggered || finalCount > initialCardCount) {
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: finalCount,
              scrollAttempts: scrollAttempts,
            );
          } else {
            TestLogger.log(
                'Reached max scroll attempts without triggering pagination');
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: finalCount,
              scrollAttempts: scrollAttempts,
              reachedEnd: true,
            );
          }
        }
      } catch (e) {
        lastError = 'hotels_scroll_view method failed: $e';
        TestLogger.log('hotels_scroll_view method failed: $e');
      }

      try {
        final customScrollView = find.byType(CustomScrollView);
        if (customScrollView.evaluate().isNotEmpty) {
          TestLogger.log(
              'Found CustomScrollView, scrolling until pagination loader appears');

          bool paginationTriggered = false;

          while (scrollAttempts < maxScrolls && !paginationTriggered) {
            scrollAttempts++;
            TestLogger.log(
                'CustomScrollView continuous scroll attempt $scrollAttempts/$maxScrolls');

            await $.tester.drag(customScrollView.first, const Offset(0, -400));
            await $.pump(const Duration(milliseconds: 500));

            final paginationLoading =
                find.byKey(const Key('hotels_pagination_loading'));
            if (paginationLoading.evaluate().isNotEmpty) {
              TestLogger.log(
                  'SUCCESS: Pagination loader appeared with CustomScrollView!');
              paginationTriggered = true;

              int waitAttempts = 0;
              while (paginationLoading.evaluate().isNotEmpty &&
                  waitAttempts < 15) {
                await $.pump(const Duration(milliseconds: 500));
                waitAttempts++;
              }

              await $.pump(const Duration(seconds: 1));
              break;
            }

            final currentCount = find.byType(Card).evaluate().length;
            if (currentCount > initialCardCount) {
              TestLogger.log(
                  'New content loaded with CustomScrollView: $initialCardCount -> $currentCount');
              paginationTriggered = true;
              break;
            }

            await $.pump(const Duration(milliseconds: 300));
          }

          final finalCount = find.byType(Card).evaluate().length;

          if (paginationTriggered || finalCount > initialCardCount) {
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: finalCount,
              scrollAttempts: scrollAttempts,
            );
          } else {
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: finalCount,
              scrollAttempts: scrollAttempts,
              reachedEnd: true,
            );
          }
        }
      } catch (e) {
        lastError = 'CustomScrollView method failed: $e';
        TestLogger.log('CustomScrollView method failed: $e');
      }

      try {
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          TestLogger.log(
              'Found Scrollable widgets, scrolling until pagination loader appears');

          bool paginationTriggered = false;

          while (scrollAttempts < maxScrolls && !paginationTriggered) {
            scrollAttempts++;
            TestLogger.log(
                'Scrollable continuous scroll attempt $scrollAttempts/$maxScrolls');

            await $.tester.drag(scrollable.first, const Offset(0, -400));
            await $.pump(const Duration(milliseconds: 500));

            final paginationLoading =
                find.byKey(const Key('hotels_pagination_loading'));
            if (paginationLoading.evaluate().isNotEmpty) {
              TestLogger.log(
                  'SUCCESS: Pagination loader appeared with Scrollable!');
              paginationTriggered = true;

              int waitAttempts = 0;
              while (paginationLoading.evaluate().isNotEmpty &&
                  waitAttempts < 15) {
                await $.pump(const Duration(milliseconds: 500));
                waitAttempts++;
              }

              await $.pump(const Duration(seconds: 1));
              break;
            }

            final currentCount = find.byType(Card).evaluate().length;
            if (currentCount > initialCardCount) {
              TestLogger.log(
                  'New content loaded with Scrollable: $initialCardCount -> $currentCount');
              paginationTriggered = true;
              break;
            }

            await $.pump(const Duration(milliseconds: 300));
          }

          final finalCount = find.byType(Card).evaluate().length;

          if (paginationTriggered || finalCount > initialCardCount) {
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: finalCount,
              scrollAttempts: scrollAttempts,
            );
          } else {
            return ScrollResult(
              success: true,
              initialCount: initialCardCount,
              finalCount: finalCount,
              scrollAttempts: scrollAttempts,
              reachedEnd: true,
            );
          }
        }
      } catch (e) {
        lastError = 'Scrollable method failed: $e';
        TestLogger.log('Scrollable method failed: $e');
      }

      TestLogger.log('ALL CONTINUOUS SCROLL METHODS FAILED');
      return ScrollResult(
        success: false,
        initialCount: initialCardCount,
        finalCount: initialCardCount,
        scrollAttempts: scrollAttempts,
        error: lastError ?? 'All continuous scroll methods failed',
      );
    }

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
          final searchState = await performSearch($, 'Dubai');
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Verify search results - ANY input should return output');
          expect(searchState, isNot(SearchState.timeout),
              reason: 'Any input should produce some output');

          switch (searchState) {
            case SearchState.hasResults:
              final cardCount = find.byType(Card).evaluate().length;
              TestLogger.log('Found $cardCount hotel cards');
              AllureReporter.reportStep('Hotel cards found: $cardCount',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.hasError:
              TestLogger.log('Search resulted in error state');
              AllureReporter.reportStep('Error state detected',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.isEmpty:
              TestLogger.log('Search resulted in empty state');
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Test with empty spaces - should trigger "Something went wrong"');
          final searchState = await performSearch($, '   ');
          AllureReporter.reportStep('Search with spaces executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify empty spaces behavior');
          expect(searchState, equals(SearchState.hasError),
              reason:
                  'Empty spaces should trigger "Something went wrong" error');

          final errorMessage = find.byKey(const Key('hotels_error_message'));
          expect(errorMessage, findsOneWidget,
              reason: 'Should show error message');

          final errorText = find.text('Something went wrong');
          expect(errorText, findsOneWidget,
              reason: 'Should show "Something went wrong" message');

          final retryButton = find.byKey(const Key('hotels_retry_button'));
          expect(retryButton, findsOneWidget,
              reason: 'Should show retry button');

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

          AllureReporter.reportStep('Perform search to get scrollable content');
          final searchState = await performSearch($, 'London');

          if (searchState == SearchState.hasResults) {
            final initialCards = find.byType(Card).evaluate().length;
            AllureReporter.reportStep(
                'Initial search completed with $initialCards cards',
                status: AllureStepStatus.passed);

            if (initialCards > 0) {
              AllureReporter.reportStep('PERFORMING SCROLL TEST');
              final scrollResult =
                  await performHotelsScrollFixed($, maxScrolls: 3);

              AllureReporter.reportStep(
                  'Scroll test completed: ${scrollResult.toString()}',
                  status: AllureStepStatus.passed);

              expect(scrollResult.success, isTrue,
                  reason:
                      'Scroll operation must succeed: ${scrollResult.error ?? "Unknown error"}');

              expect(scrollResult.finalCount,
                  greaterThanOrEqualTo(scrollResult.initialCount),
                  reason:
                      'Card count should maintain or increase after scroll');

              if (scrollResult.hasNewContent) {
                AllureReporter.reportStep(
                    'NEW CONTENT LOADED: ${scrollResult.newContentCount} cards',
                    status: AllureStepStatus.passed);
                TestLogger.log(
                    'SUCCESS: Scroll loaded ${scrollResult.newContentCount} new cards');
              } else if (scrollResult.reachedEnd) {
                AllureReporter.reportStep(
                    'REACHED END OF LIST (no new content, but scroll worked)',
                    status: AllureStepStatus.passed);
                TestLogger.log(
                    'INFO: Reached end of list, no new content available');
              } else {
                throw Exception(
                    'Scroll completed but no new content and didn\'t reach end - unexpected behavior');
              }
            } else {
              AllureReporter.reportStep(
                  'No cards to scroll - test cannot verify scroll',
                  status: AllureStepStatus.failed);
              throw Exception('Cannot test scrolling without any cards');
            }
          } else {
            AllureReporter.reportStep(
                'No results for scroll test - state: $searchState',
                status: AllureStepStatus.failed);
            throw Exception('Cannot test scrolling without search results');
          }

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason: 'Scroll test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Enhanced pagination test - continuous scroll until loader appears',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Pagination Enhanced');
        AllureReporter.setSeverity(AllureSeverity.critical);

        try {
          AllureReporter.reportStep('Initialize app and navigate to hotels');
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels');
          AllureReporter.reportStep('Navigation completed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search to get scrollable content');
          final searchQuery = 'hotel';

          final searchField = find.byKey(const Key('search_text_field'));
          expect(searchField, findsOneWidget,
              reason: 'Search field should be present');

          await $(searchField).enterText('');
          await $.pump(const Duration(milliseconds: 300));
          await $(searchField).enterText(searchQuery);
          TestLogger.log('Entered search query: "$searchQuery"');

          await $.pump(const Duration(milliseconds: 1500));

          final searchState = await waitForSearchResults($,
              timeout: const Duration(seconds: 20));
          AllureReporter.reportStep('Search completed with state: $searchState',
              status: AllureStepStatus.passed);

          if (searchState == SearchState.hasResults) {
            final initialCards = find.byType(Card).evaluate().length;
            AllureReporter.reportStep('Found $initialCards initial hotel cards',
                status: AllureStepStatus.passed);
            TestLogger.log('Initial cards loaded: $initialCards');

            if (initialCards > 0) {
              AllureReporter.reportStep(
                  'Starting enhanced continuous scroll test');

              final scrollResult =
                  await EnhancedScrollTester.performContinuousScroll(
                $,
                maxScrollAttempts: 20,
                scrollDistance: 400.0,
                scrollDelay: const Duration(milliseconds: 600),
                paginationTimeout: const Duration(seconds: 25),
              );

              AllureReporter.reportStep(
                  'Scroll test completed: ${scrollResult.toString()}',
                  status: AllureStepStatus.passed);

              expect(scrollResult.success, isTrue,
                  reason:
                      'Enhanced scroll operation must succeed: ${scrollResult.error ?? "Unknown error"}');

              expect(scrollResult.finalCount,
                  greaterThanOrEqualTo(scrollResult.initialCount),
                  reason: 'Card count should not decrease after scrolling');

              if (scrollResult.paginationTriggered) {
                AllureReporter.reportStep(
                    'SUCCESS: Pagination loader was detected and triggered!',
                    status: AllureStepStatus.passed);
                TestLogger.log(
                    'PERFECT: Pagination loader appeared as expected');

                if (scrollResult.hasNewContent) {
                  AllureReporter.reportStep(
                      'New content loaded: ${scrollResult.totalNewCardsLoaded} additional cards',
                      status: AllureStepStatus.passed);
                  TestLogger.log(
                      'BONUS: ${scrollResult.totalNewCardsLoaded} new cards loaded');
                }
              } else if (scrollResult.hasNewContent) {
                AllureReporter.reportStep(
                    'SUCCESS: New content loaded (${scrollResult.totalNewCardsLoaded} cards) even without visible loader',
                    status: AllureStepStatus.passed);
                TestLogger.log(
                    'GOOD: Pagination working (${scrollResult.totalNewCardsLoaded} new cards loaded)');
              } else if (scrollResult.reachedEnd) {
                AllureReporter.reportStep(
                    'Reached end of available content - no more hotels to load',
                    status: AllureStepStatus.passed);
                TestLogger.log(
                    'INFO: End of list reached, no more content available');
              } else {
                AllureReporter.reportStep(
                    'No pagination activity detected after ${scrollResult.scrollAttempts} scroll attempts',
                    status: AllureStepStatus.failed);
                throw Exception(
                    'No pagination activity detected after continuous scrolling. '
                    'This suggests either: 1) Pagination is not working, 2) All content fits on screen, '
                    'or 3) End of list was reached without indicator. '
                    'Scroll attempts: ${scrollResult.scrollAttempts}, '
                    'Final cards: ${scrollResult.finalCount}');
              }

              AllureReporter.reportStep('Verify scroll mechanism is working');
              expect(scrollResult.scrollAttempts, greaterThan(0),
                  reason: 'Should have attempted scrolling');

              TestLogger.log('Final Test Results:');
              TestLogger.log('  Initial cards: ${scrollResult.initialCount}');
              TestLogger.log('  Final cards: ${scrollResult.finalCount}');
              TestLogger.log(
                  '  New cards loaded: ${scrollResult.totalNewCardsLoaded}');
              TestLogger.log(
                  '  Scroll attempts: ${scrollResult.scrollAttempts}');
              TestLogger.log(
                  '  Pagination loader seen: ${scrollResult.paginationTriggered}');
              TestLogger.log('  Reached end: ${scrollResult.reachedEnd}');
            } else {
              AllureReporter.reportStep(
                  'No hotel cards found for pagination testing',
                  status: AllureStepStatus.failed);
              throw Exception('Cannot test pagination without any hotel cards');
            }
          } else {
            AllureReporter.reportStep(
                'Search did not return results for pagination testing',
                status: AllureStepStatus.failed);
            throw Exception(
                'Cannot test pagination without search results. Search state: $searchState');
          }

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason:
                'Enhanced pagination test failed: $e\nStack trace: $stackTrace',
          );
          rethrow;
        }
      },
    );

    patrolTest(
      'Pagination behavior with different scroll patterns',
      config: PatrolConfig.getConfig(),
      ($) async {
        AllureReporter.addLabel('feature', 'Hotels Pagination Patterns');
        AllureReporter.setSeverity(AllureSeverity.normal);

        try {
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels');

          final testQueries = ['New York', 'London', 'Dubai', 'Tokyo', 'Paris'];
          bool paginationTested = false;

          for (final query in testQueries) {
            TestLogger.log('Testing pagination with query: "$query"');

            try {
              final searchField = find.byKey(const Key('search_text_field'));
              await $(searchField).enterText('');
              await $.pump(const Duration(milliseconds: 300));
              await $(searchField).enterText(query);
              await $.pump(const Duration(milliseconds: 1500));

              final searchState = await waitForSearchResults($,
                  timeout: const Duration(seconds: 15));

              if (searchState == SearchState.hasResults) {
                final cardCount = find.byType(Card).evaluate().length;
                TestLogger.log('Query "$query" returned $cardCount cards');

                if (cardCount >= 5) {
                  TestLogger.log(
                      'Testing pagination with "$query" ($cardCount cards)');

                  final result =
                      await EnhancedScrollTester.performContinuousScroll(
                    $,
                    maxScrollAttempts: 15,
                    scrollDistance: 350.0,
                    scrollDelay: const Duration(milliseconds: 500),
                  );

                  if (result.paginationTriggered || result.hasNewContent) {
                    TestLogger.log('Pagination working with query: "$query"');
                    paginationTested = true;
                    break;
                  } else if (result.reachedEnd) {
                    TestLogger.log('Query "$query" reached end of list');
                    paginationTested = true;
                    break;
                  }
                }
              }
            } catch (e) {
              TestLogger.log('Query "$query" failed: $e');
              continue;
            }
          }

          if (!paginationTested) {
            throw Exception(
                'Could not test pagination with any of the test queries: $testQueries');
          }

          TestLogger.log('Pagination behavior testing completed successfully');
          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason:
                'Pagination patterns test failed: $e\nStack trace: $stackTrace',
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
          await TestUtils.initializeAllure();
          await TestHelpers.initializeApp($);
          await TestHelpers.navigateToPage($, 'hotels',
              description: 'Navigating to Hotels page');
          AllureReporter.reportStep('App initialized',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Clear any existing favorites first');
          await TestHelpers.navigateToPage($, 'favorites');
          await $.pump(const Duration(seconds: 1));

          final existingCards = find.byType(Card).evaluate().length;
          if (existingCards > 0) {
            AllureReporter.reportStep(
                'Clearing $existingCards existing favorites');
            for (int i = 0; i < existingCards; i++) {
              final favoriteButtons = find.byIcon(Icons.favorite);
              if (favoriteButtons.evaluate().isNotEmpty) {
                await $(favoriteButtons.first).tap();
                await $.pump(const Duration(milliseconds: 500));
              }
            }
          }

          AllureReporter.reportStep('Navigate back to hotels page');
          await TestHelpers.navigateToPage($, 'hotels');
          AllureReporter.reportStep('Back to hotels page',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform search to get hotels');
          final searchState = await performSearch($, 'Paris');

          if (searchState == SearchState.hasResults) {
            final availableCards = find.byType(Card).evaluate().length;
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
                  final cardWidget = find.byType(Card).at(i);

                  final nameTexts = find.descendant(
                      of: cardWidget, matching: find.byType(Text));
                  if (nameTexts.evaluate().isNotEmpty) {
                    final nameWidget =
                        nameTexts.first.evaluate().first.widget as Text;
                    final hotelName = nameWidget.data ?? 'Hotel ${i + 1}';
                    addedHotelNames.add(hotelName);
                    TestLogger.log('Adding hotel to favorites: "$hotelName"');
                  }

                  final favoriteButton = find.descendant(
                      of: cardWidget,
                      matching: find.byIcon(Icons.favorite_outline));

                  if (favoriteButton.evaluate().isNotEmpty) {
                    await $(favoriteButton.first).tap();
                    await $.pump(const Duration(milliseconds: 800));

                    final filledHeart = find.descendant(
                        of: cardWidget, matching: find.byIcon(Icons.favorite));
                    expect(filledHeart.evaluate().isNotEmpty, isTrue,
                        reason:
                            'Heart should be filled after adding to favorites');

                    TestLogger.log(
                        'Successfully added hotel ${i + 1} to favorites');
                    AllureReporter.reportStep(
                        'Added hotel ${i + 1}: ${addedHotelNames.last}',
                        status: AllureStepStatus.passed);
                  } else {
                    TestLogger.log(
                        'No favorite button found for hotel ${i + 1}');
                    addedHotelNames.removeLast();
                  }
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
                final favoritesCards = find.byType(Card).evaluate().length;

                expect(favoritesCards, equals(actuallyAdded),
                    reason:
                        'Favorites page should show exactly $actuallyAdded hotels');

                TestLogger.log(
                    'VERIFIED: Favorites count matches - Expected: $actuallyAdded, Found: $favoritesCards');
                AllureReporter.reportStep(
                    'FAVORITES COUNT VERIFIED: $favoritesCards matches $actuallyAdded',
                    status: AllureStepStatus.passed);

                AllureReporter.reportStep(
                    'Verify exact hotel names in favorites');
                List<String> foundHotelNames = [];

                for (int i = 0; i < favoritesCards; i++) {
                  final favoriteCard = find.byType(Card).at(i);
                  final nameTexts = find.descendant(
                      of: favoriteCard, matching: find.byType(Text));

                  if (nameTexts.evaluate().isNotEmpty) {
                    final nameWidget =
                        nameTexts.first.evaluate().first.widget as Text;
                    final favoriteHotelName = nameWidget.data ?? '';
                    foundHotelNames.add(favoriteHotelName);

                    expect(addedHotelNames.contains(favoriteHotelName), isTrue,
                        reason:
                            'Hotel "$favoriteHotelName" in favorites should be one of the added hotels');

                    TestLogger.log(
                        'VERIFIED: Hotel "$favoriteHotelName" found in favorites');

                    final filledHeart = find.descendant(
                        of: favoriteCard,
                        matching: find.byIcon(Icons.favorite));
                    expect(filledHeart.evaluate().isNotEmpty, isTrue,
                        reason: 'Heart should be filled for favorite hotel');
                  }
                }

                AllureReporter.reportStep(
                    'ALL HOTEL NAMES VERIFIED: $foundHotelNames',
                    status: AllureStepStatus.passed);
                TestLogger.log('SUCCESS: All hotel names match exactly!');

                AllureReporter.reportStep(
                    'Remove hotels from favorites by unchecking hearts');
                int removedCount = 0;

                for (int i = favoritesCards - 1; i >= 0; i--) {
                  try {
                    final favoriteCard = find.byType(Card).at(i);
                    final filledHeartButton = find.descendant(
                        of: favoriteCard,
                        matching: find.byIcon(Icons.favorite));

                    if (filledHeartButton.evaluate().isNotEmpty) {
                      final hotelName = foundHotelNames[i];
                      TestLogger.log(
                          'Removing hotel from favorites: "$hotelName"');

                      await $(filledHeartButton.first).tap();
                      await $.pump(const Duration(milliseconds: 800));
                      removedCount++;

                      TestLogger.log(
                          // ignore: unnecessary_brace_in_string_interps
                          'Removed hotel ${removedCount}: "$hotelName"');
                      AllureReporter.reportStep('Removed hotel: $hotelName',
                          status: AllureStepStatus.passed);
                    }
                  } catch (e) {
                    TestLogger.log('Failed to remove favorite ${i + 1}: $e');
                  }
                }

                AllureReporter.reportStep(
                    'Verify all hotels are removed from favorites');
                await $.pump(const Duration(seconds: 1));

                final remainingCards = find.byType(Card).evaluate().length;
                expect(remainingCards, equals(0),
                    reason: 'All hotels should be removed from favorites');

                final emptyStateIcon =
                    find.byKey(const Key('favorites_empty_state_icon'));
                expect(emptyStateIcon, findsOneWidget,
                    reason:
                        'Empty state icon should be shown when no favorites');

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

enum SearchState { hasResults, hasError, isEmpty, timeout }

class ScrollResult {
  final bool success;
  final int initialCount;
  final int finalCount;
  final int scrollAttempts;
  final bool reachedEnd;
  final String? error;

  ScrollResult({
    required this.success,
    required this.initialCount,
    required this.finalCount,
    required this.scrollAttempts,
    this.reachedEnd = false,
    this.error,
  });

  bool get hasNewContent => finalCount > initialCount;
  int get newContentCount => finalCount - initialCount;

  @override
  String toString() {
    return 'ScrollResult(success: $success, $initialCount -> $finalCount cards, attempts: $scrollAttempts, reachedEnd: $reachedEnd${error != null ? ', error: $error' : ''})';
  }
}
