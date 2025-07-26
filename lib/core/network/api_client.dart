import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient(this._client) : _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParams,
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    print('[ApiClient] GET $uri');

    try {
      final response = await _client.get(uri, headers: headers);
      print('[ApiClient] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[ApiClient] Exception: $e');
      rethrow;
    }
  }

// Future<Map<String, dynamic>> post(...) => // similar structure if needed
}
