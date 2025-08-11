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

  /// Log test report
  static void logTestReport(Map<String, dynamic> report) {
    final timestamp = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('📊 [$timestamp] TEST REPORT:');
    // ignore: avoid_print
    print('Test Suite: ${report['testSuite']}');
    // ignore: avoid_print
    print('Execution Time: ${report['executionTime']}ms');
    // ignore: avoid_print
    print('Test Results: ${report['testResults']}');
    // ignore: avoid_print
    print('Metrics: ${report['metrics']}');
    _logToFile('REPORT', report.toString());
  }
  
  /// Log general information
  static void logInfo(String message) {
    final timestamp = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('ℹ️ [$timestamp] INFO: $message');
    _logToFile('INFO', message);
  }
  
  /// Log test warning
  static void logTestWarning(PatrolIntegrationTester tester, String message) {
    final timestamp = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('⚠️ [$timestamp] WARNING: $message');
    _logToFile('WARNING', message);
  }

  static void _logToFile(String level, String message) {
    // Implementation for file logging
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
