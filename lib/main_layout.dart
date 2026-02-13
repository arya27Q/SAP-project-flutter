import 'package:flutter/material.dart';
import 'constants.dart';
import 'sidebar_widget.dart';

// --- IMPORTS HALAMAN (TIDAK BERUBAH) ---
import 'desktop/pages/account/sap_auth_page.dart';
import 'desktop/pages/dashboard.dart';
import 'desktop/pages/sales_AR/sales_order_page.dart';
import 'desktop/pages/sales_AR/sales_quotation_page.dart';
import 'desktop/pages/sales_AR/delivery_page.dart';
import 'desktop/pages/sales_AR/ar_down_payment_invoice_page.dart';
import 'desktop/pages/sales_AR/ar_invoice_page.dart';
import 'desktop/pages/sales_AR/ar_credit_memo_page.dart';
import 'desktop/pages/sales_AR/return_page.dart';
import 'desktop/pages/Business_Partner_Master_Data.dart';
import 'desktop/pages/purchasing/purchase_request_page.dart';
import 'desktop/pages/purchasing/purchase_quotation_page.dart';
import 'desktop/pages/purchasing/purchase_order_page.dart';
import 'desktop/pages/purchasing/good_return_page.dart';
import 'desktop/pages/purchasing/good_receipt_po_page.dart';
import 'desktop/pages/purchasing/ap_down_payment_page.dart';
import 'desktop/pages/purchasing/ap_invoice_page.dart';
import 'desktop/pages/purchasing/ap_credit_memo_page.dart';
import 'desktop/pages/banking/incoming_payments/incoming_payment_page.dart';
import 'desktop/pages/banking/outgoing_payments/outgoing_payment_page.dart';
import 'desktop/pages/financials/journal_entry_page.dart';
import 'desktop/pages/inventory/item_master_data.dart';
import 'desktop/pages/Quality_Control_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- STATE MULTI-TAB ---
  // List Judul halaman yang sedang terbuka (sebagai ID)
  List<String> _openPageKeys = [];
  // List Widget halaman yang sedang terbuka (disimpan di memori)
  List<Widget> _openPageWidgets = [];
  // Index tab yang sedang aktif
  int _activeTabIndex = 0;

  bool isLoggedIn = false;
  int userLevel = 1;
  String userName = "Admin SAP";
  String userDiv = "Super User";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Default buka Dashboard saat pertama kali load (jika sudah login)
    if (isLoggedIn) {
      _addInitialTab();
    }
  }

  void _addInitialTab() {
    _openPageKeys = ["Dashboard"];
    _openPageWidgets = [_buildPageContent("Dashboard")];
    _activeTabIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return SapAuthPage(
        onLoginSuccess: () {
          setState(() {
            isLoggedIn = true;
            _addInitialTab(); // Reset tab saat login baru
          });
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    // String ID halaman yang aktif sekarang (untuk highlight sidebar)
    String currentActiveKey =
        _openPageKeys.isNotEmpty ? _openPageKeys[_activeTabIndex] : "Dashboard";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: isMobile
          ? SidebarWidget(
              currentView: currentActiveKey,
              onViewChanged: (view) => _handleViewChange(view),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.white10,
                    width: 1,
                  ),
                ),
              ),
              child: SidebarWidget(
                currentView: currentActiveKey,
                onViewChanged: (view) => _handleViewChange(view),
              ),
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
                      icon: Icon(Icons.menu,
                          color: const Color.fromARGB(255, 63, 55, 179)),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),

                // --- TAB BAR AREA (CUSTOM - FLOATING STYLE) ---
                // Hanya muncul jika ada tab terbuka (logic desktop)
                Container(
                  height: 55, // Lebih tinggi dikit biar muat shadownya
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 60, 54, 179),
                    // --- FIX: GARIS BAWAH (HEADER) ---
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.white10,
                          width: 1), // Garis pembatas bawah
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _openPageKeys.length,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    itemBuilder: (context, index) {
                      bool isActive = _activeTabIndex == index;
                      String title = _openPageKeys[index];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _activeTabIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.transparent, // Tab aktif jadi putih
                            borderRadius:
                                BorderRadius.circular(12), // Sudut tumpul
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.08), // Bayangan halus
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Icon penanda tipe halaman
                              Icon(
                                title == "Dashboard"
                                    ? Icons.dashboard_rounded
                                    : Icons.article_rounded,
                                size: 16,
                                color: isActive
                                    ? AppColors.darkIndigo
                                    : const Color.fromARGB(255, 255, 255, 255),
                              ),
                              const SizedBox(width: 8),

                              Text(
                                title,
                                style: TextStyle(
                                  color: isActive
                                      ? AppColors.darkIndigo
                                      : const Color.fromARGB(
                                          255, 255, 255, 255),
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),

                              // Tombol Close (X)
                              // Dashboard tidak boleh di-close
                              if (title != "Dashboard") ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _closeTab(index),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.grey[100]
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: isActive
                                          ? Colors.red[300]
                                          : Colors.grey,
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --- ISI KONTEN (INDEXED STACK) ---
                Expanded(
                  child: IndexedStack(
                    index: _activeTabIndex,
                    children: _openPageWidgets,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC MULTI-TAB ---

  void _handleViewChange(String view) {
    if (view == "Login") {
      // Logic Logout
      setState(() {
        isLoggedIn = false;
        _openPageKeys.clear();
        _openPageWidgets.clear();
      });
    } else {
      // Logic Buka Tab Baru / Pindah Tab
      setState(() {
        int existingIndex = _openPageKeys.indexOf(view);

        if (existingIndex != -1) {
          // 1. Jika tab sudah ada, pindah fokus ke tab tersebut
          _activeTabIndex = existingIndex;
        } else {
          // 2. Jika belum ada, tambahkan ke list dan buat widgetnya
          _openPageKeys.add(view);
          _openPageWidgets.add(_buildPageContent(view)); // Generate widget baru
          _activeTabIndex = _openPageKeys.length - 1; // Fokus ke tab baru
        }
      });
    }

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _closeTab(int index) {
    setState(() {
      // Hapus dari list key dan list widget
      _openPageKeys.removeAt(index);
      _openPageWidgets.removeAt(index);

      // Adjust active index supaya tidak error
      if (_activeTabIndex >= index) {
        _activeTabIndex = _activeTabIndex - 1;
        // Pastikan tidak minus (minimal 0)
        if (_activeTabIndex < 0 && _openPageKeys.isNotEmpty) {
          _activeTabIndex = 0;
        }
      }
    });
  }

  // --- BUILD CONTENT (FACTORY) ---
  // Diubah menerima parameter 'viewName' agar dinamis
  Widget _buildPageContent(String viewName) {
    switch (viewName) {
      case "Dashboard":
        return DashboardPage(
          userLevel: userLevel,
          userName: userName,
          userDivision: userDiv,
          onLogout: () => setState(() => isLoggedIn = false),
        );

      case "Sales Quotation":
        return const SalesQuotationPage();
      case "Sales Order":
        return const SalesOrderPage();
      case "Delivery":
        return const DeliveryPage();
      case "A/R Down Payment Invoice":
        return const ArDownPaymentInvoicePage();
      case "A/R Invoice":
        return const ArInvoicePage();
      case "A/R Credit Memo":
        return const ArCreditMemoPage();
      case "Return":
        return const ReturnPage();

      case "Business Partner Master Data":
        return const BpMasterDataPage();

      case "Purchase Request":
        return const PurchaseRequestPage();
      case "Purchase Quotation":
        return const PurchaseQuotationPage();
      case "Purchase Order":
        return const PurchaseOrderPage();
      case "Goods Return":
        return const GoodReturnPage();
      case "Goods Receipt PO":
        return const GoodReceiptPOPage();
      case "A/P Down Payment":
        return const ApDownPaymentPage();
      case "A/P Invoice":
        return const ApInvoicePage();
      case "A/P Credit Memo":
        return const ApCreditMemoPage();

      case "Incoming Payments":
        return const IncomingPaymentPage();

      case "Outgoing Payments":
        return const OutgoingPaymentPage();

      case "Journal Entry":
        return const JournalEntryPage();

      case "Item Master Data":
        return const ItemMasterDataPage();

      case "Quality Control":
        return const DesktopQcPage();

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                "Halaman '$viewName' belum tersedia.",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkIndigo,
                ),
              ),
            ],
          ),
        );
    }
  }
}
