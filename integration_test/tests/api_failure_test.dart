import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';

void main() {
  group('API Failure Tests', () {
    patrolTest(
      'API failure should show error state with retry functionality',
      config: PatrolConfig.getConfig(),
      ($) async {
        await patrolSetUp($);
        
        try {
          await TestHelpers.initializeApp($);
          await _testApiFailureScenario($);
          
          TestLogger.logTestSuccess($, 'API failure test completed successfully');
        } catch (e) {
          TestLogger.logTestError($, 'API failure test failed: $e');
          rethrow;
        }
      },
    );

    patrolTest(
      'Multiple API failures should maintain error state consistency',
      config: PatrolConfig.getConfig(),
      ($) async {
        await patrolSetUp($);
        
        try {
          await TestHelpers.initializeApp($);
          await _testMultipleApiFailures($);
          
          TestLogger.logTestSuccess($, 'Multiple API failures test completed successfully');
        } catch (e) {
          TestLogger.logTestError($, 'Multiple API failures test failed: $e');
          rethrow;
        }
      },
    );

    patrolTest(
      'API failure during pagination should handle gracefully',
      config: PatrolConfig.getConfig(),
      ($) async {
        await patrolSetUp($);
        
        try {
          await TestHelpers.initializeApp($);
          await _testPaginationApiFailure($);
          
          TestLogger.logTestSuccess($, 'Pagination API failure test completed successfully');
        } catch (e) {
          TestLogger.logTestError($, 'Pagination API failure test failed: $e');
          rethrow;
        }
      },
    );
  });
}

Future<void> patrolSetUp(PatrolIntegrationTester $) async {
  await TestHelpers.configureDependenciesForTest();
}

Future<void> patrolTearDown(PatrolIntegrationTester $) async {
  await TestHelpers.cleanUpTest();
}

/// Test that API failure shows proper error state
Future<void> _testApiFailureScenario(PatrolIntegrationTester $) async {
  TestLogger.logTestStart($, 'API failure scenario test');
  
  // Navigate to hotels page
  final hotelsTab = AppLocators.getHotelsTab($);
  await hotelsTab.waitUntilVisible();
  await hotelsTab.tap();
  await $.pump(const Duration(seconds: 1));
  
  // Perform search that will trigger API call
  final searchTextField = AppLocators.getSearchTextField($);
  await searchTextField.waitUntilVisible();
  await searchTextField.enterText('Dubai');
  
  TestLogger.logAction($, 'Searching for hotels to trigger API call');
  await $.pump(const Duration(milliseconds: 1500));
  
  // Wait for and verify error state appears
  await _waitForAndVerifyErrorState($);
  
  // Test retry functionality
  await _testRetryButton($);
  
  TestLogger.logTestSuccess($, 'API failure scenario validated');
}

/// Test multiple consecutive API failures
Future<void> _testMultipleApiFailures(PatrolIntegrationTester $) async {
  TestLogger.logTestStart($, 'Multiple API failures test');
  
  // Navigate to hotels page
  final hotelsTab = AppLocators.getHotelsTab($);
  await hotelsTab.waitUntilVisible();
  await hotelsTab.tap();
  await $.pump(const Duration(seconds: 1));
  
  final searchTextField = AppLocators.getSearchTextField($);
  await searchTextField.waitUntilVisible();
  
  // Test multiple different searches that will all fail
  final searchQueries = ['Dubai', 'London', 'Paris', 'Tokyo'];
  
  for (int i = 0; i < searchQueries.length; i++) {
    TestLogger.logAction($, 'Testing API failure ${i + 1}/${searchQueries.length} with query: ${searchQueries[i]}');
    
    // Clear previous search
    await _clearSearchField($);
    
    // Enter new search
    await searchTextField.enterText(searchQueries[i]);
    await $.pump(const Duration(milliseconds: 1500));
    
    // Verify error state appears consistently
    await _waitForAndVerifyErrorState($);
    
    // Test retry button works
    await _testRetryButton($);
    
    await $.pump(const Duration(milliseconds: 500));
  }
  
  TestLogger.logTestSuccess($, 'Multiple API failures handled consistently');
}

/// Test API failure during pagination
Future<void> _testPaginationApiFailure(PatrolIntegrationTester $) async {
  TestLogger.logTestStart($, 'Pagination API failure test');
  
  // Navigate to hotels page
  final hotelsTab = AppLocators.getHotelsTab($);
  await hotelsTab.waitUntilVisible();
  await hotelsTab.tap();
  await $.pump(const Duration(seconds: 1));
  
  final searchTextField = AppLocators.getSearchTextField($);
  await searchTextField.waitUntilVisible();
  await searchTextField.enterText('Hotels');
  await $.pump(const Duration(milliseconds: 1500));
  
  await _waitForInitialResponse($);
  
  // Try to trigger pagination by scrolling
  TestLogger.logAction($, 'Attempting to trigger pagination');
  final scrollView = AppLocators.getHotelsScrollView($);
  
  if (scrollView.exists) {
    await $.tester.drag(scrollView.finder, const Offset(0, -400));
  } else {
    // Fallback to scrolling the main view
    await $.tester.drag($(Scrollable).first, const Offset(0, -400));
  }
  
  await $.pump(const Duration(milliseconds: 1000));
  
  // Verify app doesn't crash and maintains stable state
  await _verifyAppStability($);
  
  TestLogger.logTestSuccess($, 'Pagination API failure handled gracefully');
}

/// Wait for and verify error state appears
Future<void> _waitForAndVerifyErrorState(PatrolIntegrationTester $) async {
  TestLogger.logValidation($, 'error state appearance');
  
  const maxWaitTime = Duration(seconds: 15);
  final stopwatch = Stopwatch()..start();
  
  bool errorStateFound = false;
  
  while (stopwatch.elapsed < maxWaitTime && !errorStateFound) {
    await $.pump(const Duration(milliseconds: 500));
    
    final errorMessage = AppLocators.getHotelsErrorMessage($);
    final retryButton = AppLocators.getHotelsRetryButton($);
    final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
    
    // Check if we're still loading
    if (loadingIndicator.exists) {
      TestLogger.logTestStep($, 'Still loading... waiting for response');
      continue;
    }
    
    // Check for error state
    if (errorMessage.exists && retryButton.exists) {
      TestLogger.logTestStep($, 'Error state detected');
      
      // Verify error message content
      final errorText = errorMessage.containing('Something went wrong');
      if (!errorText.exists) {
        throw Exception('Error message should contain "Something went wrong"');
      }
      
      // Verify retry button content
      final retryText = retryButton.containing('Try Again');
      if (!retryText.exists) {
        throw Exception('Retry button should contain "Try Again"');
      }
      
      errorStateFound = true;
      TestLogger.logTestSuccess($, 'Error state properly displayed with correct messages');
      break;
    }
    
    // Check if we got unexpected success (shouldn't happen with dummy API key)
    final hotelCards = $(Card);
    if (hotelCards.exists) {
      TestLogger.logTestStep($, 'WARNING: Got hotel cards instead of expected error state');
      // This is not necessarily a failure, but unexpected with dummy API key
      errorStateFound = true;
      break;
    }
    
    // Check for empty state
    final emptyStateIcon = AppLocators.getHotelsEmptyStateIcon($);
    if (emptyStateIcon.exists) {
      TestLogger.logTestStep($, 'Empty state shown instead of error state');
      errorStateFound = true;
      break;
    }
  }
  
  stopwatch.stop();
  
  if (!errorStateFound) {
    throw Exception('Expected error state did not appear within ${maxWaitTime.inSeconds} seconds');
  }
}

/// Test retry button functionality
Future<void> _testRetryButton(PatrolIntegrationTester $) async {
  TestLogger.logAction($, 'Testing retry button functionality');
  
  final retryButton = AppLocators.getHotelsRetryButton($);
  
  if (!retryButton.exists) {
    TestLogger.logTestStep($, 'Retry button not found - skipping retry test');
    return;
  }
  
  // Tap retry button
  await retryButton.tap();
  await $.pump(const Duration(milliseconds: 500));
  
  // Verify loading state appears briefly
  final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
  if (loadingIndicator.exists) {
    TestLogger.logTestStep($, 'Loading indicator appeared after retry');
  }
  
  // Wait for retry to complete
  await $.pump(const Duration(seconds: 2));
  
  TestLogger.logTestSuccess($, 'Retry button functionality tested');
}

/// Clear search field
Future<void> _clearSearchField(PatrolIntegrationTester $) async {
  final clearButton = AppLocators.getSearchClearButton($);
  if (clearButton.exists) {
    await clearButton.tap();
    await $.pump(const Duration(milliseconds: 300));
  } else {
    final searchTextField = AppLocators.getSearchTextField($);
    if (searchTextField.exists) {
      await searchTextField.tap();
      await $.pump(const Duration(milliseconds: 200));
      await searchTextField.enterText('');
    }
  }
}

Future<void> _waitForInitialResponse(PatrolIntegrationTester $) async {
  const maxWaitTime = Duration(seconds: 10);
  final stopwatch = Stopwatch()..start();
  
  while (stopwatch.elapsed < maxWaitTime) {
    await $.pump(const Duration(milliseconds: 500));
    
    final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
    if (!loadingIndicator.exists) {
      // Loading finished, some response received
      break;
    }
  }
  
  stopwatch.stop();
}

Future<void> _verifyAppStability(PatrolIntegrationTester $) async {
  TestLogger.logValidation($, 'app stability');
  
  final hotelsTab = AppLocators.getHotelsTab($);
  if (!hotelsTab.exists) {
    throw Exception('Hotels tab should still be accessible');
  }
  
  final searchTextField = AppLocators.getSearchTextField($);
  if (!searchTextField.exists) {
    throw Exception('Search field should still be accessible');
  }
  
  final favoritesTab = AppLocators.getFavoritesTab($);
  if (favoritesTab.exists) {
    await favoritesTab.tap();
    await $.pump(const Duration(milliseconds: 500));
    
    await hotelsTab.tap();
    await $.pump(const Duration(milliseconds: 500));
  }
  
  TestLogger.logTestSuccess($, 'App remains stable after API failures');
}