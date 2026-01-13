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

  final List<Map<String, dynamic>> features = [
    {
      "icon": Icons.grid_view_rounded,
      "title": "Dynamic Dashboard",
      "subtitle": "Real-time overview.",
    },
    {
      "icon": Icons.admin_panel_settings_rounded,
      "title": "Administration",
      "subtitle": "Setup & Approvals.",
    },
    {
      "icon": Icons.account_balance_wallet_rounded,
      "title": "Financials",
      "subtitle": "Accounting & Banking.",
    },
    {
      "icon": Icons.shopping_bag_rounded,
      "title": "Sales - A/R",
      "subtitle": "Order to Invoicing.",
    },
    {
      "icon": Icons.local_shipping_rounded,
      "title": "Purchasing",
      "subtitle": "Procurement control.",
    },
    {
      "icon": Icons.inventory_2_rounded,
      "title": "Inventory",
      "subtitle": "Warehouse tracking.",
    },
    {
      "icon": Icons.people_alt_rounded,
      "title": "Business Partners",
      "subtitle": "Master data mgmt.",
    },
    {
      "icon": Icons.analytics_rounded,
      "title": "Advanced Reports",
      "subtitle": "Business insights.",
    },
    {
      "icon": Icons.security_rounded,
      "title": "Data Security",
      "subtitle": "Encrypted protection.",
    },
  ];

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- Login Logic (Tetap Sama) ---
  Future<void> loginTest() async {
    if (selectedCompany == null) {
      _showErrorSnackBar("Please select a Company first.");
      return;
    }
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showErrorSnackBar("Required fields are empty.");
      return;
    }

    Map<String, String> companyMapping = {
      "PT. Dempo Laser Metalindo Surabaya": "pt1",
      "PT. Duta Laserindo Metal": "pt2",
      "PT. Senzo Feinmetal": "pt3",
      "PT. ATMI Duta Engineering": "pt4",
    };

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      var response = await http
          .post(
            Uri.parse('http://192.168.0.101:8000/api/test-login'),
            body: {
              'email': _userController.text.trim(),
              'password': _passController.text,
              'target_pt': companyMapping[selectedCompany!]!,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        Future.delayed(
          const Duration(milliseconds: 2000),
          () => widget.onLoginSuccess(),
        );
      } else {
        _handleLoginError("Invalid credentials or incorrect Company.");
      }
    } catch (e) {
      _handleLoginError("Failed to connect to the server.");
    }
  }

  void _handleLoginError(String message) {
    setState(() {
      _isLoading = false;
      _isError = true;
      _errorMessage = message;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _isError = false);
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryIndigo,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 950) {
            return Row(
              children: [
                // --- LEFT PANEL: BRANDING (DIREVISI) ---
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
                      ),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        // SOLUSI OVERFLOW: Tambahkan scroll
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Container(
                          width: 620, // Kunci lebar agar lurus kiri
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Kunci kelurusan kiri
                            children: [
                              // LOGO & JUDUL (Sekarang Row sejajar kiri)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text(
                                    "SAP SYSTEM",
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                "Comprehensive SAP Business One Integration for Modern Enterprises.",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 50),
                              // GRID FITUR
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3.2,
                                      crossAxisSpacing: 30,
                                      mainAxisSpacing: 20,
                                    ),
                                itemCount: features.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          features[index]['icon'],
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              features[index]['title'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              features[index]['subtitle'],
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // --- RIGHT PANEL: LOGIN FORM ---
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 40,
                            ),
                            child: _buildLoginForm(isMobile: false),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: IconButton(
                            onPressed: widget.onBackToDashboard,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // MOBILE VIEW
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: _buildLoginForm(isMobile: true),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginForm({required bool isMobile}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: (_isLoading || _isSuccess || _isError) ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: _isLoading || _isSuccess || _isError,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onBackToDashboard,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                  ),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Login to Your Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkIndigo,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Enter your credentials to access the SAP environment.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Company",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCompany,
                  isExpanded: true,
                  decoration: _buildInputDecoration(
                    "Select Company",
                    Icons.business_rounded,
                  ),
                  items: companies
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedCompany = val),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Email Address",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _userController,
                  decoration: _buildInputDecoration(
                    "name@company.com",
                    Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: _buildInputDecoration(
                    "••••••••",
                    Icons.lock_outline_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            value: false,
                            onChanged: (v) {},
                            activeColor: AppColors.primaryIndigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Remember me",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: widget.onForgotPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loginTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryIndigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          InkWell(
                            onTap: widget.onGoToSignUp,
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: AppColors.primaryIndigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 16,
                              color: Colors.amber.shade900,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Note: New registrations require manual Admin approval.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryIndigo,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Verifying...",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkIndigo,
                ),
              ),
            ],
          ),
        if (_isSuccess)
          _buildStatusBox(
            color: Colors.green.shade600,
            icon: Icons.check_circle_rounded,
            title: "Success!",
            subtitle: "Access granted. Redirecting...",
          ),
        if (_isError)
          _buildStatusBox(
            color: Colors.red.shade600,
            icon: Icons.error_rounded,
            title: "Login Failed",
            subtitle: _errorMessage,
          ),
      ],
    );
  }

  Widget _buildStatusBox({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 60),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
