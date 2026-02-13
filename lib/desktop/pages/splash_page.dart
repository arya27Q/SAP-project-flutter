import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

// 🔥 IMPORT 🔥
import '../../main_layout.dart'; // Dashboard Desktop
import '../../tablet/login_page.dart'; // Login Tablet

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color darkSlate = const Color(0xFF0F172A);
  final Color accentYellow = const Color(0xFFFFD700);
  bool _isLoading = true;
  bool _showContent = false;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showContent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  // 🔥 LOGIC NAVIGASI (SUDAH DINORMALKAN KEMBALI) 🔥
  void _navigateToDashboard() {
    if (mounted) {
      // 1. Cek Lebar Layar
      double screenWidth = MediaQuery.of(context).size.width;

      bool isTablet = screenWidth < 900;

      // 2. Tentukan Tujuan Halaman
      Widget destinationPage;

      if (isTablet) {
        // Layar Sempit -> Masuk QC System
        destinationPage = const TabletLoginPage();
      } else {
        // Layar Lebar (Laptop) -> Masuk ERP System
        destinationPage = const MainLayout();
      }

      // 3. Pindah Halaman
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              destinationPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutQuart;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildCyberGrid(),
          _buildAnimatedSquare(top: 60, left: 0.06, size: 70, rotation: 0.5),
          _buildAnimatedSquare(top: 180, left: 0.18, size: 90, rotation: 0.6),
          _buildAnimatedSquare(
            bottom: 100,
            right: 0.05,
            size: 75,
            rotation: -0.2,
          ),
          _buildAnimatedSquare(
            bottom: 210,
            right: 0.15,
            size: 115,
            rotation: -0.4,
          ),
          _buildAnimatedSquare(top: 380, right: 0.28, size: 60, rotation: 0.8),

          _buildAnimatedPremiumCircle(
            -150,
            -150,
            450,
            primaryIndigo.withOpacity(0.12),
            delayMs: 0,
          ),
          _buildAnimatedPremiumCircle(
            null,
            null,
            300,
            Colors.indigoAccent.withOpacity(0.08),
            bottom: -100,
            left: -100,
            delayMs: 200,
          ),

          _buildFloatingParticle(top: 150, left: 0.15, size: 12),
          _buildFloatingParticle(top: 450, left: 0.85, size: 15),

          // Layout Utama (Teks & Tombol)
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildRobotWithGlow(),
                    const SizedBox(height: 50),
                    _buildBrandingSection(),
                    const SizedBox(height: 60),
                    _buildActionSection(),
                    const SizedBox(height: 40),
                    _buildFooterText(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... Widget Helper ...

  Widget _buildBrandingSection() {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1800),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _showContent ? 0 : 40, 0),
        child: Column(
          children: [
            Text(
              "WELCOME TO YOUR BUSINESS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 6.5,
                color: darkSlate.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryIndigo, const Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: primaryIndigo.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const Text(
                "ERP SYSTEM SAMUDRA II",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 2500),
      child: Text(
        "POWERED BY DLM GROUP TECHNOLOGY",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: darkSlate.withOpacity(0.5),
          letterSpacing: 2.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnimatedSquare({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double rotation,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left != null ? MediaQuery.of(context).size.width * left : null,
      right: right != null ? MediaQuery.of(context).size.width * right : null,
      child: AnimatedOpacity(
        opacity: _showContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 2000),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _showContent ? 0 : 20, 0),
          child: _buildFloatingSquareContent(size: size, rotation: rotation),
        ),
      ),
    );
  }

  Widget _buildFloatingSquareContent({
    required double size,
    required double rotation,
  }) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final double offset =
            Curves.easeInOutSine.transform(_floatingController.value) * 35;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: primaryIndigo.withOpacity(0.4),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryIndigo.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCyberGrid() => Opacity(
        opacity: 0.15,
        child: CustomPaint(
          size: Size.infinite,
          painter: GridPainter(gridColor: accentYellow),
        ),
      );

  Widget _buildFloatingParticle({
    required double top,
    required double left,
    required double size,
  }) =>
      Positioned(
        top: top,
        left: MediaQuery.of(context).size.width * left,
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 2000),
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, 50 * _floatingController.value),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryIndigo.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildRobotWithGlow() {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _showContent ? 0 : 30, 0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) => Container(
                width: 320 * value,
                height: 320 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withOpacity(0.15),
                      blurRadius: 100,
                      spreadRadius: 40 * value,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 350,
              height: 350,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_m6cuL6.json',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPremiumCircle(
    double? top,
    double? right,
    double size,
    Color color, {
    double? bottom,
    double? left,
    int delayMs = 0,
  }) =>
      Positioned(
        top: top,
        right: right,
        bottom: bottom,
        left: left,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 1600 + delayMs),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: color.withOpacity(0.15), width: 25),
              ),
            ),
          ),
        ),
      );

  Widget _buildActionSection() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        child: _isLoading
            ? CircularProgressIndicator(
                strokeWidth: 4,
                color: primaryIndigo.withOpacity(0.6),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryIndigo.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _navigateToDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 65,
                      vertical: 26,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: const BorderSide(color: Colors.white, width: 4.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "GET STARTED",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 15),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
      );
}

class GridPainter extends CustomPainter {
  final Color gridColor;
  GridPainter({required this.gridColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.8)
      ..strokeWidth = 0.8;
    for (double i = 0; i <= size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
