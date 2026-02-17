import 'package:flutter/material.dart';
import 'dart:ui';

import '../services/api_services.dart';
import '../constants.dart';
import 'lbts_form_page.dart';

enum AuthMode { login, signup, forgotPassword }

class TabletLoginPage extends StatefulWidget {
  const TabletLoginPage({super.key});

  @override
  State<TabletLoginPage> createState() => _TabletLoginPageState();
}

class _TabletLoginPageState extends State<TabletLoginPage> {
  AuthMode _authMode = AuthMode.login;
  bool _isReverseAnimation = false;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailResetController = TextEditingController();

  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPassController = TextEditingController();

  String selectedCompanyValue = "pt4";
  bool _isLoading = false;

  bool _obscureText = true;

  final List<Map<String, dynamic>> qcFeatures = [
    {"title": "Digital QC Inspection"},
    {"title": "Real-time Defect Tracking"},
    {"title": "Photo Evidence Upload"},
    {"title": "Instant Reporting"},
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

  // Dialog Helper
  void _showCustomDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

  void _showErrorDialog(String message) => _showCustomDialog(
        title: "Oops!",
        message: message,
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFFF5252),
      );
  void _showSuccessDialog(String message) => _showCustomDialog(
        title: "Success!",
        message: message,
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF00E676),
      );

  // --- LOGIC LOGIN SUDAH DITAMBAH DELAY & DIALOG ---
  Future<void> handleLogin() async {
    // 1. Ambil input dari user
    String email = _userController.text.trim();
    String password = _passController.text.trim();

    // 2. Validasi Input Kosong
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter your username/email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Panggil API KHUSUS TABLET
      final result = await ApiService.loginTablet(email, password);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          // A. TAMPILKAN DIALOG SUKSES (HIJAU)
          _showSuccessDialog("Login Verified! Welcome back, Inspector.");

          // B. TAHAN SEBENTAR (1.5 Detik) BIAR SEMPAT DIBACA
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            // C. BARU PINDAH KE DASHBOARD
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LbtsFormPage()),
            );
          }
        } else {
          // LOGIN GAGAL -> Tampilkan Pesan dari API
          _showErrorDialog(result['message'] ?? "Login Failed");
        }
      }
    } catch (e) {
      // ERROR KONEKSI
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog("Connection Error: $e");
      }
    }
  }

  Future<void> handleSignup() async {
    _showSuccessDialog("Registration request sent to Admin.");
    _switchAuthMode(AuthMode.login);
  }

  void _switchAuthMode(AuthMode mode) {
    setState(() {
      _isReverseAnimation = (mode == AuthMode.login);
      _authMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurBlob(AppColors.primaryIndigo),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: _buildBlurBlob(const Color(0xFF7C4DFF)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: isLandscape
                  ? _buildDesktopCardLayout()
                  : _buildMobileLayout(),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryIndigo,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 150,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCardLayout() {
    return Container(
      width: 1100,
      height: 650,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF311B92), AppColors.primaryIndigo],
                ),
              ),
              child: _buildLeftSideContent(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(50),
                  child: _buildAnimatedAuthForms(isDark: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 50,
              color: AppColors.primaryIndigo,
            ),
            const SizedBox(height: 16),
            const Text(
              "QC SYSTEM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            _buildAnimatedAuthForms(isDark: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSideContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const Text("Quality Control",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1)),
        const Text("Inspector App",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.white70)),
        const SizedBox(height: 20),
        const Text(
            "Ensure product excellence with our integrated mobile inspection tool.",
            style: TextStyle(fontSize: 15, color: Colors.white60, height: 1.5)),
        const SizedBox(height: 40),
        ...qcFeatures.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF00E676), size: 18),
                const SizedBox(width: 12),
                Text(f['title'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ]),
            )),
      ],
    );
  }

  Widget _buildAnimatedAuthForms({required bool isDark}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        final offset =
            _isReverseAnimation ? const Offset(-0.1, 0) : const Offset(0.1, 0);
        return FadeTransition(
            opacity: animation,
            child: SlideTransition(
                position: Tween<Offset>(begin: offset, end: Offset.zero)
                    .animate(animation),
                child: child));
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

  Widget _buildLoginForm({Key? key, required bool isDark}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Inspector Login",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        const Text("Access your QC dashboard.",
            style: TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 32),
        _buildLabel("Factory / Branch"),
        _buildFixedCompanyField(isDark),
        const SizedBox(height: 20),
        _buildLabel("Username / ID"),
        TextFormField(
            controller: _userController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
                Icons.badge_outlined, "QC Inspector ID", isDark)),
        const SizedBox(height: 20),
        _buildLabel("Password"),
        TextFormField(
          controller: _passController,
          obscureText: _obscureText,
          style: const TextStyle(color: Colors.white),
          decoration:
              _inputDecoration(Icons.lock_outline, "********", isDark).copyWith(
            suffixIcon: IconButton(
                icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white60),
                onPressed: () => setState(() => _obscureText = !_obscureText)),
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: () => _switchAuthMode(AuthMode.forgotPassword),
                child: const Text("Forgot Issue?",
                    style: TextStyle(color: AppColors.primaryIndigo)))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: handleLogin,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: const Text("START INSPECTION",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 30),
        Center(
            child: GestureDetector(
                onTap: () => _switchAuthMode(AuthMode.signup),
                child: RichText(
                    text: const TextSpan(
                        text: "New Inspector? ",
                        style: TextStyle(color: Colors.white60),
                        children: [
                      TextSpan(
                          text: "Register Here",
                          style: TextStyle(
                              color: AppColors.primaryIndigo,
                              fontWeight: FontWeight.bold))
                    ])))),
      ],
    );
  }

  Widget _buildSignupForm({Key? key, required bool isDark}) {
    return Column(
      key: key,
      children: [
        const Text("Register Inspector",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 30),
        _buildFixedCompanyField(isDark),
        const SizedBox(height: 16),
        TextFormField(
            controller: _signupNameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(Icons.person, "Full Name", isDark)),
        const SizedBox(height: 16),
        TextFormField(
            controller: _signupEmailController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(Icons.email, "Email", isDark)),
        const SizedBox(height: 24),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
                onPressed: handleSignup,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text("REQUEST ACCESS",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        TextButton(
            onPressed: () => _switchAuthMode(AuthMode.login),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70))),
      ],
    );
  }

  Widget _buildForgotForm({Key? key, required bool isDark}) {
    return Column(
      key: key,
      children: [
        const Text("Reset Access",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 30),
        TextFormField(
            controller: _emailResetController,
            style: const TextStyle(color: Colors.white),
            decoration:
                _inputDecoration(Icons.email, "Registered Email", isDark)),
        const SizedBox(height: 24),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog("Reset link sent.");
                  _switchAuthMode(AuthMode.login);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text("SEND RESET LINK",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        TextButton(
            onPressed: () => _switchAuthMode(AuthMode.login),
            child: const Text("Back to Login",
                style: TextStyle(color: Colors.white70))),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)));

  Widget _buildFixedCompanyField(bool isDark) {
    return TextFormField(
      initialValue: "PT. Duta Laserindo Metal",
      readOnly: true,
      style:
          const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(Icons.factory_rounded, "", isDark).copyWith(
          fillColor: Colors.black12,
          suffixIcon:
              const Icon(Icons.lock_outline, color: Colors.white30, size: 18)),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint, bool isDark) =>
      InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.primaryIndigo, width: 1.5)),
      );
}
