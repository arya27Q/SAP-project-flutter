import 'package:flutter/material.dart';
import '../../constants.dart';

class ForgotPasswordPage extends StatelessWidget {
  final VoidCallback onGoToLogin;
  final VoidCallback onBackToDashboard;

  const ForgotPasswordPage({
    super.key,
    required this.onGoToLogin,
    required this.onBackToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Penting agar keyboard tidak menutupi input di HP
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
            // Memberikan jarak aman di sekeliling layar mobile agar kotak tidak menempel
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              // Batas lebar maksimal 400px di desktop, namun fleksibel mengikuti layar di mobile
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
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Close di pojok kanan atas
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: onBackToDashboard,
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                  ),

                  const Icon(Icons.lock_reset_rounded, 
                      color: AppColors.primaryIndigo, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Lupa Password?",
                    style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.darkIndigo),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masukkan email Anda untuk menerima instruksi reset password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Email Terdaftar",
                      prefixIcon: const Icon(Icons.email_outlined),
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
                        // Logika kirim email reset password
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Kirim Instruksi", 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: onGoToLogin, 
                    child: const Text("Kembali ke Login"),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  // Tombol Kembali ke Dashboard agar user tidak terjebak
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