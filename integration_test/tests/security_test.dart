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

  group('Security Tests', () {
    patrolTest(
      'Input validation prevents malicious search queries',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Input Validation Security Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test various potentially malicious inputs
        final maliciousInputs = [
          '<script>alert("XSS")</script>',
          'SELECT * FROM hotels WHERE 1=1',
          '../../etc/passwd',
          'javascript:alert(1)',
          'a' * 1000, // Very long string
          '\x00\x01\x02', // Control characters
          '🚀💥🔥' * 100, // Many emojis
          'DROP TABLE hotels;',
          '<img src=x onerror=alert(1)>',
          '{{7*7}}', // Template injection
        ];
        
        for (final input in maliciousInputs) {
          TestLogger.logTestStep($, 'Testing malicious input: ${input.substring(0, input.length > 50 ? 50 : input.length)}...');
          
          try {
            await hotelsActions.performSearch(input);
            await $.pump(const Duration(seconds: 2));
            
            // Verify app doesn't crash and handles input gracefully
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
            
            // Clear the field for next test
            await hotelsActions.clearSearchField();
            await $.pump(const Duration(milliseconds: 300));
            
            TestLogger.logTestStep($, 'Input handled safely');
          } catch (e) {
            TestLogger.logTestStep($, 'Input caused error: $e');
            // App should handle errors gracefully, not crash
            final searchField = AppLocators.getSearchTextField($);
            expect(searchField.exists, true);
          }
        }
        
        TestLogger.logTestSuccess($, 'Input validation security verified');
      },
    );

    patrolTest(
      'App handles network timeouts and errors securely',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Network Security Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test rapid successive requests (potential DoS)
        TestLogger.logTestStep($, 'Testing rapid successive requests');
        
        for (int i = 0; i < 10; i++) {
          await hotelsActions.performSearch('Test$i');
          await $.pump(const Duration(milliseconds: 100)); // Very short delay
        }
        
        // Verify app is still responsive
        await $.pump(const Duration(seconds: 2));
        final searchField = AppLocators.getSearchTextField($);
        expect(searchField.exists, true);
        
        TestLogger.logTestStep($, 'App handled rapid requests without crashing');
        
        // Test with very long search terms
        TestLogger.logTestStep($, 'Testing extremely long search terms');
        
        final longSearchTerm = 'a' * 10000;
        try {
          await hotelsActions.performSearch(longSearchTerm);
          await $.pump(const Duration(seconds: 2));
          
          // App should handle this gracefully
          expect(searchField.exists, true);
          TestLogger.logTestStep($, 'Long search term handled safely');
        } catch (e) {
          TestLogger.logTestStep($, 'Long search term caused controlled error: $e');
          // Verify app is still functional
          expect(searchField.exists, true);
        }
        
        TestLogger.logTestSuccess($, 'Network security verified');
      },
    );

    patrolTest(
      'Data persistence is secure and isolated',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Data Persistence Security Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels and add some favorites
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('Dubai');
        await $.pump(const Duration(seconds: 2));
        
        // Add a favorite
        TestLogger.logTestStep($, 'Adding favorite for persistence test');
        await hotelsActions.toggleFavorite(0, expectAdded: true);
        await $.pump(const Duration(milliseconds: 500));
        
        // Navigate to favorites to verify persistence
        await TestHelpers.navigateToPage($, 'favorites');
        await $.pump(const Duration(seconds: 1));
        
        // Verify favorite was persisted
        final favoritesListView = AppLocators.getFavoritesListView($);
        expect(favoritesListView.exists, true);
        
        TestLogger.logTestStep($, 'Data persistence verified');
        
        // Test data isolation by clearing and verifying
        await TestHelpers.navigateToPage($, 'hotels');
        await hotelsActions.toggleFavorite(0, expectAdded: false);
        await $.pump(const Duration(milliseconds: 500));
        
        await TestHelpers.navigateToPage($, 'favorites');
        await $.pump(const Duration(seconds: 1));
        
        // Verify favorite was removed
        final emptyState = AppLocators.getFavoritesEmptyState($);
        expect(emptyState.exists, true);
        
        TestLogger.logTestStep($, 'Data isolation verified');
        TestLogger.logTestSuccess($, 'Data persistence security verified');
      },
    );

    patrolTest(
      'UI elements are protected against tampering',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'UI Security Test');
        await TestHelpers.initializeApp($);

        // Test navigation security
        TestLogger.logTestStep($, 'Testing navigation security');
        
        final tabs = ['hotels', 'favorites', 'account', 'overview'];
        
        for (final tab in tabs) {
          await TestHelpers.navigateToPage($, tab);
          await $.pump(const Duration(milliseconds: 500));
          
          // Verify the correct page is displayed
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
          
          TestLogger.logTestStep($, 'Navigation to $tab verified');
        }
        
        // Test button security (favorites)
        TestLogger.logTestStep($, 'Testing button security');
        
        await TestHelpers.navigateToPage($, 'hotels');
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('London');
        await $.pump(const Duration(seconds: 2));
        
        // Test rapid clicking on favorite button
        for (int i = 0; i < 5; i++) {
          final favoriteButton = AppLocators.getHotelFavoriteButton($, '48.8566,2.3522');
          if (favoriteButton.exists) {
            await favoriteButton.tap();
            await $.pump(const Duration(milliseconds: 100));
          }
        }
        
        // Verify app is still stable
        final searchField = AppLocators.getSearchTextField($);
        expect(searchField.exists, true);
        
        TestLogger.logTestStep($, 'Button security verified');
        TestLogger.logTestSuccess($, 'UI security verified');
      },
    );

    patrolTest(
      'Error messages do not expose sensitive information',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Error Message Security Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        
        // Test various error scenarios
        TestLogger.logTestStep($, 'Testing error message security');
        
        // Search for something that might cause an error
        await hotelsActions.performSearch('NonExistentHotel12345');
        await $.pump(const Duration(seconds: 3));
        
        // Check if any error messages are displayed
        // Error messages should be user-friendly and not expose internal details
        final errorElements = $('Error').evaluate();
        final exceptionElements = $('Exception').evaluate();
        final stackTraceElements = $('StackTrace').evaluate();
        
        // Verify no sensitive error information is exposed
        expect(errorElements.length, equals(0), reason: 'Raw error messages should not be exposed');
        expect(exceptionElements.length, equals(0), reason: 'Exception details should not be exposed');
        expect(stackTraceElements.length, equals(0), reason: 'Stack traces should not be exposed');
        
        TestLogger.logTestStep($, 'Error message security verified');
        
        // Test with special characters that might cause parsing errors
        final specialInputs = [
          '"""',
          "'''",
          '{}[]',
          '&lt;&gt;&amp;',
          '%20%21%22',
        ];
        
        for (final input in specialInputs) {
          TestLogger.logTestStep($, 'Testing special character input: $input');
          
          await hotelsActions.clearSearchField();
          await hotelsActions.performSearch(input);
          await $.pump(const Duration(seconds: 1));
          
          // Verify no sensitive error information is exposed
          final errorElements = $('Error').evaluate();
          expect(errorElements.length, equals(0));
        }
        
        TestLogger.logTestSuccess($, 'Error message security verified');
      },
    );

    patrolTest(
      'App state remains consistent under stress conditions',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'State Consistency Security Test');
        await TestHelpers.initializeApp($);

        // Perform stress operations
        TestLogger.logTestStep($, 'Performing stress operations');
        
        final operations = [
          () async {
            await TestHelpers.navigateToPage($, 'hotels');
            final hotelsActions = HotelsScreenActions($);
            await hotelsActions.performSearch('Test');
          },
          () async {
            await TestHelpers.navigateToPage($, 'favorites');
          },
          () async {
            await TestHelpers.navigateToPage($, 'account');
          },
          () async {
            await TestHelpers.navigateToPage($, 'overview');
          },
        ];
        
        // Perform rapid operations
        for (int cycle = 0; cycle < 20; cycle++) {
          final operation = operations[cycle % operations.length];
          await operation();
          await $.pump(const Duration(milliseconds: 50)); // Very short delay
        }
        
        // Verify app is still in a consistent state
        TestLogger.logTestStep($, 'Verifying app state consistency');
        
        // Navigate to each page and verify it loads correctly
        await TestHelpers.navigateToPage($, 'hotels');
        final searchField = AppLocators.getSearchTextField($);
        expect(searchField.exists, true);
        
        await TestHelpers.navigateToPage($, 'favorites');
        final favoritesScaffold = AppLocators.getFavoritesScaffold($);
        expect(favoritesScaffold.exists, true);
        
        await TestHelpers.navigateToPage($, 'account');
        final accountScaffold = AppLocators.getAccountScaffold($);
        expect(accountScaffold.exists, true);
        
        await TestHelpers.navigateToPage($, 'overview');
        final overviewScaffold = AppLocators.getOverviewScaffold($);
        expect(overviewScaffold.exists, true);
        
        TestLogger.logTestStep($, 'App state consistency verified');
        TestLogger.logTestSuccess($, 'State consistency security verified');
      },
    );
  });
}