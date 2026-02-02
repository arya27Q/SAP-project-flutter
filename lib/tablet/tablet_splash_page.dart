import 'package:flutter/material.dart';
import 'dart:async'; 
import 'login_page.dart'; 

class TabletSplashPage extends StatefulWidget {
  const TabletSplashPage({super.key});

  @override
  State<TabletSplashPage> createState() => _TabletSplashPageState();
}

class _TabletSplashPageState extends State<TabletSplashPage> {
  
  @override
  void initState() {
    super.initState();
    // LOGIC TIMER
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TabletLoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF311B92), 
              Color(0xFF4F46E5), 
              Color(0xFF7C4DFF), 
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded, // Icon QC
                size: 80,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),

            // --- APP TITLE ---
            const Text(
              "QC SYSTEM",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tablet Inspector Edition",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 60),

            // --- LOADING INDICATOR ---
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            
            const SizedBox(height: 20),
            const Text(
              "Loading assets...",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}