import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// Import all your test groups
import 'tests/dashboard_test.dart' as dashboard_tests;
import 'tests/overview_test.dart' as overview_tests;
import 'tests/hotels_test.dart' as hotels_tests;
import 'tests/account_test.dart' as account_tests;

void main() {
  // Initialize Patrol binding ONCE at the top level
  setUpAll(() async {
    // This ensures Patrol binding is initialized only once
    PatrolBinding.ensureInitialized();
  });

  group('Hotel Booking App - Complete Integration Test Suite', () {
    // Run all test suites
    group('Dashboard Tests', dashboard_tests.main);
    group('Overview Tests', overview_tests.main);
    group('Hotels Tests', hotels_tests.main);
    group('Account Tests', account_tests.main);
  });
}
