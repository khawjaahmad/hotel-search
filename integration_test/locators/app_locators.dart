import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



class AppLocators {
  AppLocators._();

  // =============================================================================
  // DASHBOARD & NAVIGATION LOCATORS
  // =============================================================================

  static const String dashboardScaffold = 'dashboard_scaffold';
  static const String navigationBar = 'navigation_bar';

  static const String overviewTab = 'navigation_overview_tab';
  static const String hotelsTab = 'navigation_hotels_tab';
  static const String favoritesTab = 'navigation_favorites_tab';
  static const String accountTab = 'navigation_account_tab';

  // =============================================================================
  // OVERVIEW PAGE LOCATORS
  // =============================================================================

  static const String overviewScaffold = 'overview_scaffold';
  static const String overviewAppBar = 'overview_app_bar';
  static const String overviewTitle = 'overview_title';
  static const String overviewIcon = 'overview_icon';

  // =============================================================================
  // HOTELS PAGE LOCATORS (Updated to match actual app keys)
  // =============================================================================

  static const String hotelsScaffold = 'hotels_scaffold'; 
  static const String hotelsAppBar = 'hotels_app_bar'; 

  static const String hotelsSearchField =
      'hotels_search_field'; 
  static const String searchTextField =
      'search_text_field'; 
  static const String searchPrefixIcon =
      'search_prefix_icon'; 
  static const String searchClearButton =
      'search_clear_button';

  static const String hotelsScrollView = 'hotels_scroll_view'; 
  static const String hotelsList = 'hotels_list'; 

  static const String hotelsLoadingIndicator =
      'hotels_loading_indicator'; 
  static const String hotelsEmptyStateIcon =
      'hotels_empty_state_icon';
  static const String hotelsErrorColumn =
      'hotels_error_column'; 
  static const String hotelsErrorMessage =
      'hotels_error_message'; 
  static const String hotelsRetryButton =
      'hotels_retry_button'; 

  static const String hotelsPaginationLoading =
      'hotels_pagination_loading'; 
  static const String hotelsPaginationErrorColumn =
      'hotels_pagination_error_column'; 
  static const String hotelsPaginationErrorMessage =
      'hotels_pagination_error_message'; 
  static const String hotelsPaginationRetryButton =
      'hotels_pagination_retry_button'; 

  // =============================================================================
  // HOTEL CARD LOCATORS (Dynamic - matches app pattern)
  // =============================================================================

  static String hotelCard(String hotelId) => 'hotel_card_$hotelId';

  static String hotelName(String hotelId) => 'hotel_name_$hotelId';

  static String hotelDescription(String hotelId) =>
      'hotel_description_$hotelId';

  static String hotelFavoriteButton(String hotelId) =>
      'hotel_favorite_button_$hotelId';

  // =============================================================================
  // FAVORITES PAGE LOCATORS
  // =============================================================================

  static const String favoritesScaffold = 'favorites_scaffold';
  static const String favoritesAppBar = 'favorites_app_bar';
  static const String favoritesTitle = 'favorites_title';
  static const String favoritesListView = 'favorites_list_view';
  static const String favoritesEmptyStateIcon = 'favorites_empty_state_icon';

  static String favoritesHotelCard(String hotelId) =>
      'favorites_hotel_card_$hotelId';

  // =============================================================================
  // ACCOUNT PAGE LOCATORS
  // =============================================================================

  static const String accountScaffold = 'account_scaffold';
  static const String accountAppBar = 'account_app_bar';
  static const String accountTitle = 'account_title';
  static const String accountIcon = 'account_icon';

  // =============================================================================
  // COMMON LOCATORS
  // =============================================================================

  static const String loadingIndicator = 'loading_indicator';
  static const String errorMessage = 'error_message';
  static const String retryButton = 'retry_button';

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  static Key key(String locator) => Key(locator);

  static Key constKey(String locator) => Key(locator);

  static bool isValidLocator(String locator) {
    return locator.isNotEmpty;
  }

  // =============================================================================
  // WIDGET TYPE FINDERS (For elements without specific keys)
  // =============================================================================

  static Finder get textFieldFinder => find.byType(TextField);
  static Finder get searchIconFinder => find.byIcon(Icons.search);
  static Finder get cancelIconFinder => find.byIcon(Icons.cancel_outlined);
  static Finder get favoriteOutlineIconFinder =>
      find.byIcon(Icons.favorite_outline);
  static Finder get favoriteFilledIconFinder => find.byIcon(Icons.favorite);
  static Finder get hotelOutlineIconFinder => find.byIcon(Icons.hotel_outlined);
  static Finder get accountCircleOutlineIconFinder =>
      find.byIcon(Icons.account_circle_outlined);
  static Finder get exploreOutlineIconFinder =>
      find.byIcon(Icons.explore_outlined);

  // =============================================================================
  // APP-SPECIFIC LOCATOR GROUPS
  // =============================================================================

  static List<String> get dashboardLocators => [
        dashboardScaffold,
        navigationBar,
        overviewTab,
        hotelsTab,
        favoritesTab,
        accountTab,
      ];

  static List<String> get overviewLocators => [
        overviewScaffold,
        overviewAppBar,
        overviewTitle,
        overviewIcon,
      ];

  static List<String> get hotelsLocators => [
        hotelsScaffold, 
        hotelsAppBar, 
        hotelsSearchField, 
        hotelsScrollView, 
        hotelsList, 
        hotelsLoadingIndicator, 
        hotelsEmptyStateIcon, 
        hotelsErrorColumn, 
        hotelsErrorMessage, 
        hotelsRetryButton, 
        hotelsPaginationLoading, 
        hotelsPaginationErrorColumn, 
        hotelsPaginationErrorMessage, 
        hotelsPaginationRetryButton, 
      ];

  static List<String> get favoritesLocators => [
        favoritesScaffold,
        favoritesAppBar,
        favoritesTitle,
        favoritesListView,
        favoritesEmptyStateIcon,
      ];

  static List<String> get accountLocators => [
        accountScaffold,
        accountAppBar,
        accountTitle,
        accountIcon,
      ];

  static List<String> get commonLocators => [
        loadingIndicator,
        errorMessage,
        retryButton,
      ];

  static List<String> get allStaticLocators => [
        ...dashboardLocators,
        ...overviewLocators,
        ...hotelsLocators,
        ...favoritesLocators,
        ...accountLocators,
        ...commonLocators,
      ];

  // =============================================================================
  // SEARCH ERROR HANDLER SUPPORT
  // =============================================================================

  static Map<String, dynamic> get searchErrorLocators => {
        'loading_indicator': hotelsLoadingIndicator,
        'empty_state': hotelsEmptyStateIcon,
        'error_message': hotelsErrorMessage,
        'retry_button': hotelsRetryButton,
        'pagination_loading': hotelsPaginationLoading,
        'pagination_error': hotelsPaginationErrorMessage,
      };
}
