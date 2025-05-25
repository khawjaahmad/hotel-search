import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_helper.dart';

abstract class BasePage {
  final PatrolIntegrationTester $;

  BasePage(this.$);

  String get pageName;

  String get pageKey;

  Future<void> verifyPageIsLoaded() async {
    await PatrolTestHelper.waitForWidget($, find.byKey(Key(pageKey)));
    PatrolTestHelper.verifyWidgetExists(pageKey);
  }

  Future<void> waitForPageToLoad({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await PatrolTestHelper.waitForWidget(
      $,
      find.byKey(Key(pageKey)),
      timeout: timeout,
    );
    await PatrolTestHelper.waitForLoadingToComplete($);
  }

  Future<void> takePageScreenshot([String? suffix]) async {
    final screenshotName = suffix != null ? '${pageName}_$suffix' : pageName;
    await PatrolTestHelper.takeScreenshot($, screenshotName);
  }

  Future<void> tapElement(String key) async {
    await PatrolTestHelper.tapByKey($, key);
  }

  Future<void> enterText(String key, String text) async {
    await PatrolTestHelper.enterTextByKey($, key, text);
  }

  void verifyElementExists(String key) {
    PatrolTestHelper.verifyWidgetExists(key);
  }

  void verifyElementNotExists(String key) {
    PatrolTestHelper.verifyWidgetNotExists(key);
  }

  void verifyTextExists(String text) {
    PatrolTestHelper.verifyTextExists(text);
  }

  Future<void> waitForElement(
    String key, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await PatrolTestHelper.waitForWidget(
      $,
      find.byKey(Key(key)),
      timeout: timeout,
    );
  }

  Future<void> waitForElementToDisappear(
    String key, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await PatrolTestHelper.waitForWidgetToDisappear(
      $,
      find.byKey(Key(key)),
      timeout: timeout,
    );
  }

  Future<void> scrollToElement(
    String scrollableKey,
    String targetKey, {
    double delta = 100,
    int maxScrolls = 10,
  }) async {
    await PatrolTestHelper.scrollUntilVisible(
      $,
      scrollableKey,
      targetKey,
      delta: delta,
      maxScrolls: maxScrolls,
    );
  }

  Future<void> waitAndVerify(
    String elementKey, {
    Duration timeout = const Duration(seconds: 10),
    String? expectedText,
  }) async {
    await waitForElement(elementKey, timeout: timeout);
    verifyElementExists(elementKey);

    if (expectedText != null) {
      verifyTextExists(expectedText);
    }
  }

  Future<void> waitForLoadingToComplete() async {
    await PatrolTestHelper.waitForLoadingToComplete($);
  }

  Future<void> clearTextField(String key) async {
    await PatrolTestHelper.clearTextByKey($, key);
  }

  bool isElementVisible(String key) {
    return find.byKey(Key(key)).evaluate().isNotEmpty;
  }

  void logAction(String action) {
    debugPrint('[$pageName] $action');
  }
}
