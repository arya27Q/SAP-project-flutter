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
  String currentView = "Dashboard";
  bool isLoggedIn = true; 
  
  int userLevel = 1; 
  String userName = "Admin SAP";
  String userDiv = "Super User";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // --- 1. LOGIKA HALAMAN FULL SCREEN (LOGIN/SIGNUP) ---
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
    
    // --- 2. LAYOUT UTAMA (DASHBOARD & SIDEBAR) ---
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundGrey,
      
      // Drawer hanya untuk mobile agar bisa panggil menu
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
          // Sidebar Desktop
          if (!isMobile)
            SidebarWidget(
              currentView: currentView,
              onViewChanged: (view) => setState(() => currentView = view),
            ),
          
          Expanded(
            child: Container(
              color: const Color(0xFFF1F5F9), // Background senada dashboard modern
              child: Column(
                children: [
                  // TOMBOL MENU KHUSUS MOBILE (Hanya muncul jika di HP)
                  if (isMobile)
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.darkIndigo),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ),
                  
                  // AREA KONTEN DINAMIS (Langsung memanggil Dashboard tanpa header putih)
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
          onLogout: () => setState(() {
            isLoggedIn = false;
            currentView = "Login";
          }),
        );
      default:
        return Center(
          key: ValueKey(currentView),
          child: Text("Halaman $currentView", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkIndigo)),
        );
    }
  }
}