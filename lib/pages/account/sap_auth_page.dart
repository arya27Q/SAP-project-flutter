import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
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

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailResetController = TextEditingController();

  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPassController = TextEditingController();

  String? selectedCompany;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscureText = true;

  final List<String> companies = [
    "PT. Dempo Laser Metalindo",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  final Map<String, String> companyMapping = {
    "PT. Dempo Laser Metalindo": "pt1",
    "PT. Duta Laserindo Metal": "pt2",
    "PT. Senzo Feinmetal": "pt3",
    "PT. ATMI Duta Engineering": "pt4",
  };

  final Map<String, String> companyDomains = {
    "PT. Dempo Laser Metalindo": "@dempo.co.id",
    "PT. Duta Laserindo Metal": "@duta.co.id",
    "PT. Senzo Feinmetal": "@senzo.co.id",
    "PT. ATMI Duta Engineering": "@atmi.co.id",
  };

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

  // --- LOGIC LOGIN (CONNECT LARAVEL) ---
  Future<void> handleLogin() async {
    if (selectedCompany == null) {
      _showErrorSnackBar("Please select a Company first.");
      return;
    }

    String email = _userController.text.trim().toLowerCase();
    String password = _passController.text.trim();
    String expectedDomain = companyDomains[selectedCompany!]!;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Required fields are empty.");
      return;
    }

    if (!email.endsWith(expectedDomain)) {
      _showErrorSnackBar("Email must use domain $expectedDomain");
      return;
    }

    // Validasi Password Login
    bool startsWithUpper = RegExp(r'^[A-Z]').hasMatch(password);
    bool hasYear = RegExp(r'\d{4}').hasMatch(password);

    if (!startsWithUpper || !hasYear || password.length < 8) {
      _showErrorSnackBar(
        "Invalid Password! (Must start with Uppercase, contain Year, min 8 chars)",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ⚠️ GANTI IP INI SESUAI IP LAPTOP KAMU
      var url = Uri.parse('http://192.168.0.101:8000/api/test-login');

      var response = await http
          .post(
            url,
            body: {
              'email': email,
              'password': password,
              'target_pt': companyMapping[selectedCompany],
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        Future.delayed(const Duration(seconds: 1), widget.onLoginSuccess);
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar(
          "Login Failed: Invalid Credentials (${response.statusCode})",
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Connection failed. Check IP & Server.");
    }
  }

  // --- LOGIC SIGN UP (SUDAH DIPERBAIKI: PAKAI target_pt) ---
  Future<void> handleSignup() async {
    if (selectedCompany == null) {
      _showErrorSnackBar("Please select a Company first.");
      return;
    }

    String name = _signupNameController.text.trim();
    String email = _signupEmailController.text.trim().toLowerCase();
    String password = _signupPassController.text.trim();
    String expectedDomain = companyDomains[selectedCompany!]!;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("All fields are required.");
      return;
    }

    if (!email.endsWith(expectedDomain)) {
      _showErrorSnackBar("Email must use domain $expectedDomain");
      return;
    }

    bool startsWithUpper = RegExp(r'^[A-Z]').hasMatch(password);
    bool hasYear = RegExp(r'\d{4}').hasMatch(password);

    if (!startsWithUpper || !hasYear || password.length < 8) {
      _showErrorSnackBar(
        "Password: Start with Uppercase, include Year, min 8 chars",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ⚠️ FIX: URL disesuaikan dengan routes/api.php kamu
      var url = Uri.parse('http://192.168.0.101:8000/api/test-register');

      var response = await http
          .post(
            url,
            body: {
              'name': name,
              'email': email,
              'password': password,
              // 👇 INI YANG PENTING: HARUS 'target_pt', BUKAN 'company_code'
              'target_pt': companyMapping[selectedCompany],
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _authMode = AuthMode.login;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account Created! Please wait for Admin approval."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Registration Failed: ${response.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Connection failed. Check Server.");
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

          if (_isLoading || _isSuccess) _buildStatusOverlay(),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    if (_isLoading) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryIndigo),
        ),
      );
    }

    if (_isSuccess) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Stack(
            children: [
              Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              Center(
                child: Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27273E),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black45, blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Login Successful!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Redirecting to Dashboard...",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  // --- DESKTOP LAYOUT (Desain Tetap) ---
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
                  const SizedBox(height: 30),
                  const Text(
                    "SAP Business\nIntegration.",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
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

          // SISI KANAN (GLASSMORPHISM TERANG)
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
                    color: Colors.white.withOpacity(0.05), // TINT PUTIH
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

  Widget _buildAnimatedAuthForms({required bool isDark}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
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

  // --- FORM WIDGETS ---
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
            onPressed: () =>
                setState(() => _authMode = AuthMode.forgotPassword),
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
            onTap: () => setState(() => _authMode = AuthMode.signup),
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
      ],
    );
  }

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
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(Icons.lock_outline, "********", isDark),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: handleSignup, // 🔥 LOGIC REAL DENGAN target_pt 🔥
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
            onPressed: () => setState(() => _authMode = AuthMode.login),
            child: const Text(
              "Back to Login",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

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
                _showErrorSnackBar("Please select a Company first.");
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Link Sent!"),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() => _authMode = AuthMode.login);
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
            onPressed: () => setState(() => _authMode = AuthMode.login),
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
      // Ikon Putih
      prefixIcon: Icon(icon, size: 20, color: Colors.white),

      hintText: hint,
      // 👇👇 GANTI INI JADI Colors.white (JANGAN white54) 👇👇
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
