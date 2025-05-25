abstract class ApiClient {
  ApiClient();

  Future<Map<String, dynamic>> get(
    String baseUrl,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });
}
