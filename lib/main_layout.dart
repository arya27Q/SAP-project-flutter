import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'constants.dart';
import 'sidebar_widget.dart';
import 'floating_window_widget.dart'; // 🔥 IMPORT BARU: File Floating Widget kamu

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
import 'desktop/pages/business_partner_master_data.dart.dart';
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

import 'desktop/pages/sales_AR/cancel_write_off_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- STATE MULTI-SPLIT VIEW & FLOATING ---
  List<String> _openPageKeys = [];
  List<Widget> _openPageWidgets = [];

  // 🔥 STATE BARU: Saklar Mode Layar & Fokus Jendela
  bool isFloatingMode = false;
  String focusedWindowKey = "Dashboard";

  bool isLoggedIn = false;
  int userLevel = 1;
  String userName = "Admin SAP";
  String userDiv = "Super User";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (isLoggedIn) {
      _addInitialWindow();
    }
  }

  void _addInitialWindow() {
    _openPageKeys = ["Dashboard"];
    _openPageWidgets = [_buildPageContent("Dashboard")];
    focusedWindowKey = "Dashboard";
  }

  // 🔥 FUNGSI BARU: Bawa Jendela ke Paling Depan (MDI)
  void _bringToFront(String key) {
    int index = _openPageKeys.indexOf(key);
    if (index != -1 && index != _openPageKeys.length - 1) {
      setState(() {
        String k = _openPageKeys.removeAt(index);
        Widget w = _openPageWidgets.removeAt(index);
        _openPageKeys.add(k);
        _openPageWidgets.add(w);
        focusedWindowKey = key;
      });
    } else if (index == _openPageKeys.length - 1) {
      setState(() {
        focusedWindowKey = key;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return SapAuthPage(
        onLoginSuccess: () {
          setState(() {
            isLoggedIn = true;
            _addInitialWindow();
          });
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

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
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]),
              child: Column(
                children: [
                  // --- HEADER WINDOW (SPLIT VIEW) ---
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double headerWidth = constraints.maxWidth < 160
                              ? 160
                              : constraints.maxWidth;

                          return OverflowBox(
                            alignment: Alignment.centerLeft,
                            minWidth: headerWidth,
                            maxWidth: headerWidth,
                            child: Container(
                              width: headerWidth,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            size: 14,
                                            color: Colors.red.shade400),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // --- ISI HALAMAN (ANTI KEPOTONG / OVERFLOW) ---
                  Expanded(
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const double minSafeWidth = 1050.0;
                          const double minSafeHeight = 600.0;

                          bool needHorizontalScroll =
                              constraints.maxWidth < minSafeWidth;
                          bool needVerticalScroll =
                              constraints.maxHeight < minSafeHeight;

                          Widget pageWrapper = SizedBox(
                            width: needHorizontalScroll
                                ? minSafeWidth
                                : constraints.maxWidth,
                            height: needVerticalScroll
                                ? minSafeHeight
                                : constraints.maxHeight,
                            child: content,
                          );

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
          // AREA KERJA KONTEN (KANAN)
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

                // 🔥 TOP BAR: TOMBOL SAKLAR MODE WORKSPACE
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Enterprise Workspace",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            fontSize: 14),
                      ),
                      Row(
                        children: [
                          Text("Split View",
                              style: TextStyle(
                                  color: !isFloatingMode
                                      ? const Color(0xFF4F46E5)
                                      : Colors.grey.shade500,
                                  fontWeight: !isFloatingMode
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12)),
                          Switch(
                            value: isFloatingMode,
                            activeTrackColor: const Color(
                                0xFF4F46E5), // Warna background saat nyala
                            activeThumbColor:
                                Colors.white, // Warna buletan saat nyala
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade200,
                            onChanged: (val) {
                              setState(() {
                                isFloatingMode = val;
                                // Kalau balik ke Split View dan layarnya kebanyakan (> 4), kita pangkas otomatis
                                if (!isFloatingMode &&
                                    _openPageKeys.length > 4) {
                                  _openPageKeys.removeRange(
                                      0, _openPageKeys.length - 4);
                                  _openPageWidgets.removeRange(
                                      0, _openPageWidgets.length - 4);
                                }
                              });
                            },
                          ),
                          Text("Floating MDI",
                              style: TextStyle(
                                  color: isFloatingMode
                                      ? const Color(0xFF4F46E5)
                                      : Colors.grey.shade500,
                                  fontWeight: isFloatingMode
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),

                // AREA KERJA UTAMA (Bisa Split View / Floating tergantung saklar)
                Expanded(
                  child: Container(
                    color: const Color(0xFFF1F5F9),
                    padding: isFloatingMode
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(8.0),
                    child: isFloatingMode
                        // 🔥 MODE 1: FLOATING WINDOWS (MDI)
                        ? Stack(
                            children: _openPageKeys.map<Widget>((key) {
                              int index = _openPageKeys.indexOf(key);
                              // Biar jendelanya kalau buka banyak nggak numpuk 100% di titik yang sama (kayak di Windows)
                              double initOffset = 20.0 + (index * 30.0);

                              return FloatingWindowWidget(
                                key: ValueKey(
                                    key), // Wajib pakai Key biar posisinya nggak ketuker
                                title: key,
                                content: _openPageWidgets[index],
                                initialX: initOffset,
                                initialY: initOffset,
                                isFocused: focusedWindowKey == key,
                                onClose: () => _closeWindow(index),
                                onFocus: () => _bringToFront(
                                    key), // Maju ke depan kalau di-klik
                              );
                            }).toList(),
                          )
                        // 🔥 MODE 2: MULTI SPLIT VIEW (DEFAULT)
                        : MultiSplitViewTheme(
                            data: MultiSplitViewThemeData(
                              dividerPainter: DividerPainters.grooved1(
                                color: Colors.grey.shade400,
                                highlightedColor: const Color(0xFF4F46E5),
                                size: 30,
                              ),
                              dividerThickness: 8,
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

  // --- LOGIC MULTI-SPLIT WINDOW & FLOATING ---

  void _handleViewChange(String view) {
    if (view == "Login") {
      setState(() {
        isLoggedIn = false;
        _openPageKeys.clear();
        _openPageWidgets.clear();
      });
    } else {
      setState(() {
        int existingIndex = _openPageKeys.indexOf(view);

        if (existingIndex == -1) {
          // Limit maksimal 4 halaman untuk Split View
          if (!isFloatingMode && _openPageKeys.length >= 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Mode Split View maksimal 4 layar! Tutup salah satu dulu atau ganti ke Mode Floating.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Limit maksimal 10 halaman untuk Floating biar RAM gak meledak
          if (isFloatingMode && _openPageKeys.length >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Mode Floating maksimal 10 layar! Silakan tutup dokumen yang tidak terpakai.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Tambah halaman baru
          _openPageKeys.add(view);
          _openPageWidgets.add(_buildPageContent(view));
          focusedWindowKey = view; // Fokus ke halaman yang baru dibuka
        } else {
          // Kalau halaman udah kebuka, dan kita di Mode Floating, bawa dia ke paling depan!
          if (isFloatingMode) {
            _bringToFront(view);
          }
        }
      });
    }

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _closeWindow(int index) {
    setState(() {
      _openPageKeys.removeAt(index);
      _openPageWidgets.removeAt(index);

      if (_openPageKeys.isEmpty) {
        _addInitialWindow();
      } else {
        // Pindah fokus ke jendela terakhir setelah di-close
        focusedWindowKey = _openPageKeys.last;
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

      case "Cancel Write Off":
        return const CancelWritteOffPage();

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
