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
    "PT. Dempo Laser Metalindo",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  // Mapping Domain untuk validasi login sesuai PT
  final Map<String, String> companyDomains = {
    "PT. Dempo Laser Metalindo": "@dempo.co.id",
    "PT. Duta Laserindo Metal": "@duta.co.id",
    "PT. Senzo Feinmetal": "@senzo.co.id",
    "PT. ATMI Duta Engineering": "@atmi.co.id",
  };

  final List<Map<String, dynamic>> features = [
    {
      "icon": Icons.grid_view_rounded,
      "title": "Dashboard",
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
      "subtitle": "Orders & Invoicing.",
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
      "icon": Icons.settings_suggest_rounded,
      "title": "Production",
      "subtitle": "MRP & Planning.",
    },
    {
      "icon": Icons.security_rounded,
      "title": "Data Security",
      "subtitle": "Encrypted protection.",
    },
    {
      "icon": Icons.analytics_rounded,
      "title": "Reports",
      "subtitle": "Business insights.",
    },
  ];

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> loginTest() async {
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
      _showErrorSnackBar("Email harus menggunakan domain $expectedDomain");
      return;
    }

    bool startsWithUpper = RegExp(r'^[A-Z]').hasMatch(password);
    bool hasYear = RegExp(r'\d{4}').hasMatch(password);

    if (!startsWithUpper || !hasYear || password.length < 8) {
      _showErrorSnackBar(
        "Password salah format! (Harus: Huruf Besar di awal, ada angka tahun, min 8 char)",
      );
      return;
    }

    Map<String, String> companyMapping = {
      "PT. Dempo Laser Metalindo": "pt1",
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
              'email': email,
              'password': password,
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
        _handleLoginError("Invalid credentials or Account not approved yet.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedOpacity(
                opacity: (_isLoading || _isSuccess || _isError) ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _isLoading || _isSuccess || _isError,
                  child: _buildMainLayout(constraints),
                ),
              );
            },
          ),
          if (_isLoading || _isSuccess || _isError)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(child: _buildStatusOverlay()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 30)],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryIndigo,
              ),
              strokeWidth: 5,
            ),
            SizedBox(height: 24),
            Text(
              "Verifying Credentials...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.darkIndigo,
              ),
            ),
          ],
        ),
      );
    }
    if (_isSuccess) {
      return _buildStatusBox(
        color: Colors.green.shade600,
        icon: Icons.check_circle_rounded,
        title: "Login Success",
        subtitle: "Redirecting to SAP Environment...",
      );
    }
    if (_isError) {
      return _buildStatusBox(
        color: Colors.red.shade600,
        icon: Icons.error_rounded,
        title: "Login Failed",
        subtitle: _errorMessage,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMainLayout(BoxConstraints constraints) {
    if (constraints.maxWidth > 950) {
      return Row(
        children: [
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
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Container(
                    width: 620,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildBrandingContent(),
                  ),
                ),
              ),
            ),
          ),
          // --- BAGIAN KANAN: BOX PEMBUNGKUS FORM ---
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey[50], 
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 35),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildLoginForm(isMobile: false),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: widget.onBackToDashboard,
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildBrandingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
          style: TextStyle(fontSize: 17, color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 50),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 20,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildLoginForm({required bool isMobile}) {
    String expectedDomain = selectedCompany != null
        ? companyDomains[selectedCompany!]!
        : "@company.co.id";

    return Column(
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
        Center(
          child: Column(
            children: [
              Text(
                "Login to Your Account",
                style: TextStyle(
                  fontSize: isMobile ? 22 : 26, // Disesuaikan ukuran mobile
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkIndigo,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Use your registered company email and password.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: isMobile ? 12 : 14),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30), 
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
                  child: Text(
                    s,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedCompany = val),
        ),
        SizedBox(height: isMobile ? 16 : 20), 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Email Address",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              "(format: name_$expectedDomain)",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _userController,
          decoration: _buildInputDecoration(
            "name$expectedDomain",
            Icons.email_outlined,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20), 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              "(format: Name_div_2025)",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: _buildInputDecoration(
            "Start with Uppercase",
            Icons.lock_outline_rounded,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (v) {},
                  activeColor: AppColors.primaryIndigo,
                  visualDensity: VisualDensity.compact,
                ),
                const Text("Remember me", style: TextStyle(fontSize: 13)),
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
        SizedBox(height: isMobile ? 16 : 25),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: loginTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        // --- WARNING BOX KUNING ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Important: Account must be registered and approved by Admin.",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Center(
          child: Row(
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
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // Outer padding dikurangi
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 20),
              ],
            ),
            padding: const EdgeInsets.all(24), // Inner padding dikurangi dari 32 ke 24
            child: _buildLoginForm(isMobile: true),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Content padding disesuaikan
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
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 30),
              ],
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