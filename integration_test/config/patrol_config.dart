import 'package:patrol/patrol.dart';

class PatrolConfig {
  static PatrolTesterConfig getConfig() {
    return PatrolTesterConfig(
      existsTimeout: const Duration(seconds: 30),
      visibleTimeout: const Duration(seconds: 30),
      settleTimeout: const Duration(seconds: 30),
      printLogs: true, 
    );
  }
}
