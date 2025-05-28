import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hotel_booking/core/di/injectable.dart';
import 'package:hotel_booking/main.dart' as app show App;
import 'package:path_provider/path_provider.dart';
import 'package:patrol/patrol.dart';

import '../locators/app_locators.dart';
import '../logger/test_logger.dart';

class TestHelpers {
  static bool _dependenciesConfigured = false;

  static Future<void> configureDependenciesForTest() async {
    if (_dependenciesConfigured) {
      TestLogger.log('Dependencies already configured, skipping');
      return;
    }

    try {
      TestLogger.log('Configuring dependencies for test');

      await GetIt.instance.reset();

      await _initializeHiveForTesting();

      configureDependencies();

      _dependenciesConfigured = true;
      TestLogger.log('Dependencies configured successfully');
    } catch (e, stackTrace) {
      TestLogger.log('Failed to configure dependencies: $e');
      TestLogger.log('Stack trace: $stackTrace');
      _dependenciesConfigured = false;
      rethrow;
    }
  }

  static Future<void> _initializeHiveForTesting() async {
    try {
      TestLogger.log('Initializing Hive for testing');

      final Directory tempDir = await getTemporaryDirectory();
      final String testHiveDir =
          '${tempDir.path}/test_hive_${DateTime.now().millisecondsSinceEpoch}';

      final Directory hiveDir = Directory(testHiveDir);
      if (!await hiveDir.exists()) {
        await hiveDir.create(recursive: true);
      }

      Hive.defaultDirectory = hiveDir.path;

      TestLogger.log('Hive directory set to: ${hiveDir.path}');
    } catch (e, stackTrace) {
      TestLogger.log('Failed to initialize Hive for testing: $e');
      TestLogger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> initializeApp(PatrolIntegrationTester $) async {
    TestLogger.log('Initializing app with Patrol Integration Testing');

    try {
      await configureDependenciesForTest();

      TestLogger.log('Pumping app widget with Patrol binding');
      await $.pumpWidgetAndSettle(
        app.App(),
        duration: const Duration(seconds: 5),
      );

      await $.pump(const Duration(milliseconds: 500));

      TestLogger.log('App initialization completed successfully');
    } catch (e, stackTrace) {
      TestLogger.log('App initialization failed: $e');
      TestLogger.log('Stack trace: $stackTrace');
      _dependenciesConfigured = false;
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

    try {
      final tabFinder = AppLocators.getNavigationTab($, tabName);

      await tabFinder.waitUntilVisible();

      await tabFinder.tap();

      await $.pump(const Duration(milliseconds: 500));
      await $.pumpAndSettle();

      TestLogger.log('Successfully navigated to $tabName');
    } catch (e, stackTrace) {
      TestLogger.log('Navigation to $tabName failed: $e');
      TestLogger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> cleanUpTest() async {
    TestLogger.log('Cleaning up test state');
    try {
      Hive.closeAllBoxes();

      if (_dependenciesConfigured) {
        await GetIt.instance.reset();
        _dependenciesConfigured = false;
      }

      TestLogger.log('Test cleanup completed');
    } catch (e) {
      TestLogger.log('Test cleanup failed: $e');
    }
  }

  static void resetTestState() {
    _dependenciesConfigured = false;
    TestLogger.log('Test state reset');
  }
}
