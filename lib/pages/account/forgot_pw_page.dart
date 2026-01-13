import 'package:flutter/material.dart';
import '../../constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback onGoToLogin;
  final VoidCallback onBackToDashboard;

  const ForgotPasswordPage({
    super.key,
    required this.onGoToLogin,
    required this.onBackToDashboard,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? selectedCompany;
  final TextEditingController _emailController = TextEditingController();

  // State untuk Loading Overlay
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isError = false;
  String _errorMessage = ""; // Sekarang digunakan di _buildStatusOverlay

  final List<String> companies = [
    "PT. Dempo Laser Metalindo Surabaya",
    "PT. Duta Laserindo Metal",
    "PT. Senzo Feinmetal",
    "PT. ATMI Duta Engineering",
  ];

  final List<Map<String, dynamic>> features = [
    {"icon": Icons.security_rounded, "title": "Secure Reset", "subtitle": "Encrypted recovery process."},
    {"icon": Icons.mark_email_read_rounded, "title": "Email Delivery", "subtitle": "Instant instruction delivery."},
    {"icon": Icons.support_agent_rounded, "title": "IT Support", "subtitle": "Contact admin for manual reset."},
    {"icon": Icons.admin_panel_settings_rounded, "title": "Verified Access", "subtitle": "Strict corporate security."},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- PERBAIKAN LOGIKA: Membuat if-else menjadi dinamis agar tidak "Dead Code" ---
  Future<void> _handleResetPassword() async {
    if (selectedCompany == null || _emailController.text.isEmpty) {
      _showErrorSnackBar("Please complete all fields!");
      return;
    }

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi pengecekan format email sederhana agar kondisi tidak selalu TRUE
      if (_emailController.text.contains('@') && _emailController.text.length > 5) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) widget.onGoToLogin();
        });
      } else {
        // Logika ini sekarang bisa dicapai (Garis oranye hilang)
        _handleResetError("The email format is invalid or not found.");
      }
    } catch (e) {
      _handleResetError("Connection failed. Try again later.");
    }
  }

  void _handleResetError(String message) {
    setState(() {
      _isLoading = false;
      _isError = true;
      _errorMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isError = false);
    });
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
          // 1. MAIN LAYOUT
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedOpacity(
                opacity: (_isLoading || _isSuccess || _isError) ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _isLoading || _isSuccess || _isError,
                  child: _buildMainContent(constraints),
                ),
              );
            },
          ),

          // 2. GLOBAL OVERLAY (True Center)
          if (_isLoading || _isSuccess || _isError)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30)],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo),
              strokeWidth: 5,
            ),
            SizedBox(height: 24),
            Text("Processing Request...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkIndigo)),
          ],
        ),
      );
    }
    if (_isSuccess) {
      return _buildStatusBox(
        color: Colors.green.shade600,
        icon: Icons.mark_email_read_rounded,
        title: "Instructions Sent",
        subtitle: "Please check your inbox for reset link.",
      );
    }
    if (_isError) {
      return _buildStatusBox(
        color: Colors.red.shade600,
        icon: Icons.error_rounded,
        title: "Request Failed",
        subtitle: _errorMessage, // Variabel dipakai di sini (Garis biru hilang)
      );
    }
    return const SizedBox.shrink();
  }

  // ... (Widget _buildMainContent, _buildForgotForm, _buildMobileLayout, dan _buildStatusBox tetap sama seperti sebelumnya) ...

  Widget _buildMainContent(BoxConstraints constraints) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                      child: _buildForgotForm(isMobile: false),
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
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Container(
                    width: 620,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_reset_rounded, color: Colors.white, size: 50),
                            SizedBox(width: 20),
                            Text("PASSWORD RECOVERY", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Don't worry! It happens to the best of us. Follow the instructions to securely regain access to your account.",
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
                            mainAxisSpacing: 15,
                          ),
                          itemCount: features.length,
                          itemBuilder: (context, index) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                  child: Icon(features[index]['icon'], color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(features[index]['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(features[index]['subtitle'], style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
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
        ],
      );
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildForgotForm({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMobile) Align(alignment: Alignment.centerLeft, child: IconButton(padding: EdgeInsets.zero, onPressed: widget.onBackToDashboard, icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryIndigo))),
        const Center(
          child: Column(
            children: [
              Text("Forgot Password?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkIndigo)),
              SizedBox(height: 10),
              Text("Enter your email address to receive reset instructions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text("Registered Company", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCompany,
          isExpanded: true,
          decoration: _buildInputDecoration("Select Company", Icons.business_rounded),
          items: companies.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (val) => setState(() => selectedCompany = val),
        ),
        const SizedBox(height: 24),
        const Text("Email Address", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _emailController, decoration: _buildInputDecoration("name@company.com", Icons.email_outlined)),
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleResetPassword,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryIndigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Send Instructions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 25),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Remember your password? ", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  InkWell(onTap: widget.onGoToLogin, child: const Text("Back to Login", style: TextStyle(color: AppColors.primaryIndigo, fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.report_problem_rounded, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(child: Text("If you are unable to reset your password, please contact your Administrator for manual recovery.", style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500, height: 1.4))),
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
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkIndigo, AppColors.primaryIndigo])),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.all(32),
            child: _buildForgotForm(isMobile: true),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 1.5)),
    );
  }

  Widget _buildStatusBox({required Color color, required IconData icon, required String title, required String subtitle}) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 60),
                const SizedBox(height: 20),
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 8),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}