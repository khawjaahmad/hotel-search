import 'dart:convert';
import 'dart:io';

import '../logger/test_logger.dart';
import '../reports/allure_reporter.dart';

/// Enhanced Allure Helper that integrates with your existing AllureReporter
/// Provides comprehensive test reporting with automatic result generation
class EnhancedAllureHelper {
  static const String _resultsDir = 'allure-results';
  static const String _screenshotsDir = 'screenshots';
  static bool _isInitialized = false;
  static final List<Map<String, dynamic>> _testResults = [];
  static DateTime? _suiteStartTime;

  /// Initialize the enhanced Allure integration
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _suiteStartTime = DateTime.now();

    // Create necessary directories
    await _createDirectories();

    // Initialize your existing AllureReporter
    await AllureReporter.initialize(
      resultsDirectory: _resultsDir,
      environment: await _getEnvironmentInfo(),
    );

    // Create environment properties file
    await _createEnvironmentProperties();

    // Create categories configuration
    await _createCategoriesConfig();

    _isInitialized = true;
    TestLogger.log('Enhanced Allure Helper initialized successfully');
  }

  /// Start a test with enhanced reporting
  static Future<void> startTest(
    String testName, {
    String? description,
    List<String>? labels,
    AllureSeverity severity = AllureSeverity.normal,
  }) async {
    await initialize();

    // Use your existing AllureReporter
    AllureReporter.startTest(testName, description: description);
    AllureReporter.setSeverity(severity);

    // Add standard labels
    AllureReporter.addLabel('framework', 'flutter_patrol');
    AllureReporter.addLabel('language', 'dart');
    AllureReporter.addLabel('testType', 'integration');

    // Add custom labels
    if (labels != null) {
      for (final label in labels) {
        final parts = label.split(':');
        if (parts.length == 2) {
          AllureReporter.addLabel(parts[0], parts[1]);
        }
      }
    }

    TestLogger.log('Enhanced Allure test started: $testName');
  }

  /// Report a test step with enhanced details
  static void reportStep(
    String stepName, {
    AllureStepStatus status = AllureStepStatus.passed,
    String? details,
    Duration? duration,
  }) {
    AllureReporter.reportStep(stepName, status: status);

    if (details != null) {
      AllureReporter.addAttachment('step_details', details);
    }

    if (duration != null) {
      TestLogger.log('Step "$stepName" took ${duration.inMilliseconds}ms');
    }
  }

  /// Report test completion with file generation
  static Future<void> finishTest(
    String testName, {
    AllureTestStatus status = AllureTestStatus.passed,
    String? errorMessage,
    String? stackTrace,
    List<String>? screenshots,
  }) async {
    // Generate unique test UUID
    final testUuid = _generateUuid();
    final startTime = DateTime.now().subtract(const Duration(seconds: 30));
    final endTime = DateTime.now();

    // Create detailed test result
    final testResult = {
      'uuid': testUuid,
      'historyId': testName.replaceAll(' ', '_').toLowerCase(),
      'fullName': testName,
      'name': testName,
      'status': status.name,
      'start': startTime.millisecondsSinceEpoch,
      'stop': endTime.millisecondsSinceEpoch,
      'labels': [
        {'name': 'framework', 'value': 'flutter_patrol'},
        {'name': 'language', 'value': 'dart'},
        {'name': 'testType', 'value': 'integration'},
        {'name': 'suite', 'value': _getSuiteFromTestName(testName)},
        {'name': 'feature', 'value': _getFeatureFromTestName(testName)},
        {'name': 'severity', 'value': 'normal'},
      ],
      'parameters': [],
      'links': [],
      'attachments': [],
    };

    // Add status details if test failed
    if (status != AllureTestStatus.passed) {
      testResult['statusDetails'] = {
        'message': errorMessage ?? 'Test failed',
        'trace': stackTrace ?? '',
      };
    }

    // Add screenshots as attachments
    if (screenshots != null) {
      for (final screenshot in screenshots) {
        final attachmentUuid = _generateUuid();
        (testResult['attachments'] as List).add({
          'name': 'Screenshot',
          'source': screenshot,
          'type': 'image/png',
          'uuid': attachmentUuid,
        });
      }
    }

    // Write test result file
    await _writeTestResult(testUuid, testResult);

    // Store for summary
    _testResults.add(testResult);

    // Use your existing AllureReporter
    await AllureReporter.finishTest(
      status: status,
      statusDetails: errorMessage,
    );

    TestLogger.log(
        'Enhanced Allure test completed: $testName (${status.name})');
  }

  /// Generate test suite summary
  static Future<void> generateSuiteSummary() async {
    if (_testResults.isEmpty) return;

    final suiteUuid = _generateUuid();
    final endTime = DateTime.now();

    final summary = {
      'uuid': suiteUuid,
      'name': 'Hotel Booking Integration Tests',
      'start': _suiteStartTime?.millisecondsSinceEpoch ??
          endTime.millisecondsSinceEpoch,
      'stop': endTime.millisecondsSinceEpoch,
      'children': _testResults.map((test) => test['uuid']).toList(),
    };

    await _writeSuiteSummary(suiteUuid, summary);
    TestLogger.log('Test suite summary generated');
  }

  /// Create directories for Allure results
  static Future<void> _createDirectories() async {
    final dirs = [_resultsDir, _screenshotsDir];

    for (final dir in dirs) {
      final directory = Directory(dir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        TestLogger.log('Created directory: $dir');
      }
    }
  }

  /// Get environment information
  static Future<Map<String, dynamic>> _getEnvironmentInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'dart_version': Platform.version,
      'test_framework': 'flutter_patrol',
      'execution_date': DateTime.now().toIso8601String(),
    };
  }

  /// Create environment.properties file for Allure
  static Future<void> _createEnvironmentProperties() async {
    final envFile = File('$_resultsDir/environment.properties');
    final envContent = '''
Platform=${Platform.operatingSystem}
Dart.Version=${Platform.version}
Test.Framework=Flutter Patrol Integration Tests
Execution.Date=${DateTime.now().toIso8601String()}
Test.Environment=local
App.Name=Hotel Booking App
''';

    await envFile.writeAsString(envContent);
    TestLogger.log('Environment properties created');
  }

  /// Create categories.json for test categorization
  static Future<void> _createCategoriesConfig() async {
    final categoriesFile = File('$_resultsDir/categories.json');
    final categories = [
      {
        'name': 'Hotels Feature Tests',
        'matchedStatuses': ['failed', 'broken'],
        'messageRegex': '.*hotels.*|.*search.*'
      },
      {
        'name': 'Favorites Feature Tests',
        'matchedStatuses': ['failed', 'broken'],
        'messageRegex': '.*favorites.*'
      },
      {
        'name': 'Navigation Tests',
        'matchedStatuses': ['failed', 'broken'],
        'messageRegex': '.*navigation.*|.*dashboard.*'
      },
      {
        'name': 'Performance Issues',
        'matchedStatuses': ['failed', 'broken'],
        'messageRegex': '.*timeout.*|.*performance.*|.*slow.*'
      },
    ];

    await categoriesFile.writeAsString(jsonEncode(categories));
    TestLogger.log('Categories configuration created');
  }

  /// Write individual test result
  static Future<void> _writeTestResult(
      String uuid, Map<String, dynamic> result) async {
    final resultFile = File('$_resultsDir/$uuid-result.json');
    await resultFile.writeAsString(jsonEncode(result));
  }

  /// Write suite summary
  static Future<void> _writeSuiteSummary(
      String uuid, Map<String, dynamic> summary) async {
    final summaryFile = File('$_resultsDir/$uuid-container.json');
    await summaryFile.writeAsString(jsonEncode(summary));
  }

  /// Generate UUID for Allure
  static String _generateUuid() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}-${now.microsecond}';
  }

  /// Extract suite name from test name
  static String _getSuiteFromTestName(String testName) {
    if (testName.toLowerCase().contains('hotel')) return 'Hotels';
    if (testName.toLowerCase().contains('favorite')) return 'Favorites';
    if (testName.toLowerCase().contains('navigation') ||
        testName.toLowerCase().contains('dashboard')) {
      return 'Navigation';
    }
    if (testName.toLowerCase().contains('overview')) return 'Overview';
    if (testName.toLowerCase().contains('account')) return 'Account';
    return 'General';
  }

  /// Extract feature name from test name
  static String _getFeatureFromTestName(String testName) {
    final lower = testName.toLowerCase();
    if (lower.contains('search')) return 'Search';
    if (lower.contains('favorite')) return 'Favorites Management';
    if (lower.contains('navigation')) return 'Navigation';
    if (lower.contains('scroll')) return 'Scrolling';
    if (lower.contains('load')) return 'Page Loading';
    if (lower.contains('error')) return 'Error Handling';
    return 'Core Functionality';
  }

  /// Get current test statistics
  static Map<String, int> getTestStatistics() {
    final stats = {
      'total': _testResults.length,
      'passed': 0,
      'failed': 0,
      'broken': 0,
      'skipped': 0,
    };

    for (final result in _testResults) {
      final status = result['status'] as String;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  /// Clean up and finalize reporting
  static Future<void> finalize() async {
    await generateSuiteSummary();

    final stats = getTestStatistics();
    TestLogger.log('Final test statistics: ${stats.toString()}');

    TestLogger.log('Allure results generated in: $_resultsDir');
    TestLogger.log('Screenshots available in: $_screenshotsDir');
  }
}

/// Extension to integrate with your existing PatrolTestHelper
extension AllureIntegration on Object {
  /// Report current action to Allure
  static void reportAction(String action,
      {AllureStepStatus status = AllureStepStatus.passed}) {
    EnhancedAllureHelper.reportStep(action, status: status);
  }

  /// Report error to Allure
  static void reportError(String error, {String? stackTrace}) {
    EnhancedAllureHelper.reportStep(
      'Error: $error',
      status: AllureStepStatus.failed,
      details: stackTrace,
    );
  }

  /// Report screenshot to Allure
  static void reportScreenshot(String name, String path) {
    EnhancedAllureHelper.reportStep(
      'Screenshot: $name',
      status: AllureStepStatus.passed,
      details: 'Screenshot saved to: $path',
    );
  }
}
