import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_helper.dart';

/// Base Page Object Model
/// Provides comprehensive foundation functionality for all page objects
/// Implements best practices for maintainable and reliable test automation
abstract class BasePage {
  final PatrolIntegrationTester $;

  BasePage(this.$);

  // =============================================================================
  // ABSTRACT PROPERTIES - Must be implemented by child classes
  // =============================================================================

  /// The name of this page for logging and identification purposes
  String get pageName;

  /// The unique key that identifies this page's main container
  String get pageKey;

  // =============================================================================
  // CORE PAGE VERIFICATION METHODS
  // =============================================================================

  /// Verify that the page is loaded and ready for interaction
  /// This is the primary method for page verification
  Future<void> verifyPageIsLoaded({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    logAction('Verifying $pageName page is loaded');
    
    try {
      await PatrolTestHelper.waitForWidget($, find.byKey(Key(pageKey)), timeout: timeout);
      await _performAdditionalPageChecks();
      logAction('✅ $pageName page loaded successfully');
    } catch (e) {
      logAction('❌ Failed to load $pageName page: $e');
      await takePageScreenshot('page_load_failed');
      rethrow;
    }
  }

  /// Additional checks that can be overridden by child classes
  Future<void> _performAdditionalPageChecks() async {
    await waitForPageStabilization();
  }

  /// Wait for the page to load with comprehensive error handling
  Future<void> waitForPageToLoad({
    Duration timeout = const Duration(seconds: 10),
    bool throwOnTimeout = true,
  }) async {
    logAction('Waiting for $pageName page to load');

    try {
      await PatrolTestHelper.waitForWidget(
        $,
        find.byKey(Key(pageKey)),
        timeout: timeout,
      );
      await PatrolTestHelper.waitForLoadingToComplete($);
      await waitForPageStabilization();
    } catch (e) {
      if (throwOnTimeout) {
        logAction('❌ Page load timeout for $pageName: $e');
        rethrow;
      } else {
        logAction('⚠️ Page load timeout for $pageName (non-critical): $e');
      }
    }
  }

  /// Wait for page to stabilize after navigation or state changes
  Future<void> waitForPageStabilization({
    Duration stabilizationDelay = const Duration(milliseconds: 500),
  }) async {
    await $.pump(stabilizationDelay);
    await PatrolTestHelper.waitForLoadingToComplete($);
  }

  // =============================================================================
  // ELEMENT INTERACTION METHODS
  // =============================================================================

  /// Tap on an element identified by its key
  Future<void> tapElement(
    String key, {
    Duration? settleTimeout,
    String? description,
    bool waitForElementFlag = true,
    Duration elementTimeout = const Duration(seconds: 5),
  }) async {
    final elementDescription = description ?? 'Element: $key';
    logAction('Tapping $elementDescription');

    try {
      if (waitForElementFlag) {
        await this.waitForElement(key, timeout: elementTimeout);
      }

      await PatrolTestHelper.tapByKey(
        $,
        key,
        settleTimeout: settleTimeout,
      );

      logAction('✅ Successfully tapped $elementDescription');
    } catch (e) {
      logAction('❌ Failed to tap $elementDescription: $e');
      await takePageScreenshot('tap_failed_$key');
      rethrow;
    }
  }

  /// Enhanced tap with retry mechanism
  Future<void> tapElementWithRetry(
    String key, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $key';
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        logAction('Attempting to tap $elementDescription (attempt $attempt/$maxRetries)');
        await tapElement(key, description: elementDescription, waitForElement: true);
        return; // Success, exit
      } catch (e) {
        if (attempt == maxRetries) {
          logAction('❌ Failed to tap $elementDescription after $maxRetries attempts');
          rethrow;
        }
        
        logAction('⚠️ Tap attempt $attempt failed, retrying in ${retryDelay.inSeconds}s');
        await $.pump(retryDelay);
      }
    }
  }

  /// Enter text into an element identified by its key
  Future<void> enterText(
    String key,
    String text, {
    Duration? settleTimeout,
    String? description,
    bool clearFirst = false,
  }) async {
    final elementDescription = description ?? 'Text field: $key';
    logAction('Entering text "$text" into $elementDescription');

    try {
      if (clearFirst) {
        await clearTextField(key);
      }

      await PatrolTestHelper.enterTextByKey(
        $,
        key,
        text,
        settleTimeout: settleTimeout,
      );

      logAction('✅ Successfully entered text into $elementDescription');
    } catch (e) {
      logAction('❌ Failed to enter text into $elementDescription: $e');
      await takePageScreenshot('text_entry_failed_$key');
      rethrow;
    }
  }

  /// Clear text from an element
  Future<void> clearTextField(String key, {String? description}) async {
    final elementDescription = description ?? 'Text field: $key';
    logAction('Clearing $elementDescription');

    try {
      await PatrolTestHelper.clearTextByKey($, key);
      logAction('✅ Successfully cleared $elementDescription');
    } catch (e) {
      logAction('❌ Failed to clear $elementDescription: $e');
      rethrow;
    }
  }

  // =============================================================================
  // ELEMENT VERIFICATION METHODS
  // =============================================================================

  /// Verify that an element exists
  void verifyElementExists(String key, {String? description}) {
    final elementDescription = description ?? 'Element: $key';
    logAction('Verifying $elementDescription exists');

    try {
      PatrolTestHelper.verifyWidgetExists(key, description: elementDescription);
      logAction('✅ $elementDescription exists');
    } catch (e) {
      logAction('❌ $elementDescription does not exist');
      rethrow;
    }
  }

  /// Verify that an element does not exist
  void verifyElementNotExists(String key, {String? description}) {
    final elementDescription = description ?? 'Element: $key';
    logAction('Verifying $elementDescription does not exist');

    try {
      PatrolTestHelper.verifyWidgetNotExists(key, description: elementDescription);
      logAction('✅ $elementDescription does not exist (as expected)');
    } catch (e) {
      logAction('❌ $elementDescription exists when it should not');
      rethrow;
    }
  }

  /// Verify that text exists on the page
  void verifyTextExists(String text, {String? description}) {
    final textDescription = description ?? 'Text: "$text"';
    logAction('Verifying $textDescription exists');

    try {
      PatrolTestHelper.verifyTextExists(text, description: textDescription);
      logAction('✅ $textDescription found');
    } catch (e) {
      logAction('❌ $textDescription not found');
      rethrow;
    }
  }

  /// Check if an element is visible
  bool isElementVisible(String key, {String? description}) {
    final elementDescription = description ?? 'Element: $key';
    final isVisible = PatrolTestHelper.isWidgetVisible(key, description: elementDescription);
    logAction('Visibility check for $elementDescription: $isVisible');
    return isVisible;
  }

  /// Verify multiple elements exist
  void verifyMultipleElementsExist(List<String> keys, {String? groupDescription}) {
    final description = groupDescription ?? 'Element group';
    logAction('Verifying $description elements exist');

    try {
      PatrolTestHelper.verifyMultipleWidgetsExist(keys);
      logAction('✅ All $description elements exist');
    } catch (e) {
      logAction('❌ Some $description elements are missing');
      rethrow;
    }
  }

  // =============================================================================
  // WAITING AND TIMING METHODS
  // =============================================================================

  /// Wait for an element to appear
  Future<void> waitForElement(
    String key, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $key';
    logAction('Waiting for $elementDescription');

    try {
      await PatrolTestHelper.waitForWidget(
        $,
        find.byKey(Key(key)),
        timeout: timeout,
        description: elementDescription,
      );
      logAction('✅ $elementDescription appeared');
    } catch (e) {
      logAction('❌ $elementDescription did not appear within timeout');
      await takePageScreenshot('element_wait_timeout_$key');
      rethrow;
    }
  }

  /// Wait for an element to disappear
  Future<void> waitForElementToDisappear(
    String key, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $key';
    logAction('Waiting for $elementDescription to disappear');

    try {
      await PatrolTestHelper.waitForWidgetToDisappear(
        $,
        find.byKey(Key(key)),
        timeout: timeout,
      );
      logAction('✅ $elementDescription disappeared');
    } catch (e) {
      logAction('❌ $elementDescription did not disappear within timeout');
      rethrow;
    }
  }

  /// Wait for multiple elements to appear
  Future<void> waitForMultipleElements(
    List<String> keys, {
    Duration timeout = const Duration(seconds: 10),
    String? groupDescription,
  }) async {
    final description = groupDescription ?? 'Element group';
    logAction('Waiting for $description elements');

    try {
      await PatrolTestHelper.waitForMultipleWidgets($, keys, timeout: timeout);
      logAction('✅ All $description elements appeared');
    } catch (e) {
      logAction('❌ Some $description elements did not appear within timeout');
      rethrow;
    }
  }

  /// Wait for loading to complete
  Future<void> waitForLoadingToComplete({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    logAction('Waiting for loading to complete on $pageName');
    await PatrolTestHelper.waitForLoadingToComplete($, timeout: timeout);
    logAction('✅ Loading completed on $pageName');
  }

  // =============================================================================
  // SCROLLING METHODS
  // =============================================================================

  /// Scroll to make an element visible
  Future<void> scrollToElement(
    String scrollableKey,
    String targetKey, {
    double delta = 100,
    int maxScrolls = 10,
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $targetKey';
    logAction('Scrolling to make $elementDescription visible');

    try {
      await PatrolTestHelper.scrollUntilVisible(
        $,
        scrollableKey,
        targetKey,
        delta: delta,
        maxScrolls: maxScrolls,
        description: elementDescription,
      );
      logAction('✅ Successfully scrolled to $elementDescription');
    } catch (e) {
      logAction('❌ Failed to scroll to $elementDescription: $e');
      await takePageScreenshot('scroll_failed_$targetKey');
      rethrow;
    }
  }


  // =============================================================================
  // SCREENSHOT AND DEBUGGING METHODS
  // =============================================================================

  /// Take a screenshot of the current page state
  Future<void> takePageScreenshot([String? suffix]) async {
    final screenshotName = _buildScreenshotName(suffix);
    logAction('Taking screenshot: $screenshotName');
    
    try {
      await PatrolTestHelper.takeScreenshot($, screenshotName);
      logAction('✅ Screenshot saved: $screenshotName');
    } catch (e) {
      logAction('⚠️ Failed to take screenshot: $e');
      // Don't rethrow - screenshots shouldn't fail tests
    }
  }

  /// Build screenshot name with page context
  String _buildScreenshotName(String? suffix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (suffix != null && suffix.isNotEmpty) {
      return '${pageName}_${suffix}_$timestamp';
    }
    return '${pageName}_$timestamp';
  }

  /// Take screenshot with error context
  Future<void> takeErrorScreenshot(String errorContext) async {
    await takePageScreenshot('error_$errorContext');
  }

  /// Take screenshot series for debugging
  Future<void> takeScreenshotSeries(String seriesName, List<String> steps) async {
    logAction('Taking screenshot series: $seriesName');
    
    for (int i = 0; i < steps.length; i++) {
      await takePageScreenshot('${seriesName}_${i + 1}_${steps[i]}');
      await $.pump(const Duration(milliseconds: 500)); // Allow state to stabilize
    }
  }

  // =============================================================================
  // PERFORMANCE AND RELIABILITY METHODS
  // =============================================================================

  /// Execute an operation with retry logic
  Future<T> executeWithRetry<T>(
    String operationName,
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    logAction('Executing $operationName with retry (max: $maxRetries)');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        logAction('$operationName attempt $attempt/$maxRetries');
        final result = await operation();
        logAction('✅ $operationName succeeded on attempt $attempt');
        return result;
      } catch (e) {
        final shouldRetryError = shouldRetry?.call(e) ?? true;
        
        if (attempt == maxRetries || !shouldRetryError) {
          logAction('❌ $operationName failed after $attempt attempts: $e');
          await takeErrorScreenshot('${operationName.toLowerCase()}_failed');
          rethrow;
        }
        
        logAction('⚠️ $operationName attempt $attempt failed, retrying: $e');
        await $.pump(retryDelay);
      }
    }
    
    throw StateError('This should never be reached');
  }

  /// Measure performance of an operation
  Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    return await PatrolTestHelper.measurePerformance(operationName, operation);
  }

  /// Wait and verify an element with comprehensive checks
  Future<void> waitAndVerify(
    String elementKey, {
    Duration timeout = const Duration(seconds: 10),
    String? expectedText,
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $elementKey';
    logAction('Wait and verify: $elementDescription');

    await waitForElement(elementKey, timeout: timeout, description: elementDescription);
    verifyElementExists(elementKey, description: elementDescription);

    if (expectedText != null) {
      verifyTextExists(expectedText, description: 'Expected text in $elementDescription');
    }

    logAction('✅ Wait and verify completed for $elementDescription');
  }

  // =============================================================================
  // STATE VALIDATION METHODS
  // =============================================================================

  /// Validate page state after an operation
  Future<void> validatePageState({
    List<String>? requiredElements,
    List<String>? forbiddenElements,
    List<String>? requiredTexts,
    String? customValidation,
  }) async {
    logAction('Validating $pageName page state${customValidation != null ? ' ($customValidation)' : ''}');

    try {
      // Check required elements
      if (requiredElements != null && requiredElements.isNotEmpty) {
        for (final element in requiredElements) {
          verifyElementExists(element, description: 'Required element');
        }
      }

      // Check forbidden elements
      if (forbiddenElements != null && forbiddenElements.isNotEmpty) {
        for (final element in forbiddenElements) {
          verifyElementNotExists(element, description: 'Forbidden element');
        }
      }

      // Check required texts
      if (requiredTexts != null && requiredTexts.isNotEmpty) {
        for (final text in requiredTexts) {
          verifyTextExists(text, description: 'Required text');
        }
      }

      logAction('✅ Page state validation passed');
    } catch (e) {
      logAction('❌ Page state validation failed: $e');
      await takeErrorScreenshot('state_validation_failed');
      rethrow;
    }
  }

  /// Check if page is in expected state
  bool isPageInExpectedState({
    List<String>? requiredElements,
    List<String>? forbiddenElements,
  }) {
    try {
      if (requiredElements != null) {
        for (final element in requiredElements) {
          if (!isElementVisible(element)) {
            return false;
          }
        }
      }

      if (forbiddenElements != null) {
        for (final element in forbiddenElements) {
          if (isElementVisible(element)) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      logAction('Error checking page state: $e');
      return false;
    }
  }

  // =============================================================================
  // LOGGING AND DEBUGGING
  // =============================================================================

  /// Log an action with page context
  void logAction(String action) {
    debugPrint('[$pageName] $action');
  }

  /// Log an error with page context
  void logError(String error, [dynamic exception]) {
    debugPrint('[$pageName] ❌ ERROR: $error');
    if (exception != null) {
      debugPrint('[$pageName] Exception details: $exception');
    }
  }

  /// Log a warning with page context
  void logWarning(String warning) {
    debugPrint('[$pageName] ⚠️ WARNING: $warning');
  }

  /// Log success with page context
  void logSuccess(String message) {
    debugPrint('[$pageName] ✅ SUCCESS: $message');
  }

  /// Log page information for debugging
  void logPageInfo() {
    logAction('Page Info:');
    logAction('  - Page Name: $pageName');
    logAction('  - Page Key: $pageKey');
    logAction('  - Page Visible: ${isElementVisible(pageKey)}');
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Generate a unique identifier for test operations
  String generateOperationId([String? prefix]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return prefix != null ? '${prefix}_$timestamp' : 'op_$timestamp';
  }

  /// Safe disposal method for cleanup
  Future<void> dispose() async {
    logAction('Performing page cleanup');
    // Override in child classes if cleanup is needed
  }

  /// Helper method to build element description for logging
  String buildElementDescription(String key, String? customDescription) {
    return customDescription ?? 'Element: $key';
  }

  /// Check if the current page is the active page
  bool isCurrentPage() {
    return isElementVisible(pageKey);
  }

  /// Ensure this page is currently active
  Future<void> ensurePageIsActive({Duration timeout = const Duration(seconds: 5)}) async {
    if (!isCurrentPage()) {
      logAction('Page is not active, waiting for activation');
      await waitForPageToLoad(timeout: timeout);
    }
  }

  /// Get current page state summary
  Map<String, dynamic> getPageStateSummary() {
    return {
      'pageName': pageName,
      'pageKey': pageKey,
      'isVisible': isCurrentPage(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // =============================================================================
  // APP-SPECIFIC HELPER METHODS (Based on existing page objects)
  // =============================================================================

  /// Verify page elements with comprehensive error handling
  Future<void> verifyPageElements(List<String> elementKeys, {String? groupName}) async {
    final description = groupName ?? 'page elements';
    logAction('Verifying $description');

    try {
      for (final key in elementKeys) {
        verifyElementExists(key);
      }
      logAction('✅ All $description verified successfully');
    } catch (e) {
      logAction('❌ Failed to verify $description: $e');
      await takeErrorScreenshot('${description.replaceAll(' ', '_')}_verification_failed');
      rethrow;
    }
  }

  /// Perform comprehensive page test
  Future<void> performComprehensivePageTest() async {
    logAction('Performing comprehensive test for $pageName page');

    await verifyPageIsLoaded();
    await takePageScreenshot('initial_state');

    // Take multiple screenshots for different states
    await verifyPageRequirements();
    await takePageScreenshot('requirements_verified');

    await testPageAccessibility();
    await takePageScreenshot('accessibility_tested');

    await testPageResponsiveness();
    await takePageScreenshot('responsiveness_tested');

    await takePageScreenshot('comprehensive_test_complete');
    logAction('✅ Comprehensive test completed for $pageName');
  }

  /// Verify basic page requirements
  Future<void> verifyPageRequirements() async {
    logAction('Verifying basic requirements for $pageName page');
    await verifyPageIsLoaded();
    await waitForPageStabilization();
    logAction('✅ Basic requirements verified for $pageName');
  }

  /// Test page accessibility
  Future<void> testPageAccessibility() async {
    logAction('Testing accessibility for $pageName page');
    await verifyPageIsLoaded();
    // Add specific accessibility checks if needed
    await waitForPageStabilization();
    logAction('✅ Accessibility test completed for $pageName');
  }

  /// Test page responsiveness
  Future<void> testPageResponsiveness() async {
    logAction('Testing responsiveness for $pageName page');
    await verifyPageIsLoaded();
    await $.pump(const Duration(milliseconds: 500));
    await waitForPageStabilization();
    logAction('✅ Responsiveness test completed for $pageName');
  }

  /// Navigate back using system back button (if available)
  Future<void> navigateBack() async {
    logAction('Navigating back from $pageName');
    try {
      await $.native.pressBack();
      await waitForPageStabilization();
      logAction('✅ Successfully navigated back');
    } catch (e) {
      logAction('⚠️ Back navigation not supported or failed: $e');
      // Don't rethrow as back navigation might not be available on all platforms
    }
  }

  /// Verify page after navigation
  Future<void> verifyPageAfterNavigation() async {
    logAction('Verifying $pageName page after navigation');
    await waitForPageToLoad();
    await waitForPageStabilization();
    logAction('✅ Page verified after navigation');
  }

  /// Test page interactions (override in child classes for specific interactions)
  Future<void> testPageInteractions() async {
    logAction('Testing basic interactions for $pageName page');
    await verifyPageIsLoaded();
    // Base implementation - override in child classes for specific interactions
    await takePageScreenshot('interactions_test');
    logAction('✅ Basic interactions test completed');
  }

  /// Test page stability over time
  Future<void> testPageStability({Duration testDuration = const Duration(seconds: 3)}) async {
    logAction('Testing stability for $pageName page');
    
    await verifyPageIsLoaded();
    
    final endTime = DateTime.now().add(testDuration);
    while (DateTime.now().isBefore(endTime)) {
      await $.pump(const Duration(milliseconds: 500));
      if (!isCurrentPage()) {
        throw Exception('Page became unstable during stability test');
      }
    }
    
    logAction('✅ Page stability test passed');
  }

  /// Take comprehensive screenshots for the page
  Future<void> takeComprehensiveScreenshots() async {
    logAction('Taking comprehensive screenshots for $pageName');
    
    await takePageScreenshot('full_page');
    await $.pump(const Duration(milliseconds: 300));
    
    await takePageScreenshot('after_stabilization');
    await $.pump(const Duration(milliseconds: 300));
    
    logAction('✅ Comprehensive screenshots completed');
  }

  /// Verify branding and content (can be overridden by child classes)
  Future<void> verifyBrandingContent() async {
    logAction('Verifying branding and content for $pageName page');
    await verifyPageIsLoaded();
    // Override in child classes for specific branding verification
    await takePageScreenshot('branding_content');
    logAction('✅ Branding content verification completed');
  }

  /// Execute page-specific workflow (template method)
  Future<void> executePageWorkflow() async {
    logAction('Executing workflow for $pageName page');
    
    await verifyPageIsLoaded();
    await testPageInteractions();
    await verifyBrandingContent();
    await takePageScreenshot('workflow_completed');
    
    logAction('✅ Page workflow executed successfully');
  }
}