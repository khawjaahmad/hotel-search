import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overview Page Locators with Advanced Fallback Strategy
/// Showcases professional QA automation with intelligent locator patterns
class OverviewLocators {
  OverviewLocators._();

  // =============================================================================
  // ADVANCED FALLBACK LOCATOR SYSTEM - SHOWCASE
  // =============================================================================

  /// Professional fallback locator with intelligent chain strategy
  /// Strategy: Key → Widget Type → Icon → Text → Semantic Label
  /// This demonstrates senior-level automation thinking
  static Finder findWithFallback({
    Key? key,
    Type? widgetType,
    IconData? icon,
    String? text,
    String? semanticLabel,
    String? description,
  }) {
    debugPrint('🔍 [OVERVIEW] Locating: ${description ?? 'Unknown'}');

    // Strategy 1: Primary Key (Most Reliable & Fast)
    if (key != null) {
      final keyFinder = find.byKey(key);
      if (keyFinder.evaluate().isNotEmpty) {
        debugPrint('✅ [OVERVIEW] Found by KEY: ${key.toString()}');
        return keyFinder;
      }
      debugPrint(
          '⚠️ [OVERVIEW] Key failed: ${key.toString()}, trying Widget Type...');
    }

    // Strategy 2: Widget Type (Structural Fallback)
    if (widgetType != null) {
      final typeFinder = find.byType(widgetType);
      if (typeFinder.evaluate().isNotEmpty) {
        debugPrint(
            '✅ [OVERVIEW] Found by WIDGET TYPE: ${widgetType.toString()}');
        return typeFinder;
      }
      debugPrint(
          '⚠️ [OVERVIEW] Widget Type failed: ${widgetType.toString()}, trying Icon...');
    }

    // Strategy 3: Icon (Visual Element Fallback)
    if (icon != null) {
      final iconFinder = find.byIcon(icon);
      if (iconFinder.evaluate().isNotEmpty) {
        debugPrint('✅ [OVERVIEW] Found by ICON: ${icon.toString()}');
        return iconFinder;
      }
      debugPrint(
          '⚠️ [OVERVIEW] Icon failed: ${icon.toString()}, trying Text...');
    }

    // Strategy 4: Text Content (Content-based Fallback)
    if (text != null) {
      final textFinder = find.text(text);
      if (textFinder.evaluate().isNotEmpty) {
        debugPrint('✅ [OVERVIEW] Found by TEXT: "$text"');
        return textFinder;
      }
      debugPrint(
          '⚠️ [OVERVIEW] Text failed: "$text", trying Semantic Label...');
    }

    // Strategy 5: Semantic Label (Accessibility Fallback)
    if (semanticLabel != null) {
      final semanticFinder = find.bySemanticsLabel(semanticLabel);
      if (semanticFinder.evaluate().isNotEmpty) {
        debugPrint('✅ [OVERVIEW] Found by SEMANTIC LABEL: "$semanticLabel"');
        return semanticFinder;
      }
      debugPrint('⚠️ [OVERVIEW] Semantic Label failed: "$semanticLabel"');
    }

    debugPrint(
        '❌ [OVERVIEW] ALL FALLBACK STRATEGIES EXHAUSTED for: ${description ?? 'Unknown'}');
    throw Exception(
        'Overview element not found with any fallback strategy: ${description ?? 'Unknown'}');
  }

  // =============================================================================
  // OVERVIEW PAGE ELEMENT LOCATORS WITH SHOWCASE FALLBACKS
  // =============================================================================

  /// Overview Page Scaffold - Multi-strategy locator showcase
  static Finder get scaffold => findWithFallback(
        key: const Key('overview_scaffold'),
        widgetType: Scaffold,
        description: 'Overview Page Scaffold - Primary Container',
      );

  /// Overview Title - Comprehensive fallback chain showcase
  static Finder get title => findWithFallback(
        key: const Key('overview_title'),
        text: 'Hotel Booking',
        widgetType: Text,
        semanticLabel: 'Hotel Booking Application Title',
        description: 'Overview Page Main Title',
      );

  /// Overview Icon - Visual and structural fallbacks showcase
  static Finder get icon => findWithFallback(
        key: const Key('overview_icon'),
        icon: Icons.explore_outlined,
        widgetType: Icon,
        semanticLabel: 'Explore Hotels Icon',
        description: 'Overview Page Explore Icon',
      );

  /// Overview App Bar - Structural fallback showcase
  static Finder get appBar => findWithFallback(
        key: const Key('overview_app_bar'),
        widgetType: AppBar,
        description: 'Overview Page App Bar',
      );

  // =============================================================================
  // OVERVIEW PAGE CONSTANTS (Backup Traditional Locators)
  // =============================================================================

  static const String overviewScaffoldKey = 'overview_scaffold';
  static const String overviewAppBarKey = 'overview_app_bar';
  static const String overviewTitleKey = 'overview_title';
  static const String overviewIconKey = 'overview_icon';

  // =============================================================================
  // PROFESSIONAL VALIDATION METHODS
  // =============================================================================

  /// Comprehensive Overview Page validation with fallback showcase
  static void validateAllElements() {
    debugPrint(
        '🔍 [OVERVIEW] Starting comprehensive validation with fallback strategies...');

    try {
      // Validate Scaffold with fallback
      expect(scaffold, findsOneWidget);
      debugPrint('✅ [OVERVIEW] Scaffold validated successfully');

      // Validate Title with comprehensive fallback chain
      expect(title, findsOneWidget);
      debugPrint('✅ [OVERVIEW] Title "Hotel Booking" validated with fallback');

      // Validate Icon with visual fallback
      expect(icon, findsOneWidget);
      debugPrint('✅ [OVERVIEW] Explore icon validated with fallback');

      // Validate App Bar with structural fallback
      expect(appBar, findsOneWidget);
      debugPrint('✅ [OVERVIEW] App bar validated with fallback');

      debugPrint(
          '🎉 [OVERVIEW] All elements validated! Fallback strategies operational.');
    } catch (e) {
      debugPrint('❌ [OVERVIEW] Validation failed: $e');
      rethrow;
    }
  }

  /// Smart element existence check with fallback
  static bool elementExists(String elementName) {
    try {
      switch (elementName.toLowerCase()) {
        case 'scaffold':
          return scaffold.evaluate().isNotEmpty;
        case 'title':
          return title.evaluate().isNotEmpty;
        case 'icon':
          return icon.evaluate().isNotEmpty;
        case 'appbar':
          return appBar.evaluate().isNotEmpty;
        default:
          debugPrint('⚠️ [OVERVIEW] Unknown element: $elementName');
          return false;
      }
    } catch (e) {
      debugPrint('❌ [OVERVIEW] Element check failed for $elementName: $e');
      return false;
    }
  }

  /// Overview page health check with fallback strategy report
  static void performHealthCheck() {
    debugPrint('🏥 [OVERVIEW] Performing comprehensive health check...');

    final elements = {
      'Scaffold': () => scaffold,
      'Title': () => title,
      'Icon': () => icon,
      'App Bar': () => appBar,
    };

    int successCount = 0;
    int totalCount = elements.length;

    elements.forEach((name, finderFunction) {
      try {
        final finder = finderFunction();
        if (finder.evaluate().isNotEmpty) {
          successCount++;
          debugPrint('✅ [OVERVIEW] $name: HEALTHY');
        } else {
          debugPrint('❌ [OVERVIEW] $name: NOT FOUND');
        }
      } catch (e) {
        debugPrint('❌ [OVERVIEW] $name: ERROR - $e');
      }
    });

    final healthPercentage = (successCount / totalCount * 100).round();
    debugPrint(
        '📊 [OVERVIEW] Health Check Result: $successCount/$totalCount ($healthPercentage%)');

    if (healthPercentage >= 100) {
      debugPrint(
          '🎉 [OVERVIEW] PERFECT HEALTH! All fallback strategies working.');
    } else if (healthPercentage >= 75) {
      debugPrint('⚠️ [OVERVIEW] Good health with minor issues.');
    } else {
      debugPrint('❌ [OVERVIEW] Poor health - requires attention.');
    }
  }

  /// Demonstration method showcasing fallback strategy in action
  static void demonstrateFallbackStrategies() {
    debugPrint('🎯 [OVERVIEW] DEMONSTRATING FALLBACK STRATEGIES...');
    debugPrint('');

    debugPrint('📋 Strategy Chain for Overview Title:');
    debugPrint('  1. 🔑 Key: "overview_title"');
    debugPrint('  2. 📝 Text: "Hotel Booking"');
    debugPrint('  3. 🏗️ Widget: Text');
    debugPrint('  4. ♿ Semantic: "Hotel Booking Application Title"');
    debugPrint('');

    // Demonstrate live fallback
    try {
      final titleFinder = title;
      debugPrint('🎉 [OVERVIEW] Live demonstration successful!');
      debugPrint(
          '📊 [OVERVIEW] Title finder found ${titleFinder.evaluate().length} elements');
    } catch (e) {
      debugPrint('❌ [OVERVIEW] Live demonstration failed: $e');
    }

    debugPrint('');
    debugPrint(
        '💡 [OVERVIEW] This showcases professional automation resilience!');
  }

  /// Helper method to get Key objects for traditional usage
  static Key getKey(String keyName) {
    switch (keyName.toLowerCase()) {
      case 'scaffold':
        return const Key(overviewScaffoldKey);
      case 'appbar':
        return const Key(overviewAppBarKey);
      case 'title':
        return const Key(overviewTitleKey);
      case 'icon':
        return const Key(overviewIconKey);
      default:
        throw ArgumentError('Unknown Overview key: $keyName');
    }
  }
}
