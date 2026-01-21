import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../constants.dart';

enum AuthMode { login, signup, forgotPassword }

class SapAuthPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const SapAuthPage({super.key, required this.onLoginSuccess});

  @override
  State<SapAuthPage> createState() => _SapAuthPageState();
}

class _SapAuthPageState extends State<SapAuthPage> {
  AuthMode _authMode = AuthMode.login;
  bool _isReverseAnimation = false;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailResetController = TextEditingController();

  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPassController = TextEditingController();

  String? selectedCompany;
  bool _isLoading = false;

  // Variabel password terpisah
  bool _obscureText = true; // Untuk Login
  bool _obscureSignup = true; // Untuk Signup

  final List<String> companies = [
    "PT. Dempo Laser Metalindo",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  final List<Map<String, dynamic>> features = [
    {"title": "Real-time Dashboard Monitoring"},
    {"title": "Seamless Inventory Management"},
    {"title": "Automated Financial Reporting"},
    {"title": "Secure Enterprise Data"},
  ];

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _emailResetController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPassController.dispose();
    super.dispose();
  }

  // --- 🔥 1. FUNGSI PEMBANTU UTAMA (WAJIB ADA) 🔥 ---
  void _showCustomDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa klik luar
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: color, // Warna background dialog (Merah/Hijau)
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon dalam lingkaran transparan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              // Judul
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Pesan
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Tombol Putih
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color, // Warna teks mengikuti tema dialog
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "OK, Got it",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🔥 2. WRAPPER POPUP ERROR (MERAH) 🔥 ---
  void _showErrorDialog(String message) {
    if (!mounted) return;
    _showCustomDialog(
      title: "Oops!",
      message: message,
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFB71C1C), // Merah Gelap
    );
  }

  // --- 🔥 3. WRAPPER POPUP SUKSES (HIJAU) 🔥 ---
  void _showSuccessDialog(String message) {
    if (!mounted) return;
    _showCustomDialog(
      title: "Success!",
      message: message,
      icon: Icons.check_circle_outline_rounded,
      color: const Color(0xFF2E7D32), // Hijau Gelap (Persis Gambar)
    );
  }

  // --- LOGIC LOGIN (POPUP HIJAU) ---
  Future<void> handleLogin() async {
    if (selectedCompany == null) {
      _showErrorDialog("Please select a Company first.");
      return;
    }

    String email = _userController.text.trim();
    String password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter your email and password.");
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi Loading
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      // 🔥 MUNCULIN POPUP HIJAU 🔥
      _showSuccessDialog("Login Successful! Redirecting...");

      // Tunggu 2 detik, tutup dialog, lalu pindah halaman
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Tutup Dialog otomatis
        }
        widget.onLoginSuccess(); // Pindah ke Dashboard
      });
    }
  }

  // --- LOGIC SIGN UP (POPUP HIJAU) ---
  Future<void> handleSignup() async {
    if (selectedCompany == null) {
      _showErrorDialog("Please select a Company first.");
      return;
    }

    if (_signupNameController.text.isEmpty ||
        _signupEmailController.text.isEmpty ||
        _signupPassController.text.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isReverseAnimation = true;
        _authMode = AuthMode.login;
      });

      // 🔥 MUNCULIN POPUP HIJAU 🔥
      _showSuccessDialog(
        "Account created successfully Please Login!",
      );
    }
  }

  void _switchAuthMode(AuthMode mode) {
    setState(() {
      _isReverseAnimation = (mode == AuthMode.login);
      _authMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Background Gelap
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryIndigo.withOpacity(0.4),
                    blurRadius: 200,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkIndigo.withOpacity(0.3),
                    blurRadius: 200,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 950) {
                    return _buildDesktopCardLayout();
                  } else {
                    return _buildMobileLayout();
                  }
                },
              ),
            ),
          ),

          // Hanya loading yang overlay, popup sukses pakai Dialog
          if (_isLoading) _buildStatusOverlay(),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryIndigo),
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopCardLayout() {
    return Container(
      width: 1200,
      height: 700,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // SISI KIRI
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "ERP System",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Enterprise System DLM Group",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Integrated enterprise management platform for maximum efficiency.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  ...features
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                f['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),

          // SISI KANAN
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border(
                      left: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          onPressed: () => SystemNavigator.pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                          tooltip: "Close App",
                        ),
                      ),
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(60),
                          child: _buildAnimatedAuthForms(isDark: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: _buildAnimatedAuthForms(isDark: true),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => SystemNavigator.pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ANIMATED FORMS ---
  Widget _buildAnimatedAuthForms({required bool isDark}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Offset beginOffset = _isReverseAnimation
            ? const Offset(-0.1, 0.0)
            : const Offset(0.1, 0.0);

        final slideAnimation =
            Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      child: _getCurrentView(isDark),
    );
  }

  Widget _getCurrentView(bool isDark) {
    switch (_authMode) {
      case AuthMode.login:
        return _buildLoginForm(key: const ValueKey("Login"), isDark: isDark);
      case AuthMode.signup:
        return _buildSignupForm(key: const ValueKey("Signup"), isDark: isDark);
      case AuthMode.forgotPassword:
        return _buildForgotForm(key: const ValueKey("Forgot"), isDark: isDark);
    }
  }

  // --- STYLING HELPERS ---
  TextStyle get _headerStyle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  TextStyle get _subHeaderStyle =>
      const TextStyle(color: Colors.white70, fontSize: 14);
  TextStyle get _labelStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // --- LOGIN FORM ---
  Widget _buildLoginForm({Key? key, required bool isDark}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome Back!", style: _headerStyle),
        const SizedBox(height: 8),
        Text("Please login to continue.", style: _subHeaderStyle),
        const SizedBox(height: 40),

        _buildLabel("Select Company"),
        _buildCompanyDropdown(isDark),
        const SizedBox(height: 20),

        _buildLabel("Email Address"),
        TextFormField(
          controller: _userController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            Icons.email_outlined,
            "user@company.co.id",
            isDark,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel("Password"),
        TextFormField(
          controller: _passController,
          obscureText: _obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(Icons.lock_outline, "********", isDark)
              .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _switchAuthMode(AuthMode.forgotPassword),
            child: const Text(
              "Forgot Password?",
              style: TextStyle(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 20),
        _buildWarningBox(
          "Important: Ensure your account is approved by an administrator before logging in.",
        ),
        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: () => _switchAuthMode(AuthMode.signup),
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(color: Colors.white70),
                children: [
                  TextSpan(
                    text: "Sign Up Now",
                    style: TextStyle(
                      color: AppColors.primaryIndigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
        const Center(
          child: Text(
            "© 2026 PT. DLM Group • Enterprise System v1.0",
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // --- SIGNUP FORM ---
  Widget _buildSignupForm({Key? key, required bool isDark}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Create Account", style: _headerStyle),
        const SizedBox(height: 8),
        Text("Fill in details to request access.", style: _subHeaderStyle),
        const SizedBox(height: 40),

        _buildLabel("Select Company"),
        _buildCompanyDropdown(isDark),
        const SizedBox(height: 20),

        _buildLabel("Full Name"),
        TextFormField(
          controller: _signupNameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            Icons.person_outline,
            "Your Name",
            isDark,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel("Work Email"),
        TextFormField(
          controller: _signupEmailController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            Icons.email_outlined,
            "email@work.co.id",
            isDark,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel("New Password"),
        TextFormField(
          controller: _signupPassController,
          obscureText: _obscureSignup,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(Icons.lock_outline, "********", isDark)
              .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSignup
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureSignup = !_obscureSignup;
                    });
                  },
                ),
              ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: handleSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Submit Request",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildWarningBox("Note: Account requests require manual approval."),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => _switchAuthMode(AuthMode.login),
            child: const Text(
              "Back to Login",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  // --- FORGOT FORM ---
  Widget _buildForgotForm({Key? key, required bool isDark}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reset Password", style: _headerStyle),
        const SizedBox(height: 8),
        Text("Enter email to get reset link.", style: _subHeaderStyle),
        const SizedBox(height: 40),

        _buildLabel("Select Company"),
        _buildCompanyDropdown(isDark),
        const SizedBox(height: 20),

        _buildLabel("Registered Email"),
        TextFormField(
          controller: _emailResetController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            Icons.mark_email_read_outlined,
            "email@work.co.id",
            isDark,
          ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (selectedCompany == null) {
                _showErrorDialog("Please select a Company first.");
                return;
              }
              // 🔥 GANTI: Pakai Dialog Sukses Kotak Hijau
              _showSuccessDialog("Link Sent (Simulation)! Please check email.");
              _switchAuthMode(AuthMode.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Send Link",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => _switchAuthMode(AuthMode.login),
            child: const Text(
              "Back to Login",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(text, style: _labelStyle),
    );
  }

  Widget _buildCompanyDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: selectedCompany,
      isExpanded: true,
      dropdownColor: const Color(0xFF2E2E48),
      style: const TextStyle(color: Colors.white),
      hint: const Text("Select Company", style: TextStyle(color: Colors.white)),
      decoration: _inputDecoration(
        Icons.business_rounded,
        "Select Company",
        isDark,
      ),
      items: companies
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => selectedCompany = v),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint, bool isDark) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: Colors.white),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryIndigo,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildWarningBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: Colors.amberAccent),
            ),
          ),
        ],
      ),
    );
  }
}
