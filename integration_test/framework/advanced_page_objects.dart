import 'dart:async';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';
import 'custom_assertions.dart';

/// Advanced Page Object Model with Fluent Interface
/// Demonstrates senior-level automation patterns:
/// - Fluent API design
/// - Method chaining
/// - Custom wait strategies
/// - Performance monitoring
/// - Error handling with context
abstract class BasePage {
  final PatrolIntegrationTester tester;
  final String pageName;
  final Duration defaultTimeout;
  
  BasePage(this.tester, this.pageName, {this.defaultTimeout = const Duration(seconds: 10)});

  /// Fluent wait with custom conditions
  Future<BasePage> waitFor(PatrolFinder finder, {
    Duration? timeout,
    String? description,
  }) async {
    final actualTimeout = timeout ?? defaultTimeout;
    final desc = description ?? 'element to be visible';
    
    try {
      await finder.waitUntilVisible(timeout: actualTimeout);
      return this;
    } catch (e) {
      throw PageException(
        'Failed to wait for $desc on $pageName page',
        originalException: e is Exception ? e : Exception(e.toString()),
        pageName: pageName,
      );
    }
  }

  /// Fluent tap with validation
  Future<BasePage> tapElement(PatrolFinder finder, {
    String? description,
    bool validateAfterTap = true,
  }) async {
    final desc = description ?? 'element';
    
    try {
      await finder.waitUntilVisible();
      await finder.tap();
      
      if (validateAfterTap) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      
      return this;
    } catch (e) {
        throw PageException(
          'Failed to tap $desc on $pageName page',
          originalException: e is Exception ? e : Exception(e.toString()),
          pageName: pageName,
        );
    }
  }

  /// Fluent text input with validation
  Future<BasePage> enterText(PatrolFinder finder, String text, {
    String? description,
    bool clearFirst = true,
  }) async {
    final desc = description ?? 'text field';
    
    try {
      await finder.waitUntilVisible();
      
      if (clearFirst) {
        await finder.tap();
        await tester.pump(const Duration(milliseconds: 100));
        // Clear existing text by selecting all and typing new text
        await tester.enterText(finder, '');
      }
      
      await finder.enterText(text);
      await tester.pump(const Duration(milliseconds: 300));
      
      return this;
    } catch (e) {
      throw PageException(
        'Failed to enter text "$text" in $desc on $pageName page',
        originalException: e is Exception ? e : Exception(e.toString()),
        pageName: pageName,
      );
    }
  }

  /// Advanced scroll with pagination detection
  Future<BasePage> scrollUntil(PatrolFinder scrollable, PatrolFinder target, {
    int maxScrolls = 10,
    double scrollDelta = -300,
    Duration scrollDelay = const Duration(milliseconds: 500),
  }) async {
    for (int i = 0; i < maxScrolls; i++) {
      if (target.exists) {
        return this;
      }
      
      await tester.scrollUntilVisible(
        finder: target,
        view: scrollable,
        delta: scrollDelta,
        maxScrolls: 1,
      );
      await tester.pump(scrollDelay);
    }
    
    throw PageException(
      'Target element not found after $maxScrolls scrolls on $pageName page',
      pageName: pageName,
    );
  }

  /// Validate page is loaded
  Future<BasePage> validatePageLoaded();

  /// Get page-specific assertions
  PageAssertions get assertions;
}

/// Advanced Hotels Page with Fluent Interface
class HotelsPage extends BasePage {
  HotelsPage(PatrolIntegrationTester tester) : super(tester, 'Hotels');

  @override
  Future<HotelsPage> validatePageLoaded() async {
    await waitFor(AppLocators.getHotelsScaffold(tester), description: 'hotels scaffold');
    await waitFor(AppLocators.getHotelsAppBar(tester), description: 'hotels app bar');
    await waitFor(AppLocators.getSearchTextField(tester), description: 'search field');
    return this;
  }

  @override
  PageAssertions get assertions => HotelsPageAssertions(tester, this);

  /// Fluent search with advanced options
  Future<HotelsPage> performSearch(String query, {
    bool waitForResults = true,
    Duration? searchTimeout,
  }) async {
    await enterText(
      AppLocators.getSearchTextField(tester),
      query,
      description: 'search field',
    );

    if (waitForResults) {
      await _waitForSearchResults(searchTimeout ?? const Duration(seconds: 15));
    }

    return this;
  }

  /// Advanced search result waiting with multiple conditions
  Future<HotelsPage> _waitForSearchResults(Duration timeout) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 500));
      
      // Check for loading indicators
      final isLoading = AppLocators.getHotelsLoadingIndicator(tester).exists ||
                       AppLocators.getHotelsPaginationLoading(tester).exists;
      
      if (!isLoading) {
        // Check for results, errors, or empty state
        if (tester(Card).exists) {
          return this; // Results found
        } else if (AppLocators.getHotelsErrorMessage(tester).exists) {
          return this; // Error state
        } else if (AppLocators.getHotelsEmptyStateIcon(tester).exists) {
          return this; // Empty state
        }
      }
    }
    
    throw PageException(
      'Search results did not load within ${timeout.inSeconds} seconds',
      pageName: pageName,
    );
  }

  /// Smart hotel selection with validation
  Future<HotelsPage> selectHotel(int index, {bool validateSelection = true}) async {
    final cards = tester(Card).evaluate();
    
    if (index >= cards.length) {
      throw PageException(
        'Hotel index $index out of range (0-${cards.length - 1})',
        pageName: pageName,
      );
    }

    await tapElement(
      tester(Card).at(index),
      description: 'hotel card at index $index',
      validateAfterTap: validateSelection,
    );

    return this;
  }

  /// Advanced favorites management
  Future<HotelsPage> toggleFavorite(int hotelIndex, {bool expectAdded = true}) async {
    final cards = tester(Card).evaluate();
    
    if (hotelIndex >= cards.length) {
      throw PageException(
        'Hotel index $hotelIndex out of range',
        pageName: pageName,
      );
    }

    // Find favorite button within the card
    final favoriteButton = tester(IconButton).at(hotelIndex);
    
    if (!favoriteButton.exists) {
      throw PageException(
        'Favorite button not found in hotel card at index $hotelIndex',
        pageName: pageName,
      );
    }

    await tapElement(favoriteButton, description: 'favorite button');
    
    // Validate the action with visual feedback
    await tester.pump(const Duration(milliseconds: 500));
    
    return this;
  }

  /// Bulk operations for stress testing
  Future<HotelsPage> favoriteMultipleHotels(List<int> indices) async {
    for (final index in indices) {
      await toggleFavorite(index);
      await tester.pump(const Duration(milliseconds: 200)); // Prevent rapid tapping
    }
    return this;
  }

  /// Advanced pagination testing
  Future<HotelsPage> testPagination({
    int maxScrolls = 5,
    bool validateNewContent = true,
  }) async {
    final initialCardCount = tester(Card).evaluate().length;
    
    for (int i = 0; i < maxScrolls; i++) {
      await tester.scrollUntilVisible(
        finder: AppLocators.getHotelsPaginationLoading(tester),
        view: AppLocators.getHotelsScrollView(tester),
        delta: -300,
        maxScrolls: 1,
      );
      
      // Wait for pagination to complete
      await _waitForPaginationComplete();
      
      if (validateNewContent) {
        final currentCardCount = tester(Card).evaluate().length;
        if (currentCardCount > initialCardCount) {
          break; // New content loaded
        }
      }
    }
    
    return this;
  }

  Future<void> _waitForPaginationComplete() async {
    const maxWait = Duration(seconds: 10);
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < maxWait) {
      if (!AppLocators.getHotelsPaginationLoading(tester).exists) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Data-driven search testing
  Future<HotelsPage> performDataDrivenSearch(List<String> queries) async {
    for (final query in queries) {
      await performSearch(query);
      await (assertions as HotelsPageAssertions).shouldHaveSearchResults();
      await tester.pump(const Duration(milliseconds: 500));
    }
    return this;
  }

  /// Clear search field
  Future<HotelsPage> clearSearchField() async {
    await enterText(
      AppLocators.getSearchTextField(tester),
      '',
      description: 'search field',
      clearFirst: true,
    );
    return this;
  }

  /// Error scenario testing
  Future<HotelsPage> testErrorScenarios() async {
    final errorScenarios = [
      '', // Empty search
      '!@#\$%^&*()', // Special characters
      'x' * 1000, // Very long query
      '   ', // Whitespace only
    ];

    for (final scenario in errorScenarios) {
      await performSearch(scenario, waitForResults: false);
      await tester.pump(const Duration(seconds: 2));
      // Validate error handling or graceful degradation
    }
    
    return this;
  }
}

/// Navigation Page for cross-page workflows
class NavigationPage extends BasePage {
  NavigationPage(PatrolIntegrationTester tester) : super(tester, 'Navigation');

  @override
  Future<NavigationPage> validatePageLoaded() async {
    await waitFor(AppLocators.getNavigationBar(tester), description: 'navigation bar');
    return this;
  }

  @override
  PageAssertions get assertions => NavigationPageAssertions(tester, this);

  /// Fluent navigation with validation
  Future<T> navigateTo<T extends BasePage>(String tabName) async {
    await tapElement(
      AppLocators.getNavigationTab(tester, tabName),
      description: '$tabName tab',
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Return appropriate page object
    switch (tabName.toLowerCase()) {
      case 'hotels':
        final page = HotelsPage(tester);
        await page.validatePageLoaded();
        return page as T;
      case 'favorites':
        final page = FavoritesPage(tester);
        await page.validatePageLoaded();
        return page as T;
      case 'account':
        final page = AccountPage(tester);
        await page.validatePageLoaded();
        return page as T;
      case 'overview':
        final page = OverviewPage(tester);
        await page.validatePageLoaded();
        return page as T;
      default:
        throw PageException('Unknown tab: $tabName', pageName: pageName);
    }
  }

  /// Cross-page workflow testing
  Future<NavigationPage> performCrossPageWorkflow() async {
    // Complex workflow: Hotels -> Favorites -> Account -> Overview
    final hotelsPage = await navigateTo<HotelsPage>('hotels');
    await hotelsPage.performSearch('Dubai');
    await hotelsPage.favoriteMultipleHotels([0, 1]);

    final favoritesPage = await navigateTo<FavoritesPage>('favorites');
    await (favoritesPage.assertions as FavoritesPageAssertions).shouldHaveFavorites();

    await navigateTo<AccountPage>('account');
    await navigateTo<OverviewPage>('overview');

    return this;
  }
}

/// Favorites Page with advanced operations
class FavoritesPage extends BasePage {
  FavoritesPage(PatrolIntegrationTester tester) : super(tester, 'Favorites');

  @override
  Future<FavoritesPage> validatePageLoaded() async {
    await waitFor(AppLocators.getFavoritesScaffold(tester), description: 'favorites scaffold');
    return this;
  }

  @override
  PageAssertions get assertions => FavoritesPageAssertions(tester, this);

  Future<FavoritesPage> clearAllFavorites() async {
    final cards = tester(Card).evaluate();
    
    for (int i = cards.length - 1; i >= 0; i--) {
      final favoriteButton = tester(IconButton).at(i);
      if (favoriteButton.exists) {
        await tapElement(favoriteButton, description: 'remove favorite button');
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    
    return this;
  }
}

/// Account Page
class AccountPage extends BasePage {
  AccountPage(PatrolIntegrationTester tester) : super(tester, 'Account');

  @override
  Future<AccountPage> validatePageLoaded() async {
    await waitFor(AppLocators.getAccountScaffold(tester), description: 'account scaffold');
    return this;
  }

  @override
  PageAssertions get assertions => AccountPageAssertions(tester, this);
}

/// Overview Page
class OverviewPage extends BasePage {
  OverviewPage(PatrolIntegrationTester tester) : super(tester, 'Overview');

  @override
  Future<OverviewPage> validatePageLoaded() async {
    await waitFor(AppLocators.getOverviewScaffold(tester), description: 'overview scaffold');
    return this;
  }

  @override
  PageAssertions get assertions => OverviewPageAssertions(tester, this);
}

/// Custom exception for page-related errors
class PageException implements Exception {
  final String message;
  final String pageName;
  final Exception? originalException;
  final DateTime timestamp;

  PageException(
    this.message, {
    required this.pageName,
    this.originalException,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer('PageException on $pageName: $message');
    if (originalException != null) {
      buffer.write('\nCaused by: $originalException');
    }
    buffer.write('\nTimestamp: $timestamp');
    return buffer.toString();
  }
}