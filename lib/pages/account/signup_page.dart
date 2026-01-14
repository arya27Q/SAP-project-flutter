import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String? selectedDivisi;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> companies = [
    "PT. Dempo Laser Metalindo",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  final List<String> divisions = [
    "IT",
    "Finance",
    "Purchasing",
    "Production",
    "Sales",
    "Inventory",
    "HR",
  ];

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getCompanyAlias(String? companyName) {
    if (companyName == null) return "company";
    if (companyName.contains("Dempo")) return "dempo";
    if (companyName.contains("Duta")) return "duta";
    if (companyName.contains("Senzo")) return "senzo";
    if (companyName.contains("ATMI")) return "atmi";
    return "company";
  }

  Future<void> _handleSignUp() async {
    String nameRaw = _nameController.text.trim();
    String nameClean = nameRaw.toLowerCase().replaceAll(' ', '');
    String email = _emailController.text.trim().toLowerCase();
    String password = _passwordController.text.trim().toLowerCase();
    String div = selectedDivisi?.toLowerCase() ?? "";
    String alias = _getCompanyAlias(selectedCompany);

    if (selectedCompany == null ||
        selectedDivisi == null ||
        nameRaw.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showErrorSnackBar("Please complete all required fields!");
      return;
    }

    String expectedEmail = "${nameClean}_$alias@gmail.com";
    if (email != expectedEmail) {
      _showErrorSnackBar("Format Email Salah! Wajib: $expectedEmail");
      return;
    }

    String expectedPw = "_${nameClean}_$div";
    if (password != expectedPw) {
      _showErrorSnackBar("Format Password Salah! Wajib: $expectedPw");
      return;
    }

    
    Map<String, String> companyMapping = {
      "PT. Dempo Laser Metalindo": "pt1",
      "PT. Duta Laserindo Metal": "pt2",
      "PT. Senzo Feinmetal": "pt3",
      "PT. ATMI Duta Engineering": "pt4",
    };

    String targetDatabase = companyMapping[selectedCompany!] ?? "pt1";

    setState(() => _isLoading = true);

    try {
      var response = await http
          .post(
            Uri.parse('http://192.168.40.92:8000/api/test-register'),
            body: {
              'name': nameRaw,
              'email': email,
              'password': _passwordController.text, // Tetap kirim password asli
              'target_pt': targetDatabase, // Ini yang masuk ke pt1/pt2/dst
              'divisi': selectedDivisi,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful! Please Login."),
              backgroundColor: Colors.green,
            ),
          );
          widget.onGoToLogin();
        }
      } else {
        _showErrorSnackBar(
          "Registration failed. Email might already be in use.",
        );
      }
    } catch (e) {
      _showErrorSnackBar("Connection Error: Server is unreachable.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
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
                opacity: _isLoading ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _isLoading,
                  child: _buildMainLayout(constraints),
                ),
              );
            },
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 30),
                      ],
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
                          "Creating Account...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.darkIndigo,
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

  Widget _buildMainLayout(BoxConstraints constraints) {
    if (constraints.maxWidth > 950) {
      return Row(
        children: [
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
                      child: _buildSignUpForm(isMobile: false),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      onPressed: widget.onBackToDashboard,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: 620,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildBrandingContent(),
                  ),
                ),
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
          "Empowering your business with the most advanced ERP solutions.",
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

  Widget _buildSignUpForm({required bool isMobile}) {
    String previewName = _nameController.text.isEmpty
        ? "nama"
        : _nameController.text.toLowerCase().replaceAll(' ', '');
    String previewAlias = _getCompanyAlias(selectedCompany);
    String previewDiv = selectedDivisi?.toLowerCase() ?? "divisi";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                "Create New Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkIndigo,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Register with the required format to access the system.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 35),
        const Text(
          "Business Unit",
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
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _isLoading
              ? null
              : (val) => setState(() => selectedCompany = val),
        ),
        const SizedBox(height: 20),
        const Text(
          "Division",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDivisi,
          isExpanded: true,
          decoration: _buildInputDecoration(
            "Select Division",
            Icons.groups_outlined,
          ),
          items: divisions
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: _isLoading
              ? null
              : (val) => setState(() => selectedDivisi = val),
        ),
        const SizedBox(height: 20),
        const Text(
          "Full Name",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          enabled: !_isLoading,
          onChanged: (v) => setState(() {}),
          decoration: _buildInputDecoration(
            "Enter your full name",
            Icons.badge_outlined,
          ),
        ),
        const SizedBox(height: 20),

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
              "(format: ${previewName}_$previewAlias@gmail.com)",
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
          controller: _emailController,
          enabled: !_isLoading,
          decoration: _buildInputDecoration(
            "e.g. budi_dempo@gmail.com",
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 20),

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
            Text(
              "(format: _${previewName}_$previewDiv)",
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
          controller: _passwordController,
          enabled: !_isLoading,
          obscureText: true,
          decoration: _buildInputDecoration(
            "e.g. _budi_it",
            Icons.lock_outline_rounded,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Create Account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  InkWell(
                    onTap: widget.onGoToLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "Registration requires manual confirmation from the Admin.",
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
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(32),
            child: _buildSignUpForm(isMobile: true),
          ),
        ),
      ),
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
}
