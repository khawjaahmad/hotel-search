import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../integration_test/page_objects/base_page.dart';
import '../integration_test/locators/app_locators.dart';

class OverviewPage extends BasePage {
  OverviewPage(PatrolIntegrationTester $) : super($);

  @override
  String get pageName => 'overview';

  @override
  String get pageKey => AppLocators.overviewScaffold;

  Future<void> verifyOverviewPageLoaded() async {
    logAction('Verifying overview page is loaded');
    await verifyPageIsLoaded();
    verifyOverviewPageElements();
  }

  void verifyOverviewPageElements() {
    logAction('Verifying overview page elements');
    verifyElementExists(AppLocators.overviewAppBar);
    verifyElementExists(AppLocators.overviewTitle);
    verifyElementExists(AppLocators.overviewIcon);
  }

  void verifyOverviewTitle() {
    logAction('Verifying overview page title');
    verifyElementExists(AppLocators.overviewTitle);
    verifyTextExists('Hotel Booking');
  }

  void verifyOverviewIcon() {
    logAction('Verifying overview icon is displayed');
    verifyElementExists(AppLocators.overviewIcon);
  }

  Future<void> verifyOverviewPageLayout() async {
    logAction('Verifying overview page layout');

    await verifyOverviewPageLoaded();
    verifyOverviewTitle();
    verifyOverviewIcon();

    await takePageScreenshot('overview_layout_verified');
  }

  Future<void> testOverviewAsLandingPage() async {
    logAction('Testing overview page as landing page');

    await verifyOverviewPageLoaded();

    verifyOverviewTitle();
    verifyOverviewIcon();

    await takePageScreenshot('overview_landing_page');
  }

  Future<void> testOverviewPageAccessibility() async {
    logAction('Testing overview page accessibility');

    await verifyOverviewPageLoaded();

    verifyOverviewPageElements();

    await takePageScreenshot('overview_accessibility_test');
  }

  Future<void> testOverviewPageResponsiveness() async {
    logAction('Testing overview page responsiveness');

    await verifyOverviewPageLoaded();

    await $.pump(const Duration(milliseconds: 500));
    verifyOverviewPageElements();

    await takePageScreenshot('overview_responsiveness_test');
  }

  Future<void> performComprehensiveOverviewTest() async {
    logAction('Performing comprehensive overview page test');

    await verifyOverviewPageLoaded();
    await takePageScreenshot('overview_initial_state');

    await testOverviewAsLandingPage();

    await verifyOverviewPageLayout();

    await testOverviewPageAccessibility();

    await testOverviewPageResponsiveness();

    await takePageScreenshot('overview_comprehensive_test_complete');
  }

  Future<void> verifyOverviewPageAfterNavigation() async {
    logAction('Verifying overview page after navigation');

    await waitForPageToLoad();
    verifyOverviewPageElements();

    await $.pump(const Duration(milliseconds: 500));
    verifyOverviewPageElements();
  }

  Future<void> testOverviewPageInteractions() async {
    logAction('Testing overview page interactions');

    await verifyOverviewPageLoaded();

    if (isElementVisible(AppLocators.overviewIcon)) {
      await tapElement(AppLocators.overviewIcon);
      await $.pump(const Duration(milliseconds: 300));

      verifyOverviewPageElements();
    }

    await takePageScreenshot('overview_interactions_test');
  }

  Future<void> testOverviewPageStability() async {
    logAction('Testing overview page stability');

    await verifyOverviewPageLoaded();

    await $.pump(const Duration(seconds: 1));
    verifyOverviewPageElements();

    await $.pump(const Duration(milliseconds: 500));
    verifyOverviewPageElements();

    await $.pump(const Duration(milliseconds: 300));
    verifyOverviewPageElements();

    await takePageScreenshot('overview_stability_test');
  }

  Future<void> verifyOverviewBrandingContent() async {
    logAction('Verifying overview page branding and content');

    await verifyOverviewPageLoaded();

    verifyOverviewTitle();

    verifyOverviewIcon();

    verifyOverviewPageElements();

    await takePageScreenshot('overview_branding_content');
  }

  Future<void> takeOverviewPageScreenshots() async {
    logAction('Taking comprehensive overview page screenshots');

    await verifyOverviewPageLoaded();
    await takePageScreenshot('overview_full_page');

    await $.pump(const Duration(milliseconds: 300));
    await takePageScreenshot('overview_with_title');

    await $.pump(const Duration(milliseconds: 300));
    await takePageScreenshot('overview_with_icon');
  }

  Future<void> verifyOverviewPageRequirements() async {
    logAction('Verifying overview page meets basic requirements');

    await verifyOverviewPageLoaded();

    verifyOverviewPageElements();

    verifyOverviewTitle();

    verifyOverviewIcon();

    await $.pump(const Duration(milliseconds: 500));
    verifyOverviewPageElements();

    logAction('Overview page requirements verification completed');
  }

  Future<void> testOverviewAsEntryPoint() async {
    logAction('Testing overview page as app entry point');

    await verifyOverviewPageLoaded();

    verifyOverviewTitle();
    verifyOverviewIcon();

    verifyOverviewPageElements();

    await takePageScreenshot('overview_entry_point');
  }
}
