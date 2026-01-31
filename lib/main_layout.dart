import 'package:flutter/material.dart';
import 'constants.dart';
import 'sidebar_widget.dart';

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
  String currentView = "Dashboard";
  bool isLoggedIn = false;
  int userLevel = 1;
  String userName = "Admin SAP";
  String userDiv = "Super User";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return SapAuthPage(
        onLoginSuccess: () {
          setState(() {
            isLoggedIn = true;
            currentView = "Dashboard";
          });
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: isMobile
          ? SidebarWidget(
              currentView: currentView,
              onViewChanged: (view) => _handleViewChange(view),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SidebarWidget(
              currentView: currentView,
              onViewChanged: (view) => _handleViewChange(view),
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
                      icon: Icon(Icons.menu, color: AppColors.darkIndigo),
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

  // --- LOGIC GANTI HALAMAN & LOGOUT ---
  void _handleViewChange(String view) {
    if (view == "Login") {
      setState(() {
        isLoggedIn = false;
      });
    } else {
      setState(() {
        currentView = view;
      });
    }
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  Widget _getContentWidget() {
    return KeyedSubtree(key: ValueKey(currentView), child: _buildPageContent());
  }

  Widget _buildPageContent() {
    switch (currentView) {
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
                "Halaman '$currentView' belum tersedia.",
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
