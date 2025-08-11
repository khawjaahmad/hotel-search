import 'dart:async';
import 'package:patrol/patrol.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';
import '../framework/custom_assertions.dart';
import 'hotels_screen_actions.dart';
import 'account_screen_actions.dart';
import 'overview_screen_actions.dart';

/// Custom exception for Dashboard page operations
class DashboardPageException implements Exception {
  final String message;
  final Exception? originalException;
  
  const DashboardPageException(this.message, {this.originalException});
  
  @override
  String toString() {
    if (originalException != null) {
      return 'DashboardPageException: $message\nCaused by: $originalException';
    }
    return 'DashboardPageException: $message';
  }
}

/// Enhanced Dashboard Screen Actions with Navigation Management
/// Includes fluent interface for cross-page workflows
class DashboardScreenActions {
  final PatrolIntegrationTester tester;
  final Duration defaultTimeout;
  
  DashboardScreenActions(this.tester, {this.defaultTimeout = const Duration(seconds: 10)});
  
  /// Get page-specific assertions
  NavigationPageAssertions get assertions => NavigationPageAssertions(tester, this);
  
  /// Fluent wait with custom conditions
  Future<DashboardScreenActions> waitFor(PatrolFinder finder, {
    Duration? timeout,
    String? description,
  }) async {
    final actualTimeout = timeout ?? defaultTimeout;
    final desc = description ?? 'element to be visible';
    
    try {
      await finder.waitUntilVisible(timeout: actualTimeout);
      return this;
    } catch (e) {
      throw DashboardPageException(
        'Failed to wait for $desc on Dashboard page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Fluent tap with validation
  Future<DashboardScreenActions> tapElement(PatrolFinder finder, {
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
      throw DashboardPageException(
        'Failed to tap $desc on Dashboard page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Fluent navigation with type-safe page returns
  Future<T> navigateTo<T>(String tabName) async {
    await tapElement(
      AppLocators.getNavigationTab(tester, tabName),
      description: '$tabName tab',
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Return appropriate page object
    switch (tabName.toLowerCase()) {
      case 'hotels':
        final page = HotelsScreenActions(tester);
        await page.validatePageLoaded();
        return page as T;
      case 'account':
         final page = AccountScreenActions();
         return page as T;
       case 'overview':
         final page = OverviewScreenActions();
         return page as T;
      default:
        throw DashboardPageException('Unknown tab: $tabName');
    }
  }

  /// Cross-page workflow testing
  Future<DashboardScreenActions> performCrossPageWorkflow() async {
    // Complex workflow: Hotels -> Account -> Overview
    final hotelsPage = await navigateTo<HotelsScreenActions>('hotels');
    await hotelsPage.performSearch('Dubai');
    await hotelsPage.favoriteMultipleHotels([0, 1]);

    await navigateTo<AccountScreenActions>('account');
    await navigateTo<OverviewScreenActions>('overview');

    return this;
  }
  static Future<void> verifyDashboardStructure(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'dashboard structure');

    final scaffold = AppLocators.getDashboardScaffold($);
    await scaffold.waitUntilVisible();

    final navigationBar = AppLocators.getNavigationBar($);
    await navigationBar.waitUntilVisible();

    await AppLocators.getOverviewTab($).waitUntilVisible();
    await AppLocators.getHotelsTab($).waitUntilVisible();
    await AppLocators.getFavoritesTab($).waitUntilVisible();
    await AppLocators.getAccountTab($).waitUntilVisible();

    TestLogger.logTestSuccess($, 'Dashboard structure verified');
  }

  static Future<void> verifyNavigationWorks(PatrolIntegrationTester $) async {
    TestLogger.logAction($, 'Testing navigation between tabs');

    final tabs = [
      'overview',
      'hotels',
      'favorites',
      'account',
    ];

    for (final tab in tabs) {
      await TestHelpers.navigateToPage($, tab);
      await $.pump(const Duration(milliseconds: 500));
      await $.pumpAndSettle();
    }

    TestLogger.logTestSuccess($, 'Navigation verification completed');
  }
}
