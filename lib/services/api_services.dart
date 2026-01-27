import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // GANTI IP sesuai kebutuhan (127.0.0.1 untuk Desktop/Simulator, 192.168.x.x untuk HP Asli)
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // --- LOGIN ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
    String targetPt, // Nama variabel disesuaikan
  ) async {
    // Sesuaikan endpoint dengan route di api.php Laravel (/test-login atau /login)
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
          // 🔥 PENTING: Key ini harus 'target_pt' sesuai Controller Laravel
          'target_pt': targetPt,
        }),
      );

      print("Login Response: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Login Gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error Koneksi: $e'};
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
          // 🔥 PENTING: Key ini harus 'target_pt'
          'target_pt': targetPt,
        }),
      );

      print("Register Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Registrasi Gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error Koneksi: $e'};
    }
  }
}
