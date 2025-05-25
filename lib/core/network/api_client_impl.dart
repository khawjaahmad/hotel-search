import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import 'api_client.dart';

@module
abstract class HttpClientModule {
  @lazySingleton
  http.Client get client => http.Client();
}

@Singleton(as: ApiClient)
class ApiClientImpl extends ApiClient {
  final http.Client _client;

  ApiClientImpl({
    required http.Client client,
  }) : _client = client;

  @override
  Future<Map<String, dynamic>> get(
    String baseUrl,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(
      Uri.https(baseUrl, path, queryParameters),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Status: ${response.statusCode}');
    }
  }
}
