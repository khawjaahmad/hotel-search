class DashboardTestStrings {
  static const String loadTest = 'Dashboard Load Test';
  static const String navigationTest = 'Dashboard Navigation Test';
  static const String initializingTest = 'Initializing dashboard test';
  static const String verifyingStructure = 'Verifying dashboard structure';
  static const String navigationStarted = 'Testing navigation between tabs';
  static const String dashboardTabName = 'overview';
}

class TestStrings {
  // Search related strings
  static const String searchQuery = 'Dubai';
  static const String emptySearchQuery = '   ';

  // Error messages
  static const String errorMessage = 'Something went wrong';
  static const String retryButtonText = 'Try again';

  // Test descriptions and logs
  static const String initializingTest = 'Initializing test';
  static const String navigatingToHotels = 'Navigating to Hotels page';
  static const String performingSearch = 'Performing search with query';
  static const String verifyingResults = 'Verifying search results';
  static const String testingPagination = 'Testing pagination behavior';
  static const String testingFavorites = 'Testing favorites functionality';
  static const String verifyingErrorState = 'Verifying error state';

  // Validation messages
  static const String searchFieldEmpty = 'Search field should be empty';
  static const String searchResultsFound = 'Search results should be displayed';
  static const String loadingIndicatorVisible =
      'Loading indicator should be visible';
  static const String errorStateVisible = 'Error state should be visible';
  static const String hotelRemovedFromFavorites =
      'Hotel should be removed from favorites';
}

class AccountTestStrings {
  static const String accountTitle = 'Your Account';

  // Navigation
  static const String accountTabName = 'account';

  // Test descriptions
  static const String loadTest = 'Account page loads with correct structure';
  static const String navigationTest = 'Account page persists after navigation';
  static const String themeTest = 'Account page theme matches system theme';
  static const String tabTest = 'Account navigation tab is working';

  // Assertion messages
  static const String scaffoldVisible = 'Account scaffold should be visible';
  static const String appBarVisible = 'Account app bar should be visible';
  static const String titleCorrect =
      'Account title should display correct text';
  static const String iconVisible = 'Account icon should be visible';
  static const String scaffoldAfterNav =
      'Account scaffold should be visible after navigation';
  static const String iconThemeColor =
      'Account icon should have a theme-based color';
  static const String tabNavigation =
      'Should navigate to account page when tab is tapped';

  static const String initializingTest = 'Initializing account page test';
  static const String verifyingStructure = 'Verifying account page structure';
  static const String verifyingScaffold = 'Verifying account scaffold';
  static const String verifyingAppBar = 'Verifying account app bar';
  static const String verifyingTitle = 'Verifying account title';
  static const String verifyingIcon = 'Verifying account icon';
  static const String verifyingTheme = 'Verifying account theme integration';
  static const String navigationAway = 'Navigating away from account page';
  static const String navigationBack = 'Navigating back to account page';
}

class HotelsTestStrings {
  // Test Names
  static const String navigationTest = 'Hotels page navigation test';
  static const String searchTest = 'Hotels search functionality test';
  static const String scrollingTest = 'Hotels scrolling and pagination test';
  static const String hotelCardsTest = 'Hotel cards validation test';
  static const String favoritesTest = 'Hotels favorites functionality test';
  static const String removeFavoritesTest =
      'Remove favorites functionality test';
  static const String negativeSearchTest = 'Negative search scenarios test';
  static const String errorHandlingTest = 'Error handling test';
  static const String crossPageNavigationTest = 'Cross-page navigation test';
  static const String searchPersistenceTest = 'Search persistence test';
  static const String comprehensiveTest = 'Comprehensive Hotels feature test';

  // Common Test Messages
  static const String initializingTest = 'Initializing Hotels test';
  static const String hotelsTabName = 'hotels';

  // Navigation
  static const String navigatingToHotels = 'Navigating to Hotels page';
  static const String verifyingStructure = 'Verifying Hotels page structure';

  // Search
  static const String testingSearch = 'Testing search functionality';
  static const String searchResultsFound = 'Search results found';
  static const String searchTimeout = 'Search timed out';
  static const String waitingForResults = 'Waiting for search results';

  // Scrolling & Pagination
  static const String testingScrolling = 'Testing scrolling and pagination';
  static const String paginationTriggered = 'Pagination loading triggered';
  static const String newCardsLoaded = 'New hotel cards loaded';

  // Hotel Cards
  static const String validatingCards = 'Validating hotel cards';
  static const String favoritingHotels = 'Favoriting selected hotels';
  static const String hotelCardValid = 'Hotel card structure valid';

  // Favorites
  static const String navigatingToFavorites = 'Navigating to Favorites page';
  static const String validatingFavorites = 'Validating favorited hotels';
  static const String removingFavorites = 'Removing favorited hotels';
  static const String favoritesEmpty = 'Favorites list is empty';

  // Error States
  static const String testingNegativeScenarios =
      'Testing negative search scenarios';
  static const String errorStateVerified = 'Error state verified';
  static const String retryFunctional = 'Retry functionality working';
  static const String errorMessage = 'Something went wrong';
  static const String retryButton = 'Try Again';

  // Test Completion
  static const String testSuiteComplete = 'Hotels test suite completed';
  static const String testSuiteFailed = 'Hotels test suite failed';

  // UI Elements
  static const String hotelsPageTitle = 'Hotels';
  static const String searchPlaceholder = 'Search Hotels';
  static const String favoritesPageTitle = 'Your Favorite Hotels';
}
