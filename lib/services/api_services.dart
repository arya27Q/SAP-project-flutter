import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // LOGIC DESKTOP

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
    String targetPt,
  ) async {
    final url = Uri.parse('$baseUrl/test-login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'target_pt': targetPt,
        }),
      );

      debugPrint("Login Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Error 404: Data Not Found.',
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Login Gagal',
        };
      }
    } catch (e) {
      String userMessage =
          'Your connection is unstable / Koneksi tidak stabil.';
      if (e is SocketException) {
        userMessage =
            'Tidak dapat terhubung ke server. Periksa internet atau IP Address.';
      }

      return {'success': false, 'message': userMessage};
    }
  }

  // --- REGISTER DESKTOP ---
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String targetPt,
  ) async {
    final url = Uri.parse('$baseUrl/test-register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'target_pt': targetPt,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Error 404: Data Not Found.',
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Registrasi Gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e is SocketException
            ? 'Your connection is unstable / Koneksi tidak stabil.'
            : 'Terjadi kesalahan sistem.',
      };
    }
  }

  // LOGIC TABLET (KHUSUS QC)

  static Future<Map<String, dynamic>> loginTablet(
      String email, String password) async {
    // ⚠️ URL KHUSUS TABLET (Nembak ke TabletAuthController Laravel)
    final url = Uri.parse('$baseUrl/tablet/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint("Tablet Login Status: ${response.statusCode}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Simpan Token Khusus Tablet ke Memory HP
        final prefs = await SharedPreferences.getInstance();

        // Simpan token & nama user biar bisa dipakai di dashboard nanti
        await prefs.setString(
            'tablet_token', responseData['data']['access_token']);
        await prefs.setString(
            'tablet_user', responseData['data']['user']['nama_lengkap']);

        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login Tablet Gagal'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Error: $e'};
    }
  }
}
