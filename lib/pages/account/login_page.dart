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

  final List<String> companies = [
    "PT. Dempo Laser Metalindo Surabaya",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  Future<void> loginTest() async {
    print("Mencoba hubungi Laravel...");
    
    try {
    
var url = Uri.parse('http://192.168.0.106:8000/api/test-koneksi');
      
      var response = await http.post(
        url,
        body: {
          'user_email': _userController.text,
          'password': _passController.text,
          'company': selectedCompany ?? 'Belum Pilih',
        },
      );

      if (response.statusCode == 200) {
        print("I/flutter: [SUCCESS] LARAVEL API BERHASIL DIAKSES!");
        
        String namaPT = selectedCompany ?? "Perusahaan";

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Berhasil masuk ke halaman dashboard $namaPT",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              // LOGIKA AGAR NOTIFIKASI DI ATAS:
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 82, // Dorong ke atas
                left: 20,
                right: 20,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        Future.delayed(const Duration(milliseconds: 1500), () {
          widget.onLoginSuccess(); 
        });

      } else {
        print("I/flutter: Server merespon tapi error status: ${response.statusCode}");
      }
    } catch (e) {
      print("I/flutter: GAGAL TOTAL: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal terhubung ke server. Cek koneksi internet/IP."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 100,
                left: 20,
                right: 20,
            ),
          ),
        );
      }
    }
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: widget.onBackToDashboard,
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkIndigo),
                  ),
                  const Text("Masuk ke Sistem", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),

                  // DROPDOWN COMPANY
                  DropdownButtonFormField<String>(
                    value: selectedCompany,
                    isExpanded: true, 
                    decoration: InputDecoration(
                      labelText: "Pilih Company",
                      prefixIcon: const Icon(Icons.business_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    hint: const Text("Pilih Unit Bisnis"),
                    items: companies.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 11)),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => selectedCompany = newValue),
                  ),
                  const SizedBox(height: 20),

                  // INPUT USERNAME
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: "Username atau email",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INPUT PASSWORD
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.onForgotPassword,
                      child: const Text("Lupa Password?"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TOMBOL MASUK
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loginTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Masuk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onGoToSignUp,
                    child: const Text("Belum punya akun? Daftar di sini"),
                  ),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),

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