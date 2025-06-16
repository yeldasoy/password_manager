import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';
  static final _storage = const FlutterSecureStorage();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');

    // --- HATA AYIKLAMA KONTROLÜ ---
    print("--- API ISTEĞI ÖNCESI OKUNAN TOKEN: $token ---");

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- KİMLİK DOĞRULAMA FONKSİYONLARI ---

  static Future<http.Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
    return http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> verifyEmail({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse('$_baseUrl/verify-email');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({'email': email, 'code': code});
    return http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> setMasterPassword({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/set-master-password');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({'email': email, 'password': password});
    return http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({'email': email, 'password': password});
    return http.post(url, headers: headers, body: body);
  }

  // --- ŞİFRE YÖNETİMİ FONKSİYONLARI ---

  static Future<http.Response> getPasswords() async {
    final url = Uri.parse('$_baseUrl/passwords');
    final authHeaders = await _getAuthHeaders();
    return http.get(url, headers: authHeaders);
  }

  static Future<http.Response> addNewPassword({
    required String siteAdi,
    required String kullaniciAdiEncrypted,
    required String sifreEncrypted,
    required String iv,
  }) async {
    final url = Uri.parse('$_baseUrl/passwords/add');
    final authHeaders = await _getAuthHeaders();
    final body = jsonEncode({
      'site_adi': siteAdi,
      'kullanici_adi': kullaniciAdiEncrypted,
      'sifre': sifreEncrypted,
      'iv': iv,
      'notlar': null,
    });
    return http.post(url, headers: authHeaders, body: body);
  }

  static Future<http.Response> deletePassword(int recordId) async {
    final url = Uri.parse('$_baseUrl/passwords/$recordId');
    final authHeaders = await _getAuthHeaders();
    return http.delete(url, headers: authHeaders);
  }
}