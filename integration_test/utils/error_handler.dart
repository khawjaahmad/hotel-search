import '../logger/test_logger.dart';

class ErrorHandler {
  static Future<T> retry<T>(
    Future<T> Function() action,
    String description, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await action();
      } catch (e, stackTrace) {
        TestLogger.error(
          'Attempt $attempt/$maxRetries failed for $description: $e',
          e,
          stackTrace,
        );
        if (attempt == maxRetries) rethrow;
        await Future.delayed(delay);
      }
    }
    throw Exception('Retry failed after $maxRetries attempts for $description');
  }
}
