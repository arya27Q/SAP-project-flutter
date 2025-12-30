import 'package:flutter/material.dart';
import '../../constants.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onGoToLogin;
  final VoidCallback onBackToDashboard;

  const SignUpPage({
    super.key,
    required this.onGoToLogin,
    required this.onBackToDashboard,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedCompany;
  bool _isLoading = false; // 1. Tambahkan state loading

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> companies = [
    "PT. Dempo Laser Metalindo Surabaya",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. Ubah fungsi handle menjadi async
  Future<void> _handleSignUp() async {
    // Validasi sederhana
    if (selectedCompany == null || 
        _nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data!")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    // Simulasi proses pengiriman data ke server (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    print("Mendaftar di: $selectedCompany");
    print("Nama: ${_nameController.text}");
    print("Email: ${_emailController.text}");
    
    if (mounted) {
      setState(() {
        _isLoading = false; // Berhenti loading
      });
      
      // Tampilkan pesan sukses sebelum pindah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran Berhasil! Silahkan Login."),
          backgroundColor: Colors.green,
        ),
      );

      widget.onGoToLogin();
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
              constraints: const BoxConstraints(maxWidth: 450),
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
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: _isLoading ? null : widget.onBackToDashboard, // Matikan tombol jika loading
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                  ),
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
                  
                  // --- DROPDOWN ---
                  DropdownButtonFormField<String>(
                    value: selectedCompany,
                    // Matikan dropdown jika sedang loading
                    onChanged: _isLoading ? null : (newValue) {
                      setState(() {
                        selectedCompany = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Daftar untuk Company",
                      prefixIcon: const Icon(Icons.business_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    hint: const Text("Pilih Unit Bisnis"),
                    items: companies.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, 
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // --- INPUT NAMA ---
                  TextField(
                    controller: _nameController,
                    enabled: !_isLoading, // Disable jika loading
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- INPUT EMAIL ---
                  TextField(
                    controller: _emailController,
                    enabled: !_isLoading, // Disable jika loading
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- INPUT PASSWORD ---
                  TextField(
                    controller: _passwordController,
                    enabled: !_isLoading, // Disable jika loading
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // --- TOMBOL DAFTAR DENGAN LOADING ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text("Daftar Sekarang",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: _isLoading ? null : widget.onGoToLogin,
                    child: const Text("Sudah punya akun? Masuk di sini"),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  TextButton.icon(
                    onPressed: _isLoading ? null : widget.onBackToDashboard,
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