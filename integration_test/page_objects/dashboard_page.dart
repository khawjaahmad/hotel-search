import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/app_locators.dart';

/// Enhanced Dashboard Page Object Model
/// Utilizes advanced locator system with comprehensive fallback strategies
/// Professional navigation management with detailed error handling and validation
/// Optimized for critical integration testing scenarios
class DashboardPage extends BasePage {
  DashboardPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'dashboard';

  @override
  String get pageKey => AppLocators.dashboardScaffold;

  // =============================================================================
  // ENHANCED NAVIGATION METHODS WITH COMPREHENSIVE ERROR HANDLING
  // =============================================================================

  /// Navigate to Overview tab with enhanced validation
  Future<void> navigateToOverview() async {
    logAction('Navigating to Overview tab with enhanced validation');

    try {
      await _executeTabNavigation(
        'overview',
        AppLocators.overviewTab,
        expectedPageKey: 'overview_scaffold',
      );

      await takePageScreenshot('overview_tab_selected');
      logSuccess('Successfully navigated to Overview tab');
    } catch (e) {
      logError('Failed to navigate to Overview tab', e);
      await takeErrorScreenshot('overview_navigation_failed');
      rethrow;
    }
  }

  /// Navigate to Hotels tab with enhanced validation
  Future<void> navigateToHotels() async {
    logAction('Navigating to Hotels tab with enhanced validation');

    try {
      await _executeTabNavigation(
        'hotels',
        AppLocators.hotelsTab,
        expectedPageKey: 'hotels_scaffold',
      );

      await takePageScreenshot('hotels_tab_selected');
      logSuccess('Successfully navigated to Hotels tab');
    } catch (e) {
      logError('Failed to navigate to Hotels tab', e);
      await takeErrorScreenshot('hotels_navigation_failed');
      rethrow;
    }
  }

  /// Navigate to Favorites tab with enhanced validation
  Future<void> navigateToFavorites() async {
    logAction('Navigating to Favorites tab with enhanced validation');

    try {
      await _executeTabNavigation(
        'favorites',
        AppLocators.favoritesTab,
        expectedPageKey: 'favorites_scaffold',
      );

      await takePageScreenshot('favorites_tab_selected');
      logSuccess('Successfully navigated to Favorites tab');
    } catch (e) {
      logError('Failed to navigate to Favorites tab', e);
      await takeErrorScreenshot('favorites_navigation_failed');
      rethrow;
    }
  }

  /// Navigate to Account tab with enhanced validation
  Future<void> navigateToAccount() async {
    logAction('Navigating to Account tab with enhanced validation');

    try {
      await _executeTabNavigation(
        'account',
        AppLocators.accountTab,
        expectedPageKey: 'account_scaffold',
      );

      await takePageScreenshot('account_tab_selected');
      logSuccess('Successfully navigated to Account tab');
    } catch (e) {
      logError('Failed to navigate to Account tab', e);
      await takeErrorScreenshot('account_navigation_failed');
      rethrow;
    }
  }

  /// Execute tab navigation with comprehensive validation
  Future<void> _executeTabNavigation(String tabName, String tabKey,
      {String? expectedPageKey}) async {
    logAction('Executing navigation to $tabName tab');

    // Pre-navigation validation
    await _validateNavigationReadiness();

    // Execute tab tap with enhanced error handling
    await executeWithRetry(
      'Navigate to $tabName',
      () async {
        await tapElement(tabKey, description: '$tabName tab');
        await waitForLoadingToComplete();

        // Validate successful navigation
        if (expectedPageKey != null) {
          await waitForElement(expectedPageKey,
              timeout: const Duration(seconds: 8),
              description: '$tabName page scaffold');
        }
      },
      maxRetries: 2,
      retryDelay: const Duration(milliseconds: 800),
    );

    // Post-navigation validation
    await _validateNavigationResult(tabName, expectedPageKey);
  }

  /// Validate navigation readiness
  Future<void> _validateNavigationReadiness() async {
    // Ensure dashboard is loaded and navigation bar is accessible
    await ensurePageIsActive();
    verifyNavigationBarVisible();

    // Wait for any ongoing transitions to complete
    await $.pump(const Duration(milliseconds: 300));
  }

  /// Validate navigation result
  Future<void> _validateNavigationResult(
      String tabName, String? expectedPageKey) async {
    if (expectedPageKey != null) {
      // Verify the expected page is now visible
      expect(isElementVisible(expectedPageKey), isTrue,
          reason: '$tabName page should be visible after navigation');
    }

    // Ensure navigation bar is still accessible
    verifyNavigationBarVisible();

    logAction('Navigation to $tabName validated successfully');
  }

  // =============================================================================
  // ENHANCED NAVIGATION BAR VERIFICATION
  // =============================================================================

  /// Verify navigation bar is visible with comprehensive validation
  void verifyNavigationBarVisible() {
    logAction('Verifying navigation bar visibility with enhanced validation');

    try {
      // Primary verification
      verifyElementExists(AppLocators.navigationBar,
          description: 'Main navigation bar');

      // Additional verification using smart finder from AppLocators
      final navBar = find.byKey(Key(AppLocators.navigationBar));
      expect(navBar, findsOneWidget,
          reason: 'Navigation bar should be present and accessible');

      // Verify navigation bar is functional (not just visible)
      expect(navBar.evaluate().first.widget, isA<NavigationBar>(),
          reason: 'Navigation element should be a NavigationBar widget');

      logSuccess('Navigation bar visibility verified');
    } catch (e) {
      logError('Navigation bar verification failed', e);
      rethrow;
    }
  }

  /// Verify all navigation tabs are visible and accessible
  void verifyAllTabsVisible() {
    logAction('Verifying all navigation tabs with comprehensive validation');

    try {
      final tabsData = [
        {
          'key': AppLocators.overviewTab,
          'name': 'Overview',
          'icon': Icons.explore_outlined
        },
        {
          'key': AppLocators.hotelsTab,
          'name': 'Hotels',
          'icon': Icons.hotel_outlined
        },
        {
          'key': AppLocators.favoritesTab,
          'name': 'Favorites',
          'icon': Icons.favorite_outline
        },
        {
          'key': AppLocators.accountTab,
          'name': 'Account',
          'icon': Icons.account_circle_outlined
        },
      ];

      for (final tabData in tabsData) {
        final tabKey = tabData['key'] as String;
        final tabName = tabData['name'] as String;
        final tabIcon = tabData['icon'] as IconData;

        // Verify tab element exists
        verifyElementExists(tabKey, description: '$tabName tab');

        // Verify tab icon is present
        expect(find.byIcon(tabIcon), findsOneWidget,
            reason: '$tabName tab icon should be visible');

        logAction('✅ $tabName tab verified');
      }

      // Use AppLocators validation method
      AppLocators.validateNavigation();

      logSuccess('All navigation tabs verified successfully');
    } catch (e) {
      logError('Navigation tabs verification failed', e);
      rethrow;
    }
  }

  /// Verify specific navigation tab properties
  void verifyNavigationTab(String tabName) {
    logAction('Verifying specific navigation tab: $tabName');

    try {
      // Use AppLocators smart navigation tab finder
      final tabFinder = AppLocators.getNavigationTab(tabName);
      expect(tabFinder, findsOneWidget,
          reason: '$tabName tab should be accessible');

      logSuccess('Navigation tab verified: $tabName');
    } catch (e) {
      logError('Navigation tab verification failed: $tabName', e);
      rethrow;
    }
  }

  // =============================================================================
  // ENHANCED DASHBOARD VERIFICATION
  // =============================================================================

  /// Comprehensive dashboard loading verification
  Future<void> verifyDashboardLoaded() async {
    logAction('Verifying dashboard loaded with comprehensive validation');

    try {
      // Use enhanced page verification from base class
      await verifyPageIsLoaded();

      // Dashboard-specific verifications
      await _verifyDashboardStructure();
      await _verifyNavigationFunctionality();

      // Use AppLocators comprehensive validation
      AppLocators.validateDashboard();

      await takePageScreenshot('dashboard_fully_loaded');
      logSuccess('Dashboard loading verification completed successfully');
    } catch (e) {
      logError('Dashboard loading verification failed', e);
      await takeErrorScreenshot('dashboard_load_failed');
      rethrow;
    }
  }

  /// Verify dashboard structure using enhanced locators
  Future<void> _verifyDashboardStructure() async {
    logAction('Verifying dashboard structure');

    // Verify main container
    verifyElementExists(AppLocators.dashboardScaffold,
        description: 'Dashboard main scaffold');

    // Verify navigation components
    verifyNavigationBarVisible();
    verifyAllTabsVisible();

    // Wait for structure to stabilize
    await waitForPageStabilization();
  }

  /// Verify navigation functionality
  Future<void> _verifyNavigationFunctionality() async {
    logAction('Verifying navigation functionality');

    // Test each tab is accessible (without full navigation)
    final tabs = ['overview', 'hotels', 'favorites', 'account'];

    for (final tab in tabs) {
      try {
        verifyNavigationTab(tab);
        logAction('✅ $tab tab is functional');
      } catch (e) {
        logError('Navigation tab not functional: $tab', e);
        rethrow;
      }
    }

    logSuccess('Navigation functionality verified');
  }

  // =============================================================================
  // ENHANCED NAVIGATION WORKFLOWS
  // =============================================================================

  /// Navigate through all tabs with comprehensive validation
  Future<void> navigateThroughAllTabs() async {
    logAction('Navigating through all tabs with enhanced validation');

    try {
      final navigationSteps = [
        {'method': navigateToOverview, 'name': 'Overview'},
        {'method': navigateToHotels, 'name': 'Hotels'},
        {'method': navigateToFavorites, 'name': 'Favorites'},
        {'method': navigateToAccount, 'name': 'Account'},
      ];

      for (int i = 0; i < navigationSteps.length; i++) {
        final step = navigationSteps[i];
        final method = step['method'] as Future<void> Function();
        final name = step['name'] as String;

        logAction(
            'Step ${i + 1}/${navigationSteps.length}: Navigating to $name');

        await method();
        await $.pump(const Duration(milliseconds: 600));

        // Verify we're still on dashboard
        verifyNavigationBarVisible();

        logSuccess('Successfully completed navigation step to $name');
      }

      await takePageScreenshot('all_tabs_navigation_complete');
      logSuccess('Navigation through all tabs completed successfully');
    } catch (e) {
      logError('Navigation through all tabs failed', e);
      await takeErrorScreenshot('all_tabs_navigation_failed');
      rethrow;
    }
  }

  /// Verify navigation is working correctly with comprehensive testing
  Future<void> verifyNavigationWorking() async {
    logAction('Verifying navigation is working with comprehensive testing');

    try {
      // Test navigation sequence with validation
      final navigationSequence = [
        {
          'method': navigateToHotels,
          'name': 'Hotels',
          'expectedKey': 'hotels_scaffold'
        },
        {
          'method': navigateToFavorites,
          'name': 'Favorites',
          'expectedKey': 'favorites_scaffold'
        },
        {
          'method': navigateToAccount,
          'name': 'Account',
          'expectedKey': 'account_scaffold'
        },
        {
          'method': navigateToOverview,
          'name': 'Overview',
          'expectedKey': 'overview_scaffold'
        },
      ];

      for (final nav in navigationSequence) {
        final method = nav['method'] as Future<void> Function();
        final name = nav['name'] as String;
        final expectedKey = nav['expectedKey'] as String;

        logAction('Testing navigation to $name');

        await method();
        await $.pump(const Duration(seconds: 1));

        // Verify we reached the expected page
        expect(isElementVisible(expectedKey), isTrue,
            reason: 'Should be on $name page after navigation');

        // Verify navigation bar is still accessible
        verifyNavigationBarVisible();

        logSuccess('Navigation to $name verified successfully');
      }

      await takePageScreenshot('navigation_verification_complete');
      logSuccess('Navigation verification completed successfully');
    } catch (e) {
      logError('Navigation verification failed', e);
      await takeErrorScreenshot('navigation_verification_failed');
      rethrow;
    }
  }

  /// Test rapid navigation for stress testing
  Future<void> testRapidNavigation({int cycles = 2}) async {
    logAction('Testing rapid navigation for $cycles cycles');

    try {
      for (int cycle = 1; cycle <= cycles; cycle++) {
        logAction('Rapid navigation cycle $cycle/$cycles');

        // Quick navigation sequence
        await navigateToHotels();
        await $.pump(const Duration(milliseconds: 200));

        await navigateToFavorites();
        await $.pump(const Duration(milliseconds: 200));

        await navigateToAccount();
        await $.pump(const Duration(milliseconds: 200));

        await navigateToOverview();
        await $.pump(const Duration(milliseconds: 200));

        // Verify dashboard is still stable after rapid navigation
        verifyNavigationBarVisible();

        logAction('Rapid navigation cycle $cycle completed');
      }

      await takePageScreenshot('rapid_navigation_test_complete');
      logSuccess('Rapid navigation test completed successfully');
    } catch (e) {
      logError('Rapid navigation test failed', e);
      await takeErrorScreenshot('rapid_navigation_failed');
      rethrow;
    }
  }

  // =============================================================================
  // ENHANCED SCREENSHOT AND DOCUMENTATION
  // =============================================================================

  /// Take comprehensive navigation screenshots with context
  Future<void> takeNavigationScreenshots() async {
    logAction('Taking comprehensive navigation screenshots');

    try {
      final screenshotTasks = [
        {'method': navigateToOverview, 'name': 'overview_tab'},
        {'method': navigateToHotels, 'name': 'hotels_tab'},
        {'method': navigateToFavorites, 'name': 'favorites_tab'},
        {'method': navigateToAccount, 'name': 'account_tab'},
      ];

      for (final task in screenshotTasks) {
        final method = task['method'] as Future<void> Function();
        final name = task['name'] as String;

        await method();
        await $.pump(const Duration(milliseconds: 500));
        await takePageScreenshot(name);

        logAction('Screenshot captured: $name');
      }

      // Return to overview for clean final state
      await navigateToOverview();
      await takePageScreenshot('navigation_screenshots_complete');

      logSuccess('Navigation screenshots completed successfully');
    } catch (e) {
      logError('Navigation screenshots failed', e);
      await takeErrorScreenshot('navigation_screenshots_failed');
    }
  }

  // =============================================================================
  // PERFORMANCE AND RELIABILITY TESTING
  // =============================================================================

  /// Measure navigation performance across tabs
  Future<NavigationPerformanceResult> measureNavigationPerformance(
      {int iterations = 3}) async {
    logAction('Measuring navigation performance over $iterations iterations');

    try {
      final performanceData = <NavigationTiming>[];

      for (int i = 1; i <= iterations; i++) {
        logAction('Performance measurement iteration $i/$iterations');

        // Measure each navigation
        final overviewTime =
            await _measureSingleNavigation('Overview', navigateToOverview);
        final hotelsTime =
            await _measureSingleNavigation('Hotels', navigateToHotels);
        final favoritesTime =
            await _measureSingleNavigation('Favorites', navigateToFavorites);
        final accountTime =
            await _measureSingleNavigation('Account', navigateToAccount);

        performanceData.add(NavigationTiming(
          iteration: i,
          overviewMs: overviewTime,
          hotelsMs: hotelsTime,
          favoritesMs: favoritesTime,
          accountMs: accountTime,
        ));

        // Brief pause between iterations
        await $.pump(const Duration(milliseconds: 500));
      }

      final result = NavigationPerformanceResult(
        iterations: iterations,
        timings: performanceData,
      );

      logSuccess(
          'Navigation performance measurement completed: ${result.summary}');
      return result;
    } catch (e) {
      logError('Navigation performance measurement failed', e);
      return NavigationPerformanceResult.failed();
    }
  }

  /// Measure single navigation timing
  Future<int> _measureSingleNavigation(
      String name, Future<void> Function() navigationMethod) async {
    return await measurePerformance(
      'Navigate to $name',
      () async {
        await navigationMethod();
        // Ensure navigation is complete
        await $.pump(const Duration(milliseconds: 100));
      },
    ).then((duration) => duration.inMilliseconds);
  }

  /// Test navigation stability over time
  Future<void> testNavigationStability({
    Duration testDuration = const Duration(seconds: 10),
  }) async {
    logAction(
        'Testing navigation stability for ${testDuration.inSeconds} seconds');

    try {
      final endTime = DateTime.now().add(testDuration);
      int navigationCount = 0;

      while (DateTime.now().isBefore(endTime)) {
        // Perform navigation cycle
        await navigateToHotels();
        await navigateToFavorites();
        await navigateToAccount();
        await navigateToOverview();

        navigationCount += 4;

        // Verify dashboard is still stable
        verifyNavigationBarVisible();
        verifyAllTabsVisible();

        await $.pump(const Duration(milliseconds: 200));
      }

      await takePageScreenshot('navigation_stability_test_complete');
      logSuccess(
          'Navigation stability test completed: $navigationCount navigations');
    } catch (e) {
      logError('Navigation stability test failed', e);
      await takeErrorScreenshot('navigation_stability_failed');
      rethrow;
    }
  }

  // =============================================================================
  // COMPREHENSIVE DASHBOARD HEALTH CHECK
  // =============================================================================

  /// Perform comprehensive dashboard health check
  Future<void> performDashboardHealthCheck() async {
    logAction('Performing comprehensive dashboard health check');

    try {
      // Structure validation
      await verifyDashboardLoaded();

      // Navigation functionality validation
      await verifyNavigationWorking();

      // Performance validation
      final performance = await measureNavigationPerformance(iterations: 2);
      expect(performance.isHealthy, isTrue,
          reason: 'Navigation performance should be within acceptable limits');

      // Stability validation
      await testNavigationStability(testDuration: const Duration(seconds: 5));

      // Use AppLocators comprehensive health check
      AppLocators.performComprehensiveHealthCheck();

      await takePageScreenshot('dashboard_health_check_complete');
      logSuccess('Dashboard health check completed successfully');
    } catch (e) {
      logError('Dashboard health check failed', e);
      await takeErrorScreenshot('dashboard_health_check_failed');
      rethrow;
    }
  }

  /// Generate dashboard status report
  Future<DashboardStatusReport> generateStatusReport() async {
    logAction('Generating comprehensive dashboard status report');

    try {
      // Collect dashboard information
      final isLoaded = isCurrentPage();
      final hasNavBar = isElementVisible(AppLocators.navigationBar);
      final tabsVisible = _countVisibleTabs();
      final performance = await measureNavigationPerformance(iterations: 1);

      final report = DashboardStatusReport(
        isLoaded: isLoaded,
        hasNavigationBar: hasNavBar,
        visibleTabsCount: tabsVisible,
        performance: performance,
        timestamp: DateTime.now(),
      );

      logSuccess('Dashboard status report generated: ${report.summary}');
      return report;
    } catch (e) {
      logError('Dashboard status report generation failed', e);
      return DashboardStatusReport.failed();
    }
  }

  /// Count visible navigation tabs
  int _countVisibleTabs() {
    final tabs = [
      AppLocators.overviewTab,
      AppLocators.hotelsTab,
      AppLocators.favoritesTab,
      AppLocators.accountTab,
    ];

    return tabs.where((tab) => isElementVisible(tab)).length;
  }

  /// Ensure the dashboard page is active and ready for interaction
  Future<void> ensurePageIsActive() async {
    logAction('Ensuring dashboard page is active');

    try {
      if (!isCurrentPage()) {
        await verifyPageIsLoaded();
      }
      await waitForPageStabilization();
      logSuccess('Dashboard page is active');
    } catch (e) {
      logError('Failed to ensure dashboard page is active', e);
      await takeErrorScreenshot('page_activation_failed');
      rethrow;
    }
  }

  /// Measure performance of an operation with timing
  Future<Duration> measurePerformance(
    String operationName,
    Future<void> Function() operation,
  ) async {
    logAction('Measuring performance of: $operationName');

    final stopwatch = Stopwatch()..start();
    try {
      await operation();
      stopwatch.stop();

      final duration = stopwatch.elapsed;
      logSuccess('$operationName completed in ${duration.inMilliseconds}ms');
      return duration;
    } catch (e) {
      stopwatch.stop();
      logError(
          '$operationName failed after ${stopwatch.elapsed.inMilliseconds}ms',
          e);
      rethrow;
    }
  }
}

// =============================================================================
// SUPPORTING DATA CLASSES FOR ENHANCED DASHBOARD TESTING
// =============================================================================

/// Navigation timing data for performance analysis
class NavigationTiming {
  final int iteration;
  final int overviewMs;
  final int hotelsMs;
  final int favoritesMs;
  final int accountMs;

  NavigationTiming({
    required this.iteration,
    required this.overviewMs,
    required this.hotelsMs,
    required this.favoritesMs,
    required this.accountMs,
  });

  int get totalMs => overviewMs + hotelsMs + favoritesMs + accountMs;
  double get averageMs => totalMs / 4.0;

  @override
  String toString() {
    return 'NavigationTiming(iteration: $iteration, avg: ${averageMs.toStringAsFixed(1)}ms, total: ${totalMs}ms)';
  }
}

/// Navigation performance analysis result
class NavigationPerformanceResult {
  final int iterations;
  final List<NavigationTiming> timings;
  final bool isSuccessful;

  NavigationPerformanceResult({
    required this.iterations,
    required this.timings,
    this.isSuccessful = true,
  });

  NavigationPerformanceResult.failed()
      : iterations = 0,
        timings = [],
        isSuccessful = false;

  double get averageNavigationTime {
    if (timings.isEmpty) return 0.0;
    return timings.map((t) => t.averageMs).reduce((a, b) => a + b) /
        timings.length;
  }

  bool get isHealthy =>
      isSuccessful && averageNavigationTime < 2000; // Under 2 seconds

  String get summary {
    if (!isSuccessful) return 'Failed';
    return 'Avg: ${averageNavigationTime.toStringAsFixed(1)}ms, Healthy: $isHealthy';
  }

  @override
  String toString() {
    return 'NavigationPerformance(iterations: $iterations, successful: $isSuccessful, ${summary})';
  }
}

/// Comprehensive dashboard status report
class DashboardStatusReport {
  final bool isLoaded;
  final bool hasNavigationBar;
  final int visibleTabsCount;
  final NavigationPerformanceResult performance;
  final DateTime timestamp;
  final bool isSuccessful;

  DashboardStatusReport({
    required this.isLoaded,
    required this.hasNavigationBar,
    required this.visibleTabsCount,
    required this.performance,
    required this.timestamp,
    this.isSuccessful = true,
  });

  DashboardStatusReport.failed()
      : isLoaded = false,
        hasNavigationBar = false,
        visibleTabsCount = 0,
        performance = NavigationPerformanceResult.failed(),
        timestamp = DateTime.now(),
        isSuccessful = false;

  bool get isHealthy =>
      isSuccessful &&
      isLoaded &&
      hasNavigationBar &&
      visibleTabsCount == 4 &&
      performance.isHealthy;

  String get summary {
    if (!isSuccessful) return 'Dashboard Status: Failed';
    return 'Dashboard Status: ${isHealthy ? 'Healthy' : 'Issues'} - Tabs: $visibleTabsCount/4, ${performance.summary}';
  }

  @override
  String toString() {
    return 'DashboardStatus(loaded: $isLoaded, navBar: $hasNavigationBar, tabs: $visibleTabsCount, healthy: $isHealthy)';
  }
}
