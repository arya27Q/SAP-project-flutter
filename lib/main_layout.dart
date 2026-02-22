import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
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
import 'desktop/pages/financials/chart_of_accounts_page.dart';
import 'desktop/pages/inventory/item_master_data.dart';
import 'desktop/pages/inventory/good_issue_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- STATE MULTI-SPLIT VIEW ---
  // List Judul halaman yang sedang terbuka (sebagai ID)
  List<String> _openPageKeys = [];
  // List Widget halaman yang sedang terbuka (disimpan di memori)
  List<Widget> _openPageWidgets = [];

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
      _addInitialWindow();
    }
  }

  void _addInitialWindow() {
    _openPageKeys = ["Dashboard"];
    _openPageWidgets = [_buildPageContent("Dashboard")];
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return SapAuthPage(
        onLoginSuccess: () {
          setState(() {
            isLoggedIn = true;
            _addInitialWindow(); // Reset window saat login baru
          });
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    // String ID halaman yang aktif (yang terakhir diklik)
    String currentActiveKey =
        _openPageKeys.isNotEmpty ? _openPageKeys.last : "Dashboard";

    // --- CONTROLLER SPLIT VIEW ---
    MultiSplitViewController contentSplitController = MultiSplitViewController(
      areas: _openPageKeys.asMap().entries.map((entry) {
        int index = entry.key;
        String title = entry.value;
        Widget content = _openPageWidgets[index];

        return Area(
          builder: (context, area) {
            return Container(
              margin: const EdgeInsets.all(4), // Jarak antar window
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0,
                          0.05), // FIX: Menggunakan format yang tidak deprecated
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]),
              child: Column(
                children: [
                  // --- HEADER WINDOW (JUDUL & CLOSE) ---
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    // 🔥 FIX: Pelindung biar header nggak error kalau layar super sempit
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const double minHeaderWidth = 140.0;
                          bool needScroll =
                              constraints.maxWidth < minHeaderWidth;

                          Widget headerContent = Container(
                            width: needScroll
                                ? minHeaderWidth
                                : constraints.maxWidth,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        title == "Dashboard"
                                            ? Icons.dashboard_rounded
                                            : Icons.article_rounded,
                                        size: 16,
                                        color: const Color(0xFF4F46E5),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF2D3748)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (title != "Dashboard" ||
                                    _openPageKeys.length > 1)
                                  InkWell(
                                    onTap: () => _closeWindow(index),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close,
                                          size: 14, color: Colors.red.shade400),
                                    ),
                                  )
                              ],
                            ),
                          );

                          // Kalau terlalu sempit, biarkan scroll (tapi disembunyikan pakai ClipRect)
                          if (needScroll) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              child: headerContent,
                            );
                          }
                          return headerContent;
                        },
                      ),
                    ),
                  ),

                  // --- ISI HALAMAN (ANTI KEPOTONG / OVERFLOW) ---
                  Expanded(
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Ukuran minimum form agar tidak nabrak (sesuaikan jika perlu)
                          const double minSafeWidth = 1050.0;
                          const double minSafeHeight = 600.0;

                          bool needHorizontalScroll =
                              constraints.maxWidth < minSafeWidth;
                          bool needVerticalScroll =
                              constraints.maxHeight < minSafeHeight;

                          // Kunci ukuran form, kalau layar kekecilan, form tetap utuh
                          Widget pageWrapper = SizedBox(
                            width: needHorizontalScroll
                                ? minSafeWidth
                                : constraints.maxWidth,
                            height: needVerticalScroll
                                ? minSafeHeight
                                : constraints.maxHeight,
                            child: content,
                          );

                          // Otomatis kasih scroll kalau sempit
                          if (needHorizontalScroll && needVerticalScroll) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: pageWrapper,
                              ),
                            );
                          } else if (needHorizontalScroll) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: pageWrapper,
                            );
                          } else if (needVerticalScroll) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: pageWrapper,
                            );
                          }

                          // Tampil normal kalau layar lebar
                          return pageWrapper;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );

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
          // ==========================================
          // SIDEBAR MENU (KIRI)
          // ==========================================
          if (!isMobile)
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(right: BorderSide(color: Colors.white10, width: 1)),
              ),
              child: SidebarWidget(
                currentView: currentActiveKey,
                onViewChanged: (view) => _handleViewChange(view),
              ),
            ),

          // ==========================================
          // AREA KERJA KONTEN (KANAN) DENGAN SPLIT VIEW
          // ==========================================
          Expanded(
            child: Column(
              children: [
                // Tombol Menu untuk Mobile
                if (isMobile)
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.menu,
                          color: Color.fromARGB(255, 63, 55, 179)),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),

                // Area Kerja Multi Split View
                Expanded(
                  child: Container(
                    color: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.all(8.0),
                    // Theme untuk mengatur garis pembatas (divider)
                    child: MultiSplitViewTheme(
                      data: MultiSplitViewThemeData(
                        dividerPainter: DividerPainters.grooved1(
                          color: Colors.grey.shade400,
                          highlightedColor:
                              const Color(0xFF4F46E5), // Biru Indigo
                          size: 30, // Panjang titik-titik
                        ),
                        dividerThickness: 8, // Ketebalan area drag
                      ),
                      child: MultiSplitView(
                        controller: contentSplitController,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC MULTI-SPLIT WINDOW ---

  void _handleViewChange(String view) {
    if (view == "Login") {
      // Logic Logout
      setState(() {
        isLoggedIn = false;
        _openPageKeys.clear();
        _openPageWidgets.clear();
      });
    } else {
      // Logic Buka Halaman Baru Sebelahan
      setState(() {
        int existingIndex = _openPageKeys.indexOf(view);

        // Kalau halaman udah kebuka, nggak usah nambah lagi (biar nggak dobel)
        if (existingIndex == -1) {
          // Limit maksimal 3 halaman biar nggak terlalu kecil layarnya
          if (_openPageKeys.length >= 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Maksimal buka 4 layar bersamaan! Tutup salah satu dulu ya!.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Tambah ke list dan generate widgetnya
          _openPageKeys.add(view);
          _openPageWidgets.add(_buildPageContent(view));
        }
      });
    }

    // Tutup drawer kalau di mode mobile
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _closeWindow(int index) {
    setState(() {
      // Hapus dari list
      _openPageKeys.removeAt(index);
      _openPageWidgets.removeAt(index);

      // Kalau semua ditutup, kembalikan ke dashboard biar layar nggak kosong hitam
      if (_openPageKeys.isEmpty) {
        _addInitialWindow();
      }
    });
  }

  // --- BUILD CONTENT (FACTORY) ---
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

      case "Good Issue":
        return const GoodIssuePage();

      case "Chart of Accounts":
        return const ChartOfAccountsPage();

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                "Halaman '$viewName' belum tersedia.",
                style: const TextStyle(
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
