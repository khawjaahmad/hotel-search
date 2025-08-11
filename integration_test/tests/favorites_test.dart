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

  patrolTest(
    'Empty favorites state displays correctly',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Empty Favorites State Test');
      await TestHelpers.initializeApp($);

      // Navigate to favorites page
      TestLogger.logNavigation($, 'favorites page');
      await TestHelpers.navigateToPage($, 'favorites');

      // Verify empty state
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      await emptyStateIcon.waitUntilVisible();
      
      TestLogger.logValidation($, 'empty state icon visibility');
      expect(emptyStateIcon.exists, true);
      
      TestLogger.logTestSuccess($, 'Empty favorites state verified');
    },
  );

  patrolTest(
    'Add and remove favorites workflow',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Favorites Workflow Test');
      await TestHelpers.initializeApp($);

      // Navigate to hotels and search
      TestLogger.logNavigation($, 'hotels page');
      await TestHelpers.navigateToPage($, 'hotels');
      
      final hotelsActions = HotelsScreenActions($);
      await hotelsActions.performSearch('Dubai');
      await $.pump(const Duration(seconds: 2));

      // Add first hotel to favorites
      TestLogger.logAction($, 'Adding hotel to favorites');
      await hotelsActions.toggleFavorite(0, expectAdded: true);
      
      // Navigate to favorites and verify
      TestLogger.logNavigation($, 'favorites page');
      await TestHelpers.navigateToPage($, 'favorites');
      await $.pump(const Duration(seconds: 1));
      
      // Verify favorites page is not empty
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      expect(emptyStateIcon.exists, false);
      
      TestLogger.logTestSuccess($, 'Favorites workflow completed');
    },
  );

  patrolTest(
    'Multiple favorites management',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Multiple Favorites Test');
      await TestHelpers.initializeApp($);

      // Navigate to hotels and search
      await TestHelpers.navigateToPage($, 'hotels');
      
      final hotelsActions = HotelsScreenActions($);
      await hotelsActions.performSearch('London');
      await $.pump(const Duration(seconds: 2));

      // Add multiple hotels to favorites
      TestLogger.logAction($, 'Adding multiple hotels to favorites');
      for (int i = 0; i < 3; i++) {
        await hotelsActions.toggleFavorite(i, expectAdded: true);
        await $.pump(const Duration(milliseconds: 500));
      }
      
      // Navigate to favorites and verify
      await TestHelpers.navigateToPage($, 'favorites');
      await $.pump(const Duration(seconds: 1));
      
      // Verify favorites page is not empty
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      expect(emptyStateIcon.exists, false);
      
      TestLogger.logTestSuccess($, 'Multiple favorites management verified');
    },
  );

  patrolTest(
    'Favorites navigation and interaction',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Favorites Navigation Test');
      await TestHelpers.initializeApp($);

      // Setup favorites
      await TestHelpers.navigateToPage($, 'hotels');
      final hotelsActions = HotelsScreenActions($);
      await hotelsActions.performSearch('Tokyo');
      await $.pump(const Duration(seconds: 2));
      await hotelsActions.toggleFavorite(0, expectAdded: true);
      
      // Navigate to favorites
      await TestHelpers.navigateToPage($, 'favorites');
      await $.pump(const Duration(seconds: 1));
      
      // Verify favorites page is not empty
      final emptyStateIcon = AppLocators.getFavoritesEmptyStateIcon($);
      expect(emptyStateIcon.exists, false);
      
      // Test navigation between tabs
      await TestHelpers.navigateToPage($, 'hotels');
      await $.pump(const Duration(milliseconds: 500));
      
      await TestHelpers.navigateToPage($, 'favorites');
      await $.pump(const Duration(milliseconds: 500));
      
      TestLogger.logTestSuccess($, 'Favorites navigation verified');
    },
  );
}