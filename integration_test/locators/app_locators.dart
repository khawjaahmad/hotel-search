import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

class AppLocators {
  AppLocators._();

  static PatrolFinder getDashboardScaffold(PatrolIntegrationTester $) {
    return $(#dashboard_scaffold);
  }

  static PatrolFinder getNavigationBar(PatrolIntegrationTester $) {
    return $(#navigation_bar);
  }

  static PatrolFinder getOverviewTab(PatrolIntegrationTester $) {
    return $(#navigation_overview_tab);
  }

  static PatrolFinder getHotelsTab(PatrolIntegrationTester $) {
    return $(#navigation_hotels_tab);
  }

  static PatrolFinder getFavoritesTab(PatrolIntegrationTester $) {
    return $(#navigation_favorites_tab);
  }

  static PatrolFinder getAccountTab(PatrolIntegrationTester $) {
    return $(#navigation_account_tab);
  }

  static PatrolFinder getOverviewScaffold(PatrolIntegrationTester $) {
    return $(#overview_scaffold);
  }

  static PatrolFinder getOverviewAppBar(PatrolIntegrationTester $) {
    return $(#overview_app_bar);
  }

  static PatrolFinder getOverviewTitle(PatrolIntegrationTester $) {
    return $(#overview_title);
  }

  static PatrolFinder getOverviewIcon(PatrolIntegrationTester $) {
    return $(#overview_icon);
  }

  static PatrolFinder getHotelsScaffold(PatrolIntegrationTester $) {
    return $(#hotels_scaffold);
  }

  static PatrolFinder getHotelsAppBar(PatrolIntegrationTester $) {
    return $(#hotels_app_bar);
  }

  static PatrolFinder getHotelsSearchField(PatrolIntegrationTester $) {
    return $(#hotels_search_field);
  }

  static PatrolFinder getSearchTextField(PatrolIntegrationTester $) {
    return $(#search_text_field);
  }

  static PatrolFinder getSearchPrefixIcon(PatrolIntegrationTester $) {
    return $(#search_prefix_icon);
  }

  static PatrolFinder getSearchClearButton(PatrolIntegrationTester $) {
    return $(#search_clear_button);
  }

  static PatrolFinder getSearchSuffixIcon(PatrolIntegrationTester $) {
    return $(#search_suffix_icon);
  }

  static PatrolFinder getHotelsScrollView(PatrolIntegrationTester $) {
    return $(#hotels_scroll_view);
  }

  static PatrolFinder getHotelsList(PatrolIntegrationTester $) {
    return $(#hotels_list);
  }

  static PatrolFinder getHotelsLoadingIndicator(PatrolIntegrationTester $) {
    return $(#hotels_loading_indicator);
  }

  static PatrolFinder getHotelsEmptyStateIcon(PatrolIntegrationTester $) {
    return $(#hotels_empty_state_icon);
  }

  static PatrolFinder getHotelsErrorColumn(PatrolIntegrationTester $) {
    return $(#hotels_error_column);
  }

  static PatrolFinder getHotelsErrorMessage(PatrolIntegrationTester $) {
    return $(#hotels_error_message);
  }

  static PatrolFinder getHotelsRetryButton(PatrolIntegrationTester $) {
    return $(#hotels_retry_button);
  }

  static PatrolFinder getHotelsPaginationLoading(PatrolIntegrationTester $) {
    return $(#hotels_pagination_loading);
  }

  static PatrolFinder getHotelsPaginationErrorColumn(
      PatrolIntegrationTester $) {
    return $(#hotels_pagination_error_column);
  }

  static PatrolFinder getHotelsPaginationErrorMessage(
      PatrolIntegrationTester $) {
    return $(#hotels_pagination_error_message);
  }

  static PatrolFinder getHotelsPaginationRetryButton(
      PatrolIntegrationTester $) {
    return $(#hotels_pagination_retry_button);
  }

  static PatrolFinder getFavoritesScaffold(PatrolIntegrationTester $) {
    return $(#favorites_scaffold);
  }

  static PatrolFinder getFavoritesAppBar(PatrolIntegrationTester $) {
    return $(#favorites_app_bar);
  }

  static PatrolFinder getFavoritesTitle(PatrolIntegrationTester $) {
    return $(#favorites_title);
  }

  static PatrolFinder getFavoritesListView(PatrolIntegrationTester $) {
    return $(#favorites_list_view);
  }

  static PatrolFinder getFavoritesEmptyStateIcon(PatrolIntegrationTester $) {
    return $(#favorites_empty_state_icon);
  }

  static PatrolFinder getAccountScaffold(PatrolIntegrationTester $) {
    return $(#account_scaffold);
  }

  static PatrolFinder getAccountAppBar(PatrolIntegrationTester $) {
    return $(#account_app_bar);
  }

  static PatrolFinder getAccountTitle(PatrolIntegrationTester $) {
    return $(#account_title);
  }

  static PatrolFinder getAccountIcon(PatrolIntegrationTester $) {
    return $(#account_icon);
  }

  static PatrolFinder getHotelCard(PatrolIntegrationTester $, String hotelId) {
    return $(#hotel_card_$hotelId);
  }

  static PatrolFinder getHotelName(PatrolIntegrationTester $, String hotelId) {
    return $(#hotel_name_$hotelId);
  }

  static PatrolFinder getHotelDescription(
      PatrolIntegrationTester $, String hotelId) {
    return $(#hotel_description_$hotelId);
  }

  static PatrolFinder getHotelFavoriteButton(
      PatrolIntegrationTester $, String hotelId) {
    return $(#hotel_favorite_button_$hotelId);
  }

  static PatrolFinder getFavoritesHotelCard(
      PatrolIntegrationTester $, String hotelId) {
    return $(#favorites_hotel_card_$hotelId);
  }

  static PatrolFinder getNavigationTab(
      PatrolIntegrationTester $, String tabName) {
    switch (tabName.toLowerCase()) {
      case 'overview':
        return getOverviewTab($);
      case 'hotels':
        return getHotelsTab($);
      case 'favorites':
        return getFavoritesTab($);
      case 'account':
        return getAccountTab($);
      default:
        throw ArgumentError('Unknown navigation tab: $tabName');
    }
  }

  static PatrolFinder getSearchField(PatrolIntegrationTester $) {
    return getSearchTextField($);
  }

  static PatrolFinder getLoadingIndicator(PatrolIntegrationTester $) {
    return getHotelsLoadingIndicator($);
  }

  static PatrolFinder getErrorMessage(PatrolIntegrationTester $) {
    return getHotelsErrorMessage($);
  }

  static PatrolFinder getRetryButton(PatrolIntegrationTester $) {
    return getHotelsRetryButton($);
  }

  static PatrolFinder getFavoritesEmptyState(PatrolIntegrationTester $) {
    return getFavoritesEmptyStateIcon($);
  }

  static PatrolFinder getPageTitle(PatrolIntegrationTester $, String pageName) {
    switch (pageName.toLowerCase()) {
      case 'overview':
        return getOverviewTitle($);
      case 'favorites':
        return getFavoritesTitle($);
      case 'account':
        return getAccountTitle($);
      default:
        // ignore: unnecessary_string_interpolations
        return $('$pageName');
    }
  }

  static PatrolFinder getPageScaffold(
      PatrolIntegrationTester $, String pageKey) {
    return $(pageKey);
  }

  static Future<void> smartTap(
    PatrolIntegrationTester $,
    PatrolFinder finder, {
    String? description,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await finder.waitUntilVisible();
        await finder.tap();
        return;
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await $.pump(const Duration(seconds: 1));
      }
    }
  }

  static Future<void> smartEnterText(
    PatrolIntegrationTester $,
    PatrolFinder finder,
    String text, {
    bool clearFirst = true,
    String? description,
  }) async {
    await finder.waitUntilVisible();

    if (clearFirst) {
      await finder.tap();
      await $.pump(const Duration(milliseconds: 300));
      await $(TextField).enterText('');
    }

    await finder.enterText(text);
  }

  static Future<void> smartScrollTo(
    PatrolIntegrationTester $,
    PatrolFinder targetFinder, {
    PatrolFinder? view,
    String? description,
  }) async {
    if (view != null) {
      await targetFinder.scrollTo(view: view);
    } else {
      await targetFinder.scrollTo();
    }
  }

  static Future<void> smartWaitFor(
    PatrolIntegrationTester $,
    PatrolFinder finder, {
    String? description,
  }) async {
    await finder.waitUntilVisible();
  }

  static Future<void> validateNavigation(PatrolIntegrationTester $) async {
    await smartWaitFor($, getNavigationBar($));

    final tabs = ['overview', 'hotels', 'favorites', 'account'];
    for (final tab in tabs) {
      final tabFinder = getNavigationTab($, tab);
      await smartWaitFor($, tabFinder);
    }
  }

  static Future<void> validatePageStructure(
    PatrolIntegrationTester $,
    String pageKey, {
    List<PatrolFinder>? requiredElements,
    String? pageName,
  }) async {
    await smartWaitFor($, getPageScaffold($, pageKey));

    if (requiredElements != null) {
      for (final element in requiredElements) {
        await smartWaitFor($, element);
      }
    }
  }

  static Future<void> validateSearchFunctionality(
      PatrolIntegrationTester $) async {
    final searchField = getSearchField($);
    await smartWaitFor($, searchField);
    await smartWaitFor($, getSearchPrefixIcon($));
    await smartWaitFor($, getSearchClearButton($));
  }

  static Future<void> validateHotelCard(
    PatrolIntegrationTester $,
    String hotelId, {
    bool shouldHaveFavoriteButton = true,
  }) async {
    final cardFinder = getHotelCard($, hotelId);
    await smartWaitFor($, cardFinder);
    await smartWaitFor($, getHotelName($, hotelId));

    if (shouldHaveFavoriteButton) {
      await smartWaitFor($, getHotelFavoriteButton($, hotelId));
    }
  }

  static Future<void> validateEmptyState(
      PatrolIntegrationTester $, String pageType) async {
    PatrolFinder emptyStateFinder;
    switch (pageType.toLowerCase()) {
      case 'hotels':
        emptyStateFinder = getHotelsEmptyStateIcon($);
        break;
      case 'favorites':
        emptyStateFinder = getFavoritesEmptyState($);
        break;
      default:
        emptyStateFinder = $(Icons.hourglass_empty);
    }
    await smartWaitFor($, emptyStateFinder);
  }

  static Future<void> validateErrorState(PatrolIntegrationTester $) async {
    await smartWaitFor($, getErrorMessage($));
    await smartWaitFor($, getRetryButton($));
  }

  static String? extractHotelId(String keyString) {
    final match = RegExp(r'hotel_card_([0-9\.\-,]+)').firstMatch(keyString);
    return match?.group(1);
  }

  static bool elementExists(PatrolIntegrationTester $, PatrolFinder finder) {
    try {
      return finder.exists;
    } catch (e) {
      return false;
    }
  }

  static List<PatrolFinder Function(PatrolIntegrationTester $)>
      get navigationTabFinders => [
            getOverviewTab,
            getHotelsTab,
            getFavoritesTab,
            getAccountTab,
          ];

  static List<PatrolFinder Function(PatrolIntegrationTester $)>
      get pageScaffoldFinders => [
            getDashboardScaffold,
            getOverviewScaffold,
            getHotelsScaffold,
            getFavoritesScaffold,
            getAccountScaffold,
          ];

  static List<PatrolFinder Function(PatrolIntegrationTester $)>
      get loadingIndicatorFinders => [
            getHotelsLoadingIndicator,
            getHotelsPaginationLoading,
          ];

  static List<PatrolFinder Function(PatrolIntegrationTester $)>
      get errorElementFinders => [
            getHotelsErrorMessage,
            getHotelsRetryButton,
            getHotelsPaginationErrorMessage,
            getHotelsPaginationRetryButton,
          ];

  static const testHotelIds = [
    '48.8566,2.3522',
    '51.5074,-0.1278',
    '40.7128,-74.0060',
    '35.6762,139.6503',
  ];

  static const testSearchQueries = [
    'Paris',
    'London',
    'New York',
    'Tokyo',
    'Hotel',
  ];

  static const pageTransitionTimeout = Duration(seconds: 5);
  static const searchTimeout = Duration(seconds: 15);
  static const networkTimeout = Duration(seconds: 20);

  static Future<Duration> measureFinderPerformance(
    PatrolIntegrationTester $,
    PatrolFinder finder,
    String operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      switch (operation.toLowerCase()) {
        case 'find':
          finder.exists;
          break;
        case 'tap':
          await finder.tap();
          break;
        case 'wait':
          await finder.waitUntilVisible();
          break;
        default:
          finder.exists;
      }
    } catch (e) {
      // Performance measurement continues even on error
    }

    stopwatch.stop();
    return stopwatch.elapsed;
  }
}
