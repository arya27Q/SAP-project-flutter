import 'package:flutter/material.dart';
import 'constants.dart';
import 'sidebar_widget.dart';

import 'pages/account/login_page.dart';
import 'pages/account/signup_page.dart';
import 'pages/account/forgot_pw_page.dart'; // Pastikan nama file ini sesuai di folder kamu

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Secara default masuk ke Dashboard (isLoggedIn = true) agar tidak terhalang testing
  String currentView = "Dashboard";
  bool isLoggedIn = true; 
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // --- 1. LOGIKA HALAMAN FULL SCREEN (ACCOUNT) ---
    
    // Halaman Login
    if (currentView == "Login") {
      return LoginPage(
        onLoginSuccess: () => setState(() { 
          isLoggedIn = true; 
          currentView = "Dashboard"; 
        }),
        onGoToSignUp: () => setState(() => currentView = "Sign Up"),
        onForgotPassword: () => setState(() => currentView = "Forgot Password"),
        onBackToDashboard: () => setState(() => currentView = "Dashboard"),
      );
    }
    
    // Halaman Sign Up
    if (currentView == "Sign Up") {
      return SignUpPage(
        onGoToLogin: () => setState(() => currentView = "Login"),
        onBackToDashboard: () => setState(() => currentView = "Dashboard"),
      );
    }

    // Halaman Forgot Password
    if (currentView == "Forgot Password") {
      return ForgotPasswordPage(
        onGoToLogin: () => setState(() => currentView = "Login"),
        onBackToDashboard: () => setState(() => currentView = "Dashboard"),
      );
    }

    // --- 2. LAYOUT UTAMA (DASHBOARD & SIDEBAR) ---
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundGrey,
      
      // Sidebar untuk Mobile (Drawer)
      drawer: isMobile 
        ? SidebarWidget(
            currentView: currentView,
            onViewChanged: (view) {
              setState(() => currentView = view);
              Navigator.pop(context); 
            },
          ) 
        : null,

      body: Row(
        children: [
          // Sidebar untuk Desktop
          if (!isMobile)
            SidebarWidget(
              currentView: currentView,
              onViewChanged: (view) => setState(() => currentView = view),
            ),
          
          Expanded(
            child: Container(
              color: const Color(0xFFF5F3FF), 
              child: Column(
                children: [
                  _buildTopProfileHeader(isMobile),
                  
                  // Area Konten Dinamis
                  Expanded(
                    child: _buildPageContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk isi konten tengah
  Widget _buildPageContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Center(
        key: ValueKey(currentView),
        child: Text(
          "Halaman $currentView",
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: AppColors.darkIndigo,
          ),
        ),
      ),
    );
  }

  // Header Profil & Menu
  Widget _buildTopProfileHeader(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryIndigo.withOpacity(0.1),
              spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu, color: AppColors.darkIndigo),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            
            const Spacer(),

            // Tampilan Profil (Dropdown Logout)
            if (isLoggedIn)
              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'logout') {
                    setState(() {
                      isLoggedIn = false;
                      currentView = "Login";
                    });
                  } else {
                    setState(() => currentView = value);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Profile', child: Text("Profile")),
                  const PopupMenuItem(value: 'logout', child: Text("Logout", style: TextStyle(color: Colors.red))),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMobile)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Admin SAP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("Super User", style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    const SizedBox(width: 12),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryIndigo,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              )
            else
              // Tombol Sign In jika status logout
              ElevatedButton(
                onPressed: () => setState(() => currentView = "Login"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryIndigo),
                child: const Text("Sign In", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}