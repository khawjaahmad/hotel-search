import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hotel_booking/core/di/injectable.dart';
import 'package:hotel_booking/main.dart' as app show App;
import 'package:path_provider/path_provider.dart';
import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';
import 'test_logger.dart';

class TestHelpers {
  static bool _dependenciesConfigured = false;

  static Future<void> configureDependenciesForTest() async {
    if (_dependenciesConfigured) {
      return;
    }

    try {
      await GetIt.instance.reset();
      await _initializeHiveForTesting();
      configureDependencies();
      _dependenciesConfigured = true;
    } catch (e) {
      _dependenciesConfigured = false;
      rethrow;
    }
  }

  static Future<void> _initializeHiveForTesting() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String testHiveDir =
          '${tempDir.path}/test_hive_${DateTime.now().millisecondsSinceEpoch}';

      final Directory hiveDir = Directory(testHiveDir);
      if (!await hiveDir.exists()) {
        await hiveDir.create(recursive: true);
      }

      Hive.defaultDirectory = hiveDir.path;
    } catch (e) {
      rethrow;
    }
  }

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
    }
  }

  static void resetTestState() {
    _dependenciesConfigured = false;
  }
}
