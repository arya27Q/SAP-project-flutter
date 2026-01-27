import 'dart:convert';
import 'dart:io'; // Untuk deteksi SocketException
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // --- LOGIN ---
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

      // debugPrint berasal dari foundation.dart, ini yang bikin kuning hilang
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
      // Menggunakan SocketException di sini agar dart:io tidak kuning
      String userMessage =
          'Your connection is unstable / Koneksi tidak stabil.';
      if (e is SocketException) {
        userMessage =
            'Tidak dapat terhubung ke server. Periksa internet atau IP Address.';
      }

      return {'success': false, 'message': userMessage};
    }
  }

  // --- REGISTER ---
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
          'message':
              'Error 404: Data Not Found.',
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
}
