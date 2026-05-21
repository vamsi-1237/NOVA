import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String accessTokenKey =
      "access_token";

  static const String refreshTokenKey =
      "refresh_token";

  // SAVE TOKENS
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {

    await _storage.write(
      key: accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: refreshTokenKey,
      value: refreshToken,
    );
  }

  // GET ACCESS TOKEN
  static Future<String?> getAccessToken() async {

    return await _storage.read(
      key: accessTokenKey,
    );
  }

  // GET REFRESH TOKEN
  static Future<String?> getRefreshToken() async {

    return await _storage.read(
      key: refreshTokenKey,
    );
  }

  // CLEAR TOKENS
  static Future<void> clearTokens() async {

    await _storage.deleteAll();
  }
}