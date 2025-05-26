import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import '../logger/test_logger.dart';

class DeviceManager {
  static DeviceConfig? _config;
  static String _currentEnvironment = 'local';

  static Future<void> initialize({String? environment}) async {
    _currentEnvironment =
        environment ?? Platform.environment['TEST_ENVIRONMENT'] ?? 'local';
    await _loadConfig();
    TestLogger.log(
        'DeviceManager initialized for environment: $_currentEnvironment');
  }

  static Future<void> _loadConfig() async {
    try {
      final configFile = File('integration_test/config/device_config.yaml');
      if (await configFile.exists()) {
        final yamlString = await configFile.readAsString();
        final yamlMap = loadYaml(yamlString);
        _config = DeviceConfig.fromYaml(yamlMap);
        TestLogger.log('Device configuration loaded successfully');
      } else {
        TestLogger.log('Device config file not found, using defaults');
        _config = DeviceConfig.defaultConfig();
      }
    } catch (e) {
      TestLogger.log('Error loading device config: $e');
      _config = DeviceConfig.defaultConfig();
    }
  }

  static Future<List<DeviceInfo>> getAvailableDevices(
      {String? platform}) async {
    if (_config == null) await initialize();

    final List<DeviceInfo> devices = [];

    switch (_currentEnvironment) {
      case 'local':
        devices.addAll(await _getLocalDevices(platform: platform));
        break;
      case 'firebase':
        devices.addAll(await _getFirebaseDevices(platform: platform));
        break;
      case 'browserstack':
        devices.addAll(await _getBrowserStackDevices(platform: platform));
        break;
    }

    return devices;
  }

  static Future<List<DeviceInfo>> _getLocalDevices({String? platform}) async {
    final List<DeviceInfo> devices = [];

    if (platform == null || platform == 'ios') {
      devices.addAll(await _getIOSSimulators());
    }

    if (platform == null || platform == 'android') {
      devices.addAll(await _getAndroidEmulators());
    }

    return devices;
  }

  static Future<List<DeviceInfo>> _getIOSSimulators() async {
    final List<DeviceInfo> devices = [];

    try {
      final result =
          await Process.run('xcrun', ['simctl', 'list', 'devices', '--json']);
      if (result.exitCode == 0) {
        final data = jsonDecode(result.stdout);
        final devicesList = data['devices'] as Map<String, dynamic>;

        for (final runtime in devicesList.keys) {
          final runtimeDevices = devicesList[runtime] as List<dynamic>;
          for (final device in runtimeDevices) {
            if (device['availability'] == '(available)' ||
                device['isAvailable'] == true) {
              final deviceInfo = DeviceInfo(
                id: device['udid'],
                name: device['name'],
                platform: 'ios',
                version: _extractIOSVersion(runtime),
                status: device['state'] == 'Booted'
                    ? DeviceStatus.online
                    : DeviceStatus.offline,
                environment: 'local',
                metadata: {
                  'runtime': runtime,
                  'state': device['state'],
                  'udid': device['udid'],
                },
              );
              devices.add(deviceInfo);
            }
          }
        }
      }
    } catch (e) {
      TestLogger.log('Error getting iOS simulators: $e');
    }

    return devices;
  }

  static Future<List<DeviceInfo>> _getAndroidEmulators() async {
    final List<DeviceInfo> devices = [];

    try {
      final result = await Process.run('adb', ['devices', '-l']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.contains('emulator') && line.contains('device')) {
            final parts = line.split(RegExp(r'\s+'));
            final deviceId = parts[0];
            final deviceInfo = DeviceInfo(
              id: deviceId,
              name: _getEmulatorName(deviceId),
              platform: 'android',
              version: await _getAndroidVersion(deviceId),
              status: DeviceStatus.online,
              environment: 'local',
              metadata: {
                'port': _extractPort(deviceId),
                'serial': deviceId,
              },
            );
            devices.add(deviceInfo);
          }
        }
      }
    } catch (e) {
      TestLogger.log('Error getting Android emulators: $e');
    }

    return devices;
  }

  static Future<DeviceInfo?> selectDevice({
    String? preferredName,
    String? platform,
    String? version,
  }) async {
    final availableDevices = await getAvailableDevices(platform: platform);

    if (availableDevices.isEmpty) {
      TestLogger.log('No available devices found');
      return null;
    }

    // Try to find preferred device by name
    if (preferredName != null) {
      final preferred = availableDevices
          .where((d) =>
              d.name.toLowerCase().contains(preferredName.toLowerCase()) ||
              d.id.contains(preferredName))
          .toList();

      if (preferred.isNotEmpty) {
        TestLogger.log('Selected preferred device: ${preferred.first.name}');
        return preferred.first;
      }
    }

    // Filter by platform if specified
    var filteredDevices = availableDevices;
    if (platform != null) {
      filteredDevices =
          filteredDevices.where((d) => d.platform == platform).toList();
    }

    // Filter by version if specified
    if (version != null) {
      filteredDevices =
          filteredDevices.where((d) => d.version.startsWith(version)).toList();
    }

    if (filteredDevices.isNotEmpty) {
      final selected = filteredDevices.first;
      TestLogger.log('Selected device: ${selected.name} (${selected.id})');
      return selected;
    }

    TestLogger.log('No matching device found, using first available');
    return availableDevices.first;
  }

  static Future<bool> startDevice(DeviceInfo device) async {
    TestLogger.log('Starting device: ${device.name}');

    try {
      if (device.platform == 'ios') {
        return await _startIOSSimulator(device);
      } else if (device.platform == 'android') {
        return await _startAndroidEmulator(device);
      }
    } catch (e) {
      TestLogger.log('Error starting device ${device.name}: $e');
      return false;
    }

    return false;
  }

  static Future<bool> _startIOSSimulator(DeviceInfo device) async {
    try {
      final result = await Process.run('xcrun', ['simctl', 'boot', device.id]);
      if (result.exitCode == 0 ||
          result.stderr.toString().contains('already booted')) {
        TestLogger.log('iOS Simulator ${device.name} started successfully');
        await Future.delayed(const Duration(seconds: 5)); // Wait for boot
        return true;
      }
    } catch (e) {
      TestLogger.log('Error starting iOS simulator: $e');
    }
    return false;
  }

  static Future<bool> _startAndroidEmulator(DeviceInfo device) async {
    if (device.status == DeviceStatus.online) {
      TestLogger.log('Android emulator ${device.name} already running');
      return true;
    }

    try {
      final avdName = _getAVDNameFromDevice(device);
      if (avdName != null) {
        Process.start(
            'emulator', ['-avd', avdName, '-no-snapshot', '-wipe-data']);

        // Wait for device to come online
        for (int i = 0; i < 60; i++) {
          await Future.delayed(const Duration(seconds: 2));
          final devices = await _getAndroidEmulators();
          if (devices.any((d) =>
              d.name == device.name && d.status == DeviceStatus.online)) {
            TestLogger.log(
                'Android emulator ${device.name} started successfully');
            return true;
          }
        }
      }
    } catch (e) {
      TestLogger.log('Error starting Android emulator: $e');
    }

    return false;
  }

  static Future<List<DeviceInfo>> _getFirebaseDevices(
      {String? platform}) async {
    // Implementation for Firebase Test Lab
    return [];
  }

  static Future<List<DeviceInfo>> _getBrowserStackDevices(
      {String? platform}) async {
    // Implementation for BrowserStack
    return [];
  }

  // Helper methods
  static String _extractIOSVersion(String runtime) {
    final match = RegExp(r'iOS-(\d+)-(\d+)').firstMatch(runtime);
    if (match != null) {
      return '${match.group(1)}.${match.group(2)}';
    }
    return 'Unknown';
  }

  static String _getEmulatorName(String deviceId) {
    final port = _extractPort(deviceId);
    return _config?.getEmulatorNameByPort(port) ?? 'Android_$port';
  }

  static String _extractPort(String deviceId) {
    final match = RegExp(r'emulator-(\d+)').firstMatch(deviceId);
    return match?.group(1) ?? '5554';
  }

  static Future<String> _getAndroidVersion(String deviceId) async {
    try {
      final result = await Process.run('adb',
          ['-s', deviceId, 'shell', 'getprop', 'ro.build.version.release']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      TestLogger.log('Error getting Android version: $e');
    }
    return 'Unknown';
  }

  static String? _getAVDNameFromDevice(DeviceInfo device) {
    final port = device.metadata['port'] as String?;
    return _config?.getAVDNameByPort(port);
  }

  static void logDeviceInfo(List<DeviceInfo> devices) {
    TestLogger.log('Available devices (${devices.length}):');
    for (final device in devices) {
      TestLogger.log(
          '  - ${device.name} (${device.platform} ${device.version}) - ${device.status.name}');
    }
  }
}

class DeviceInfo {
  final String id;
  final String name;
  final String platform;
  final String version;
  final DeviceStatus status;
  final String environment;
  final Map<String, dynamic> metadata;

  DeviceInfo({
    required this.id,
    required this.name,
    required this.platform,
    required this.version,
    required this.status,
    required this.environment,
    this.metadata = const {},
  });

  @override
  String toString() => '$name ($platform $version) - ${status.name}';
}

enum DeviceStatus {
  online,
  offline,
  booting,
  error,
}

class DeviceConfig {
  final Map<String, dynamic> environments;
  final Map<String, dynamic> execution;

  DeviceConfig({
    required this.environments,
    required this.execution,
  });

  factory DeviceConfig.fromYaml(Map<String, dynamic> yaml) {
    return DeviceConfig(
      environments: yaml['environments'] ?? {},
      execution: yaml['execution'] ?? {},
    );
  }

  factory DeviceConfig.defaultConfig() {
    return DeviceConfig(
      environments: {},
      execution: {
        'default_platform': 'local',
        'parallel_execution': true,
        'max_parallel_devices': 2,
      },
    );
  }

  String? getEmulatorNameByPort(String? port) {
    if (port == null) return null;

    final androidEmulators =
        environments['local']?['android_emulators'] as Map<String, dynamic>?;
    if (androidEmulators != null) {
      for (final entry in androidEmulators.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config['port'] == port) {
          return config['name'] as String?;
        }
      }
    }
    return null;
  }

  String? getAVDNameByPort(String? port) {
    if (port == null) return null;

    final androidEmulators =
        environments['local']?['android_emulators'] as Map<String, dynamic>?;
    if (androidEmulators != null) {
      for (final entry in androidEmulators.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config['port'] == port) {
          return config['avd_name'] as String?;
        }
      }
    }
    return null;
  }
}
