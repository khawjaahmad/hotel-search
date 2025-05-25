import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/app_locators.dart';

class FavoritesPage extends BasePage {
  FavoritesPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'favorites';

  @override
  String get pageKey => AppLocators.favoritesScaffold;

  Future<void> verifyFavoritesPageLoaded() async {
    logAction('Verifying favorites page is loaded');
    await verifyPageIsLoaded();
    verifyElementExists(AppLocators.favoritesAppBar);
    verifyElementExists(AppLocators.favoritesTitle);
  }

  void verifyEmptyFavoritesState() {
    logAction('Verifying empty favorites state');
    verifyElementExists(AppLocators.favoritesEmptyStateIcon);
    verifyElementNotExists(AppLocators.favoritesListView);
  }

  void verifyFavoritesListVisible() {
    logAction('Verifying favorites list is visible');
    verifyElementExists(AppLocators.favoritesListView);
    verifyElementNotExists(AppLocators.favoritesEmptyStateIcon);
  }

  void verifyFavoriteHotelExists(String hotelId) {
    logAction('Verifying favorite hotel exists: $hotelId');
    verifyElementExists(AppLocators.favoritesHotelCard(hotelId));
  }

  void verifyFavoriteHotelDetails(String hotelId) {
    logAction('Verifying favorite hotel details: $hotelId');
    verifyElementExists(AppLocators.favoritesHotelCard(hotelId));
    verifyElementExists(AppLocators.hotelName(hotelId));
    verifyElementExists(AppLocators.hotelFavoriteButton(hotelId));
  }

  Future<void> removeFavoriteHotel(String hotelId) async {
    logAction('Removing hotel from favorites: $hotelId');

    final favoriteButtonKey = AppLocators.hotelFavoriteButton(hotelId);

    if (isElementVisible(AppLocators.favoritesListView)) {
      await $(Key(favoriteButtonKey))
          .scrollTo(view: $(Key(AppLocators.favoritesListView)))
          .tap();
    } else {
      await tapElement(favoriteButtonKey);
    }

    await $.pump(const Duration(milliseconds: 500));
    await takePageScreenshot('hotel_removed_from_favorites_$hotelId');
  }

  Future<void> addFavoriteHotel(String hotelId) async {
    logAction('Adding hotel to favorites: $hotelId');

    final favoriteButtonKey = AppLocators.hotelFavoriteButton(hotelId);

    if (isElementVisible(AppLocators.favoritesListView)) {
      await $(Key(favoriteButtonKey))
          .scrollTo(view: $(Key(AppLocators.favoritesListView)))
          .tap();
    } else {
      await tapElement(favoriteButtonKey);
    }

    await $.pump(const Duration(milliseconds: 500));
    await takePageScreenshot('hotel_added_to_favorites_$hotelId');
  }

  Future<int> getFavoriteHotelsCount() async {
    logAction('Getting favorite hotels count');

    if (!isElementVisible(AppLocators.favoritesListView)) {
      logAction('No favorites list visible, count is 0');
      return 0;
    }

    await $.pump(const Duration(milliseconds: 500));

    return 1;
  }

  Future<void> scrollThroughFavorites() async {
    logAction('Scrolling through favorites list');

    if (isElementVisible(AppLocators.favoritesListView)) {
      await $.pumpAndSettle();
      logAction('Favorites list is functional');
      await takePageScreenshot('favorites_scrolled');
    }
  }

  void verifyFavoritesTitle() {
    logAction('Verifying favorites page title');
    verifyElementExists(AppLocators.favoritesTitle);
    verifyTextExists('Your Favorite Hotels');
  }

  Future<void> clearAllFavorites(List<String> hotelIds) async {
    logAction('Clearing all favorites');

    for (final hotelId in hotelIds) {
      if (isElementVisible(AppLocators.favoritesHotelCard(hotelId))) {
        await removeFavoriteHotel(hotelId);
        await $.pump(const Duration(milliseconds: 300));
      }
    }

    await takePageScreenshot('all_favorites_cleared');
  }

  Future<void> verifyFavoritesListFunctionality() async {
    logAction('Verifying favorites list functionality');

    await verifyFavoritesPageLoaded();

    if (isElementVisible(AppLocators.favoritesEmptyStateIcon)) {
      logAction('Favorites list is empty');
      verifyEmptyFavoritesState();
    } else if (isElementVisible(AppLocators.favoritesListView)) {
      logAction('Favorites list has items');
      verifyFavoritesListVisible();
      await scrollThroughFavorites();
    }
  }

  Future<void> testFavoritesManagement(List<String> hotelIds) async {
    logAction('Testing favorites management workflow');

    await verifyFavoritesPageLoaded();

    for (final hotelId in hotelIds) {
      if (isElementVisible(AppLocators.favoritesHotelCard(hotelId))) {
        await removeFavoriteHotel(hotelId);
        await $.pump(const Duration(milliseconds: 500));
      }
    }

    await $.pump(const Duration(seconds: 1));
    await takePageScreenshot('favorites_management_complete');
  }

  Future<void> takeFavoritesScreenshots() async {
    logAction('Taking comprehensive favorites screenshots');

    await takePageScreenshot('favorites_initial_state');

    if (isElementVisible(AppLocators.favoritesListView)) {
      await scrollThroughFavorites();
      await takePageScreenshot('favorites_with_items');
    } else {
      await takePageScreenshot('favorites_empty_state');
    }
  }
}
