import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'base_page.dart';
import '../locators/app_locators.dart';

class AccountPage extends BasePage {
  AccountPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'account';

  @override
  String get pageKey => AppLocators.accountScaffold;

  Future<void> verifyAccountPageLoaded() async {
    logAction('Verifying account page is loaded');
    await verifyPageIsLoaded();
    verifyAccountPageElements();
  }

  void verifyAccountPageElements() {
    logAction('Verifying account page elements');
    verifyElementExists(AppLocators.accountAppBar);
    verifyElementExists(AppLocators.accountTitle);
    verifyElementExists(AppLocators.accountIcon);
  }

  void verifyAccountTitle() {
    logAction('Verifying account page title');
    verifyElementExists(AppLocators.accountTitle);
    verifyTextExists('Your Account');
  }

  void verifyAccountIcon() {
    logAction('Verifying account icon is displayed');
    verifyElementExists(AppLocators.accountIcon);
  }

  Future<void> verifyAccountPageLayout() async {
    logAction('Verifying account page layout');

    await verifyAccountPageLoaded();
    verifyAccountTitle();
    verifyAccountIcon();

    await takePageScreenshot('account_layout_verified');
  }

  Future<void> testAccountPageAccessibility() async {
    logAction('Testing account page accessibility');

    await verifyAccountPageLoaded();

    verifyAccountPageElements();

    await takePageScreenshot('account_accessibility_test');
  }

  Future<void> testAccountPageResponsiveness() async {
    logAction('Testing account page responsiveness');

    await verifyAccountPageLoaded();

    await $.pump(const Duration(milliseconds: 500));
    verifyAccountPageElements();

    await takePageScreenshot('account_responsiveness_test');
  }

  Future<void> performComprehensiveAccountTest() async {
    logAction('Performing comprehensive account page test');

    await verifyAccountPageLoaded();
    await takePageScreenshot('account_initial_state');

    await verifyAccountPageLayout();

    await testAccountPageAccessibility();

    await testAccountPageResponsiveness();

    await takePageScreenshot('account_comprehensive_test_complete');
  }

  Future<void> verifyAccountPageAfterNavigation() async {
    logAction('Verifying account page after navigation');

    await waitForPageToLoad();
    verifyAccountPageElements();

    await $.pump(const Duration(milliseconds: 500));
    verifyAccountPageElements();
  }

  Future<void> testAccountPageInteractions() async {
    logAction('Testing account page interactions');

    await verifyAccountPageLoaded();

    if (isElementVisible(AppLocators.accountIcon)) {
      await tapElement(AppLocators.accountIcon);
      await $.pump(const Duration(milliseconds: 300));

      verifyAccountPageElements();
    }

    await takePageScreenshot('account_interactions_test');
  }

  Future<void> testAccountPagePersistence() async {
    logAction('Testing account page persistence');

    await verifyAccountPageLoaded();

    await $.pump(const Duration(seconds: 1));
    verifyAccountPageElements();

    await $.pump(const Duration(milliseconds: 500));
    verifyAccountPageElements();

    await takePageScreenshot('account_persistence_test');
  }

  Future<void> takeAccountPageScreenshots() async {
    logAction('Taking comprehensive account page screenshots');

    await verifyAccountPageLoaded();
    await takePageScreenshot('account_full_page');

    await $.pump(const Duration(milliseconds: 300));
    await takePageScreenshot('account_with_title');

    await $.pump(const Duration(milliseconds: 300));
    await takePageScreenshot('account_with_icon');
  }

  Future<void> verifyAccountPageRequirements() async {
    logAction('Verifying account page meets basic requirements');

    await verifyAccountPageLoaded();

    verifyAccountPageElements();

    verifyAccountTitle();

    verifyAccountIcon();

    await $.pump(const Duration(milliseconds: 500));
    verifyAccountPageElements();

    logAction('Account page requirements verification completed');
  }
}
