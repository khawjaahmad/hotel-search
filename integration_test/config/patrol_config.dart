import 'package:patrol/patrol.dart';

class PatrolConfig {
  static PatrolTesterConfig getConfig() {
    return PatrolTesterConfig(
      settleTimeout: const Duration(seconds: 10),
      existsTimeout: const Duration(seconds: 10),
      visibleTimeout: const Duration(seconds: 10),
    );
  }
}
