import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onGoToSignUp;
  final VoidCallback onBackToDashboard;
  final VoidCallback onForgotPassword;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onGoToSignUp,
    required this.onBackToDashboard,
    required this.onForgotPassword,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  String? selectedCompany;
  bool _isLoading = false; // Status loading untuk tombol

  final List<String> companies = [
    "PT. Dempo Laser Metalindo Surabaya",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> loginTest() async {
    // 1. Validasi Input Dasar
    if (selectedCompany == null) {
      _showErrorSnackBar("Silakan pilih Company terlebih dahulu");
      return;
    }
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showErrorSnackBar("Username/Email dan Password wajib diisi");
      return;
    }

    setState(() => _isLoading = true);
    debugPrint("Mencoba hubungi Laravel...");

    try {
      var url = Uri.parse('http://192.168.0.106:8000/api/test-koneksi');

      var response = await http
          .post(
            url,
            body: {
              'user_email': _userController.text.trim(),
              'password': _passController.text,
              'company': selectedCompany!,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("I/flutter: [SUCCESS] API TERHUBUNG!");
        if (mounted) _showSuccessSnackBar(selectedCompany!);

        Future.delayed(const Duration(milliseconds: 1500), () {
          widget.onLoginSuccess();
        });
      } else {
        _showErrorSnackBar(
          "Gagal Masuk: Server merespon ${response.statusCode}",
        );
      }
    } catch (e) {
      print("I/flutter: ERROR KONEKSI: $e");
      _showErrorSnackBar(
        "Gagal terhubung ke server. Pastikan Laravel running dan satu Wi-Fi.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Helper Notifikasi ---
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String namaPT) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Selamat Datang di $namaPT",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 82,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              // --- PAKAI STACK UNTUK OVERLAY LOADING ---
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. LAYER FORM LOGIN
                  Opacity(
                    opacity: _isLoading ? 0.2 : 1.0, // Memudar saat loading
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: widget.onBackToDashboard,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryIndigo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "SAP SYSTEM",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkIndigo,
                          ),
                        ),
                        const Text(
                          "Masuk ke Sistem",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        // --- DROPDOWN COMPANY ---
                        DropdownButtonFormField<String>(
                          value: selectedCompany,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Pilih Company",
                            prefixIcon: const Icon(Icons.business_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: companies
                              .map(
                                (String value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isLoading
                              ? null
                              : (val) => setState(() => selectedCompany = val),
                        ),
                        const SizedBox(height: 20),

                        // --- INPUT USERNAME ---
                        TextField(
                          controller: _userController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: "Username atau email",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- INPUT PASSWORD ---
                        TextField(
                          controller: _passController,
                          enabled: !_isLoading,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : widget.onForgotPassword,
                            child: const Text("Lupa Password?"),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- TOMBOL MASUK ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : loginTest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryIndigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : widget.onGoToSignUp,
                          child: const Text("Belum punya akun? Daftar di sini"),
                        ),
                      ],
                    ),
                  ),

                  if (_isLoading)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryIndigo,
                          ),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Memuat halaman...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkIndigo,
                          ),
                        ),
                        const Text(
                          "Menuju ke Beranda...",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              minHeight: 5,
                              backgroundColor: Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryIndigo,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ), // Akhir Stack
            ), // Akhir Container Putih
          ), // Akhir ScrollView
        ), // Akhir Center
      ), // Akhir Container Background
    ); // Akhir Scaffold
  }
}
