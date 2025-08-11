import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Advanced Test Data Management System
/// Demonstrates senior-level automation patterns:
/// - Data-driven testing
/// - Test data factories
/// - Environment-specific configurations
/// - Dynamic data generation
/// - Test data isolation
class TestDataManager {
  static final TestDataManager _instance = TestDataManager._internal();
  factory TestDataManager() => _instance;
  TestDataManager._internal();

  final Map<String, dynamic> _testData = {};
  final Map<String, TestDataSet> _dataSets = {};
  final Random _random = Random();

  /// Initialize test data from various sources
  Future<void> initialize() async {
    await _loadStaticTestData();
    await _loadEnvironmentSpecificData();
    _generateDynamicTestData();
  }

  /// Load static test data from JSON files
  Future<void> _loadStaticTestData() async {
    try {
      final searchQueries = await _loadJsonData('search_queries.json');
      final hotelData = await _loadJsonData('hotel_test_data.json');
      final userProfiles = await _loadJsonData('user_profiles.json');

      _testData['searchQueries'] = searchQueries;
      _testData['hotels'] = hotelData;
      _testData['users'] = userProfiles;
    } catch (e) {
      // Fallback to hardcoded data if files don't exist
      _loadFallbackData();
    }
  }

  /// Load environment-specific test data
  Future<void> _loadEnvironmentSpecificData() async {
    final environment = Platform.environment['TEST_ENV'] ?? 'dev';
    
    try {
      final envData = await _loadJsonData('test_data_$environment.json');
      _testData['environment'] = envData;
    } catch (e) {
      _testData['environment'] = _getDefaultEnvironmentData(environment);
    }
  }

  /// Generate dynamic test data for each test run
  void _generateDynamicTestData() {
    _testData['dynamic'] = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'sessionId': _generateSessionId(),
      'randomSeed': _random.nextInt(1000000),
    };
  }

  /// Load JSON data from file
  Future<Map<String, dynamic>> _loadJsonData(String fileName) async {
    final file = File('integration_test/test_data/$fileName');
    if (await file.exists()) {
      final content = await file.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    }
    throw FileSystemException('Test data file not found: $fileName');
  }

  /// Fallback data when files are not available
  void _loadFallbackData() {
    _testData['searchQueries'] = {
      'valid': ['Dubai', 'London', 'Paris', 'Tokyo', 'New York', 'Berlin'],
      'invalid': ['', '   ', '!@#\$%^&*()', 'x' * 1000],
      'edge_cases': ['a', 'AB', '123', 'Hotel-Name', 'Café París']
    };

    _testData['hotels'] = {
      'sample_hotels': [
        {
          'name': 'Grand Hotel Dubai',
          'location': 'Dubai, UAE',
          'rating': 4.5,
          'price': 250
        },
        {
          'name': 'London Palace',
          'location': 'London, UK',
          'rating': 4.2,
          'price': 180
        }
      ]
    };

    _testData['users'] = {
      'test_user': {
        'name': 'Test User',
        'email': 'test@example.com',
        'preferences': ['luxury', 'business']
      }
    };
  }

  /// Get default environment data
  Map<String, dynamic> _getDefaultEnvironmentData(String environment) {
    switch (environment) {
      case 'prod':
        return {
          'api_timeout': 30000,
          'max_retries': 3,
          'performance_threshold': 2000
        };
      case 'staging':
        return {
          'api_timeout': 20000,
          'max_retries': 2,
          'performance_threshold': 3000
        };
      default: // dev
        return {
          'api_timeout': 10000,
          'max_retries': 1,
          'performance_threshold': 5000
        };
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Get search queries for testing
  List<String> getSearchQueries({String type = 'valid'}) {
    final queries = _testData['searchQueries']?[type] as List<dynamic>?;
    return queries?.cast<String>() ?? ['Dubai'];
  }

  /// Get random search query
  String getRandomSearchQuery({String type = 'valid'}) {
    final queries = getSearchQueries(type: type);
    return queries[_random.nextInt(queries.length)];
  }

  /// Get test data set for specific scenario
  TestDataSet getDataSet(String scenario) {
    if (!_dataSets.containsKey(scenario)) {
      _dataSets[scenario] = _createDataSet(scenario);
    }
    return _dataSets[scenario]!;
  }

  /// Create data set for specific scenario
  TestDataSet _createDataSet(String scenario) {
    switch (scenario) {
      case 'search_functionality':
        return SearchTestDataSet(this);
      case 'favorites_management':
        return FavoritesTestDataSet(this);
      case 'performance_testing':
        return PerformanceTestDataSet(this);
      case 'error_scenarios':
        return ErrorScenarioDataSet(this);
      case 'cross_platform':
        return CrossPlatformDataSet(this);
      default:
        return DefaultTestDataSet(this);
    }
  }

  /// Get environment configuration
  Map<String, dynamic> getEnvironmentConfig() {
    return Map<String, dynamic>.from(_testData['environment'] ?? {});
  }

  /// Get dynamic test data
  Map<String, dynamic> getDynamicData() {
    return Map<String, dynamic>.from(_testData['dynamic'] ?? {});
  }

  /// Clean up test data after test execution
  void cleanup() {
    _dataSets.clear();
    // Keep static data for reuse
  }

  /// Reset dynamic data for new test session
  void resetSession() {
    _generateDynamicTestData();
    _dataSets.clear();
  }
}

/// Base class for test data sets
abstract class TestDataSet {
  final TestDataManager manager;
  
  TestDataSet(this.manager);
  
  /// Get test data for the scenario
  Map<String, dynamic> getData();
  
  /// Validate test data
  bool validate();
  
  /// Get test parameters
  List<TestParameter> getParameters();
}

/// Search functionality test data
class SearchTestDataSet extends TestDataSet {
  SearchTestDataSet(super.manager);

  @override
  Map<String, dynamic> getData() {
    return {
      'valid_queries': manager.getSearchQueries(type: 'valid'),
      'invalid_queries': manager.getSearchQueries(type: 'invalid'),
      'edge_cases': manager.getSearchQueries(type: 'edge_cases'),
      'performance_queries': _getPerformanceQueries(),
      'localization_queries': _getLocalizationQueries(),
    };
  }

  @override
  bool validate() {
    final data = getData();
    return data['valid_queries'].isNotEmpty &&
           data['invalid_queries'].isNotEmpty;
  }

  @override
  List<TestParameter> getParameters() {
    return [
      TestParameter('query', manager.getRandomSearchQuery()),
      TestParameter('timeout', manager.getEnvironmentConfig()['api_timeout']),
      TestParameter('retries', manager.getEnvironmentConfig()['max_retries']),
    ];
  }

  List<String> _getPerformanceQueries() {
    return ['a', 'ab', 'abc', 'hotel', 'luxury hotel', 'business hotel suite'];
  }

  List<String> _getLocalizationQueries() {
    return ['Hôtel', 'Café', 'Москва', '東京', '北京', 'São Paulo'];
  }
}

/// Favorites management test data
class FavoritesTestDataSet extends TestDataSet {
  FavoritesTestDataSet(super.manager);

  @override
  Map<String, dynamic> getData() {
    return {
      'hotels_to_favorite': _getHotelsToFavorite(),
      'batch_operations': _getBatchOperations(),
      'stress_test_data': _getStressTestData(),
    };
  }

  @override
  bool validate() {
    final data = getData();
    return data['hotels_to_favorite'].isNotEmpty;
  }

  @override
  List<TestParameter> getParameters() {
    return [
      TestParameter('hotel_indices', [0, 1, 2]),
      TestParameter('batch_size', 5),
      TestParameter('stress_count', 20),
    ];
  }

  List<int> _getHotelsToFavorite() {
    return [0, 1, 2, 3, 4]; // Hotel indices to favorite
  }

  List<Map<String, dynamic>> _getBatchOperations() {
    return [
      {'action': 'add', 'indices': [0, 1, 2]},
      {'action': 'remove', 'indices': [1]},
      {'action': 'add', 'indices': [3, 4]},
      {'action': 'clear_all', 'indices': []},
    ];
  }

  Map<String, dynamic> _getStressTestData() {
    return {
      'rapid_operations': 50,
      'concurrent_users': 3,
      'operation_delay': 100, // milliseconds
    };
  }
}

/// Performance testing data
class PerformanceTestDataSet extends TestDataSet {
  PerformanceTestDataSet(super.manager);

  @override
  Map<String, dynamic> getData() {
    return {
      'load_test_queries': _getLoadTestQueries(),
      'memory_test_data': _getMemoryTestData(),
      'network_scenarios': _getNetworkScenarios(),
      'thresholds': manager.getEnvironmentConfig(),
    };
  }

  @override
  bool validate() {
    final data = getData();
    return data['thresholds']['performance_threshold'] != null;
  }

  @override
  List<TestParameter> getParameters() {
    return [
      TestParameter('max_response_time', manager.getEnvironmentConfig()['performance_threshold']),
      TestParameter('memory_threshold', 100), // MB
      TestParameter('fps_threshold', 60),
    ];
  }

  List<String> _getLoadTestQueries() {
    return List.generate(100, (index) => 'Query $index');
  }

  Map<String, dynamic> _getMemoryTestData() {
    return {
      'large_result_sets': true,
      'image_loading': true,
      'cache_stress': true,
    };
  }

  List<Map<String, dynamic>> _getNetworkScenarios() {
    return [
      {'type': 'slow_network', 'delay': 3000},
      {'type': 'intermittent', 'failure_rate': 0.3},
      {'type': 'timeout', 'timeout': 1000},
    ];
  }
}

/// Error scenario test data
class ErrorScenarioDataSet extends TestDataSet {
  ErrorScenarioDataSet(super.manager);

  @override
  Map<String, dynamic> getData() {
    return {
      'invalid_inputs': _getInvalidInputs(),
      'boundary_conditions': _getBoundaryConditions(),
      'system_errors': _getSystemErrors(),
      'recovery_scenarios': _getRecoveryScenarios(),
    };
  }

  @override
  bool validate() {
    return true; // Error scenarios are always valid
  }

  @override
  List<TestParameter> getParameters() {
    return [
      TestParameter('error_tolerance', 3),
      TestParameter('recovery_timeout', 5000),
      TestParameter('retry_attempts', manager.getEnvironmentConfig()['max_retries']),
    ];
  }

  List<Map<String, dynamic>> _getInvalidInputs() {
    return [
      {'input': '', 'expected': 'empty_input_error'},
      {'input': '   ', 'expected': 'whitespace_error'},
      {'input': '!@#\$%^&*()', 'expected': 'special_chars_error'},
      {'input': 'x' * 1000, 'expected': 'length_limit_error'},
    ];
  }

  List<Map<String, dynamic>> _getBoundaryConditions() {
    return [
      {'condition': 'min_length', 'value': 1},
      {'condition': 'max_length', 'value': 255},
      {'condition': 'unicode_chars', 'value': '🏨🌟⭐'},
    ];
  }

  List<String> _getSystemErrors() {
    return [
      'network_timeout',
      'server_error',
      'memory_limit',
      'permission_denied',
    ];
  }

  List<Map<String, dynamic>> _getRecoveryScenarios() {
    return [
      {'error': 'network_timeout', 'recovery': 'retry_with_backoff'},
      {'error': 'server_error', 'recovery': 'show_error_message'},
      {'error': 'memory_limit', 'recovery': 'clear_cache_and_retry'},
    ];
  }
}

/// Cross-platform test data
class CrossPlatformDataSet extends TestDataSet {
  CrossPlatformDataSet(super.manager);

  @override
  Map<String, dynamic> getData() {
    return {
      'platform_specific': _getPlatformSpecificData(),
      'screen_sizes': _getScreenSizes(),
      'orientations': _getOrientations(),
      'accessibility': _getAccessibilityData(),
    };
  }

  @override
  bool validate() {
    return true;
  }

  @override
  List<TestParameter> getParameters() {
    return [
      TestParameter('platform', Platform.operatingSystem),
      TestParameter('screen_density', 2.0),
      TestParameter('accessibility_enabled', false),
    ];
  }

  Map<String, dynamic> _getPlatformSpecificData() {
    return {
      'ios': {'gestures': ['tap', 'swipe', 'pinch'], 'navigation': 'cupertino'},
      'android': {'gestures': ['tap', 'swipe', 'long_press'], 'navigation': 'material'},
    };
  }

  List<Map<String, dynamic>> _getScreenSizes() {
    return [
      {'name': 'phone', 'width': 375, 'height': 667},
      {'name': 'tablet', 'width': 768, 'height': 1024},
      {'name': 'large_phone', 'width': 414, 'height': 896},
    ];
  }

  List<String> _getOrientations() {
    return ['portrait', 'landscape'];
  }

  Map<String, dynamic> _getAccessibilityData() {
    return {
      'screen_reader': true,
      'high_contrast': true,
      'large_text': true,
      'voice_control': false,
    };
  }
}

/// Default test data set
class DefaultTestDataSet extends TestDataSet {
  DefaultTestDataSet(super.manager);

  @override
  Map<String, dynamic> getData() {
    return {
      'basic_queries': manager.getSearchQueries(),
      'session_data': manager.getDynamicData(),
    };
  }

  @override
  bool validate() {
    return true;
  }

  @override
  List<TestParameter> getParameters() {
    return [
      TestParameter('default_timeout', 10000),
      TestParameter('default_retries', 1),
    ];
  }
}

/// Test parameter class
class TestParameter {
  final String name;
  final dynamic value;
  final String? description;
  
  TestParameter(this.name, this.value, {this.description});
  
  @override
  String toString() => '$name: $value';
}

/// Test data factory for creating test-specific data
class TestDataFactory {
  static Map<String, dynamic> createHotelData({
    String? name,
    String? location,
    double? rating,
    int? price,
  }) {
    final random = Random();
    return {
      'name': name ?? 'Test Hotel ${random.nextInt(1000)}',
      'location': location ?? 'Test City, Test Country',
      'rating': rating ?? (3.0 + random.nextDouble() * 2.0),
      'price': price ?? (100 + random.nextInt(400)),
      'amenities': ['WiFi', 'Pool', 'Gym', 'Spa'][random.nextInt(4)],
      'availability': true,
    };
  }

  static Map<String, dynamic> createUserData({
    String? name,
    String? email,
    List<String>? preferences,
  }) {
    final random = Random();
    return {
      'name': name ?? 'Test User ${random.nextInt(1000)}',
      'email': email ?? 'test${random.nextInt(1000)}@example.com',
      'preferences': preferences ?? ['business', 'luxury'],
      'loyalty_level': ['bronze', 'silver', 'gold', 'platinum'][random.nextInt(4)],
    };
  }

  static Map<String, dynamic> createSearchData({
    String? query,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) {
    final random = Random();
    final now = DateTime.now();
    return {
      'query': query ?? 'Test City ${random.nextInt(100)}',
      'check_in': checkIn ?? now.add(Duration(days: random.nextInt(30))),
      'check_out': checkOut ?? now.add(Duration(days: 30 + random.nextInt(7))),
      'guests': guests ?? (1 + random.nextInt(4)),
      'rooms': 1 + random.nextInt(3),
    };
  }
}