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
