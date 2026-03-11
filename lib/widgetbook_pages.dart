import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ==========================================
// 1. IMPORTS SEMUA HALAMAN LU
// ==========================================
import 'pages/account/sap_auth_page.dart';
import 'pages/dashboard.dart';
import 'pages/sales_AR/sales_order_page.dart';
import 'pages/sales_AR/sales_quotation_page.dart';
import 'pages/sales_AR/delivery_page.dart';
import 'pages/sales_AR/ar_down_payment_invoice_page.dart';
import 'pages/sales_AR/ar_invoice_page.dart';
import 'pages/sales_AR/ar_credit_memo_page.dart';
import 'pages/sales_AR/return_page.dart';
import 'pages/business_partner_master_data.dart';
import 'pages/purchasing/purchase_request_page.dart';
import 'pages/purchasing/purchase_quotation_page.dart';
import 'pages/purchasing/purchase_order_page.dart';
import 'pages/purchasing/good_return_page.dart';
import 'pages/purchasing/good_receipt_po_page.dart';
import 'pages/purchasing/ap_down_payment_page.dart';
import 'pages/purchasing/ap_invoice_page.dart';
import 'pages/purchasing/ap_credit_memo_page.dart';
import 'pages/banking/incoming_payments/incoming_payment_page.dart';
import 'pages/banking/outgoing_payments/outgoing_payment_page.dart';
import 'pages/financials/journal_entry_page.dart';
import 'pages/financials/chart_of_accounts_page.dart';
import 'pages/inventory/item_master_data.dart';
import 'pages/inventory/good_issue_page.dart';
import 'pages/inventory/inventory_transfer_page.dart';
import 'pages/inventory/inventory_transaction/inventory_counting_page.dart';
import 'pages/inventory/inventory_transaction/inventory_posting_page.dart';
import 'pages/sales_AR/cancel_write_off_page.dart';
import 'pages/inventory/good_receipt_page.dart';
import 'pages/administration/setup/inventory/item_group.dart';
import 'pages/administration/setup/inventory/warehouse.dart';
import 'pages/administration/setup/business_partner/countries.dart';

// ==========================================
// 2. MANTRA WIDGETBOOK (KATALOG FULL ERP)
// ==========================================

// --- AUTH & DASHBOARD ---
@widgetbook.UseCase(name: 'Login SAP', type: SapAuthPage)
Widget buildSapAuth(BuildContext context) => SapAuthPage(onLoginSuccess: () {});

@widgetbook.UseCase(name: 'Dashboard', type: DashboardPage)
Widget buildDashboard(BuildContext context) => DashboardPage(
      userLevel: 1,
      userName: "Admin SAP",
      userDivision: "Super User",
      onLogout: () {},
    );

// --- SALES (A/R) ---
@widgetbook.UseCase(name: 'Sales Quotation', type: SalesQuotationPage)
Widget buildSalesQuotation(BuildContext context) => const SalesQuotationPage();

@widgetbook.UseCase(name: 'Sales Order', type: SalesOrderPage)
Widget buildSalesOrder(BuildContext context) => const SalesOrderPage();

@widgetbook.UseCase(name: 'Delivery', type: DeliveryPage)
Widget buildDelivery(BuildContext context) => const DeliveryPage();

@widgetbook.UseCase(name: 'A/R Down Payment', type: ArDownPaymentInvoicePage)
Widget buildArDownPayment(BuildContext context) =>
    const ArDownPaymentInvoicePage();

@widgetbook.UseCase(name: 'A/R Invoice', type: ArInvoicePage)
Widget buildArInvoice(BuildContext context) => const ArInvoicePage();

@widgetbook.UseCase(name: 'A/R Credit Memo', type: ArCreditMemoPage)
Widget buildArCreditMemo(BuildContext context) => const ArCreditMemoPage();

@widgetbook.UseCase(name: 'Return', type: ReturnPage)
Widget buildReturn(BuildContext context) => const ReturnPage();

@widgetbook.UseCase(name: 'Cancel Write Off', type: CancelWritteOffPage)
Widget buildCancelWriteOff(BuildContext context) => const CancelWritteOffPage();

// --- BUSINESS PARTNER ---
@widgetbook.UseCase(name: 'BP Master Data', type: BpMasterDataPage)
Widget buildBpMasterData(BuildContext context) => const BpMasterDataPage();

// --- PURCHASING (A/P) ---
@widgetbook.UseCase(name: 'Purchase Request', type: PurchaseRequestPage)
Widget buildPurchaseRequest(BuildContext context) =>
    const PurchaseRequestPage();

@widgetbook.UseCase(name: 'Purchase Quotation', type: PurchaseQuotationPage)
Widget buildPurchaseQuotation(BuildContext context) =>
    const PurchaseQuotationPage();

@widgetbook.UseCase(name: 'Purchase Order', type: PurchaseOrderPage)
Widget buildPurchaseOrder(BuildContext context) => const PurchaseOrderPage();

@widgetbook.UseCase(name: 'Goods Receipt PO', type: GoodReceiptPOPage)
Widget buildGoodReceiptPO(BuildContext context) => const GoodReceiptPOPage();

@widgetbook.UseCase(name: 'Goods Return', type: GoodReturnPage)
Widget buildGoodReturn(BuildContext context) => const GoodReturnPage();

@widgetbook.UseCase(name: 'A/P Down Payment', type: ApDownPaymentPage)
Widget buildApDownPayment(BuildContext context) => const ApDownPaymentPage();

@widgetbook.UseCase(name: 'A/P Invoice', type: ApInvoicePage)
Widget buildApInvoice(BuildContext context) => const ApInvoicePage();

@widgetbook.UseCase(name: 'A/P Credit Memo', type: ApCreditMemoPage)
Widget buildApCreditMemo(BuildContext context) => const ApCreditMemoPage();

// --- BANKING ---
@widgetbook.UseCase(name: 'Incoming Payments', type: IncomingPaymentPage)
Widget buildIncomingPayment(BuildContext context) =>
    const IncomingPaymentPage();

@widgetbook.UseCase(name: 'Outgoing Payments', type: OutgoingPaymentPage)
Widget buildOutgoingPayment(BuildContext context) =>
    const OutgoingPaymentPage();

// --- FINANCIALS ---
@widgetbook.UseCase(name: 'Journal Entry', type: JournalEntryPage)
Widget buildJournalEntry(BuildContext context) => const JournalEntryPage();

@widgetbook.UseCase(name: 'Chart of Accounts', type: ChartOfAccountsPage)
Widget buildChartOfAccounts(BuildContext context) =>
    const ChartOfAccountsPage();

// --- INVENTORY ---
@widgetbook.UseCase(name: 'Item Master Data', type: ItemMasterDataPage)
Widget buildItemMasterData(BuildContext context) => const ItemMasterDataPage();

@widgetbook.UseCase(name: 'Good Receipt', type: GoodReceiptPage)
Widget buildGoodReceipt(BuildContext context) => const GoodReceiptPage();

@widgetbook.UseCase(name: 'Good Issue', type: GoodIssuePage)
Widget buildGoodIssue(BuildContext context) => const GoodIssuePage();

@widgetbook.UseCase(name: 'Inventory Transfer', type: InventoryTransferPage)
Widget buildInventoryTransfer(BuildContext context) =>
    const InventoryTransferPage();

@widgetbook.UseCase(name: 'Inventory Counting', type: InventoryCountingPage)
Widget buildInventoryCounting(BuildContext context) =>
    const InventoryCountingPage();

@widgetbook.UseCase(name: 'Inventory Posting', type: InventoryPostingPage)
Widget buildInventoryPosting(BuildContext context) =>
    const InventoryPostingPage();

// --- ADMINISTRATION (SETUP) ---
@widgetbook.UseCase(name: 'Item Group Setup', type: ItemGroupPage)
Widget buildItemGroup(BuildContext context) => const ItemGroupPage();

@widgetbook.UseCase(name: 'Warehouse Setup', type: WarehouseSetupPage)
Widget buildWarehouse(BuildContext context) => const WarehouseSetupPage();

@widgetbook.UseCase(name: 'Countries Setup', type: CountriesSetupPage)
Widget buildCountries(BuildContext context) => const CountriesSetupPage();
