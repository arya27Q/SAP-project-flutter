import 'package:flutter/material.dart';
import '../../constants.dart';

class LoginPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      // Mencegah konten terpotong saat keyboard muncul di HP
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
          // Agar bisa di-scroll jika layar HP terlalu pendek
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              // Batas lebar: di HP mengikuti layar, di Desktop maksimal 400
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Close
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: onBackToDashboard,
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                  ),

                  // LOGO SAP
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 30),
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

                  // INPUT USERNAME
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INPUT PASSWORD
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // TOMBOL LUPA PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onForgotPassword,
                      child: const Text("Lupa Password?"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TOMBOL MASUK
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onLoginSuccess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
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
                    onPressed: onGoToSignUp,
                    child: const Text("Belum punya akun? Daftar di sini"),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  // TOMBOL KEMBALI
                  TextButton.icon(
                    onPressed: onBackToDashboard,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text("Kembali ke Dashboard"),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}