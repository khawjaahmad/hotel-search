# ✍️ Writing Tests Guide - Patrol Framework

Comprehensive guide for writing effective tests using Patrol framework in the Hotel Booking QA Automation project.

## 📚 Table of Contents

1. [Patrol Test Structure](#patrol-test-structure)
2. [Test Organization](#test-organization)
3. [Writing Integration Tests](#writing-integration-tests)
4. [Screen Action Objects](#screen-action-objects)
5. [Element Locators](#element-locators)
6. [Test Utilities](#test-utilities)
7. [Best Practices](#best-practices)
8. [Common Patterns](#common-patterns)
9. [Debugging Tests](#debugging-tests)

## 🎯 Patrol Test Structure

### Basic Test Template

```dart
import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/feature_screen_actions.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    'Feature functionality test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Feature Test');
      await TestHelpers.initializeApp($);
      
      // Test implementation
      await FeatureScreenActions.performAction($);
      
      TestLogger.logTestSuccess($, 'Favorites functionality verified');
    },
  );
}
```

### Test Pattern Breakdown

#### 1. Initialization Pattern
```dart
// Always start tests with app initialization
await TestHelpers.initializeApp($);

// Log major test phases
TestLogger.logTestStart($, 'Test Name');
TestLogger.logNavigation($, 'target page');
TestLogger.logAction($, 'performing action');
TestLogger.logValidation($, 'expected result');
TestLogger.logTestSuccess($, 'completion message');
```

#### 2. Navigation Pattern
```dart
// Use helper for consistent navigation
await TestHelpers.navigateToPage($, 'hotels');
await TestHelpers.navigateToPage($, 'favorites');
await TestHelpers.navigateToPage($, 'account');

// Verify navigation completed
await HotelsScreenActions.verifyHotelsPageStructure($);
```

#### 3. Action Pattern
```dart
// Delegate actions to screen action objects
await HotelsScreenActions.performSearchTest($, 'Dubai');
await HotelsScreenActions.favoriteRandomHotels($);
await HotelsScreenActions.validateHotelCards($);
```

## 🎬 Screen Action Objects

Screen Action Objects encapsulate page-specific operations and validations.

### Creating Screen Actions

```dart
// integration_test/screens/hotels_screen_actions.dart
import 'package:patrol/patrol.dart';
import '../helpers/test_logger.dart';
import '../locators/app_locators.dart';

class HotelsScreenActions {
  
  static Future<void> navigateToHotelsPage(PatrolIntegrationTester $) async {
    TestLogger.logNavigation($, 'Hotels page');
    
    final hotelsTab = AppLocators.getHotelsTab($);
    await hotelsTab.waitUntilVisible();
    await hotelsTab.tap();
    
    await verifyHotelsPageStructure($);
  }
  
  static Future<void> verifyHotelsPageStructure(PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'Hotels page structure');
    
    // Verify main page elements
    final scaffold = AppLocators.getHotelsScaffold($);
    await scaffold.waitUntilExists();
    
    final appBar = AppLocators.getHotelsAppBar($);
    await appBar.waitUntilExists();
    
    final searchField = AppLocators.getHotelsSearchField($);
    await searchField.waitUntilExists();
    
    TestLogger.logTestSuccess($, 'Hotels page structure verified');
  }
  
  static Future<void> performSearchTest(
    PatrolIntegrationTester $, 
    String searchQuery
  ) async {
    TestLogger.logAction($, 'Testing search functionality with query: "$searchQuery"');
    
    final searchTextField = AppLocators.getSearchTextField($);
    await searchTextField.waitUntilVisible();
    await searchTextField.tap();
    
    await searchTextField.enterText(searchQuery);
    
    // Wait for search to process
    await $.pump(const Duration(milliseconds: 1500));
    
    await _waitForSearchResults($);
    
    TestLogger.logTestSuccess($, 'Search functionality test completed');
  }
  
  static Future<void> _waitForSearchResults(PatrolIntegrationTester $) async {
    TestLogger.logWaiting($, 'search results to populate');
    
    const maxWaitTime = Duration(seconds: 15);
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < maxWaitTime) {
      await $.pump(const Duration(milliseconds: 500));
      
      final loadingIndicator = AppLocators.getHotelsLoadingIndicator($);
      final paginationLoading = AppLocators.getHotelsPaginationLoading($);
      
      final isLoading = loadingIndicator.exists || paginationLoading.exists;
      
      if (!isLoading) {
        final hasCards = $(Card).exists;
        final hasError = AppLocators.getHotelsErrorMessage($).exists;
        final hasEmpty = AppLocators.getHotelsEmptyStateIcon($).exists;
        
        if (hasCards) {
          TestLogger.logTestSuccess($, 'Search results populated - hotel cards found');
          await validateHotelCards($);
          return;
        } else if (hasError) {
          TestLogger.logTestStep($, 'Search resulted in error state');
          return;
        } else if (hasEmpty) {
          TestLogger.logTestStep($, 'Search resulted in empty state');
          return;
        }
      }
    }
    
    stopwatch.stop();
    throw Exception('Search results did not populate within timeout');
  }
  
  static Future<void> validateHotelCards(PatrolIntegrationTester $) async {
    TestLogger.logValidation($, 'hotel cards information');
    
    final cardFinder = $(Card);
    final cards = cardFinder.evaluate();
    
    if (cards.isEmpty) {
      throw Exception('Should have at least one hotel card');
    }
    
    final cardsToValidate = cards.length > 3 ? 3 : cards.length;
    
    for (int i = 0; i < cardsToValidate; i++) {
      await _validateSingleHotelCard($, i);
    }
    
    TestLogger.logTestSuccess($, 'Hotel cards validation completed');
  }
  
  static Future<void> _validateSingleHotelCard(
    PatrolIntegrationTester $, 
    int cardIndex
  ) async {
    TestLogger.logValidation($, 'hotel card $cardIndex structure');
    
    final cardWidget = $(Card).at(cardIndex);
    
    if (!cardWidget.exists) {
      throw Exception('Hotel card $cardIndex should exist');
    }
    
    await cardWidget.waitUntilExists();
    
    TestLogger.logTestSuccess($, 'Hotel card $cardIndex validated');
  }
}
```

### Screen Action Patterns

#### 1. Verification Methods
```dart
static Future<void> verifyPageStructure(PatrolIntegrationTester $) async {
  // Verify essential page elements exist
  await AppLocators.getPageScaffold($).waitUntilExists();
  await AppLocators.getPageAppBar($).waitUntilExists();
  // Additional verifications...
}
```

#### 2. Action Methods
```dart
static Future<void> performAction(PatrolIntegrationTester $, String param) async {
  TestLogger.logAction($, 'Performing action with: $param');
  
  // Find element
  final element = AppLocators.getTargetElement($);
  await element.waitUntilVisible();
  
  // Perform action
  await element.tap();
  // or
  await element.enterText(param);
  
  // Wait for response
  await $.pump(const Duration(milliseconds: 500));
  
  TestLogger.logTestSuccess($, 'Action completed');
}
```

#### 3. Validation Methods
```dart
static Future<void> validateResults(PatrolIntegrationTester $) async {
  TestLogger.logValidation($, 'expected results');
  
  // Check for expected elements
  final resultElement = AppLocators.getResultElement($);
  if (!resultElement.exists) {
    throw Exception('Expected result not found');
  }
  
  // Additional validations...
  TestLogger.logTestSuccess($, 'Validation completed');
}
```

## 🎯 Element Locators

Centralized element location management using AppLocators.

### Locator Structure

```dart
// integration_test/locators/app_locators.dart
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

class AppLocators {
  AppLocators._();

  // Dashboard Locators
  static PatrolFinder getDashboardScaffold(PatrolIntegrationTester $) {
    return $(#dashboard_scaffold);
  }

  static PatrolFinder getNavigationBar(PatrolIntegrationTester $) {
    return $(#navigation_bar);
  }

  // Tab Navigation
  static PatrolFinder getOverviewTab(PatrolIntegrationTester $) {
    return $(#navigation_overview_tab);
  }

  static PatrolFinder getHotelsTab(PatrolIntegrationTester $) {
    return $(#navigation_hotels_tab);
  }

  // Hotels Page Locators
  static PatrolFinder getHotelsScaffold(PatrolIntegrationTester $) {
    return $(#hotels_scaffold);
  }

  static PatrolFinder getHotelsSearchField(PatrolIntegrationTester $) {
    return $(#hotels_search_field);
  }

  static PatrolFinder getSearchTextField(PatrolIntegrationTester $) {
    return $(#search_text_field);
  }

  // Dynamic Locators
  static PatrolFinder getHotelCard(PatrolIntegrationTester $, String hotelId) {
    return $(#hotel_card_$hotelId);
  }

  static PatrolFinder getHotelFavoriteButton(
    PatrolIntegrationTester $, 
    String hotelId
  ) {
    return $(#hotel_favorite_button_$hotelId);
  }

  // Utility Methods
  static PatrolFinder getNavigationTab(
    PatrolIntegrationTester $, 
    String tabName
  ) {
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

  // Smart Interaction Methods
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
}
```

### Locator Best Practices

#### 1. Use Semantic Keys
```dart
// In Flutter widgets
Widget build(BuildContext context) {
  return Scaffold(
    key: const Key('hotels_scaffold'),  // Semantic key
    appBar: AppBar(
      key: const Key('hotels_app_bar'),
      title: Text('Hotels'),
    ),
    // ...
  );
}

// In locators
static PatrolFinder getHotelsScaffold(PatrolIntegrationTester $) {
  return $(#hotels_scaffold);  // Use symbol syntax for keys
}
```

#### 2. Dynamic Locators
```dart
// For elements with dynamic IDs
static PatrolFinder getHotelCard(PatrolIntegrationTester $, String hotelId) {
  return $(#hotel_card_$hotelId);
}

// Usage
final hotelId = '40.7128,-74.0060';  // lat,lng coordinates
final cardFinder = AppLocators.getHotelCard($, hotelId);
```

#### 3. Fallback Strategies
```dart
static PatrolFinder getSubmitButton(PatrolIntegrationTester $) {
  // Try key first
  final keyFinder = $(#submit_button);
  if (keyFinder.exists) return keyFinder;
  
  // Fall back to text
  final textFinder = $('Submit');
  if (textFinder.exists) return textFinder;
  
  // Fall back to type
  return $(ElevatedButton);
}
```

## 🛠️ Test Utilities

### Test Helpers

```dart
// integration_test/helpers/test_helpers.dart
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hotel_booking/core/di/injectable.dart';
import 'package:hotel_booking/main.dart' as app;
import 'package:patrol/patrol.dart';

class TestHelpers {
  static bool _dependenciesConfigured = false;
  
  static Future<void> initializeApp(PatrolIntegrationTester $) async {
    try {
      await configureDependenciesForTest();
      
      await $.pumpWidgetAndSettle(
        app.App(),
        duration: const Duration(seconds: 5),
      );
      
      await $.pump(const Duration(milliseconds: 500));
    } catch (e) {
      _dependenciesConfigured = false;
      rethrow;
    }
  }
  
  static Future<void> navigateToPage(
    PatrolIntegrationTester $,
    String tabName, {
    String? description,
  }) async {
    try {
      TestLogger.logNavigation($, tabName);
      final tabFinder = AppLocators.getNavigationTab($, tabName);
      
      await tabFinder.waitUntilVisible();
      await tabFinder.tap();
      
      await $.pump(const Duration(milliseconds: 500));
      await $.pumpAndSettle();
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<void> cleanUpTest() async {
    try {
      Hive.closeAllBoxes();
      
      if (_dependenciesConfigured) {
        await GetIt.instance.reset();
        _dependenciesConfigured = false;
      }
    } catch (e) {
      // Intentionally empty - cleanup errors should not fail tests
    }
  }
  
  static void resetTestState() {
    _dependenciesConfigured = false;
  }
}
```

### Test Logger

```dart
// integration_test/helpers/test_logger.dart
import 'package:patrol/patrol.dart';

class TestLogger {
  static void logTestStart(PatrolIntegrationTester $, String testName) {
    $.log('🚀 Starting: $testName');
  }

  static void logTestStep(PatrolIntegrationTester $, String step) {
    $.log('📋 $step');
  }

  static void logTestSuccess(PatrolIntegrationTester $, String message) {
    $.log('✅ $message');
  }

  static void logTestError(PatrolIntegrationTester $, String error) {
    $.log('❌ $error');
  }

  static void logNavigation(PatrolIntegrationTester $, String destination) {
    $.log('🧭 Navigating to: $destination');
  }

  static void logAction(PatrolIntegrationTester $, String action) {
    $.log('⚡ $action');
  }

  static void logValidation(PatrolIntegrationTester $, String validation) {
    $.log('🔍 Validating: $validation');
  }

  static void logWaiting(PatrolIntegrationTester $, String waitingFor) {
    $.log('⏳ Waiting for: $waitingFor');
  }
}
```

## ✅ Best Practices

### 1. Test Structure
```dart
// ✅ Good: Clear test structure
patrolTest('Hotels search displays results when query is valid', ($) async {
  // Arrange
  await TestHelpers.initializeApp($);
  await TestHelpers.navigateToPage($, 'hotels');
  
  // Act
  await HotelsScreenActions.performSearchTest($, 'Dubai');
  
  // Assert
  await HotelsScreenActions.validateHotelCards($);
});

// ❌ Bad: Unclear test purpose
patrolTest('Test hotels', ($) async {
  // Multiple actions without clear purpose
});
```

### 2. Wait Strategies
```dart
// ✅ Good: Explicit waits with timeouts
await AppLocators.getHotelCard($, hotelId).waitUntilVisible();

// ✅ Good: Smart waiting with conditions
while (stopwatch.elapsed < maxWaitTime) {
  await $.pump(const Duration(milliseconds: 500));
  if (AppLocators.getSearchResults($).exists) break;
}

// ❌ Bad: Fixed delays
await $.pump(const Duration(seconds: 5));  // May be too short or too long
```

### 3. Error Handling
```dart
// ✅ Good: Descriptive error messages
if (!AppLocators.getHotelCard($, hotelId).exists) {
  throw Exception('Hotel card with ID $hotelId should be visible after search');
}

// ✅ Good: Graceful fallbacks
try {
  await AppLocators.getPrimaryButton($).tap();
} catch (e) {
  TestLogger.logTestStep($, 'Primary button not found, trying secondary');
  await AppLocators.getSecondaryButton($).tap();
}
```

### 4. Test Data Management
```dart
// ✅ Good: Parameterized test data
const testSearchQueries = ['Dubai', 'London', 'New York', 'Tokyo'];

for (final query in testSearchQueries) {
  patrolTest('Hotels search works for $query', ($) async {
    await HotelsScreenActions.performSearchTest($, query);
  });
}

// ✅ Good: Clean test data
patrolSetUp(() async {
  await TestHelpers.clearTestData();
});
```

### 5. Assertions
```dart
// ✅ Good: Specific assertions
final hotelCards = AppLocators.getHotelCards($);
if (hotelCards.evaluate().length < 1) {
  throw Exception('Should display at least 1 hotel card for Dubai search');
}

// ✅ Good: Multiple validation points
await HotelsScreenActions.validateHotelCards($);
await HotelsScreenActions.validatePagination($);
await HotelsScreenActions.validateFilters($);
```

## 🔄 Common Patterns

### 1. Navigation Pattern
```dart
// Standard navigation with verification
static Future<void> navigateAndVerify(
  PatrolIntegrationTester $,
  String destination,
) async {
  await TestHelpers.navigateToPage($, destination);
  
  switch (destination) {
    case 'hotels':
      await HotelsScreenActions.verifyHotelsPageStructure($);
      break;
    case 'favorites':
      await FavoritesScreenActions.verifyFavoritesPageStructure($);
      break;
    // Add other cases
  }
}
```

### 2. Search Pattern
```dart
// Reusable search with validation
static Future<void> performSearch(
  PatrolIntegrationTester $,
  String query,
  {bool expectResults = true}
) async {
  await _enterSearchQuery($, query);
  await _waitForSearchCompletion($);
  
  if (expectResults) {
    await _validateSearchResults($);
  } else {
    await _validateEmptyState($);
  }
}
```

### 3. CRUD Pattern
```dart
// Create, Read, Update, Delete pattern for favorites
static Future<void> testFavoritesCRUD(PatrolIntegrationTester $) async {
  // Create
  await addHotelToFavorites($, testHotel);
  
  // Read
  await verifyHotelInFavorites($, testHotel);
  
  // Update (toggle)
  await toggleFavoriteStatus($, testHotel);
  
  // Delete  
  await removeHotelFromFavorites($, testHotel);
  await verifyHotelNotInFavorites($, testHotel);
}
```

## 🐛 Debugging Tests

### 1. Debug Configuration
```dart
// Use debug config for longer timeouts
patrolTest(
  'Debug test with extended timeouts',
  config: PatrolConfig.getDebugConfig(),
  ($) async {
    // Test implementation with debug logging
  },
);
```

### 2. Screenshot Debugging
```dart
// Take screenshots at key points
static Future<void> debugSearchFlow(PatrolIntegrationTester $) async {
  await $.takeScreenshot('01_initial_state');
  
  await performSearchTest($, 'Dubai');
  await $.takeScreenshot('02_search_results');
  
  await favoriteRandomHotels($);
  await $.takeScreenshot('03_after_favoriting');
}
```

### 3. Logging Strategy
```dart
// Comprehensive logging for debugging
static Future<void> debugAction(PatrolIntegrationTester $) async {
  TestLogger.logTestStep($, 'Starting debug action');
  
  final element = AppLocators.getTargetElement($);
  TestLogger.logTestStep($, 'Element exists: ${element.exists}');
  TestLogger.logTestStep($, 'Element visible: ${element.visible}');
  
  try {
    await element.tap();
    TestLogger.logTestSuccess($, 'Element tapped successfully');
  } catch (e) {
    TestLogger.logTestError($, 'Failed to tap element: $e');
    await $.takeScreenshot('debug_tap_failure');
    rethrow;
  }
}
```

### 4. Element Inspection
```dart
// Inspect element properties for debugging
static Future<void> inspectElement(
  PatrolIntegrationTester $,
  PatrolFinder finder,
) async {
  TestLogger.logTestStep($, 'Inspecting element...');
  TestLogger.logTestStep($, 'Exists: ${finder.exists}');
  
  if (finder.exists) {
    final elements = finder.evaluate();
    TestLogger.logTestStep($, 'Count: ${elements.length}');
    
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      TestLogger.logTestStep($, 'Element $i: ${element.widget.runtimeType}');
    }
  }
}
```

## 🎯 Advanced Patterns

### 1. Conditional Testing
```dart
// Test different paths based on app state
static Future<void> conditionalTest(PatrolIntegrationTester $) async {
  final hasData = AppLocators.getHotelCards($).exists;
  
  if (hasData) {
    await testWithExistingData($);
  } else {
    await testEmptyState($);
  }
}
```

### 2. Retry Mechanisms
```dart
// Retry flaky operations
static Future<void> retryableAction(
  PatrolIntegrationTester $,
  Future<void> Function() action,
  {int maxRetries = 3}
) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await action();
      return;
    } catch (e) {
      if (attempt == maxRetries) rethrow;
      
      TestLogger.logTestStep($, 'Attempt $attempt failed, retrying...');
      await $.pump(const Duration(seconds: 1));
    }
  }
}
```

### 3. Performance Testing
```dart
// Measure test execution time
static Future<void> performanceTest(PatrolIntegrationTester $) async {
  final stopwatch = Stopwatch()..start();
  
  await performSearchTest($, 'Dubai');
  
  stopwatch.stop();
  final executionTime = stopwatch.elapsedMilliseconds;
  
  TestLogger.logTestStep($, 'Search completed in ${executionTime}ms');
  
  if (executionTime > 5000) {  // 5 seconds threshold
    TestLogger.logTestStep($, 'Warning: Search took longer than expected');
  }
}
```

---

**Test Writing Mastery Complete! ✍️**  
You now have comprehensive knowledge of writing effective Patrol tests for the Hotel Booking application.($, 'Feature test completed');
    },
  );
}
```

### Key Components Explained

#### 1. Test Setup and Teardown
```dart
patrolSetUp(() async {
  TestHelpers.resetTestState();     // Reset any global state
});

patrolTearDown(() async {
  await TestHelpers.cleanUpTest();  // Cleanup resources
});
```

#### 2. Test Declaration
```dart
patrolTest(
  'Descriptive test name',           // Clear, specific test name
  config: PatrolConfig.getConfig(),  // Custom configuration
  ($) async {                        // PatrolIntegrationTester instance
    // Test implementation
  },
);
```

#### 3. Test Configuration
```dart
// Use different configs for different test types
config: PatrolConfig.getConfig(),      // Standard config
config: PatrolConfig.getDebugConfig(), // Debug config (longer timeouts)
config: PatrolConfig.getFastConfig(),  // Fast config (shorter timeouts)
```

## 🗂️ Test Organization

### File Structure
```
integration_test/
├── tests/                          # Main test files
│   ├── dashboard_test.dart         # Dashboard functionality
│   ├── hotels_test.dart           # Hotel search and management
│   ├── overview_test.dart         # Overview page functionality
│   └── account_test.dart          # Account management
├── screens/                        # Screen action objects
│   ├── dashboard_screen_actions.dart
│   ├── hotels_screen_actions.dart
│   ├── overview_screen_actions.dart
│   └── account_screen_actions.dart
├── locators/                       # Element locators
│   └── app_locators.dart          # Centralized locators
├── helpers/                        # Test utilities
│   ├── test_helpers.dart          # Common test operations
│   ├── test_logger.dart           # Logging utilities
│   └── test_data_factory.dart     # Test data creation
└── config/                         # Configuration
    └── patrol_config.dart         # Patrol configurations
```

### Naming Conventions

```dart
// Test files: feature_test.dart
dashboard_test.dart
hotels_test.dart
favorites_test.dart

// Test names: Feature + Action + Expected Result
'Hotels search functionality test'
'Dashboard navigation between tabs test'
'Favorites add and remove functionality test'

// Screen actions: FeatureScreenActions
DashboardScreenActions
HotelsScreenActions
FavoritesScreenActions

// Helper methods: descriptive action names
performSearchTest()
validateHotelCards()
navigateToFavorites()
```

## 🧪 Writing Integration Tests

### Complete Test Example

```dart
// integration_test/tests/hotels_test.dart
import 'package:patrol/patrol.dart';

import '../config/patrol_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_logger.dart';
import '../screens/hotels_screen_actions.dart';

void main() {
  patrolSetUp(() async {
    TestHelpers.resetTestState();
  });

  patrolTearDown(() async {
    await TestHelpers.cleanUpTest();
  });

  patrolTest(
    'Hotels search functionality test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Hotels Search Test');
      
      // Initialize app
      await TestHelpers.initializeApp($);
      
      // Navigate to hotels page
      TestLogger.logNavigation($, 'Hotels page');
      await TestHelpers.navigateToPage($, 'hotels');
      
      // Perform search
      TestLogger.logAction($, 'Testing search functionality');
      await HotelsScreenActions.performSearchTest($, 'Dubai');
      
      // Validate results
      TestLogger.logValidation($, 'search results');
      await HotelsScreenActions.validateHotelCards($);
      
      TestLogger.logTestSuccess($, 'Search functionality verified');
    },
  );

  patrolTest(
    'Hotels favorites functionality test',
    config: PatrolConfig.getConfig(),
    ($) async {
      TestLogger.logTestStart($, 'Hotels Favorites Test');
      await TestHelpers.initializeApp($);
      
      // Clear existing favorites first
      await TestHelpers.navigateToPage($, 'favorites');
      await HotelsScreenActions.clearExistingFavorites($);
      
      // Navigate to hotels and search
      await TestHelpers.navigateToPage($, 'hotels');
      await HotelsScreenActions.performSearchTest($, 'Tokyo');
      
      // Add hotels to favorites
      TestLogger.logAction($, 'Adding hotels to favorites');
      await HotelsScreenActions.favoriteRandomHotels($);
      
      // Validate favorites page
      TestLogger.logValidation($, 'favorites page');
      await HotelsScreenActions.validateFavoritesPage($);
      
      TestLogger.logTestSuccess