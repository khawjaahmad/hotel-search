import '../logger/test_logger.dart';
import '../reports/allure_reporter.dart';

class TestUtils {
  static Future<void> initializeAllure() async {
    TestLogger.log('Initializing Allure reporting');
    await AllureReporter.initialize();
  }

  static Duration getDefaultTimeout() {
    return const Duration(seconds: 30); // Matches dart_test.yaml
  }
}
