import 'package:flutter/material.dart';
import '../../constants.dart';

class SignUpPage extends StatelessWidget {
  final VoidCallback onGoToLogin;
  final VoidCallback onBackToDashboard; // Tambahkan ini

  const SignUpPage({
    super.key,
    required this.onGoToLogin,
    required this.onBackToDashboard, // Tambahkan ini
  });
// ... sisa kodenya

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
          ),
        ),
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_alt_1_rounded, 
                    color: AppColors.primaryIndigo, size: 50),
                const SizedBox(height: 16),
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.darkIndigo),
                ),
                const Text("Lengkapi data untuk mendaftar", 
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Nanti tambahkan logika daftar di sini
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryIndigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Daftar Sekarang", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 3. Ubah bagian Navigator.pop menjadi onGoToLogin
                TextButton(
                  onPressed: onGoToLogin, 
                  child: const Text("Sudah punya akun? Masuk di sini"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}