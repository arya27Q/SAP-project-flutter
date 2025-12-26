import 'package:flutter/material.dart';
import '../../constants.dart';

class ForgotPasswordPage extends StatefulWidget { // Diubah menjadi StatefulWidget
  final VoidCallback onGoToLogin;
  final VoidCallback onBackToDashboard;

  const ForgotPasswordPage({
    super.key,
    required this.onGoToLogin,
    required this.onBackToDashboard,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Variabel untuk menyimpan pilihan Company
  String? selectedCompany;

  // Daftar Company (Samakan dengan di Login & Sign Up agar konsisten)
  final List<String> companies = [
    "PT. Dempo Laser Metalindo Surabaya",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

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
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Close
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: widget.onBackToDashboard,
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
                    "Pilih company dan masukkan email untuk menerima instruksi reset.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  // --- DROPDOWN PILIH COMPANY ---
                  DropdownButtonFormField<String>(
                    value: selectedCompany,
                    isExpanded: true, // Agar teks panjang tidak berantakan
                    decoration: InputDecoration(
                      labelText: "Pilih Company",
                      prefixIcon: const Icon(Icons.business_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    hint: const Text("Pilih Unit Bisnis"),
                    items: companies.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCompany = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // INPUT EMAIL
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Email Terdaftar",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // TOMBOL KIRIM
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika: Kirim 'selectedCompany' dan 'email' ke Laravel
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
                    onPressed: widget.onGoToLogin, 
                    child: const Text("Kembali ke Login"),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  // Tombol Kembali ke Dashboard
                  TextButton.icon(
                    onPressed: widget.onBackToDashboard,
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