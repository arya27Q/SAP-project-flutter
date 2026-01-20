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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidCompanyEmail(String email, String? company) {
    if (company == null) return false;
    String? domain = companyDomains[company];
    return domain != null && email.endsWith(domain);
  }

  bool _isValidPassword(String pw, String? divisi) {
    if (divisi == null || pw.isEmpty) return false;
    bool startsWithUpper = RegExp(r'^[A-Z]').hasMatch(pw);
    bool containsDivisi = pw.toLowerCase().contains(divisi.toLowerCase());
    bool containsYear = RegExp(r'\d{4}').hasMatch(pw);
    return pw.length >= 8 && startsWithUpper && containsDivisi && containsYear;
  }

  Future<void> _handleSignUp() async {
    String nameRaw = _nameController.text.trim();
    String email = _emailController.text.trim().toLowerCase();
    String password = _passwordController.text.trim();

    if (selectedCompany == null ||
        selectedDivisi == null ||
        nameRaw.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showErrorSnackBar("Please complete all required fields!");
      return;
    }

    if (!_isValidCompanyEmail(email, selectedCompany)) {
      String domain = companyDomains[selectedCompany!] ?? "@company.co.id";
      _showErrorSnackBar("Email must use domain $domain");
      return;
    }

    if (!_isValidPassword(password, selectedDivisi)) {
      _showErrorSnackBar(
        "Password format: Uppercase start, contains '${selectedDivisi!}', and year.",
      );
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
            Uri.parse('http://192.168.0.101:8000/api/test-register'),
            body: {
              'name': nameRaw,
              'email': email,
              'password': password,
              'target_pt': targetDatabase,
              'divisi': selectedDivisi!,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful!"),
              backgroundColor: Colors.green,
            ),
          );
          widget.onGoToLogin();
        }
      } else {
        _showErrorSnackBar("Registration failed. Email might already exist.");
      }
    } catch (e) {
      _showErrorSnackBar("Connection Error: Server unreachable.");
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
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.05),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
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
    );
  }

  Widget _buildMainLayout(BoxConstraints constraints) {
    bool isDesktop = constraints.maxWidth > 950;
    return isDesktop
        ? Row(
            children: [
              Expanded(flex: 4, child: _buildLeftFormSection()),
              Expanded(flex: 6, child: _buildRightBrandingSection()),
            ],
          )
        : _buildMobileLayout();
  }

  Widget _buildLeftFormSection() {
    return Container(
      color: Colors.grey[50],
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildSignUpForm(isMobile: false),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              onPressed: widget.onBackToDashboard,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightBrandingSection() {
    return Container(
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
          child: Container(width: 620, child: _buildBrandingContent()),
        ),
      ),
    );
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

  Widget _buildSignUpForm({bool isMobile = false}) {
    String previewName = _nameController.text.isEmpty
        ? "name"
        : _nameController.text.toLowerCase().replaceAll(' ', '');
    String previewDomain = selectedCompany != null
        ? companyDomains[selectedCompany!]!
        : "@company.co.id";
    String previewDiv = selectedDivisi?.toLowerCase() ?? "division";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create New Account",
          style: TextStyle(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkIndigo,
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel("Business Unit"),
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
          onChanged: (val) => setState(() => selectedCompany = val),
        ),
        const SizedBox(height: 14),
        _buildLabel("Division"),
        DropdownButtonFormField<String>(
          value: selectedDivisi,
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
          onChanged: (val) => setState(() => selectedDivisi = val),
        ),
        const SizedBox(height: 14),
        _buildLabel("Full Name"),
        TextField(
          controller: _nameController,
          onChanged: (v) => setState(() {}),
          style: const TextStyle(fontSize: 14),
          decoration: _buildInputDecoration(
            "Enter your full name",
            Icons.badge_outlined,
          ),
        ),
        const SizedBox(height: 14),
        _buildLabel("Company Email (${previewName}$previewDomain)"),
        TextField(
          controller: _emailController,
          style: const TextStyle(fontSize: 14),
          decoration: _buildInputDecoration(
            "e.g. ${previewName}$previewDomain",
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 14),
        _buildLabel("Password (Name_${previewDiv}_2025)"),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(fontSize: 14),
          decoration: _buildInputDecoration(
            "Min 8 chars, Uppercase start",
            Icons.lock_outline_rounded,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              elevation: 0,
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
        const SizedBox(height: 20),
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
              Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Admin will be notified. Contact IT Admin for activation.",
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
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.grey, fontSize: 13),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 15),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: _buildSignUpForm(isMobile: true),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );

  InputDecoration _buildInputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
