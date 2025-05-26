import '../logger/test_logger.dart';

class AllureReporter {
  static String? _currentTestName;
  static final List<String> _steps = [];
  static final Map<String, String> _labels = {};
  static AllureSeverity _severity = AllureSeverity.normal;

  static Future<void> initialize({
    String resultsDirectory = 'allure-results',
    Map<String, dynamic>? environment,
  }) async {
    TestLogger.log('Allure reporter initialized (in-memory mode)');
  }

  static void startTest(String testName, {String? description}) {
    _currentTestName = testName;
    _steps.clear();
    _labels.clear();
    TestLogger.log('Starting test: $testName');
  }

  static void reportStep(String name,
      {AllureStepStatus status = AllureStepStatus.passed}) {
    final step = '$name - ${status.name}';
    _steps.add(step);
    TestLogger.log('Step: $step');
  }

  static void setTestStatus({
    AllureTestStatus status = AllureTestStatus.passed,
    String? reason,
  }) {
    TestLogger.log(
        'Test status: ${status.name}${reason != null ? ' - $reason' : ''}');
  }

  static Future<void> finishTest({
    AllureTestStatus status = AllureTestStatus.passed,
    String? statusDetails,
    List<String>? labels,
  }) async {
    TestLogger.log(
        'Test completed: ${_currentTestName ?? 'Unknown'} - ${status.name}');
    if (statusDetails != null) {
      TestLogger.log('Status details: $statusDetails');
    }
    if (_steps.isNotEmpty) {
      TestLogger.log('Steps executed: ${_steps.length}');
      for (final step in _steps) {
        TestLogger.log('  - $step');
      }
    }
    _reset();
  }

  static void addLabel(String name, String value) {
    _labels[name] = value;
    TestLogger.log('Label added: $name=$value');
  }

  static void setSeverity(AllureSeverity severity) {
    _severity = severity;
    TestLogger.log('Severity set: ${severity.name}');
  }

  static void addAttachment(String name, String content,
      {String type = 'text/plain'}) {
    TestLogger.log('Attachment: $name (${content.length} chars)');
    if (content.length < 500) {
      TestLogger.log('Content: $content');
    }
  }

  static void _reset() {
    _currentTestName = null;
    _steps.clear();
    _labels.clear();
    _severity = AllureSeverity.normal;
  }
}

enum AllureStepStatus {
  passed,
  failed,
  broken,
  skipped,
}

enum AllureTestStatus {
  passed,
  failed,
  broken,
  skipped,
}

enum AllureSeverity {
  blocker,
  critical,
  normal,
  minor,
  trivial,
}
