import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiCaller {
  static const String baseUrl = "http://localhost:3000";

  //PRIVATE

  //if token is there, sends token automatically
  static Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getAccessToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  //function to get new access token
  static Future<bool> _refreshToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final uri = Uri.parse("$baseUrl/refresh");

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await AuthStorage.saveTokens(accessToken: data["access_token"],
          refreshToken: data["refresh_token"]);

      return true;
    }

    return false;
  }

  //function to automatically perform refresh token whenever access token expires
  static Future<String> _request(
      Future<http.Response> Function(Map<String, String> headers) call,
      ) async {
    Map<String, String> headers = await _headers();

    http.Response response = await call(headers);

    // If unauthorized → try refresh once
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        headers = await _headers(); // get new token
        response = await call(headers); // retry once
      }
    }

    return response.body;
  }

  //PUBLIC
  //ACTUAL METHODS WE CAN USE OUTSIDE THIS CLAS

  static Future<String> get(String endpoint) async {
    final uri = Uri.parse("$baseUrl$endpoint");

    return _request((headers) => http.get(uri, headers: headers));
  }

  static Future<String> post(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final uri = Uri.parse("$baseUrl$endpoint");

    return _request(
          (headers) => http.post(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  static Future<String> put(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final uri = Uri.parse("$baseUrl$endpoint");

    return _request(
          (headers) => http.post(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  static Future<String> delete(String endpoint) async {
    final uri = Uri.parse("$baseUrl$endpoint");

    return _request((headers) => http.delete(uri, headers: headers));
  }
}