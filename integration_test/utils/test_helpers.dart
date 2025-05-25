import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;
import '../locators/app_locators.dart';
import '../logger/test_logger.dart';

class TestHelpers {
  static bool _isAppInitialized = false;

  static Future<void> initializeApp(PatrolIntegrationTester $) async {
    TestLogger.log('Initializing app for testing');

    try {
      if (!_isAppInitialized) {
        TestLogger.log('First-time app initialization');
        app.main();
        await $.pump(const Duration(seconds: 3));
        _isAppInitialized = true;
      } else {
        TestLogger.log('App already initialized, pumping frames');
        await $.pump(const Duration(seconds: 1));
      }

      await $.pumpAndSettle();
      await $.pump(const Duration(milliseconds: 500));

      TestLogger.log('App initialization completed successfully');
    } catch (e) {
      TestLogger.log('App initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> navigateToPage(
    PatrolIntegrationTester $,
    String tabName, {
    String? description,
  }) async {
    TestLogger.log(
        'Navigating to $tabName tab${description != null ? ': $description' : ''}');
    final tabFinder = AppLocators.getNavigationTab($, tabName);
    await AppLocators.smartTap($, tabFinder, description: description);
  }

  static Future<void> validatePageElements(
    PatrolIntegrationTester $,
    String pageKey,
    List<PatrolFinder> elements, {
    String? pageName,
    String? description,
  }) async {
    TestLogger.log(
        'Validating page structure for $pageKey${description != null ? ': $description' : ''}');
    await AppLocators.validatePageStructure(
      $,
      pageKey,
      requiredElements: elements,
      pageName: pageName,
    );
  }

  static Future<bool> isElementVisible(
    PatrolIntegrationTester $,
    PatrolFinder finder, {
    String? description,
  }) async {
    TestLogger.log(
        'Checking visibility of element${description != null ? ': $description' : ''}');
    try {
      return finder.exists;
    } catch (e) {
      TestLogger.log('Element visibility check failed: $e');
      return false;
    }
  }

  static Future<void> waitForAppStability(PatrolIntegrationTester $) async {
    TestLogger.log('Waiting for app stability');
    await $.pumpAndSettle();
    await $.pump(const Duration(milliseconds: 500));
  }

  static void resetAppState() {
    TestLogger.log('Resetting app initialization state');
    _isAppInitialized = false;
  }
}
