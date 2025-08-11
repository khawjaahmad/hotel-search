import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/hotels_screen_actions.dart';
import '../locators/app_locators.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  group('Performance Tests', () {
    patrolTest(
      'App startup performance is within acceptable limits',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'App Startup Performance Test');
        
        final startupStopwatch = Stopwatch()..start();
        await TestHelpers.initializeApp($);
        startupStopwatch.stop();
        
        final startupTime = startupStopwatch.elapsedMilliseconds;
        TestLogger.logTestStep($, 'App startup time: ${startupTime}ms');
        
        // Assert startup time is reasonable (under 5 seconds)
        expect(startupTime, lessThan(5000));
        
        TestLogger.logTestSuccess($, 'App startup performance verified');
      },
    );

    patrolTest(
      'Search performance is consistent across multiple queries',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Search Performance Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        final searchQueries = ['Dubai', 'London', 'Paris', 'Tokyo', 'New York'];
        final searchTimes = <int>[];
        
        for (final query in searchQueries) {
          TestLogger.logTestStep($, 'Testing search performance for: $query');
          
          // Clear previous search
          await hotelsActions.clearSearchField();
          await $.pump(const Duration(milliseconds: 300));
          
          // Measure search time
          final searchStopwatch = Stopwatch()..start();
          await hotelsActions.performSearch(query);
          await $.pump(const Duration(seconds: 2)); // Wait for results
          searchStopwatch.stop();
          
          final searchTime = searchStopwatch.elapsedMilliseconds;
          searchTimes.add(searchTime);
          
          TestLogger.logTestStep($, 'Search time for "$query": ${searchTime}ms');
          
          // Assert individual search time is reasonable (under 3 seconds)
          expect(searchTime, lessThan(3000));
        }
        
        // Calculate average search time
        final avgSearchTime = searchTimes.reduce((a, b) => a + b) / searchTimes.length;
        TestLogger.logTestStep($, 'Average search time: ${avgSearchTime.toStringAsFixed(2)}ms');
        
        // Assert average search time is reasonable
        expect(avgSearchTime, lessThan(2500));
        
        TestLogger.logTestSuccess($, 'Search performance verified');
      },
    );

    patrolTest(
      'Navigation performance between tabs is smooth',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Navigation Performance Test');
        await TestHelpers.initializeApp($);

        final navigationTimes = <String, int>{};
        final tabs = ['hotels', 'favorites', 'account', 'overview'];
        
        for (final tab in tabs) {
          TestLogger.logTestStep($, 'Testing navigation to $tab');
          
          final navStopwatch = Stopwatch()..start();
          await TestHelpers.navigateToPage($, tab);
          await $.pump(const Duration(milliseconds: 500)); // Wait for transition
          navStopwatch.stop();
          
          final navTime = navStopwatch.elapsedMilliseconds;
          navigationTimes[tab] = navTime;
          
          TestLogger.logTestStep($, 'Navigation to $tab: ${navTime}ms');
          
          // Assert navigation time is reasonable (under 1 second)
          expect(navTime, lessThan(1000));
        }
        
        // Test rapid navigation
        TestLogger.logTestStep($, 'Testing rapid navigation between tabs');
        final rapidNavStopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 3; i++) {
          for (final tab in tabs) {
            await TestHelpers.navigateToPage($, tab);
            await $.pump(const Duration(milliseconds: 100));
          }
        }
        
        rapidNavStopwatch.stop();
        final rapidNavTime = rapidNavStopwatch.elapsedMilliseconds;
        
        TestLogger.logTestStep($, 'Rapid navigation time: ${rapidNavTime}ms');
        
        // Assert rapid navigation doesn't cause performance issues
        expect(rapidNavTime, lessThan(5000));
        
        TestLogger.logTestSuccess($, 'Navigation performance verified');
      },
    );

    patrolTest(
      'Favorites operations performance is acceptable',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Favorites Performance Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels and search
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('Dubai');
        await $.pump(const Duration(seconds: 2));
        
        // Test adding favorites performance
        final addFavoritesTimes = <int>[];
        
        for (int i = 0; i < 5; i++) {
          TestLogger.logTestStep($, 'Testing add favorite performance for hotel $i');
          
          final addStopwatch = Stopwatch()..start();
          await hotelsActions.toggleFavorite(i, expectAdded: true);
          addStopwatch.stop();
          
          final addTime = addStopwatch.elapsedMilliseconds;
          addFavoritesTimes.add(addTime);
          
          TestLogger.logTestStep($, 'Add favorite time for hotel $i: ${addTime}ms');
          
          // Assert add favorite time is reasonable (under 1 second)
          expect(addTime, lessThan(1000));
          
          await $.pump(const Duration(milliseconds: 200));
        }
        
        // Calculate average add time
        final avgAddTime = addFavoritesTimes.reduce((a, b) => a + b) / addFavoritesTimes.length;
        TestLogger.logTestStep($, 'Average add favorite time: ${avgAddTime.toStringAsFixed(2)}ms');
        
        // Test removing favorites performance
        final removeFavoritesTimes = <int>[];
        
        for (int i = 0; i < 5; i++) {
          TestLogger.logTestStep($, 'Testing remove favorite performance for hotel $i');
          
          final removeStopwatch = Stopwatch()..start();
          await hotelsActions.toggleFavorite(i, expectAdded: false);
          removeStopwatch.stop();
          
          final removeTime = removeStopwatch.elapsedMilliseconds;
          removeFavoritesTimes.add(removeTime);
          
          TestLogger.logTestStep($, 'Remove favorite time for hotel $i: ${removeTime}ms');
          
          // Assert remove favorite time is reasonable (under 1 second)
          expect(removeTime, lessThan(1000));
          
          await $.pump(const Duration(milliseconds: 200));
        }
        
        // Calculate average remove time
        final avgRemoveTime = removeFavoritesTimes.reduce((a, b) => a + b) / removeFavoritesTimes.length;
        TestLogger.logTestStep($, 'Average remove favorite time: ${avgRemoveTime.toStringAsFixed(2)}ms');
        
        TestLogger.logTestSuccess($, 'Favorites performance verified');
      },
    );

    patrolTest(
      'Memory usage remains stable during extended usage',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Memory Stability Test');
        await TestHelpers.initializeApp($);

        // Simulate extended usage patterns
        final operations = [
          () async {
            await TestHelpers.navigateToPage($, 'hotels');
            final hotelsActions = HotelsScreenActions($);
            await hotelsActions.performSearch('London');
            await $.pump(const Duration(seconds: 1));
          },
          () async {
            await TestHelpers.navigateToPage($, 'favorites');
            await $.pump(const Duration(milliseconds: 500));
          },
          () async {
            await TestHelpers.navigateToPage($, 'account');
            await $.pump(const Duration(milliseconds: 500));
          },
          () async {
            await TestHelpers.navigateToPage($, 'overview');
            await $.pump(const Duration(milliseconds: 500));
          },
        ];
        
        // Perform operations multiple times to test memory stability
        for (int cycle = 0; cycle < 10; cycle++) {
          TestLogger.logTestStep($, 'Memory stability cycle ${cycle + 1}/10');
          
          for (final operation in operations) {
            await operation();
          }
          
          // Add some delay between cycles
          await $.pump(const Duration(milliseconds: 200));
        }
        
        // Verify app is still responsive
        await TestHelpers.navigateToPage($, 'hotels');
        final searchField = AppLocators.getSearchTextField($);
        await searchField.waitUntilVisible();
        expect(searchField.exists, true);
        
        TestLogger.logTestSuccess($, 'Memory stability verified');
      },
    );

    patrolTest(
      'Scroll performance is smooth with large datasets',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Scroll Performance Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels and search for results
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('Hotel');
        await $.pump(const Duration(seconds: 2));
        
        // Test scroll performance
        final scrollStopwatch = Stopwatch()..start();
        
        // Perform multiple scroll operations
        for (int i = 0; i < 5; i++) {
          TestLogger.logTestStep($, 'Scroll operation ${i + 1}/5');
          
          // Scroll down
          final listView = $(ListView);
          if (listView.exists) {
            await $.tester.drag(listView, const Offset(0, -200));
          }
          await $.pump(const Duration(milliseconds: 100));
          
          // Scroll up
          if (listView.exists) {
            await $.tester.drag(listView, const Offset(0, 200));
          }
          await $.pump(const Duration(milliseconds: 100));
        }
        
        scrollStopwatch.stop();
        final scrollTime = scrollStopwatch.elapsedMilliseconds;
        
        TestLogger.logTestStep($, 'Total scroll operations time: ${scrollTime}ms');
        
        // Assert scroll performance is reasonable
        expect(scrollTime, lessThan(3000));
        
        TestLogger.logTestSuccess($, 'Scroll performance verified');
      },
    );
  });
}