import 'dart:async';
import 'package:patrol/patrol.dart';

import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';
import '../framework/custom_assertions.dart';

/// Custom exception for Account page operations
class AccountPageException implements Exception {
  final String message;
  final Exception? originalException;
  
  const AccountPageException(this.message, {this.originalException});
  
  @override
  String toString() {
    if (originalException != null) {
      return 'AccountPageException: $message\nCaused by: $originalException';
    }
    return 'AccountPageException: $message';
  }
}

/// Enhanced Account Screen Actions with User Management
/// Includes fluent interface for account operations
class AccountScreenActions {
  final PatrolIntegrationTester? tester;
  final Duration defaultTimeout;
  
  AccountScreenActions({this.tester, this.defaultTimeout = const Duration(seconds: 10)});
  
  /// Get page-specific assertions
  AccountPageAssertions get assertions => AccountPageAssertions(tester!, this);
  
  /// Fluent wait with custom conditions
  Future<AccountScreenActions> waitFor(PatrolFinder finder, {
    Duration? timeout,
    String? description,
  }) async {
    final actualTimeout = timeout ?? defaultTimeout;
    final desc = description ?? 'element to be visible';
    
    try {
      await finder.waitUntilVisible(timeout: actualTimeout);
      return this;
    } catch (e) {
      throw AccountPageException(
        'Failed to wait for $desc on Account page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Fluent tap with validation
  Future<AccountScreenActions> tapElement(PatrolFinder finder, {
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
      throw AccountPageException(
        'Failed to tap $desc on Account page',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Validate page is loaded
  Future<AccountScreenActions> validatePageLoaded() async {
    if (tester == null) return this;
    
    try {
      await AppLocators.getAccountTitle(tester!).waitUntilVisible();
      TestLogger.logTestSuccess(tester!, 'Account page loaded successfully');
      return this;
    } catch (e) {
      throw AccountPageException(
        'Account page failed to load',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Enhanced profile management
  Future<AccountScreenActions> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (tester == null) return this;
    
    TestLogger.logAction(tester!, 'Updating user profile');
    
    // Note: Profile fields would need to be added to AppLocators
    // For now, using account scaffold as placeholder
    final accountScaffold = AppLocators.getAccountScaffold(tester!);
    await waitFor(accountScaffold, description: 'account scaffold');
    
    TestLogger.logTestSuccess(tester!, 'Profile update functionality ready');
    return this;
  }

  /// Settings management
  Future<AccountScreenActions> toggleNotifications(bool enabled) async {
    if (tester == null) return this;
    
    TestLogger.logAction(tester!, 'Toggling notifications: $enabled');
    
    // Note: Notification toggle would need to be added to AppLocators
    // For now, using account icon as placeholder
    final accountIcon = AppLocators.getAccountIcon(tester!);
    await waitFor(accountIcon, description: 'account icon');
    
    TestLogger.logTestSuccess(tester!, 'Notification toggle functionality ready');
    return this;
  }  static Future<void> verifyAccountPageStructure(
      PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'account page structure');

    final locators = [
      AppLocators.getAccountScaffold($),
      AppLocators.getAccountAppBar($),
      AppLocators.getAccountTitle($).containing('Your Account'),
      AppLocators.getAccountIcon($),
    ];

    for (final locator in locators) {
      await locator.waitUntilExists();
    }

    final appBarElements = AppLocators.getAccountAppBar($).evaluate();
    if (appBarElements.length != 1) {
      throw Exception(
          'Expected exactly 1 app bar, found ${appBarElements.length}');
    }

    TestLogger.logTestSuccess($, 'Account page structure verified');
  }
}
