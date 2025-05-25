import 'package:flutter/foundation.dart';

class TestLogger {
  static void log(String message) {
    if (kDebugMode) {
      print('[TEST_LOG] $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[TEST_ERROR] $message');
      if (error != null) print('[TEST_ERROR] $error');
      if (stackTrace != null) print('[TEST_ERROR] $stackTrace');
    }
  }
}
