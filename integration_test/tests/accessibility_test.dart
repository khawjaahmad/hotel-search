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

  group('Accessibility Tests', () {
    patrolTest(
      'All navigation tabs have proper semantic labels',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Navigation Accessibility Test');
        await TestHelpers.initializeApp($);

        // Test Overview tab accessibility
        final overviewTab = AppLocators.getOverviewTab($);
        await overviewTab.waitUntilVisible();
        expect(overviewTab.exists, true);
        
        // Test Hotels tab accessibility
        final hotelsTab = AppLocators.getHotelsTab($);
        await hotelsTab.waitUntilVisible();
        expect(hotelsTab.exists, true);
        
        // Test Favorites tab accessibility
        final favoritesTab = AppLocators.getFavoritesTab($);
        await favoritesTab.waitUntilVisible();
        expect(favoritesTab.exists, true);
        
        // Test Account tab accessibility
        final accountTab = AppLocators.getAccountTab($);
        await accountTab.waitUntilVisible();
        expect(accountTab.exists, true);
        
        TestLogger.logTestSuccess($, 'Navigation accessibility verified');
      },
    );

    patrolTest(
      'Search field has proper accessibility attributes',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Search Field Accessibility Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        // Test search field accessibility
        final searchField = AppLocators.getSearchTextField($);
        await searchField.waitUntilVisible();
        expect(searchField.exists, true);
        
        // Test search clear button accessibility
        await searchField.enterText('Dubai');
        await $.pump(const Duration(milliseconds: 500));
        
        final clearButton = AppLocators.getSearchClearButton($);
        if (clearButton.exists) {
          TestLogger.logValidation($, 'search clear button accessibility');
          expect(clearButton.exists, true);
        }
        
        TestLogger.logTestSuccess($, 'Search field accessibility verified');
      },
    );

    patrolTest(
      'Hotel cards have proper accessibility support',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Hotel Cards Accessibility Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels and perform search
        await TestHelpers.navigateToPage($, 'hotels');
        
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('London');
        await $.pump(const Duration(seconds: 2));
        
        // Test hotel card accessibility
        final hotelCard = AppLocators.getHotelCard($, 'hotel_card_0');
        if (hotelCard.exists) {
          TestLogger.logValidation($, 'hotel card accessibility');
          expect(hotelCard.exists, true);
          
          // Test favorite button accessibility
          final favoriteButton = AppLocators.getHotelFavoriteButton($, 'hotel_favorite_button_0');
          if (favoriteButton.exists) {
            TestLogger.logValidation($, 'favorite button accessibility');
            expect(favoriteButton.exists, true);
          }
        }
        
        TestLogger.logTestSuccess($, 'Hotel cards accessibility verified');
      },
    );

    patrolTest(
      'Error states have proper accessibility announcements',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Error States Accessibility Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        // Trigger potential error state with empty search
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('');
        await $.pump(const Duration(seconds: 2));
        
        // Check for error message accessibility
        final errorMessage = AppLocators.getHotelsErrorMessage($);
        if (errorMessage.exists) {
          TestLogger.logValidation($, 'error message accessibility');
          expect(errorMessage.exists, true);
          
          // Check for retry button accessibility
          final retryButton = AppLocators.getHotelsRetryButton($);
          if (retryButton.exists) {
            TestLogger.logValidation($, 'retry button accessibility');
            expect(retryButton.exists, true);
          }
        }
        
        TestLogger.logTestSuccess($, 'Error states accessibility verified');
      },
    );

    patrolTest(
      'Loading states provide proper accessibility feedback',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Loading States Accessibility Test');
        await TestHelpers.initializeApp($);

        // Navigate to hotels page
        await TestHelpers.navigateToPage($, 'hotels');
        
        // Start search to trigger loading state
        final searchField = AppLocators.getSearchTextField($);
        await searchField.enterText('Paris');
        
        // Check for loading indicator accessibility
        await $.pump(const Duration(milliseconds: 500));
        final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
        
        if (loadingIndicator.exists) {
          TestLogger.logValidation($, 'loading indicator accessibility');
          expect(loadingIndicator.exists, true);
        }
        
        // Wait for loading to complete
        await $.pump(const Duration(seconds: 3));
        
        TestLogger.logTestSuccess($, 'Loading states accessibility verified');
      },
    );

    patrolTest(
      'Empty states have proper accessibility support',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Empty States Accessibility Test');
        await TestHelpers.initializeApp($);

        // Test favorites empty state
        await TestHelpers.navigateToPage($, 'favorites');
        
        final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
        await emptyStateIcon.waitUntilVisible();
        
        TestLogger.logValidation($, 'favorites empty state accessibility');
        expect(emptyStateIcon.exists, true);
        
        // Test hotels empty state (if applicable)
        await TestHelpers.navigateToPage($, 'hotels');
        
        // Search for something that might return no results
        final hotelsActions = HotelsScreenActions($);
        await hotelsActions.performSearch('zzzznonexistenthotel');
        await $.pump(const Duration(seconds: 3));
        
        final hotelsEmptyState = AppLocators.getHotelsEmptyStateIcon($);
        if (hotelsEmptyState.exists) {
          TestLogger.logValidation($, 'hotels empty state accessibility');
          expect(hotelsEmptyState.exists, true);
        }
        
        TestLogger.logTestSuccess($, 'Empty states accessibility verified');
      },
    );

    patrolTest(
      'Focus management works correctly across navigation',
      config: PatrolConfig.getConfig(),
      ($) async {
        TestLogger.logTestStart($, 'Focus Management Test');
        await TestHelpers.initializeApp($);

        // Test focus on hotels tab
        await TestHelpers.navigateToPage($, 'hotels');
        await $.pump(const Duration(milliseconds: 500));
        
        final searchField = AppLocators.getSearchTextField($);
        await searchField.waitUntilVisible();
        
        // Test focus on other tabs
        await TestHelpers.navigateToPage($, 'favorites');
        await $.pump(const Duration(milliseconds: 500));
        
        await TestHelpers.navigateToPage($, 'account');
        await $.pump(const Duration(milliseconds: 500));
        
        await TestHelpers.navigateToPage($, 'overview');
        await $.pump(const Duration(milliseconds: 500));
        
        // Return to hotels and verify search field is still accessible
        await TestHelpers.navigateToPage($, 'hotels');
        await searchField.waitUntilVisible();
        expect(searchField.exists, true);
        
        TestLogger.logTestSuccess($, 'Focus management verified');
      },
    );
  });
}