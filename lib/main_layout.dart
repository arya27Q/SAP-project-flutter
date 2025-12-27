import 'package:flutter/material.dart';
import 'constants.dart';
import 'sidebar_widget.dart';
import 'pages/account/login_page.dart';
import 'pages/account/signup_page.dart';
import 'pages/account/forgot_pw_page.dart';
import 'pages/dashboard.dart'; 

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- UBAH: Mulai dari halaman Login agar tidak langsung masuk ---
  String currentView = "Login"; 
  bool isLoggedIn = false;      
  
  // Data user (Nanti diisi setelah loginTest sukses)
  int userLevel = 1; 
  String userName = "Admin SAP";
  String userDiv = "Super User";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // --- 1. LOGIKA HALAMAN FULL SCREEN (LOGIN/SIGNUP/FORGOT PW) ---
    // Jika belum login atau sedang di view auth, tampilkan tanpa Sidebar
    if (!isLoggedIn || currentView == "Login" || currentView == "Sign Up" || currentView == "Forgot Password") {
      if (currentView == "Login") {
        return LoginPage(
          onLoginSuccess: () {
            setState(() { 
              isLoggedIn = true; 
              currentView = "Dashboard"; 
            });
          },
          onGoToSignUp: () => setState(() => currentView = "Sign Up"),
          onForgotPassword: () => setState(() => currentView = "Forgot Password"),
          onBackToDashboard: () {
            // Jika user klik close/back tapi belum login, tetap di login
            if (!isLoggedIn) {
              setState(() => currentView = "Login");
            } else {
              setState(() => currentView = "Dashboard");
            }
          },
        );
      } 
      
      if (currentView == "Sign Up") {
        return SignUpPage(
          onGoToLogin: () => setState(() => currentView = "Login"),
          onBackToDashboard: () => setState(() => currentView = isLoggedIn ? "Dashboard" : "Login"),
        );
      }

      if (currentView == "Forgot Password") {
        return ForgotPasswordPage(
          onGoToLogin: () => setState(() => currentView = "Login"),
          onBackToDashboard: () => setState(() => currentView = isLoggedIn ? "Dashboard" : "Login"),
        );
      }
    }
    
    // --- 2. LAYOUT UTAMA (DASHBOARD & MENU DENGAN SIDEBAR) ---
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
              color: const Color(0xFFF1F5F9), 
              child: Column(
                children: [
                  // Header Menu Button untuk Mobile
                  if (isMobile)
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.darkIndigo),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ),
                  
                  // Area Konten Halaman
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

  Widget _buildPageContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _getContentWidget(),
    );
  }

  Widget _getContentWidget() {
    switch (currentView) {
      case "Dashboard":
        return DashboardPage(
          key: const ValueKey("Dashboard"),
          userLevel: userLevel,
          userName: userName,
          userDivision: userDiv,
          onLogout: () {
            setState(() {
              isLoggedIn = false;
              currentView = "Login";
            });
          },
        );
      default:
        return Center(
          key: ValueKey(currentView),
          child: Text(
            "Halaman $currentView", 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkIndigo)
          ),
        );
    }
  }
}