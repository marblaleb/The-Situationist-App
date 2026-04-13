import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '_web_storage_stub.dart'
    if (dart.library.html) '_web_storage.dart';

class AuthService {
  static const _jwtKey = 'jwt';
  final FlutterSecureStorage _storage;

  AuthService(this._storage);

  Future<String?> getToken() async {
    if (kIsWeb) return webReadToken(_jwtKey);
    return _storage.read(key: _jwtKey);
  }

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      webWriteToken(_jwtKey, token);
      return;
    }
    await _storage.write(key: _jwtKey, value: token);
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      webClearToken(_jwtKey);
      return;
    }
    await _storage.deleteAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    try {
      final exp = _extractExp(token);
      return exp.isAfter(DateTime.now().toUtc());
    } catch (_) {
      return false;
    }
  }

  String? extractUserId(String token) {
    try {
      final claims = _decodeClaims(token);
      return claims['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  String? extractEmail(String token) {
    try {
      final claims = _decodeClaims(token);
      return claims['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  DateTime _extractExp(String token) {
    final claims = _decodeClaims(token);
    final exp = claims['exp'] as int;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }

  Map<String, dynamic> _decodeClaims(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT');
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    return jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
  }
}
