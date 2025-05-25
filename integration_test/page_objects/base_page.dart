import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_helper.dart';

/// Base Page Object Model
/// Provides comprehensive foundation functionality for all page objects
/// Implements best practices for maintainable and reliable test automation
/// Updated to align with new locator and helper architecture
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
      await PatrolTestHelper.waitForWidget($, find.byKey(Key(pageKey)),
          timeout: timeout, description: '$pageName page scaffold');
      await _performStabilityChecks();
      logSuccess('$pageName page loaded successfully');
    } catch (e) {
      logError('Failed to load $pageName page', e);
      await takeErrorScreenshot('page_load_failed');
      rethrow;
    }
  }

  /// Enhanced stability checks after page load
  Future<void> _performStabilityChecks() async {
    await waitForPageStabilization();
    await PatrolTestHelper.waitForLoadingToComplete($);
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

  /// Enhanced tap with comprehensive error handling and retry mechanism
  Future<void> tapElement(
    String elementKey, {
    Duration? timeout,
    String? description,
    bool waitForElement = true,
    int maxRetries = 2,
  }) async {
    final elementDescription = description ?? 'Element: $elementKey';
    logAction('Tapping $elementDescription');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (waitForElement) {
          await this.waitForElement(elementKey,
              timeout: timeout ?? const Duration(seconds: 10),
              description: elementDescription);
        }

        await PatrolTestHelper.tapByKey($, elementKey,
            description: elementDescription);
        logSuccess('Successfully tapped $elementDescription');
        return;
      } catch (e) {
        if (attempt == maxRetries) {
          logError(
              'Failed to tap $elementDescription after $maxRetries attempts',
              e);
          await takeErrorScreenshot('tap_failed_$elementKey');
          rethrow;
        }

        logWarning('Tap attempt $attempt failed, retrying: $e');
        await $.pump(const Duration(milliseconds: 500));
      }
    }
  }

  /// Enhanced text entry with validation and clear options
  Future<void> enterText(
    String elementKey,
    String text, {
    Duration? timeout,
    String? description,
    bool clearFirst = false,
    bool validateEntry = false,
  }) async {
    final elementDescription = description ?? 'Text field: $elementKey';
    logAction('Entering text "$text" into $elementDescription');

    try {
      if (clearFirst) {
        await clearTextField(elementKey, description: elementDescription);
      }

      await PatrolTestHelper.enterTextByKey($, elementKey, text,
          description: elementDescription);

      if (validateEntry) {
        await _validateTextEntry(elementKey, text);
      }

      logSuccess('Successfully entered text into $elementDescription');
    } catch (e) {
      logError('Failed to enter text into $elementDescription', e);
      await takeErrorScreenshot('text_entry_failed_$elementKey');
      rethrow;
    }
  }

  /// Validate that text was actually entered
  Future<void> _validateTextEntry(
      String elementKey, String expectedText) async {
    // This would need specific implementation based on TextField access patterns
    // For now, just pump to ensure text is processed
    await $.pump(const Duration(milliseconds: 300));
  }

  /// Clear text from an element with multiple strategies
  Future<void> clearTextField(String elementKey, {String? description}) async {
    final elementDescription = description ?? 'Text field: $elementKey';
    logAction('Clearing $elementDescription');

    try {
      await PatrolTestHelper.clearTextByKey($, elementKey,
          description: elementDescription);
      await $.pump(const Duration(milliseconds: 300));
      logSuccess('Successfully cleared $elementDescription');
    } catch (e) {
      logError('Failed to clear $elementDescription', e);
      rethrow;
    }
  }

  // =============================================================================
  // ELEMENT VERIFICATION METHODS
  // =============================================================================

  /// Verify element exists with enhanced error context
  void verifyElementExists(String elementKey, {String? description}) {
    final elementDescription = description ?? 'Element: $elementKey';
    logAction('Verifying $elementDescription exists');

    try {
      PatrolTestHelper.verifyWidgetExists(elementKey,
          description: elementDescription);
      logSuccess('$elementDescription exists');
    } catch (e) {
      logError('$elementDescription does not exist');
      rethrow;
    }
  }

  /// Verify element does not exist
  void verifyElementNotExists(String elementKey, {String? description}) {
    final elementDescription = description ?? 'Element: $elementKey';
    logAction('Verifying $elementDescription does not exist');

    try {
      PatrolTestHelper.verifyWidgetNotExists(elementKey,
          description: elementDescription);
      logSuccess('$elementDescription does not exist (as expected)');
    } catch (e) {
      logError('$elementDescription exists when it should not');
      rethrow;
    }
  }

  /// Verify text content exists
  void verifyTextExists(String text, {String? description}) {
    final textDescription = description ?? 'Text: "$text"';
    logAction('Verifying $textDescription exists');

    try {
      PatrolTestHelper.verifyTextExists(text, description: textDescription);
      logSuccess('$textDescription found');
    } catch (e) {
      logError('$textDescription not found');
      rethrow;
    }
  }

  /// Enhanced visibility check with logging
  bool isElementVisible(String elementKey, {String? description}) {
    final elementDescription = description ?? 'Element: $elementKey';
    final isVisible = PatrolTestHelper.isWidgetVisible(elementKey);

    if (description != null) {
      logAction('Visibility check for $elementDescription: $isVisible');
    }

    return isVisible;
  }

  /// Verify multiple elements exist
  void verifyMultipleElementsExist(List<String> elementKeys,
      {String? groupDescription}) {
    final description = groupDescription ?? 'element group';
    logAction('Verifying $description elements exist');

    try {
      PatrolTestHelper.verifyMultipleWidgetsExist(elementKeys);
      logSuccess('All $description elements exist');
    } catch (e) {
      logError('Some $description elements are missing');
      rethrow;
    }
  }

  // =============================================================================
  // WAITING AND TIMING METHODS
  // =============================================================================

  /// Wait for element with comprehensive timeout handling
  Future<void> waitForElement(
    String elementKey, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $elementKey';
    logAction('Waiting for $elementDescription');

    try {
      await PatrolTestHelper.waitForWidget(
        $,
        find.byKey(Key(elementKey)),
        timeout: timeout,
        description: elementDescription,
      );
      logSuccess('$elementDescription appeared');
    } catch (e) {
      logError('$elementDescription did not appear within timeout');
      await takeErrorScreenshot('element_wait_timeout_$elementKey');
      rethrow;
    }
  }

  /// Wait for element to disappear
  Future<void> waitForElementToDisappear(
    String elementKey, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
  }) async {
    final elementDescription = description ?? 'Element: $elementKey';
    logAction('Waiting for $elementDescription to disappear');

    try {
      await PatrolTestHelper.waitForWidgetToDisappear(
        $,
        find.byKey(Key(elementKey)),
        timeout: timeout,
        description: elementDescription,
      );
      logSuccess('$elementDescription disappeared');
    } catch (e) {
      logError('$elementDescription did not disappear within timeout');
      rethrow;
    }
  }

  /// Wait for multiple elements to appear
  Future<void> waitForMultipleElements(
    List<String> elementKeys, {
    Duration timeout = const Duration(seconds: 10),
    String? groupDescription,
  }) async {
    final description = groupDescription ?? 'element group';
    logAction('Waiting for $description elements');

    try {
      await PatrolTestHelper.waitForMultipleWidgets($, elementKeys,
          timeout: timeout);
      logSuccess('All $description elements appeared');
    } catch (e) {
      logError('Some $description elements did not appear within timeout');
      rethrow;
    }
  }

  /// Wait for loading to complete with page context
  Future<void> waitForLoadingToComplete({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    logAction('Waiting for loading to complete on $pageName');
    await PatrolTestHelper.waitForLoadingToComplete($, timeout: timeout);
    logSuccess('Loading completed on $pageName');
  }

  // =============================================================================
  // SCROLLING METHODS
  // =============================================================================

  /// Scroll to make an element visible with comprehensive error handling
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
      logSuccess('Successfully scrolled to $elementDescription');
    } catch (e) {
      logError('Failed to scroll to $elementDescription', e);
      await takeErrorScreenshot('scroll_failed_$targetKey');
      rethrow;
    }
  }

  // =============================================================================
  // SCREENSHOT AND DEBUGGING METHODS
  // =============================================================================

  /// Take screenshot with enhanced naming and error handling
  Future<void> takePageScreenshot(String suffix, {String? description}) async {
    final screenshotName = _buildScreenshotName(suffix);
    final desc = description ?? screenshotName;
    logAction('Taking screenshot: $desc');

    try {
      await PatrolTestHelper.takeScreenshot($, screenshotName,
          description: desc);
      logSuccess('Screenshot saved: $screenshotName');
    } catch (e) {
      logWarning('Failed to take screenshot: $e');
      // Don't rethrow - screenshots shouldn't fail tests
    }
  }

  /// Take error screenshot with context
  Future<void> takeErrorScreenshot(String errorContext) async {
    final screenshotName = _buildScreenshotName('error_$errorContext');
    logAction('Taking error screenshot: $screenshotName');

    try {
      await PatrolTestHelper.takeScreenshot($, screenshotName);
    } catch (e) {
      logWarning('Failed to take error screenshot: $e');
    }
  }

  /// Build screenshot name with timestamp
  String _buildScreenshotName(String suffix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${pageName}_${suffix}_$timestamp';
  }

  // =============================================================================
  // PERFORMANCE AND RELIABILITY METHODS
  // =============================================================================

  /// Execute operation with retry logic and performance measurement
  Future<T> executeWithRetry<T>(
    String operationName,
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    return await PatrolTestHelper.measurePerformance(
      '$pageName - $operationName',
      () async {
        for (int attempt = 1; attempt <= maxRetries; attempt++) {
          try {
            logAction('$operationName attempt $attempt/$maxRetries');
            final result = await operation();
            logSuccess('$operationName succeeded on attempt $attempt');
            return result;
          } catch (e) {
            final shouldRetryError = shouldRetry?.call(e) ?? true;

            if (attempt == maxRetries || !shouldRetryError) {
              logError('$operationName failed after $attempt attempts', e);
              await takeErrorScreenshot(
                  '${operationName.toLowerCase()}_failed');
              rethrow;
            }

            logWarning('$operationName attempt $attempt failed, retrying: $e');
            await $.pump(retryDelay);
          }
        }
        throw StateError('This should never be reached');
      },
    );
  }

  // =============================================================================
  // STATE VALIDATION METHODS
  // =============================================================================

  /// Comprehensive page state validation
  Future<void> validatePageState({
    List<String>? requiredElements,
    List<String>? forbiddenElements,
    List<String>? requiredTexts,
    String? validationContext,
  }) async {
    final context = validationContext != null ? ' ($validationContext)' : '';
    logAction('Validating $pageName page state$context');

    try {
      // Verify required elements
      if (requiredElements != null && requiredElements.isNotEmpty) {
        for (final element in requiredElements) {
          verifyElementExists(element, description: 'Required element');
        }
      }

      // Verify forbidden elements are not present
      if (forbiddenElements != null && forbiddenElements.isNotEmpty) {
        for (final element in forbiddenElements) {
          verifyElementNotExists(element, description: 'Forbidden element');
        }
      }

      // Verify required texts
      if (requiredTexts != null && requiredTexts.isNotEmpty) {
        for (final text in requiredTexts) {
          verifyTextExists(text, description: 'Required text');
        }
      }

      logSuccess('Page state validation passed');
    } catch (e) {
      logError('Page state validation failed', e);
      await takeErrorScreenshot('state_validation_failed');
      rethrow;
    }
  }

  /// Quick page health check
  bool isPageHealthy({
    List<String>? criticalElements,
  }) {
    try {
      // Check if page is visible
      if (!isCurrentPage()) {
        return false;
      }

      // Check critical elements if provided
      if (criticalElements != null) {
        for (final element in criticalElements) {
          if (!isElementVisible(element)) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      logWarning('Error during health check: $e');
      return false;
    }
  }

  // =============================================================================
  // LOGGING AND DEBUGGING
  // =============================================================================

  /// Enhanced logging with structured output
  void logAction(String action) {
    debugPrint('🔷 [$pageName] $action');
  }

  void logError(String error, [dynamic exception]) {
    debugPrint('❌ [$pageName] ERROR: $error');
    if (exception != null) {
      debugPrint('🔍 [$pageName] Exception details: $exception');
    }
  }

  void logWarning(String warning) {
    debugPrint('⚠️ [$pageName] WARNING: $warning');
  }

  void logSuccess(String message) {
    debugPrint('✅ [$pageName] SUCCESS: $message');
  }

  void logInfo(String info) {
    debugPrint('ℹ️ [$pageName] INFO: $info');
  }

  /// Log detailed page information for debugging
  void logPageInfo() {
    logInfo('Page Details:');
    logInfo('  - Name: $pageName');
    logInfo('  - Key: $pageKey');
    logInfo('  - Visible: ${isElementVisible(pageKey)}');
    logInfo('  - Timestamp: ${DateTime.now().toIso8601String()}');
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if the current page is active
  bool isCurrentPage() {
    return isElementVisible(pageKey);
  }

  /// Ensure page is ready for interactions
  Future<void> ensurePageIsReady(
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (!isCurrentPage()) {
      logAction('Page not active, waiting for activation');
      await verifyPageIsLoaded(timeout: timeout);
    }
    await waitForPageStabilization();
  }

  /// Get comprehensive page state summary
  Map<String, dynamic> getPageStateSummary() {
    return {
      'pageName': pageName,
      'pageKey': pageKey,
      'isVisible': isCurrentPage(),
      'isHealthy': isPageHealthy(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Generate unique operation ID for debugging
  String generateOperationId([String? prefix]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return prefix != null ? '${prefix}_$timestamp' : 'op_$timestamp';
  }

  // =============================================================================
  // COMPREHENSIVE TEST METHODS
  // =============================================================================

  /// Perform basic page verification test
  Future<void> performBasicPageTest() async {
    logAction('Performing basic page test for $pageName');

    await verifyPageIsLoaded();
    await takePageScreenshot('basic_test_loaded');

    if (isPageHealthy()) {
      logSuccess('Basic page test passed');
    } else {
      logError('Basic page test failed - page is not healthy');
      await takeErrorScreenshot('basic_test_failed');
      throw Exception('Basic page test failed for $pageName');
    }
  }

  /// Test page stability over time
  Future<void> testPageStability({
    Duration testDuration = const Duration(seconds: 3),
  }) async {
    logAction(
        'Testing page stability for $pageName over ${testDuration.inSeconds}s');

    await verifyPageIsLoaded();

    final endTime = DateTime.now().add(testDuration);
    int checkCount = 0;

    while (DateTime.now().isBefore(endTime)) {
      await $.pump(const Duration(milliseconds: 500));
      checkCount++;

      if (!isCurrentPage()) {
        logError(
            'Page became unstable during stability test after $checkCount checks');
        await takeErrorScreenshot('stability_test_failed');
        throw Exception('Page stability test failed for $pageName');
      }
    }

    logSuccess('Page stability test passed ($checkCount checks)');
  }

  /// Comprehensive page workflow (template method)
  Future<void> executePageWorkflow() async {
    logAction('Executing comprehensive workflow for $pageName');

    await verifyPageIsLoaded();
    await takePageScreenshot('workflow_start');

    await performPageSpecificActions();
    await takePageScreenshot('workflow_actions_complete');

    await validatePageAfterActions();
    await takePageScreenshot('workflow_complete');

    logSuccess('Page workflow executed successfully');
  }

  /// Override in child classes for page-specific actions
  Future<void> performPageSpecificActions() async {
    logInfo('No page-specific actions defined for $pageName');
  }

  /// Override in child classes for page-specific validation
  Future<void> validatePageAfterActions() async {
    await validatePageState();
  }

  /// Safe disposal method for cleanup
  Future<void> dispose() async {
    logAction('Performing cleanup for $pageName page');
    // Override in child classes if cleanup is needed
  }
}
