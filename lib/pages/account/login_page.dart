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
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isError = false; 
  String _errorMessage = "";

  
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
    if (selectedCompany == null) {
      _showErrorSnackBar("Silakan pilih Company terlebih dahulu");
      return;
    }
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showErrorSnackBar("Username/Email dan Password wajib diisi");
      return;
    }

    // --- LOGIC MULTI-DATABASE MAPPING ---
    // Mengubah nama tampilan PT menjadi ID Koneksi di Laravel
    Map<String, String> companyMapping = {
      "PT. Dempo Laser Metalindo Surabaya": "pt1",
      "PT. Duta Laserindo Metal": "pt2",
      "PT. Senzo Feinmetal": "pt3",
      "PT. ATMI Duta Engineering": "pt4",
    };
    String targetPT = companyMapping[selectedCompany!]!;

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      // Menggunakan IP Laravel : 192.168.0.107
      var url = Uri.parse('http://192.168.0.101:8000/api/test-login');
      var response = await http.post(
        url,
        body: {
          'email': _userController.text.trim(),
          'password': _passController.text,
          'target_pt': targetPT, // ID Koneksi (pt1, pt2, dll)
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          widget.onLoginSuccess();
        });
      } else {
        // Gagal login (401 atau lainnya)
        _handleLoginError("Email/Password salah atau PT tidak sesuai");
      }
    } catch (e) {
      _handleLoginError("Gagal terhubung ke Server ");
    }
  }

  void _handleLoginError(String message) {
    setState(() {
      _isLoading = false;
      _isError = true;
      _errorMessage = message;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isError = false;
        });
      }
    });
  }

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: (_isLoading || _isSuccess || _isError) ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: _isLoading || _isSuccess || _isError,
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
                          DropdownButtonFormField<String>(
                            value: selectedCompany,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: "Pilih Company",
                              prefixIcon: const Icon(Icons.business_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: companies.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
                            onChanged: (val) => setState(() => selectedCompany = val),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _userController,
                            decoration: InputDecoration(
                              labelText: "Username atau email",
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                            child: TextButton(onPressed: widget.onForgotPassword, child: const Text("Lupa Password?")),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loginTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryIndigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Masuk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(onPressed: widget.onGoToSignUp, child: const Text("Belum punya akun? Daftar di sini")),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo)),
                        SizedBox(height: 20),
                        Text("Memproses...", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkIndigo)),
                      ],
                    ),
                  if (_isSuccess)
                    _buildStatusBox(
                      color: Colors.green.shade600,
                      icon: Icons.check_rounded,
                      title: "Berhasil!",
                      subtitle: "Selamat Datang",
                    ),
                  if (_isError)
                    _buildStatusBox(
                      color: Colors.red.shade600,
                      icon: Icons.close_rounded,
                      title: "Gagal!",
                      subtitle: _errorMessage,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBox({required Color color, required IconData icon, required String title, required String subtitle}) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                ),
                child: Icon(icon, color: Colors.white, size: 70),
              ),
              const SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}