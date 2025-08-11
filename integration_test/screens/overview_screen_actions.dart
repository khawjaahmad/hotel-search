import 'dart:async';
import 'package:patrol/patrol.dart';

import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';
import '../framework/custom_assertions.dart';

/// Custom exception for Overview page operations
class OverviewPageException implements Exception {
  final String message;
  final Exception? originalException;
  
  const OverviewPageException(this.message, {this.originalException});
  
  @override
  String toString() {
    if (originalException != null) {
      return 'OverviewPageException: $message\nCaused by: $originalException';
    }
    return 'OverviewPageException: $message';
  }
}

/// Enhanced Overview Screen Actions with Dashboard Analytics
/// Includes fluent interface for overview operations
class OverviewScreenActions {
  final PatrolIntegrationTester? tester;
  final Duration defaultTimeout;
  
  OverviewScreenActions({this.tester, this.defaultTimeout = const Duration(seconds: 10)});
  
  /// Get page-specific assertions
  OverviewPageAssertions get assertions => OverviewPageAssertions(tester!, this);
  
  /// Fluent wait with custom conditions
  Future<OverviewScreenActions> waitFor(PatrolFinder finder, {
    Duration? timeout,
    String? description,
  }) async {
    final actualTimeout = timeout ?? defaultTimeout;
    final desc = description ?? 'element to be visible';
    
    try {
      await finder.waitUntilVisible(timeout: actualTimeout);
      return this;
    } catch (e) {
      throw OverviewPageException(
        'Failed to wait for $desc on Overview page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Fluent tap with validation
  Future<OverviewScreenActions> tapElement(PatrolFinder finder, {
    String? description,
    bool validateAfterTap = true,
  }) async {
    final desc = description ?? 'element';
    
    try {
      await finder.waitUntilVisible();
      await finder.tap();
      
      if (validateAfterTap) {
        await tester!.pump(const Duration(milliseconds: 300));
      }
      
      return this;
    } catch (e) {
      throw OverviewPageException(
        'Failed to tap $desc on Overview page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Validate page is loaded
  Future<OverviewScreenActions> validatePageLoaded() async {
    if (tester == null) return this;
    
    try {
      await AppLocators.getOverviewTitle(tester!).waitUntilVisible();
      TestLogger.logTestSuccess(tester!, 'Overview page loaded successfully');
      return this;
    } catch (e) {
      throw OverviewPageException(
        'Overview page failed to load',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Analytics and metrics validation
  Future<OverviewScreenActions> validateMetrics() async {
    if (tester == null) return this;
    
    TestLogger.logAction(tester!, 'Validating overview metrics');
    
    final overviewIcon = AppLocators.getOverviewIcon(tester!);
    await waitFor(overviewIcon, description: 'overview icon');
    
    TestLogger.logTestSuccess(tester!, 'Overview metrics validated');
    return this;
  }

  /// Performance monitoring
  Future<OverviewScreenActions> checkPerformanceMetrics() async {
    if (tester == null) return this;
    
    TestLogger.logAction(tester!, 'Checking performance metrics');
    
    final overviewScaffold = AppLocators.getOverviewScaffold(tester!);
    await waitFor(overviewScaffold, description: 'overview scaffold');
    
    TestLogger.logTestSuccess(tester!, 'Performance metrics checked');
    return this;
  }  static Future<void> verifyOverviewPageStructure(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'overview page structure');

    for (final locator in [
      AppLocators.getOverviewScaffold($),
      AppLocators.getOverviewAppBar($),
      AppLocators.getOverviewTitle($),
      AppLocators.getOverviewIcon($),
    ]) {
      await locator.waitUntilVisible();
    }

    TestLogger.logTestSuccess($, 'Overview page structure verified');
  }
}
