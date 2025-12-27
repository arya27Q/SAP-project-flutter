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

  // Controller untuk menangkap input teks
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
    // Penting: Bersihkan controller agar tidak memakan memori
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
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

    // Logika pengiriman ke Laravel nantinya
    print("Mendaftar di: $selectedCompany");
    print("Nama: ${_nameController.text}");
    print("Email: ${_emailController.text}");
    
    // Untuk testing, kita asumsikan sukses dan kembali ke login
    widget.onGoToLogin();
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
                      onPressed: widget.onBackToDashboard,
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
                  
                  // --- DROPDOWN PILIH COMPANY ---
                  DropdownButtonFormField<String>(
                    value: selectedCompany,
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
                    onChanged: (newValue) {
                      setState(() {
                        selectedCompany = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- INPUT NAMA ---
                  TextField(
                    controller: _nameController,
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
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Daftar Sekarang",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: widget.onGoToLogin,
                    child: const Text("Sudah punya akun? Masuk di sini"),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

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