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

  group('Edge Cases Tests', () {
    patrolTest(
      'App handles extremely long search queries gracefully',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Long Search Query Edge Case Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test various long search queries
        final longQueries = [
          'a' * 100,
          'Hotel' * 50,
          'Very Long Hotel Name That Goes On And On And On' * 10,
          '🏨' * 200, // Unicode characters
          'Search Query With Many Words ' * 25,
        ];
        
        for (final query in longQueries) {
          TestLogger.logTestStep($, 'Testing long query of length: ${query.length}');
          
          try {
            await hotelsActions.performSearch(query);
            await $.pump(const Duration(seconds: 2));
            
            // Verify app doesn't crash
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
            
            // Clear for next test
            await hotelsActions.clearSearchField();
            await $.pump(const Duration(milliseconds: 300));
            
            TestLogger.logTestStep($, 'Long query handled successfully');
          } catch (e) {
            TestLogger.logTestStep($, 'Long query caused controlled error: $e');
            // App should still be functional
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
          }
        }
        
        TestLogger.logTestSuccess($, 'Long search queries handled gracefully');
      },
    );

    patrolTest(
      'App handles special characters and unicode in search',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Special Characters Edge Case Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test various special character combinations
        final specialQueries = [
          '🏨🌟⭐🎯', // Emojis
          'Hôtel Café', // Accented characters
          '酒店', // Chinese characters
          'فندق', // Arabic characters
          'Отель', // Cyrillic characters
          '!@#\$%^&*()', // Special symbols
          '"Hotel"', // Quotes
          "'Hotel'", // Single quotes
          'Hotel\nName', // Newline
          'Hotel\tName', // Tab
          'Hotel & Resort', // Ampersand
          'Hotel <> Resort', // Angle brackets
          'Hotel [Premium]', // Square brackets
          'Hotel {Luxury}', // Curly brackets
          'Hotel|Resort', // Pipe character
          'Hotel~Resort', // Tilde
          'Hotel`Resort', // Backtick
        ];
        
        for (final query in specialQueries) {
          TestLogger.logTestStep($, 'Testing special characters: $query');
          
          try {
            await hotelsActions.performSearch(query);
            await $.pump(const Duration(seconds: 2));
            
            // Verify app handles special characters
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
            
            // Clear for next test
            await hotelsActions.clearSearchField();
            await $.pump(const Duration(milliseconds: 300));
            
            TestLogger.logTestStep($, 'Special characters handled successfully');
          } catch (e) {
            TestLogger.logTestStep($, 'Special characters caused controlled error: $e');
            // Verify app is still functional
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
          }
        }
        
        TestLogger.logTestSuccess($, 'Special characters handled gracefully');
      },
    );

    patrolTest(
      'App handles rapid navigation and state changes',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Rapid Navigation Edge Case Test');
        await TestHelpers.initializeApp($);

        // Test rapid navigation between tabs
        final tabs = ['hotels', 'favorites', 'account', 'overview'];
        
        TestLogger.logTestStep($, 'Testing rapid tab switching');
        
        for (int cycle = 0; cycle < 5; cycle++) {
          for (final tab in tabs) {
            await TestHelpers.navigateToPage($, tab);
            await $.pump(const Duration(milliseconds: 50)); // Very fast switching
          }
        }
        
        // Verify app is still responsive
        await $.pump(const Duration(seconds: 1));
        
        // Test each tab is still functional
        for (final tab in tabs) {
          await TestHelpers.navigateToPage($, tab);
          await $.pump(const Duration(milliseconds: 500));
          
          switch (tab) {
            case 'hotels':
              final searchField = AppLocators.getSearchTextField($);
              expect(searchField.exists, true);
              break;
            case 'favorites':
              final favoritesScaffold = AppLocators.getFavoritesScaffold($);
              expect(favoritesScaffold.exists, true);
              break;
            case 'account':
              final accountScaffold = AppLocators.getAccountScaffold($);
              expect(accountScaffold.exists, true);
              break;
            case 'overview':
              final overviewScaffold = AppLocators.getOverviewScaffold($);
              expect(overviewScaffold.exists, true);
              break;
          }
        }
        
        TestLogger.logTestSuccess($, 'Rapid navigation handled successfully');
      },
    );

    patrolTest(
      'App handles empty and whitespace-only search queries',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Empty Search Edge Case Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test various empty/whitespace queries
        final emptyQueries = [
          '', // Empty string
          ' ', // Single space
          '   ', // Multiple spaces
          '\t', // Tab character
          '\n', // Newline
          '\r', // Carriage return
          '\t\n\r ', // Mixed whitespace
          '   \t   \n   ', // Complex whitespace
        ];
        
        for (final query in emptyQueries) {
          TestLogger.logTestStep($, 'Testing empty/whitespace query: "${query.replaceAll('\n', '\\n').replaceAll('\t', '\\t').replaceAll('\r', '\\r')}"');
          
          try {
            await hotelsActions.performSearch(query);
            await $.pump(const Duration(seconds: 2));
            
            // Verify app handles empty queries appropriately
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
            
            // Check if empty state is shown or if it handles gracefully
            // The app should either show empty state or handle it gracefully
            
            TestLogger.logTestStep($, 'Empty query handled appropriately');
          } catch (e) {
            TestLogger.logTestStep($, 'Empty query caused controlled error: $e');
            // Verify app is still functional
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
          }
        }
        
        TestLogger.logTestSuccess($, 'Empty search queries handled gracefully');
      },
    );

    patrolTest(
      'App handles boundary values for favorites operations',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Favorites Boundary Edge Case Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels and search
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('Hotel');
        await $.pump(const Duration(seconds: 2));
        
        // Test rapid favorite/unfavorite operations
        TestLogger.logTestStep($, 'Testing rapid favorite operations');
        
        for (int i = 0; i < 10; i++) {
          try {
            await hotelsActions.toggleFavorite(0, expectAdded: true);
            await $.pump(const Duration(milliseconds: 100));
            await hotelsActions.toggleFavorite(0, expectAdded: false);
            await $.pump(const Duration(milliseconds: 100));
            
            TestLogger.logTestStep($, 'Rapid favorite cycle ${i + 1} completed');
          } catch (e) {
            TestLogger.logTestStep($, 'Rapid favorite operation caused error: $e');
            // Verify app is still functional
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
            break;
          }
        }
        
        // Test adding multiple favorites quickly
        TestLogger.logTestStep($, 'Testing multiple quick favorites');
        
        for (int i = 0; i < 5; i++) {
          try {
            await hotelsActions.toggleFavorite(i, expectAdded: true);
            await $.pump(const Duration(milliseconds: 50));
          } catch (e) {
            TestLogger.logTestStep($, 'Quick favorite $i caused error: $e');
            break;
          }
        }
        
        // Verify favorites page still works
        await TestHelpers.navigateToPage($, 'favorites');
        await $.pump(const Duration(seconds: 1));
        
        final favoritesScaffold = AppLocators.getFavoritesScaffold($);
        expect(favoritesScaffold.exists, true);
        
        TestLogger.logTestSuccess($, 'Favorites boundary operations handled');
      },
    );

    patrolTest(
      'App handles network-related edge cases',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Network Edge Cases Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test rapid successive searches (potential network flooding)
        TestLogger.logTestStep($, 'Testing rapid successive searches');
        
        final rapidSearches = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
        
        for (final search in rapidSearches) {
          try {
            await hotelsActions.performSearch(search);
            await $.pump(const Duration(milliseconds: 100)); // Very short delay
          } catch (e) {
            TestLogger.logTestStep($, 'Rapid search "$search" caused error: $e');
          }
        }
        
        // Wait for any pending operations
        await $.pump(const Duration(seconds: 3));
        
        // Verify app is still responsive
        final searchField = AppLocators.getSearchTextField($);
        expect(searchField.exists, true);
        
        // Test search cancellation by rapid query changes
        TestLogger.logTestStep($, 'Testing search cancellation scenarios');
        
        await hotelsActions.performSearch('LongSearchTerm');
        await $.pump(const Duration(milliseconds: 100));
        await hotelsActions.clearSearchField();
        await $.pump(const Duration(milliseconds: 100));
        await hotelsActions.performSearch('NewSearch');
        await $.pump(const Duration(seconds: 2));
        
        // Verify final state is consistent
        expect(searchField.exists, true);
        
        TestLogger.logTestSuccess($, 'Network edge cases handled gracefully');
      },
    );

    patrolTest(
      'App handles memory pressure scenarios',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Memory Pressure Edge Case Test');
        await TestHelpers.initializeApp($);

        // Simulate memory pressure through extensive operations
        TestLogger.logTestStep($, 'Simulating memory pressure');
        
        final operations = [
          () async {
            await TestHelpers.navigateToPage($, 'hotels');
            final hotelsActions = HotelsScreenActions($);
            await hotelsActions.performSearch('Memory Test ${DateTime.now().millisecondsSinceEpoch}');
            await $.pump(const Duration(milliseconds: 500));
          },
          () async {
            await TestHelpers.navigateToPage($, 'favorites');
            await $.pump(const Duration(milliseconds: 200));
          },
          () async {
            await TestHelpers.navigateToPage($, 'account');
            await $.pump(const Duration(milliseconds: 200));
          },
          () async {
            await TestHelpers.navigateToPage($, 'overview');
            await $.pump(const Duration(milliseconds: 200));
          },
        ];
        
        // Perform many operations to stress memory
        for (int cycle = 0; cycle < 50; cycle++) {
          final operation = operations[cycle % operations.length];
          try {
            await operation();
            
            if (cycle % 10 == 0) {
              TestLogger.logTestStep($, 'Memory pressure cycle ${cycle + 1}/50');
            }
          } catch (e) {
            TestLogger.logTestStep($, 'Memory pressure caused error at cycle $cycle: $e');
            break;
          }
        }
        
        // Verify app is still functional after memory pressure
        await TestHelpers.navigateToPage($, 'hotels');
        final searchField = AppLocators.getSearchTextField($);
        expect(searchField.exists, true);
        
        // Test basic functionality still works
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('Final Test');
        await $.pump(const Duration(seconds: 2));
        
        expect(searchField.exists, true);
        
        TestLogger.logTestSuccess($, 'Memory pressure scenarios handled');
      },
    );

    patrolTest(
      'App handles concurrent user interactions',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Concurrent Interactions Edge Case Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test concurrent search and navigation
        TestLogger.logTestStep($, 'Testing concurrent search and navigation');
        
        // Start a search
        await hotelsActions.performSearch('Concurrent Test');
        
        // Immediately try to navigate (simulating user impatience)
        await $.pump(const Duration(milliseconds: 100));
        await TestHelpers.navigateToPage($, 'favorites');
        await $.pump(const Duration(milliseconds: 100));
        await TestHelpers.navigateToPage($, 'hotels');
        
        // Wait for any pending operations
        await $.pump(const Duration(seconds: 2));
        
        // Verify app state is consistent
        final searchField = AppLocators.getSearchTextField($);
        expect(searchField.exists, true);
        
        // Test concurrent favorite operations
        TestLogger.logTestStep($, 'Testing concurrent favorite operations');
        
        await hotelsActions.performSearch('Dubai');
        await $.pump(const Duration(seconds: 2));
        
        // Try to add favorite while searching for something else
        try {
          await hotelsActions.toggleFavorite(0, expectAdded: true);
          await $.pump(const Duration(milliseconds: 100));
          await hotelsActions.performSearch('London');
          await $.pump(const Duration(milliseconds: 100));
          await hotelsActions.toggleFavorite(0, expectAdded: false);
        } catch (e) {
          TestLogger.logTestStep($, 'Concurrent operations caused controlled error: $e');
        }
        
        // Verify final state
        await $.pump(const Duration(seconds: 2));
        expect(searchField.exists, true);
        
        TestLogger.logTestSuccess($, 'Concurrent interactions handled gracefully');
      },
    );
  });
}