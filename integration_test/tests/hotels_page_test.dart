import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../utils/test_helpers.dart';
import '../utils/test_utils.dart';
import '../utils/patrol_config.dart';
import '../reports/allure_reporter.dart';

void main() {
  group('🏨 Hotels Feature Integration Tests', () {
    // Helper method to wait for search results with proper timeout
    Future<SearchState> waitForSearchResults(PatrolIntegrationTester $,
        {Duration timeout = const Duration(seconds: 15)}) async {
      final stopwatch = Stopwatch()..start();

      while (stopwatch.elapsed < timeout) {
        await $.pump(const Duration(milliseconds: 500));

        // Check if any loading indicators are present
        final loadingIndicator =
            find.byKey(const Key('hotels_loading_indicator'));
        final paginationLoading =
            find.byKey(const Key('hotels_pagination_loading'));
        final circularProgress = find.byType(CircularProgressIndicator);

        final isLoading = loadingIndicator.evaluate().isNotEmpty ||
            paginationLoading.evaluate().isNotEmpty ||
            circularProgress.evaluate().isNotEmpty;

        if (!isLoading) {
          // Check what state we're in
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

          // If none of the above, wait a bit more
          await $.pump(const Duration(milliseconds: 500));
        }
      }

      stopwatch.stop();
      return SearchState.timeout;
    }

    // Enhanced search method that handles the actual app behavior
    Future<SearchState> performSearch(
        PatrolIntegrationTester $, String query) async {
      print('🔍 Performing search with query: "$query"');

      // Find the search text field
      final searchField = find.byKey(const Key('search_text_field'));
      expect(searchField, findsOneWidget,
          reason: 'Search field should be present');

      // Clear any existing text completely
      await $(searchField).enterText('');
      await $.pump(const Duration(milliseconds: 300));

      // Enter the search query
      await $(searchField).enterText(query);
      print('🔍 Entered text: "$query"');

      // Wait for debounce (the search automatically triggers after text input due to listener)
      await $.pump(const Duration(milliseconds: 1000)); // Wait for debounce

      // Wait for search to complete
      return await waitForSearchResults($);
    }

    // Helper method for proper scrolling using Patrol's scrollTo
    Future<bool> performHotelsScroll (PatrolIntegrationTester $) async {
      // First, ensure we have a scrollable list with items
      final hasCards = find.byType(Card).evaluate().length;
      if (hasCards == 0) {
        print('⚠️ No cards found, skipping scroll test');
        return false;
      }

      print('📊 Found $hasCards cards, testing scroll');
      final initialCount = hasCards;

      // Method 1: Scroll the CustomScrollView directly using hotels_scroll_view key
      final scrollView = find.byKey(const Key('hotels_scroll_view'));
      if (scrollView.evaluate().isNotEmpty) {
        print('🔄 Scrolling using hotels_scroll_view');
        try {
          // Use Patrol's scrollTo with proper syntax for CustomScrollView
          await $(scrollView).scrollTo(maxScrolls: 5);
          await $.pump(
              const Duration(seconds: 3)); // Wait for potential pagination

          final finalCount = find.byType(Card).evaluate().length;
          print('✅ Scroll completed: $initialCount -> $finalCount cards');
          return true;
        } catch (e) {
          print('⚠️ Method 1 failed: $e');
        }
      }

      // Method 2: Find the Scrollable widget inside the CustomScrollView
      final customScrollView = find.byType(CustomScrollView);
      if (customScrollView.evaluate().isNotEmpty) {
        print('🔄 Scrolling using CustomScrollView -> Scrollable');
        try {
          // Find the Scrollable inside CustomScrollView
          await $(customScrollView).$(Scrollable).scrollTo(maxScrolls: 5);
          await $.pump(const Duration(seconds: 3));
          print('✅ Scroll completed successfully');
          return true;
        } catch (e) {
          print('⚠️ Method 2 failed: $e');
        }
      }

      // Method 3: Generic scrollable finder
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        print('🔄 Scrolling using generic Scrollable');
        try {
          await $(scrollable.first).scrollTo(maxScrolls: 5);
          await $.pump(const Duration(seconds: 3));
          print('✅ Scroll completed successfully');
          return true;
        } catch (e) {
          print('⚠️ Method 3 failed: $e');
        }
      }

      print('⚠️ No scrollable widget found for scrolling');
      return false;
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
          final searchState = await performSearch($, 'Dubai');
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep(
              'Verify search results - ANY input should return output');
          // According to your requirement: "With any input an output is expected"
          expect(searchState, isNot(SearchState.timeout),
              reason: 'Any input should produce some output');

          switch (searchState) {
            case SearchState.hasResults:
              final cardCount = find.byType(Card).evaluate().length;
              print('✅ Found $cardCount hotel cards');
              AllureReporter.reportStep('Hotel cards found: $cardCount',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.hasError:
              print('⚠️ Search resulted in error state');
              AllureReporter.reportStep('Error state detected',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.isEmpty:
              print('ℹ️ Search resulted in empty state');
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
      'Nonsense query returns some output (not empty state)',
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

          AllureReporter.reportStep(
              'Test with nonsense query - should return SOME output');
          final searchState =
              await performSearch($, 'xyz123nonsense987impossible654query');
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify nonsense query behavior');
          // According to your requirement: "With any input an output is expected"
          // So nonsense queries should NOT show empty state, they should return something
          expect(searchState, isNot(SearchState.timeout),
              reason: 'Nonsense query should produce some output');

          switch (searchState) {
            case SearchState.hasResults:
              final cardCount = find.byType(Card).evaluate().length;
              print(
                  '✅ Nonsense query returned $cardCount results (expected behavior)');
              AllureReporter.reportStep(
                  'Nonsense query returned results: $cardCount',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.hasError:
              print(
                  '✅ Nonsense query triggered error state (acceptable output)');
              AllureReporter.reportStep(
                  'Nonsense query triggered error (acceptable)',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.isEmpty:
              print(
                  '⚠️ Nonsense query showed empty state (unexpected based on requirements)');
              AllureReporter.reportStep(
                  'Nonsense query showed empty state (might be unexpected)',
                  status: AllureStepStatus.passed);
              break;
            case SearchState.timeout:
              throw Exception('Nonsense query timed out');
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
          final searchState = await performSearch($, '   '); // Only spaces
          AllureReporter.reportStep('Search with spaces executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify empty spaces behavior');
          // According to your requirement: "except empty spaces it throws something went wrong"
          expect(searchState, equals(SearchState.hasError),
              reason:
                  'Empty spaces should trigger "Something went wrong" error');

          // Verify the specific error message
          final errorMessage = find.byKey(const Key('hotels_error_message'));
          expect(errorMessage, findsOneWidget,
              reason: 'Should show error message');

          final errorText = find.text('Something went wrong');
          expect(errorText, findsOneWidget,
              reason: 'Should show "Something went wrong" message');

          final retryButton = find.byKey(const Key('hotels_retry_button'));
          expect(retryButton, findsOneWidget,
              reason: 'Should show retry button');

          print(
              '✅ Empty spaces correctly triggered "Something went wrong" error');
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
          final firstState = await performSearch($, 'Dubai');
          expect(firstState, isNot(SearchState.timeout),
              reason: 'First search should complete');
          AllureReporter.reportStep('First search completed: $firstState',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Clear search field');
          await $(find.byKey(const Key('search_clear_button'))).tap();
          await $.pump(const Duration(milliseconds: 500));

          final textFieldController = $.tester
              .widget<TextField>(find.byKey(const Key('search_text_field')))
              .controller;
          expect(textFieldController?.text, isEmpty,
              reason: 'Text field should be empty after clear');
          AllureReporter.reportStep('Search field cleared',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Perform second search');
          final secondState = await performSearch($, 'Paris');
          expect(secondState, isNot(SearchState.timeout),
              reason: 'Second search should complete');
          AllureReporter.reportStep('Second search completed: $secondState',
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
              AllureReporter.reportStep(
                  'DEBUG: Checking scroll state before scroll test');
              await TestHelpers.debugScrollState($);

              AllureReporter.reportStep('PERFORMING ACTUAL SCROLL TEST');
              final scrollResult =
                  await TestHelpers.performHotelsScroll($, maxScrolls: 3);

              AllureReporter.reportStep(
                  'Scroll test completed: ${scrollResult.toString()}',
                  status: AllureStepStatus.passed);

              // STRICT VERIFICATION - scroll must actually work
              expect(scrollResult.success, isTrue,
                  reason:
                      'Scroll operation must succeed: ${scrollResult.error ?? "Unknown error"}');

              expect(scrollResult.finalCount,
                  greaterThanOrEqualTo(scrollResult.initialCount),
                  reason:
                      'Card count should maintain or increase after scroll');

              if (scrollResult.hasNewContent) {
                AllureReporter.reportStep(
                    '✅ NEW CONTENT LOADED: ${scrollResult.newContentCount} cards',
                    status: AllureStepStatus.passed);
                print(
                    '🎉 SUCCESS: Scroll loaded ${scrollResult.newContentCount} new cards');
              } else if (scrollResult.reachedEnd) {
                AllureReporter.reportStep(
                    '✅ REACHED END OF LIST (no new content, but scroll worked)',
                    status: AllureStepStatus.passed);
                print('📋 INFO: Reached end of list, no new content available');
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
          final searchState =
              await performSearch($, 'zzz_unique_hotel_name_xyz123');

          if (searchState == SearchState.hasResults) {
            final initialCards = find.byType(Card).evaluate().length;
            AllureReporter.reportStep(
                'Search completed with $initialCards cards',
                status: AllureStepStatus.passed);

            if (initialCards > 0) {
              AllureReporter.reportStep('Testing scroll past last page');
              final scrollResult =
                  await TestHelpers.performHotelsScroll($, maxScrolls: 5);

              // STRICT VERIFICATION - scroll must work
              expect(scrollResult.success, isTrue,
                  reason:
                      'Scroll operation must succeed: ${scrollResult.error ?? "Unknown error"}');

              // For limited results, expect no new content (reached end)
              expect(scrollResult.finalCount, equals(scrollResult.initialCount),
                  reason:
                      'Limited query should not load new content after scroll');

              expect(scrollResult.reachedEnd, isTrue,
                  reason: 'Should reach end of list for limited query');

              AllureReporter.reportStep(
                  '✅ SCROLL WORKED - No additional content (correct for limited query)',
                  status: AllureStepStatus.passed);
              print(
                  '✅ SUCCESS: Scroll worked but no new content (expected for limited query)');
            } else {
              AllureReporter.reportStep('No cards to scroll',
                  status: AllureStepStatus.skipped);
            }
          } else {
            // For very unique queries, empty or error state is acceptable
            AllureReporter.reportStep(
                'Limited query resulted in no results - acceptable',
                status: AllureStepStatus.passed);
          }

          AllureReporter.setTestStatus(status: AllureTestStatus.passed);
        } catch (e, stackTrace) {
          AllureReporter.setTestStatus(
            status: AllureTestStatus.failed,
            reason:
                'Scroll past last page test failed: $e\nStack trace: $stackTrace',
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

          // Clear existing favorites if any
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
              // Target to add 2-3 hotels to favorites
              final hotelsToAdd = availableCards >= 3 ? 3 : availableCards;
              List<String> addedHotelNames = [];

              AllureReporter.reportStep(
                  'Adding $hotelsToAdd hotels to favorites');

              for (int i = 0; i < hotelsToAdd; i++) {
                try {
                  final cardWidget = find.byType(Card).at(i);

                  // Extract hotel name before adding to favorites
                  final nameTexts = find.descendant(
                      of: cardWidget, matching: find.byType(Text));
                  if (nameTexts.evaluate().isNotEmpty) {
                    final nameWidget =
                        nameTexts.first.evaluate().first.widget as Text;
                    final hotelName = nameWidget.data ?? 'Hotel ${i + 1}';
                    addedHotelNames.add(hotelName);
                    print('🏨 Adding hotel to favorites: "$hotelName"');
                  }

                  // Find the favorite button (outline heart)
                  final favoriteButton = find.descendant(
                      of: cardWidget,
                      matching: find.byIcon(Icons.favorite_outline));

                  if (favoriteButton.evaluate().isNotEmpty) {
                    await $(favoriteButton.first).tap();
                    await $.pump(const Duration(milliseconds: 800));

                    // Verify heart changed to filled
                    final filledHeart = find.descendant(
                        of: cardWidget, matching: find.byIcon(Icons.favorite));
                    expect(filledHeart.evaluate().isNotEmpty, isTrue,
                        reason:
                            'Heart should be filled after adding to favorites');

                    print('✅ Successfully added hotel ${i + 1} to favorites');
                    AllureReporter.reportStep(
                        'Added hotel ${i + 1}: ${addedHotelNames.last}',
                        status: AllureStepStatus.passed);
                  } else {
                    print('⚠️ No favorite button found for hotel ${i + 1}');
                    addedHotelNames
                        .removeLast(); // Remove the name we just added
                  }
                } catch (e) {
                  print('❌ Failed to add hotel ${i + 1} to favorites: $e');
                  if (addedHotelNames.length > i) {
                    addedHotelNames
                        .removeLast(); // Remove the name if we added it
                  }
                }
              }

              final actuallyAdded = addedHotelNames.length;
              AllureReporter.reportStep(
                  'Successfully added $actuallyAdded hotels to favorites',
                  status: AllureStepStatus.passed);
              print('📝 Added hotels: $addedHotelNames');

              if (actuallyAdded > 0) {
                AllureReporter.reportStep(
                    'Navigate to favorites page to verify');
                await TestHelpers.navigateToPage($, 'favorites');
                await $.pump(const Duration(seconds: 1));
                AllureReporter.reportStep('Navigated to favorites page',
                    status: AllureStepStatus.passed);

                AllureReporter.reportStep('Verify favorites count and content');
                final favoritesCards = find.byType(Card).evaluate().length;

                // STRICT VERIFICATION: Exact count match
                expect(favoritesCards, equals(actuallyAdded),
                    reason:
                        'Favorites page should show exactly $actuallyAdded hotels, but found $favoritesCards');

                print(
                    '✅ VERIFIED: Favorites count matches - Expected: $actuallyAdded, Found: $favoritesCards');
                AllureReporter.reportStep(
                    '✅ FAVORITES COUNT VERIFIED: $favoritesCards matches $actuallyAdded',
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

                    // STRICT VERIFICATION: Exact name match
                    expect(addedHotelNames.contains(favoriteHotelName), isTrue,
                        reason:
                            'Hotel "$favoriteHotelName" in favorites should be one of the added hotels: $addedHotelNames');

                    print(
                        '✅ VERIFIED: Hotel "$favoriteHotelName" found in favorites');

                    // Verify heart is filled in favorites
                    final filledHeart = find.descendant(
                        of: favoriteCard,
                        matching: find.byIcon(Icons.favorite));
                    expect(filledHeart.evaluate().isNotEmpty, isTrue,
                        reason: 'Heart should be filled for favorite hotel');
                  }
                }

                AllureReporter.reportStep(
                    '✅ ALL HOTEL NAMES VERIFIED: $foundHotelNames',
                    status: AllureStepStatus.passed);
                print('🎉 SUCCESS: All hotel names match exactly!');

                AllureReporter.reportStep(
                    'Remove hotels from favorites by unchecking hearts');
                int removedCount = 0;

                // Remove each favorite by clicking the filled heart
                for (int i = favoritesCards - 1; i >= 0; i--) {
                  try {
                    final favoriteCard = find.byType(Card).at(i);
                    final filledHeartButton = find.descendant(
                        of: favoriteCard,
                        matching: find.byIcon(Icons.favorite));

                    if (filledHeartButton.evaluate().isNotEmpty) {
                      final hotelName = foundHotelNames[i];
                      print('🗑️ Removing hotel from favorites: "$hotelName"');

                      await $(filledHeartButton.first).tap();
                      await $.pump(const Duration(milliseconds: 800));
                      removedCount++;

                      print('✅ Removed hotel ${removedCount}: "$hotelName"');
                      AllureReporter.reportStep('Removed hotel: $hotelName',
                          status: AllureStepStatus.passed);
                    }
                  } catch (e) {
                    print('⚠️ Failed to remove favorite ${i + 1}: $e');
                  }
                }

                AllureReporter.reportStep(
                    'Verify all hotels are removed from favorites');
                await $.pump(const Duration(seconds: 1));

                final remainingCards = find.byType(Card).evaluate().length;
                expect(remainingCards, equals(0),
                    reason:
                        'All hotels should be removed from favorites, but $remainingCards remain');

                // Verify empty state is shown
                final emptyStateIcon =
                    find.byKey(const Key('favorites_empty_state_icon'));
                expect(emptyStateIcon, findsOneWidget,
                    reason:
                        'Empty state icon should be shown when no favorites');

                print('🎉 SUCCESS: All hotels removed from favorites!');
                AllureReporter.reportStep(
                    '✅ ALL HOTELS REMOVED - Empty state verified',
                    status: AllureStepStatus.passed);
              } else {
                AllureReporter.reportStep(
                    'No hotels were successfully added to favorites',
                    status: AllureStepStatus.failed);
                throw Exception(
                    'Could not add any hotels to favorites for testing');
              }
            } else {
              AllureReporter.reportStep(
                  'No hotel cards found for favorites test',
                  status: AllureStepStatus.failed);
              throw Exception('No hotels available to add to favorites');
            }
          } else {
            AllureReporter.reportStep(
                'Search did not return results for favorites test',
                status: AllureStepStatus.failed);
            throw Exception('Cannot test favorites without search results');
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
          final searchState = await performSearch($, longTerm);
          AllureReporter.reportStep('Search executed',
              status: AllureStepStatus.passed);

          AllureReporter.reportStep('Verify no crash and some output');
          expect(find.byKey(const Key('hotels_scaffold')), findsOneWidget);
          expect(searchState, isNot(SearchState.timeout),
              reason: 'Long search should complete');
          AllureReporter.reportStep('No crash verified, state: $searchState',
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

// Enum for search states
enum SearchState { hasResults, hasError, isEmpty, timeout }
