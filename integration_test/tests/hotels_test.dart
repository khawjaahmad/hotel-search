import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/hotels_screen_actions.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    'Hotels page navigation test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Hotels Navigation Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await HotelsScreenActions.navigateToHotelsPage($);

      TestLogger.logTestSuccess($, 'Hotels navigation completed');
    },
  );

  patrolTest(
    'Hotels search functionality test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Hotels Search Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logAction($, 'Testing search functionality');
      await HotelsScreenActions.performSearchTest($, 'Dubai');

      TestLogger.logTestSuccess($, 'Search functionality verified');
    },
  );

  patrolTest(
    'Hotels scrolling and pagination test',
    config: PatrolConfig.getConfig(),
    tags: ['demo'],
    ($) async {
      TestLogger.logTestStart($, 'Hotels Scrolling & Pagination Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logAction($, 'Performing search with London');
      await HotelsScreenActions.performSearchTest($, 'London');

      TestLogger.logAction($, 'Testing scrolling and pagination');
      await HotelsScreenActions.testScrollingAndPagination($);

      TestLogger.logTestSuccess($, 'Scrolling and pagination verified');
    },
  );

  patrolTest(
    'Hotel cards validation test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Hotel Cards Validation Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logAction($, 'Searching for Paris hotels');
      await HotelsScreenActions.performSearchTest($, 'Paris');

      TestLogger.logValidation($, 'hotel cards structure');
      await HotelsScreenActions.validateHotelCards($);

      TestLogger.logTestSuccess($, 'Hotel cards validation completed');
    },
  );

  patrolTest(
    'Hotels favorites functionality test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Hotels Favorites Test');
      await TestHelpers.initializeApp($);

      TestLogger.logTestStep($, 'Clearing existing favorites');
      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.clearExistingFavorites($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logAction($, 'Searching for Tokyo hotels');
      await HotelsScreenActions.performSearchTest($, 'Tokyo');

      TestLogger.logAction($, 'Adding hotels to favorites');
      await HotelsScreenActions.favoriteRandomHotels($);

      TestLogger.logValidation($, 'favorites page');
      await HotelsScreenActions.validateFavoritesPage($);

      TestLogger.logTestSuccess($, 'Favorites functionality verified');
    },
  );

  patrolTest(
    'Remove favorites functionality test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Remove Favorites Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logTestStep($, 'Adding hotels to favorites for removal test');
      await HotelsScreenActions.performSearchTest($, 'New York');
      await HotelsScreenActions.favoriteRandomHotels($);

      TestLogger.logNavigation($, 'Favorites page');
      await TestHelpers.navigateToPage($, 'favorites');

      TestLogger.logAction($, 'Removing favorited hotels');
      await HotelsScreenActions.removeFavoriteHotels($);

      TestLogger.logTestSuccess($, 'Remove favorites functionality verified');
    },
  );

  patrolTest(
    'Negative search scenarios test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Negative Search Scenarios Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logAction($, 'Testing negative search scenarios');
      await HotelsScreenActions.testNegativeSearchScenarios($);

      TestLogger.logTestSuccess($, 'Negative search scenarios verified');
    },
  );

  patrolTest(
    'Error handling test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Error Handling Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logAction($, 'Testing empty search input');
      await HotelsScreenActions.testEmptySearchInput($);

      TestLogger.logAction($, 'Testing special characters in search');
      await HotelsScreenActions.testSpecialCharacterSearch($);

      TestLogger.logAction($, 'Testing very long search query');
      await HotelsScreenActions.testLongSearchQuery($);

      TestLogger.logTestSuccess($, 'Error handling verified');
    },
  );

  patrolTest(
    'Cross-page navigation test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Cross-page Navigation Test');
      await TestHelpers.initializeApp($);

      TestLogger.logTestStep($, 'Testing cross-page navigation with favorites');
      await TestHelpers.navigateToPage($, 'hotels');

      await HotelsScreenActions.performSearchTest($, 'Berlin');
      await HotelsScreenActions.favoriteRandomHotels($);

      TestLogger.logTestStep(
          $, 'Testing navigation flow: Hotels -> Favorites -> Hotels');
      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.validateFavoritesPage($);

      await TestHelpers.navigateToPage($, 'hotels');
      await HotelsScreenActions.verifyHotelsPageStructure($);

      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.validateFavoritesPage($);

      await HotelsScreenActions.removeFavoriteHotels($);

      TestLogger.logTestSuccess($, 'Cross-page navigation verified');
    },
  );

  patrolTest(
    'Search persistence test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Search Persistence Test');
      await TestHelpers.initializeApp($);

      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');

      const searchQuery = 'Barcelona';
      TestLogger.logAction(
          $, 'Testing search persistence with query: $searchQuery');
      await HotelsScreenActions.performSearchTest($, searchQuery);

      TestLogger.logTestStep($, 'Navigating away to test search persistence');
      await TestHelpers.navigateToPage($, 'account');

      TestLogger.logNavigation($, 'back to Hotels');
      await TestHelpers.navigateToPage($, 'hotels');

      TestLogger.logValidation($, 'search state after navigation');
      await HotelsScreenActions.verifySearchStateAfterNavigation($);

      TestLogger.logTestSuccess($, 'Search persistence verified');
    },
  );

  patrolTest(
    'Comprehensive Hotels feature test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Comprehensive Hotels Feature Test');
      await TestHelpers.initializeApp($);

      TestLogger.logTestStep($, 'Running comprehensive Hotels feature test');
      await HotelsScreenActions.runCompleteHotelsTest($);

      TestLogger.logTestSuccess($, 'Comprehensive test suite completed');
    },
  );
}
