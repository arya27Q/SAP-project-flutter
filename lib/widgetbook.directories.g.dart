// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_project_sap/widgetbook_pages.dart'
    as _flutter_project_sap_widgetbook_pages;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'pages',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'BpMasterDataPage',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'BP Master Data',
            builder: _flutter_project_sap_widgetbook_pages.buildBpMasterData,
          )
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'DashboardPage',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Dashboard',
            builder: _flutter_project_sap_widgetbook_pages.buildDashboard,
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'account',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'SapAuthPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Login SAP',
                builder: _flutter_project_sap_widgetbook_pages.buildSapAuth,
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'administration',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'setup',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'business_partner',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'CountriesSetupPage',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Countries Setup',
                        builder: _flutter_project_sap_widgetbook_pages
                            .buildCountries,
                      )
                    ],
                  )
                ],
              ),
              _widgetbook.WidgetbookFolder(
                name: 'inventory',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'ItemGroupPage',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Item Group Setup',
                        builder: _flutter_project_sap_widgetbook_pages
                            .buildItemGroup,
                      )
                    ],
                  ),
                  _widgetbook.WidgetbookComponent(
                    name: 'WarehouseSetupPage',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Warehouse Setup',
                        builder: _flutter_project_sap_widgetbook_pages
                            .buildWarehouse,
                      )
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'banking',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'incoming_payments',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'IncomingPaymentPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Incoming Payments',
                    builder: _flutter_project_sap_widgetbook_pages
                        .buildIncomingPayment,
                  )
                ],
              )
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'outgoing_payments',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'OutgoingPaymentPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Outgoing Payments',
                    builder: _flutter_project_sap_widgetbook_pages
                        .buildOutgoingPayment,
                  )
                ],
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'financials',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ChartOfAccountsPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Chart of Accounts',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildChartOfAccounts,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'JournalEntryPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Journal Entry',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildJournalEntry,
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'inventory',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'GoodIssuePage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Good Issue',
                builder: _flutter_project_sap_widgetbook_pages.buildGoodIssue,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'GoodReceiptPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Good Receipt',
                builder: _flutter_project_sap_widgetbook_pages.buildGoodReceipt,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'InventoryTransferPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Inventory Transfer',
                builder: _flutter_project_sap_widgetbook_pages
                    .buildInventoryTransfer,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ItemMasterDataPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Item Master Data',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildItemMasterData,
              )
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'inventory_transaction',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'InventoryCountingPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inventory Counting',
                    builder: _flutter_project_sap_widgetbook_pages
                        .buildInventoryCounting,
                  )
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'InventoryPostingPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inventory Posting',
                    builder: _flutter_project_sap_widgetbook_pages
                        .buildInventoryPosting,
                  )
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'purchasing',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ApCreditMemoPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'A/P Credit Memo',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildApCreditMemo,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ApDownPaymentPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'A/P Down Payment',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildApDownPayment,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ApInvoicePage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'A/P Invoice',
                builder: _flutter_project_sap_widgetbook_pages.buildApInvoice,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'GoodReceiptPOPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Goods Receipt PO',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildGoodReceiptPO,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'GoodReturnPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Goods Return',
                builder: _flutter_project_sap_widgetbook_pages.buildGoodReturn,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PurchaseOrderPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Purchase Order',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildPurchaseOrder,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PurchaseQuotationPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Purchase Quotation',
                builder: _flutter_project_sap_widgetbook_pages
                    .buildPurchaseQuotation,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PurchaseRequestPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Purchase Request',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildPurchaseRequest,
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'sales_AR',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ArCreditMemoPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'A/R Credit Memo',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildArCreditMemo,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ArDownPaymentInvoicePage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'A/R Down Payment',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildArDownPayment,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ArInvoicePage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'A/R Invoice',
                builder: _flutter_project_sap_widgetbook_pages.buildArInvoice,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CancelWritteOffPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Cancel Write Off',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildCancelWriteOff,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DeliveryPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Delivery',
                builder: _flutter_project_sap_widgetbook_pages.buildDelivery,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReturnPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Return',
                builder: _flutter_project_sap_widgetbook_pages.buildReturn,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SalesOrderPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Sales Order',
                builder: _flutter_project_sap_widgetbook_pages.buildSalesOrder,
              )
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SalesQuotationPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Sales Quotation',
                builder:
                    _flutter_project_sap_widgetbook_pages.buildSalesQuotation,
              )
            ],
          ),
        ],
      ),
    ],
  )
];
