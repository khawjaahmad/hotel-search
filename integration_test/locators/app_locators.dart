import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Enhanced App Locators with Advanced Fallback Strategy
/// Complete single-file solution with professional locator patterns
class AppLocators {
  AppLocators._();

  // =============================================================================
  // PROFESSIONAL FALLBACK LOCATOR SYSTEM - SHOWCASE
  // =============================================================================

  /// Advanced locator with intelligent fallback chain
  /// Strategy: Key → Widget Type → Icon → Text → Semantic Label
  static Finder findWithFallback({
    Key? key,
    Type? widgetType,
    IconData? icon,
    String? text,
    String? semanticLabel,
    String? description,
  }) {
    debugPrint('🔍 Locating element: ${description ?? 'Unknown'}');

    // Strategy 1: Primary Key (Most Reliable)
    if (key != null) {
      final keyFinder = find.byKey(key);
      if (keyFinder.evaluate().isNotEmpty) {
        debugPrint('✅ Found by KEY: ${key.toString()}');
        return keyFinder;
      }
      debugPrint('⚠️ Key not found: ${key.toString()}, trying fallback...');
    }

    // Strategy 2: Widget Type (Structural)
    if (widgetType != null) {
      final typeFinder = find.byType(widgetType);
      if (typeFinder.evaluate().isNotEmpty) {
        debugPrint('✅ Found by WIDGET TYPE: ${widgetType.toString()}');
        return typeFinder;
      }
      debugPrint(
          '⚠️ Widget type not found: ${widgetType.toString()}, trying fallback...');
    }

    // Strategy 3: Icon (Visual Element)
    if (icon != null) {
      final iconFinder = find.byIcon(icon);
      if (iconFinder.evaluate().isNotEmpty) {
        debugPrint('✅ Found by ICON: ${icon.toString()}');
        return iconFinder;
      }
      debugPrint('⚠️ Icon not found: ${icon.toString()}, trying fallback...');
    }

    // Strategy 4: Text Content (Content-based)
    if (text != null) {
      final textFinder = find.text(text);
      if (textFinder.evaluate().isNotEmpty) {
        debugPrint('✅ Found by TEXT: "$text"');
        return textFinder;
      }
      debugPrint('⚠️ Text not found: "$text", trying fallback...');
    }

    // Strategy 5: Semantic Label (Accessibility)
    if (semanticLabel != null) {
      final semanticFinder = find.bySemanticsLabel(semanticLabel);
      if (semanticFinder.evaluate().isNotEmpty) {
        debugPrint('✅ Found by SEMANTIC LABEL: "$semanticLabel"');
        return semanticFinder;
      }
      debugPrint('⚠️ Semantic label not found: "$semanticLabel"');
    }

    debugPrint(
        '❌ ALL FALLBACK STRATEGIES FAILED for: ${description ?? 'Unknown'}');
    throw Exception(
        'Element not found with any fallback strategy: ${description ?? 'Unknown'}');
  }

  // =============================================================================
  // DASHBOARD & NAVIGATION LOCATORS
  // =============================================================================

  static const String dashboardScaffold = 'dashboard_scaffold';
  static const String navigationBar = 'navigation_bar';
  static const String overviewTab = 'navigation_overview_tab';
  static const String hotelsTab = 'navigation_hotels_tab';
  static const String favoritesTab = 'navigation_favorites_tab';
  static const String accountTab = 'navigation_account_tab';

  /// Smart Navigation Tab Finder with Fallback Strategy
  static Finder getNavigationTab(String tabName) {
    debugPrint('🔍 [NAVIGATION] Locating tab: $tabName');

    switch (tabName.toLowerCase()) {
      case 'overview':
        return findWithFallback(
          key: const Key(overviewTab),
          text: 'Overview',
          icon: Icons.explore_outlined,
          description: 'Overview Navigation Tab',
        );
      case 'hotels':
        return findWithFallback(
          key: const Key(hotelsTab),
          text: 'Hotels',
          icon: Icons.hotel_outlined,
          description: 'Hotels Navigation Tab',
        );
      case 'favorites':
        return findWithFallback(
          key: const Key(favoritesTab),
          text: 'Favorites',
          icon: Icons.favorite_outline,
          description: 'Favorites Navigation Tab',
        );
      case 'account':
        return findWithFallback(
          key: const Key(accountTab),
          text: 'Account',
          icon: Icons.account_circle_outlined,
          description: 'Account Navigation Tab',
        );
      default:
        throw ArgumentError('Unknown navigation tab: $tabName');
    }
  }

  // =============================================================================
  // OVERVIEW PAGE LOCATORS WITH FALLBACK SHOWCASE
  // =============================================================================

  static const String overviewScaffold = 'overview_scaffold';
  static const String overviewAppBar = 'overview_app_bar';
  static const String overviewTitle = 'overview_title';
  static const String overviewIcon = 'overview_icon';

  /// Overview Page Locators with Advanced Fallback Strategy
  static Finder get overviewPageScaffold => findWithFallback(
        key: const Key(overviewScaffold),
        widgetType: Scaffold,
        description: 'Overview Page Scaffold',
      );

  static Finder get overviewPageTitle => findWithFallback(
        key: const Key(overviewTitle),
        text: 'Hotel Booking',
        widgetType: Text,
        semanticLabel: 'Hotel Booking Title',
        description: 'Overview Page Title',
      );

  static Finder get overviewPageIcon => findWithFallback(
        key: const Key(overviewIcon),
        icon: Icons.explore_outlined,
        widgetType: Icon,
        semanticLabel: 'Explore Icon',
        description: 'Overview Page Icon',
      );

  static Finder get overviewPageAppBar => findWithFallback(
        key: const Key(overviewAppBar),
        widgetType: AppBar,
        description: 'Overview App Bar',
      );

  // =============================================================================
  // HOTELS PAGE LOCATORS
  // =============================================================================

  static const String hotelsScaffold = 'hotels_scaffold';
  static const String hotelsAppBar = 'hotels_app_bar';
  static const String hotelsSearchField = 'hotels_search_field';
  static const String searchTextField = 'search_text_field';
  static const String searchPrefixIcon = 'search_prefix_icon';
  static const String searchClearButton = 'search_clear_button';
  static const String hotelsScrollView = 'hotels_scroll_view';
  static const String hotelsList = 'hotels_list';
  static const String hotelsLoadingIndicator = 'hotels_loading_indicator';
  static const String hotelsEmptyStateIcon = 'hotels_empty_state_icon';
  static const String hotelsErrorColumn = 'hotels_error_column';
  static const String hotelsErrorMessage = 'hotels_error_message';
  static const String hotelsRetryButton = 'hotels_retry_button';
  static const String hotelsPaginationLoading = 'hotels_pagination_loading';
  static const String hotelsPaginationErrorColumn =
      'hotels_pagination_error_column';
  static const String hotelsPaginationErrorMessage =
      'hotels_pagination_error_message';
  static const String hotelsPaginationRetryButton =
      'hotels_pagination_retry_button';

  /// Dynamic Hotel Card Locators
  static String hotelCard(String hotelId) => 'hotel_card_$hotelId';
  static String hotelName(String hotelId) => 'hotel_name_$hotelId';
  static String hotelDescription(String hotelId) =>
      'hotel_description_$hotelId';
  static String hotelFavoriteButton(String hotelId) =>
      'hotel_favorite_button_$hotelId';

  /// Hotels Search Field with Fallback
  static Finder get hotelsSearchFieldFinder => findWithFallback(
        key: const Key(hotelsSearchField),
        widgetType: TextField,
        description: 'Hotels Search Field',
      );

  // =============================================================================
  // FAVORITES PAGE LOCATORS
  // =============================================================================

  static const String favoritesScaffold = 'favorites_scaffold';
  static const String favoritesAppBar = 'favorites_app_bar';
  static const String favoritesTitle = 'favorites_title';
  static const String favoritesListView = 'favorites_list_view';
  static const String favoritesEmptyStateIcon = 'favorites_empty_state_icon';

  /// Dynamic Favorites Locators
  static String favoritesHotelCard(String hotelId) =>
      'favorites_hotel_card_$hotelId';

  /// Favorites Title with Fallback
  static Finder get favoritesTitleFinder => findWithFallback(
        key: const Key(favoritesTitle),
        text: 'Your Favorite Hotels',
        widgetType: Text,
        description: 'Favorites Page Title',
      );

  // =============================================================================
  // ACCOUNT PAGE LOCATORS
  // =============================================================================

  static const String accountScaffold = 'account_scaffold';
  static const String accountAppBar = 'account_app_bar';
  static const String accountTitle = 'account_title';
  static const String accountIcon = 'account_icon';

  /// Account Page Elements with Fallback
  static Finder get accountPageTitle => findWithFallback(
        key: const Key(accountTitle),
        text: 'Your Account',
        widgetType: Text,
        description: 'Account Page Title',
      );

  static Finder get accountPageIcon => findWithFallback(
        key: const Key(accountIcon),
        icon: Icons.account_circle_outlined,
        widgetType: Icon,
        description: 'Account Page Icon',
      );

  // =============================================================================
  // COMMON LOCATORS
  // =============================================================================

  static const String loadingIndicator = 'loading_indicator';
  static const String errorMessage = 'error_message';
  static const String retryButton = 'retry_button';

  /// Common Loading Indicator with Fallback
  static Finder get commonLoadingFinder => findWithFallback(
        key: const Key(loadingIndicator),
        widgetType: CircularProgressIndicator,
        description: 'Loading Indicator',
      );

  /// Common Error Message with Fallback
  static Finder get commonErrorFinder => findWithFallback(
        key: const Key(errorMessage),
        text: 'Something went wrong',
        description: 'Error Message',
      );

  // =============================================================================
  // WIDGET TYPE FINDERS
  // =============================================================================

  static Finder get textFieldFinder => find.byType(TextField);
  static Finder get searchIconFinder => find.byIcon(Icons.search);
  static Finder get cancelIconFinder => find.byIcon(Icons.cancel_outlined);
  static Finder get favoriteOutlineIconFinder =>
      find.byIcon(Icons.favorite_outline);
  static Finder get favoriteFilledIconFinder => find.byIcon(Icons.favorite);
  static Finder get hotelIconFinder => find.byIcon(Icons.hotel_outlined);
  static Finder get accountCircleIconFinder =>
      find.byIcon(Icons.account_circle_outlined);
  static Finder get exploreIconFinder => find.byIcon(Icons.explore_outlined);

  // =============================================================================
  // VALIDATION METHODS WITH FALLBACK SHOWCASE
  // =============================================================================

  /// Validate Overview Page with Fallback Strategies
  static void validateOverviewPage() {
    debugPrint('🔍 [OVERVIEW] Validating with fallback strategies...');

    expect(overviewPageScaffold, findsOneWidget);
    debugPrint('✅ [OVERVIEW] Scaffold validated with fallback');

    expect(overviewPageTitle, findsOneWidget);
    debugPrint('✅ [OVERVIEW] Title validated with fallback');

    expect(overviewPageIcon, findsOneWidget);
    debugPrint('✅ [OVERVIEW] Icon validated with fallback');

    expect(overviewPageAppBar, findsOneWidget);
    debugPrint('✅ [OVERVIEW] App bar validated with fallback');

    debugPrint(
        '🎉 [OVERVIEW] All elements validated with fallback strategies!');
  }

  /// Validate Navigation with Fallback
  static void validateNavigation() {
    debugPrint('🔍 [NAVIGATION] Validating navigation system...');

    expect(find.byKey(const Key(navigationBar)), findsOneWidget);

    final tabs = ['overview', 'hotels', 'favorites', 'account'];
    for (final tab in tabs) {
      final tabFinder = getNavigationTab(tab);
      expect(tabFinder, findsOneWidget);
      debugPrint('✅ [NAVIGATION] $tab tab validated with fallback');
    }

    debugPrint('✅ [NAVIGATION] Navigation validation complete');
  }

  /// Validate Dashboard Structure
  static void validateDashboard() {
    debugPrint('🔍 [DASHBOARD] Validating dashboard structure...');

    expect(find.byKey(const Key(dashboardScaffold)), findsOneWidget);
    validateNavigation();

    debugPrint('✅ [DASHBOARD] Dashboard validation complete');
  }

  /// Comprehensive Health Check with Fallback Demonstration
  static void performComprehensiveHealthCheck() {
    debugPrint(
        '🏥 [APP] Starting comprehensive health check with fallback strategies...');

    try {
      validateDashboard();

      // Check individual pages if loaded
      if (find.byKey(const Key(overviewScaffold)).evaluate().isNotEmpty) {
        validateOverviewPage();
      }

      debugPrint('🎉 [APP] Comprehensive health check completed!');
      debugPrint('📊 [APP] All fallback strategies operational');
    } catch (e) {
      debugPrint('❌ [APP] Health check failed: $e');
      rethrow;
    }
  }

  /// Demonstrate Fallback Strategies in Action
  static void demonstrateFallbackStrategies() {
    debugPrint('🎯 [SHOWCASE] DEMONSTRATING FALLBACK STRATEGIES...');
    debugPrint('');

    debugPrint('📋 Fallback Chain Example - Overview Title:');
    debugPrint('  1. 🔑 Primary Key: "overview_title"');
    debugPrint('  2. 📝 Text Fallback: "Hotel Booking"');
    debugPrint('  3. 🏗️ Widget Fallback: Text widget');
    debugPrint('  4. ♿ Accessibility: "Hotel Booking Title"');
    debugPrint('');

    debugPrint('📋 Navigation Tab Fallback Example:');
    debugPrint('  1. 🔑 Key: "navigation_hotels_tab"');
    debugPrint('  2. 📝 Text: "Hotels"');
    debugPrint('  3. 🎨 Icon: Icons.hotel_outlined');
    debugPrint('');

    debugPrint('💡 This showcases professional automation resilience!');
    debugPrint('🎉 Fallback strategies ensure tests survive UI changes');
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  static Key key(String locator) => Key(locator);

  static bool isElementVisible(String keyString) {
    return find.byKey(Key(keyString)).evaluate().isNotEmpty;
  }

  /// Get all dashboard locators
  static List<String> get dashboardLocators => [
        dashboardScaffold,
        navigationBar,
        overviewTab,
        hotelsTab,
        favoritesTab,
        accountTab,
      ];

  /// Get all overview locators
  static List<String> get overviewLocators => [
        overviewScaffold,
        overviewAppBar,
        overviewTitle,
        overviewIcon,
      ];

  /// Get all hotels locators
  static List<String> get hotelsLocators => [
        hotelsScaffold,
        hotelsAppBar,
        hotelsSearchField,
        searchTextField,
        hotelsScrollView,
        hotelsList,
        hotelsLoadingIndicator,
        hotelsEmptyStateIcon,
        hotelsErrorMessage,
        hotelsRetryButton,
        hotelsPaginationLoading,
        hotelsPaginationErrorMessage,
        hotelsPaginationRetryButton,
      ];

  /// Get all favorites locators
  static List<String> get favoritesLocators => [
        favoritesScaffold,
        favoritesAppBar,
        favoritesTitle,
        favoritesListView,
        favoritesEmptyStateIcon,
      ];

  /// Get all account locators
  static List<String> get accountLocators => [
        accountScaffold,
        accountAppBar,
        accountTitle,
        accountIcon,
      ];

  /// Get all common locators
  static List<String> get commonLocators => [
        loadingIndicator,
        errorMessage,
        retryButton,
      ];

  /// Print comprehensive locator summary
  static void printLocatorSummary() {
    debugPrint(
        '📋 [APP] Comprehensive Locator Summary with Fallback Strategies:');
    debugPrint('  🏠 Dashboard: ${dashboardLocators.length} locators');
    debugPrint(
        '  🌟 Overview: ${overviewLocators.length} locators + Advanced Fallback');
    debugPrint(
        '  🏨 Hotels: ${hotelsLocators.length} locators + Dynamic Cards');
    debugPrint('  💝 Favorites: ${favoritesLocators.length} locators');
    debugPrint('  👤 Account: ${accountLocators.length} locators');
    debugPrint('  🔧 Common: ${commonLocators.length} shared locators');
    debugPrint(
        '  🎯 Total: Complete coverage with professional fallback strategies');
  }

  /// Validate all static locators exist
  static void validateAllStaticLocators() {
    final allLocators = [
      ...dashboardLocators,
      ...overviewLocators,
      ...hotelsLocators,
      ...favoritesLocators,
      ...accountLocators,
      ...commonLocators,
    ];

    debugPrint(
        '🔍 [VALIDATION] Checking ${allLocators.length} static locators...');

    for (final locator in allLocators) {
      if (isElementVisible(locator)) {
        debugPrint('✅ Found: $locator');
      } else {
        debugPrint('⚠️ Not visible: $locator');
      }
    }

    debugPrint('✅ [VALIDATION] Static locator check complete');
  }
}
