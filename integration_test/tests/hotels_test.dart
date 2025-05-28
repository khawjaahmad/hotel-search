import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../screens/hotels_screen_actions.dart';
import '../strings/test_strings.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    HotelsTestStrings.navigationTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await HotelsScreenActions.navigateToHotelsPage($);
    },
  );

  patrolTest(
    HotelsTestStrings.searchTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log(HotelsTestStrings.testingSearch);
      await HotelsScreenActions.performSearchTest($, 'Dubai');
    },
  );

  patrolTest(
    HotelsTestStrings.scrollingTest,
    config: PatrolConfig.getConfig(),
    tags: ['demo'],
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log(HotelsTestStrings.testingSearch);
      await HotelsScreenActions.performSearchTest($, 'London');

      $.log(HotelsTestStrings.testingScrolling);
      await HotelsScreenActions.testScrollingAndPagination($);
    },
  );

  patrolTest(
    HotelsTestStrings.hotelCardsTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log(HotelsTestStrings.testingSearch);
      await HotelsScreenActions.performSearchTest($, 'Paris');

      $.log(HotelsTestStrings.validatingCards);
      await HotelsScreenActions.validateHotelCards($);
    },
  );

  patrolTest(
    HotelsTestStrings.favoritesTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log('Clearing existing favorites');
      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.clearExistingFavorites($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log(HotelsTestStrings.testingSearch);
      await HotelsScreenActions.performSearchTest($, 'Tokyo');

      $.log(HotelsTestStrings.favoritingHotels);
      await HotelsScreenActions.favoriteRandomHotels($);

      $.log(HotelsTestStrings.validatingFavorites);
      await HotelsScreenActions.validateFavoritesPage($);
    },
  );

  patrolTest(
    HotelsTestStrings.removeFavoritesTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log('Adding hotels to favorites for removal test');
      await HotelsScreenActions.performSearchTest($, 'New York');
      await HotelsScreenActions.favoriteRandomHotels($);

      $.log(HotelsTestStrings.navigatingToFavorites);
      await TestHelpers.navigateToPage($, 'favorites');

      $.log(HotelsTestStrings.removingFavorites);
      await HotelsScreenActions.removeFavoriteHotels($);
    },
  );

  patrolTest(
    HotelsTestStrings.negativeSearchTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log(HotelsTestStrings.testingNegativeScenarios);
      await HotelsScreenActions.testNegativeSearchScenarios($);
    },
  );

  patrolTest(
    HotelsTestStrings.errorHandlingTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log('Testing empty search input');
      await HotelsScreenActions.testEmptySearchInput($);

      $.log('Testing special characters in search - FIXED VERSION');
      await HotelsScreenActions.testSpecialCharacterSearch($);

      $.log('Testing very long search query');
      await HotelsScreenActions.testLongSearchQuery($);
    },
  );

  patrolTest(
    HotelsTestStrings.crossPageNavigationTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log('Testing cross-page navigation with favorites');
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      await HotelsScreenActions.performSearchTest($, 'Berlin');
      await HotelsScreenActions.favoriteRandomHotels($);

      $.log('Testing navigation flow: Hotels -> Favorites -> Hotels');
      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.validateFavoritesPage($);

      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);
      await HotelsScreenActions.verifyHotelsPageStructure($);

      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.validateFavoritesPage($);

      await HotelsScreenActions.removeFavoriteHotels($);
    },
  );

  patrolTest(
    HotelsTestStrings.searchPersistenceTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log(HotelsTestStrings.navigatingToHotels);
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      const searchQuery = 'Barcelona';
      $.log('Testing search persistence with query: $searchQuery');
      await HotelsScreenActions.performSearchTest($, searchQuery);

      $.log('Navigating away to test search persistence');
      await TestHelpers.navigateToPage($, 'account');

      $.log('Navigating back to Hotels');
      await TestHelpers.navigateToPage($, HotelsTestStrings.hotelsTabName);

      $.log('Verifying search state after navigation');
      await HotelsScreenActions.verifySearchStateAfterNavigation($);
    },
  );

  patrolTest(
    HotelsTestStrings.comprehensiveTest,
    config: PatrolConfig.getConfig(),
    ($) async {
      $.log(HotelsTestStrings.initializingTest);
      await TestHelpers.initializeApp($);

      $.log('Running comprehensive Hotels feature test');
      await HotelsScreenActions.runCompleteHotelsTest($);
    },
  );
}
