import 'package:flutter/material.dart';
import 'pages/purchasing/purchase_quotation_page.dart';
import 'constants.dart';
import 'sidebar_widget.dart';
import 'pages/account/login_page.dart';
import 'pages/account/signup_page.dart';
import 'pages/account/forgot_pw_page.dart';
import 'pages/dashboard.dart';
import 'pages/sales_AR/sales_order_page.dart';
import 'pages/sales_AR/sales_quotation_page.dart';
import 'pages/sales_AR/delivery_page.dart';
import 'pages/bpmasterdata_page.dart';
import 'pages/purchasing/purchase_request_page.dart';
import 'pages/purchasing/purchase_order_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String currentView = "Login";
  bool isLoggedIn = false;

  int userLevel = 1;
  String userName = "Admin SAP";
  String userDiv = "Super User";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // 1. HALAMAN FULL SCREEN (LOGIN/SIGNUP/FORGOT PW)
    if (!isLoggedIn ||
        currentView == "Login" ||
        currentView == "Sign Up" ||
        currentView == "Forgot Password") {
      switch (currentView) {
        case "Sign Up":
          return SignUpPage(
            onGoToLogin: () => setState(() => currentView = "Login"),
            onBackToDashboard: () => setState(
              () => currentView = isLoggedIn ? "Dashboard" : "Login",
            ),
          );
        case "Forgot Password":
          return ForgotPasswordPage(
            onGoToLogin: () => setState(() => currentView = "Login"),
            onBackToDashboard: () => setState(
              () => currentView = isLoggedIn ? "Dashboard" : "Login",
            ),
          );
        default: // Login Page
          return LoginPage(
            onLoginSuccess: () {
              setState(() {
                isLoggedIn = true;
                currentView = "Dashboard";
              });
            },
            onGoToSignUp: () => setState(() => currentView = "Sign Up"),
            onForgotPassword: () =>
                setState(() => currentView = "Forgot Password"),
            onBackToDashboard: () {
              setState(() => currentView = isLoggedIn ? "Dashboard" : "Login");
            },
          );
      }
    }

    // 2. LAYOUT UTAMA (DENGAN SIDEBAR)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(
        0xFFF1F5F9,
      ), // Pakai slate grey agar kontras dengan kotak putih

      drawer: isMobile
          ? SidebarWidget(
              currentView: currentView,
              onViewChanged: (view) {
                setState(() => currentView = view);
                Navigator.pop(context); // Tutup sidebar setelah pilih menu
              },
            )
          : null,

      body: Row(
        children: [
          if (!isMobile)
            SidebarWidget(
              currentView: currentView,
              onViewChanged: (view) => setState(() => currentView = view),
            ),

          Expanded(
            child: Column(
              children: [
                if (isMobile)
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.darkIndigo),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _getContentWidget(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

      case "Sales Quotation":
        return const SalesQuotationPage(key: ValueKey("Sales Quotation"));

      case "Sales Order":
        return const SalesOrderPage(key: ValueKey("Sales Order"));

      case "Delivery":
        return const DeliveryPage(key: ValueKey("Delivery"));

      case "Business Partner Master Data":
        return const BpMasterDataPage(
          key: ValueKey("Business Partner Master Data"),
        );

      case "Purchase Request":
        return const PurchaseRequestPage(key: ValueKey("Purchase Request"));

      case "Purchase Quotation":
        return const PurchaseQuotationPage(key: ValueKey("Purchase Quotation"));

      case "Purchase Order":
        return const PurchaseOrderPage(key: ValueKey("Purchase Order"));

      default:
        return Center(
          key: ValueKey(currentView),
          child: Text(
            "Halaman $currentView",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkIndigo,
            ),
          ),
        );
    }
  }
}
