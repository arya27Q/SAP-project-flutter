import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArDownPaymentInvoicePage extends StatefulWidget {
  const ArDownPaymentInvoicePage({super.key});

  @override
  State<ArDownPaymentInvoicePage> createState() =>
      _ArDownPaymentInvoicePageState();
}

class _ArDownPaymentInvoicePageState extends State<ArDownPaymentInvoicePage>
    with SingleTickerProviderStateMixin {
  bool showSidePanel = false;
  late TabController _tabController;
  int _rowCount = 10;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color.fromARGB(255, 255, 255, 255);
  final Color borderGrey = const Color.fromARGB(255, 208, 213, 220);
  final ScrollController _horizontalScroll = ScrollController();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};

  String formatPrice(String value) {
    String cleanText = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return "0,00";
    double parsed = double.tryParse(cleanText) ?? 0.0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    );

    return formatter.format(parsed);
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _fieldValues[key] ?? initial),
    );
  }

  FocusNode _getFnPrecision(String key) {
    if (!_focusNodes.containsKey(key)) {
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus) {
          final controller = _getCtrl(key);
          if (controller.text.trim().isEmpty) return;

          String cleanText = controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
          double? parsed = double.tryParse(cleanText);

          if (mounted) {
            setState(() {
              if (parsed != null) {
                controller.text = parsed.toStringAsFixed(4);
              } else {
                controller.text = "0.0000";
              }
              _fieldValues[key] = controller.text;
            });
          }
        }
      });
      _focusNodes[key] = fn;
    }
    return _focusNodes[key]!;
  }

  FocusNode _getFn(
    String key, {
    bool isReadOnly = false,
    String defaultValue = "0,00",
    bool isPercent = false,
  }) {
    if (!_focusNodes.containsKey(key)) {
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus && !isReadOnly) {
          final controller = _getCtrl(key);

          if (controller.text.trim().isEmpty) {
            _fieldValues[key] = "";
            return;
          }

          bool isNumericField = key.contains("qty") ||
              key.contains("stock") ||
              key.contains("price") ||
              key.contains("total") ||
              key.contains("disc") ||
              key.contains("p_service") ||
              key.contains("p_ref") ||
              key.contains("f_before") ||
              key.contains("f_freight") ||
              key.contains("f_tax") ||
              key.contains("f_rounding");

          if (isNumericField) {
            // Bersihkan semua karakter non-angka termasuk % lama
            String cleanText = controller.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            double? parsed = double.tryParse(cleanText);

            if (mounted) {
              setState(() {
                if (parsed != null) {
                  if (isPercent) {
                    // UBAH DI SINI: Tambahkan simbol % setelah angka
                    controller.text = "${parsed.toStringAsFixed(0)}%";
                  } else {
                    controller.text = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: '',
                      decimalDigits: 2,
                    ).format(parsed);
                  }
                } else {
                  controller.text = defaultValue;
                }
                _fieldValues[key] = controller.text;

                _syncTotalBeforeDiscount();
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _fieldValues[key] = controller.text;
              });
            }
          }
        }
      });
      _focusNodes[key] = fn;
    }
    return _focusNodes[key]!;
  }

  double _getGrandTotal() {
    double parseValue(String key) {
      String val = _controllers[key]?.text ?? _fieldValues[key] ?? "0";
      String cleanVal =
          val.replaceAll('.', '').replaceAll(',', '.').replaceAll('%', '');

      return double.tryParse(cleanVal) ?? 0.0;
    }

    double before = parseValue("f_before_disc");
    double discVal = parseValue("f_disc_val");
    double wtaxamount = parseValue("f_wtaxamount");
    double tax = parseValue("f_tax");
    double rounding = parseValue("f_rounding");

    // Rumus: (Sebelum Diskon - Diskon) + WTax + Rounding + Pajak
    return (before - discVal) + wtaxamount + rounding + tax;
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      String day = picked.day.toString().padLeft(2, '0');
      String month = picked.month.toString().padLeft(2, '0');
      String year = picked.year.toString();
      String formattedDate = "$day/$month/$year";

      setState(() {
        _getCtrl(key).text = formattedDate;
        _fieldValues[key] = formattedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    _focusNodes.forEach((_, f) => f.dispose());
    _tabController.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rowCount < 10) _rowCount = 10;
    return Scaffold(
      backgroundColor: bgSlate,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                RepaintBoundary(child: _buildModernHeader()),
                const SizedBox(height: 16),
                _buildTabSection(),
                const SizedBox(height: 16),
                _buildModernFooter(),
              ],
            ),
          ),
          if (showSidePanel)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: RepaintBoundary(child: _buildFloatingSidePanel()),
            ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildModernFieldRow("Customer", "h_cust"),
                  _buildModernFieldRow("Name", "h_name"),
                  _buildModernFieldRow("Contact Person", "h_cont"),
                  _buildModernFieldRow("Customer Ref. No.", "h_ref"),
                  _buildBpCurrencyRow(),
                ],
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildModernNoFieldRow(
                    "No.",
                    "h_no_series",
                    ["Primary", "Manual"],
                    "h_no_val",
                    initialNo: "",
                  ),
                  _buildModernFieldRow("Status", "h_stat", initial: ""),
                  _buildHeaderDate("Posting Date", "h_post", ""),
                  _buildHeaderDate("Delivery Date", "h_deliv", ""),
                  _buildHeaderDate("Document Date", "h_doc", ""),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryIndigo,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              labelColor: primaryIndigo,
              unselectedLabelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              tabs: const [
                Tab(text: "Contents"),
                Tab(text: "Logistics"),
                Tab(text: "Accounting"),
                Tab(text: "Attachments"),
              ],
              onTap: (index) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildContentsTab(),
                _buildLogisticsTab(),
                _buildAccountingTab(),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("Attachments Content"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: primaryIndigo, width: 2.5),
            ),
          ),
          child: Row(
            children: [
              const Text(
                "Item/Service Type",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: _buildSmallDropdown("item_type_main", [
                  "Item",
                  "Service",
                ]),
              ),
              const Spacer(),
              _buildAddRowButtons(),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 500),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: borderGrey, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Scrollbar(
              controller: _horizontalScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScroll,
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: DataTable(
                    columnSpacing: 30,
                    horizontalMargin: 15,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(primaryIndigo),
                    border: TableBorder(
                      verticalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      horizontalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    columns: _buildStaticColumns(),
                    rows: List.generate(
                      _rowCount,
                      (index) => _buildDataRow(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(int index) {
    return DataRow(
      cells: [
        DataCell(
          Center(
            child: Text("${index + 1}", style: const TextStyle(fontSize: 12)),
          ),
        ),
        _buildSearchableCell("item_no_$index"),
        _buildModernTableCell("desc_$index"),
        _buildModernTableCell("details_$index"),
        _buildModernTableCell("qty_$index", initial: "0"),
        _buildModernTableCell("uom_$index"),
        _buildModernTableCell("whse_$index"),
        _buildModernTableCell("price_$index", initial: "0,00"),
        _buildModernTableCell("disc_$index", initial: "0%", isPercent: true),
        _buildModernTableCell("tax_code_$index"),
        _buildModernTableCell("wtax_liable_$index"),
        _buildModernTableCell("material_$index"),
        _buildModernTableCell("material_from_$index"),
        _buildModernTableCell("project_line_$index"),
        _buildModernTableCell("optional_$index"),
        _buildModernTableCell("ref_item_$index"),
      ],
    );
  }

  Widget _buildAddRowButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => showSidePanel = true),
          style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo),
          child: const Text(
            "Add Item SO",
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _rowCount++),
          icon: const Icon(Icons.add_box, color: Colors.green),
        ),
        IconButton(
          onPressed: () => setState(() => _rowCount > 10 ? _rowCount-- : null),
          icon: const Icon(Icons.indeterminate_check_box, color: Colors.red),
        ),
      ],
    );
  }

  DataCell _buildModernTableCell(
    String key, {
    String initial = "",
    bool isPercent = false,
  }) {
    final controller = _getCtrl(key, initial: initial);

    bool isNumeric = key.contains("qty") ||
        key.contains("stock") ||
        key.contains("price") ||
        key.contains("total") ||
        key.contains("disc") ||
        key.contains("p_service") ||
        key.contains("p_ref") ||
        key.contains("f_before") ||
        key.contains("wtax") ||
        key.contains("tax") ||
        key.contains("rounding");

    String defValue = isPercent ? "0%" : "0,00";
    final focusNode = _getFn(
      key,
      defaultValue: isNumeric ? defValue : "",
      isPercent: isPercent,
    );

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: isNumeric ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
              ),
              onChanged: (val) {
                _fieldValues[key] = val;
                if (isNumeric) {
                  _syncTotalBeforeDiscount();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    DataColumn centeredHeader(String label) {
      return DataColumn(
        label: Expanded(
          child: Center(child: Text(label, style: headerStyle)),
        ),
      );
    }

    return [
      centeredHeader("#"),
      centeredHeader("Item No."),
      centeredHeader("Item Description"),
      centeredHeader("Item Details"),
      centeredHeader("Quantity"),
      centeredHeader("UoM Name"),
      centeredHeader("Whse"),
      centeredHeader("Unit Price"),
      centeredHeader("Discount %"),
      centeredHeader("Tax Code"),
      centeredHeader("WTax Liable"),
      centeredHeader("Material"),
      centeredHeader("Material From"),
      centeredHeader("Project Line"),
      centeredHeader("Optional"),
      centeredHeader("Ref Item"),
    ];
  }

  DataCell _buildSearchableCell(String key) {
    return DataCell(
      InkWell(
        onTap: () {
          List<String> dummyData = [
            "Option A",
            "Option B",
            "Option C",
            "Option D",
          ];
          _showSearchDialog("Select Item", key, dummyData);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 120,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fieldValues[key] ?? _controllers[key]?.text ?? "",
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.search,
                  size: 14,
                  color: primaryIndigo.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;
    for (int i = 0; i < _rowCount; i++) {
      String val =
          _fieldValues["total_$i"] ?? _controllers["total_$i"]?.text ?? "0";
      totalAllRows +=
          double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }
    setState(() {
      _getCtrl("f_before_disc").text = totalAllRows.toStringAsFixed(2);
      _fieldValues["f_before_disc"] = totalAllRows.toStringAsFixed(2);
    });
  }

  Widget _buildLogisticsTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildModernFieldRow("Ship To", "log_ship_to",
                      isTextArea: true),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Bill To", "log_bill_to",
                      isTextArea: true),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Shipping Type", "log_ship_type", [
                    "",
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernCheckbox("Print Picking Sheet", "cb_print"),
                  _buildModernCheckbox(
                    "Proc. Doc. For Non Drop-Ship",
                    "cb_non_drop",
                  ),
                  _buildModernCheckbox("Proc. Doc. For Drop-Ship", "cb_drop"),
                  _buildModernCheckbox("Approved", "cb_approved"),
                  _buildModernCheckbox("Allow Partial Delivery", "cb_partial"),
                  const SizedBox(height: 20),
                  _buildModernFieldRow("Pick and Pack Remarks", "log_pick_rem"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("BP Channel Name", "log_bp_name"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                    "BP Channel Contact",
                    "log_bp_cont",
                    [""],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildAccountingTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildModernFieldRow("Journal Remark", "acc_journal"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Payment Terms", "acc_pay_terms", [
                    "",
                  ]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Payment Method", "acc_pay_method", [
                    "",
                  ]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                    "Central Bank Ind.",
                    "acc_central_bank",
                    [""],
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "Manually\nRecalculate Due Date",
                    "acc_manual_due",
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "Cash Discount\nDate Offset",
                    "acc_cash_disc",
                  ),
                  const SizedBox(height: 12),
                  _buildModernCheckbox(
                    "Use Shipped Goods Account",
                    "cb_shipped_acc",
                  ),
                ],
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              child: Column(
                children: [
                  _buildModernFieldRow("BP Project", "acc_bp_proj"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Cancellation Date", "acc_cancel_date"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Required Date", "acc_req_date"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Indicator", "acc_indicator", [""]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Federal Tax ID", "acc_tax_id"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Order Number", "acc_order_no"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Referenced Document", "acc_ref_doc"),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildModernFooter() {
    double grandTotal = _getGrandTotal();
    String formattedTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    ).format(grandTotal);
    _getCtrl("f_total_final").text = "IDR $formattedTotal";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern("Sales Employee", "f_employ", [
                      "",
                    ]),
                    const SizedBox(height: 12),
                    _buildModernFieldRow("Owner", "f_owner"),
                    const SizedBox(height: 12),
                    _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              SizedBox(
                width: 450,
                child: Column(
                  children: [
                    _buildSummaryRowWithAutoValue(
                      "Total Before Discount",
                      "f_before_disc",
                    ),
                    const SizedBox(height: 2),
                    _buildDiscountRow(),
                    const SizedBox(height: 10),
                    _buildSummaryRowWithAutoValue("Tax", "f_tax"),
                    const SizedBox(height: 2),
                    _buildRoundingRow(),
                    const SizedBox(height: 2),
                    _buildSummaryRowWithAutoValue(
                      "Wtax Amount",
                      "f_wtaxamount",
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 1),
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Total",
                      "f_total_final",
                      isBold: true,
                      isReadOnly: true,
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Applied Amount",
                      "f_applied_amt",
                      isBold: true,
                      isReadOnly: true,
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Balance Due",
                      "f_balance_due",
                      isBold: true,
                      isReadOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildActionButtons(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDiscountRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const SizedBox(
              width: 140,
              child: Text("DPM", style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 58),
            SizedBox(
              width: 40,
              child: _buildSummaryBox(
                "f_disc_pct",
                isPercent: true,
                defaultValue: "0",
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text("%", style: TextStyle(fontSize: 12)),
            ),
            Expanded(child: _buildSummaryBox("f_disc_val")),
          ],
        ),
      );

  Widget _buildHeaderDate(String label, String key, String initial) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, key),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: primaryIndigo.withValues(alpha: 0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                  border: Border.all(
                    color: primaryIndigo.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: IgnorePointer(
                          child: TextField(
                            controller: _getCtrl(key, initial: initial),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 14, // Sesuai permintaanmu
                        color: primaryIndigo.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFieldRowPrecision(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "0.0000",
  }) {
    final controller = _getCtrl(key, initial: initial);
    final focusNode = _getFnPrecision(key);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120, // KUNCI LURUS: 120
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 28), // KUNCI LURUS: 28
          Expanded(
            child: Container(
              height: isTextArea ? 80 : 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: bgSlate,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderGrey),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: isTextArea ? 3 : 1,
                textAlign: TextAlign.left,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (val) {
                  _fieldValues[key] = val;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundingRow() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _checkStates["cb_rounding"] ?? false,
                      onChanged: (v) =>
                          setState(() => _checkStates["cb_rounding"] = v!),
                      activeColor: primaryIndigo,
                      side: BorderSide(color: borderGrey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Rounding",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 58),
            Expanded(
              child: _buildSummaryBox(
                "f_rounding",
                isReadOnly: !(_checkStates["cb_rounding"] ?? false),
              ),
            ),
          ],
        ),
      );

  Widget _buildActionButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildSAPActionButton("Add", isPrimary: true),
            const SizedBox(width: 8),
            _buildSAPActionButton("Delete", isDanger: true),
            const Spacer(),
            _buildSAPActionButton("Copy From",
                customColor: Colors.blue.shade700),
            const SizedBox(width: 8),
            _buildSAPActionButton("Copy To",
                customColor: Colors.orange.shade600),
          ],
        ),
      );

  Widget _buildSummaryRowWithAutoValue(
    String label,
    String key, {
    String defaultValue = "0.00",
    bool isBold = false,
    bool isReadOnly = false,
  }) {
    final controller = _getCtrl(
      key,
      initial: _fieldValues[key] ?? defaultValue,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 58),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                readOnly: isReadOnly,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                ),
                onChanged: (val) {
                  if (!isReadOnly) setState(() => _fieldValues[key] = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(
    String key, {
    String defaultValue = "0.00",
    bool isReadOnly = false,
    bool isPercent = false,
  }) {
    final controller = _getCtrl(
      key,
      initial: _fieldValues[key] ?? defaultValue,
    );
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        ),
        onChanged: (val) {
          if (!isReadOnly) {
            setState(() {
              _fieldValues[key] = val;
              if (key == "f_disc_pct") {
                double pct = double.tryParse(val) ?? 0;
                double before = double.tryParse(
                      _getCtrl(
                        "f_before_disc",
                      ).text.replaceAll(RegExp(r'[^0-9.]'), ''),
                    ) ??
                    0;
                _getCtrl("f_disc_val").text =
                    (before * pct / 100).toStringAsFixed(2);
                _fieldValues["f_disc_val"] = _getCtrl("f_disc_val").text;
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
    bool isDecimal = false,
  }) {
    String effectiveInitial = (isDecimal && initial.isEmpty) ? "0.00" : initial;
    final controller = _getCtrl(key, initial: effectiveInitial);
    FocusNode? focusNode;
    if (isDecimal) {
      focusNode = _getFn(key, defaultValue: "0.00");
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120, // KUNCI LURUS: 120
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 28), // KUNCI LURUS: 28
          Expanded(
            child: Container(
              height: isTextArea ? 80 : 35,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: isTextArea ? 3 : 1,
                textAlign: TextAlign.left,
                keyboardType: isDecimal
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
                onChanged: (val) {
                  _fieldValues[key] = val;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNoFieldRow(
    String label,
    String dropdownKey,
    List<String> seriesOptions,
    String textKey, {
    String initialNo = "",
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120, // KUNCI LURUS: 120
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondarySlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 28), // KUNCI LURUS: 28
            Expanded(
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 110,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dropdownValues[dropdownKey] ??
                              seriesOptions.first,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: primaryIndigo,
                          ),
                          onChanged: (v) =>
                              setState(() => _dropdownValues[dropdownKey] = v!),
                          items: seriesOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _getCtrl(textKey, initial: initialNo),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                        ),
                        onChanged: (val) {
                          _fieldValues[textKey] = val;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildModernCheckbox(String label, String key) => Row(
        children: [
          SizedBox(
            width: 24,
            height: 32,
            child: Checkbox(
              value: _checkStates[key] ?? false,
              activeColor: primaryIndigo,
              onChanged: (val) => setState(() => _checkStates[key] = val!),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  // 1. Tambahkan parameter {double? customWidth}
  Widget _buildSmallDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: primaryIndigo,
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (val) => setState(() => _dropdownValues[key] = val!),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSmallDropdownRowModern(
    String label,
    String key,
    List<String> items,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120, // KUNCI LURUS: 120
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondarySlate,
                  fontWeight: FontWeight.w500,
                  // Tetap dikasih shadow di text labelnya biar konsisten sama request sebelumnya
                  shadows: [
                    Shadow(
                      offset: const Offset(0.5, 0.5),
                      blurRadius: 1.0,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28), // KUNCI LURUS: 28
            Expanded(child: _buildSmallDropdown(key, items)),
          ],
        ),
      );

  Widget _buildChooseFromListField(
    String label,
    String key,
    List<String> data,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondarySlate,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: const Offset(0.5, 0.5),
                      blurRadius: 1.0,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: InkWell(
                onTap: () => _showSearchDialog(label, key, data),
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    // Border ungu tipis
                    border: Border.all(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _getCtrl(key).text.isEmpty
                                  ? (data.isNotEmpty ? data.first : "")
                                  : _getCtrl(key).text,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      // Icon Search (Warna Indigo Soft)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.search,
                          size: 16,
                          color: primaryIndigo.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _showSearchDialog(String label, String key, List<String> data) {
    List<String> filteredList = List.from(data);
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(" $label", style: const TextStyle(fontSize: 14)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Cari data...",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setDialogState(
                    () => filteredList = data
                        .where((e) => e.toLowerCase().contains(v.toLowerCase()))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(filteredList[i]),
                      onTap: () {
                        setState(() {
                          _getCtrl(key).text = filteredList[i];
                          _fieldValues[key] = filteredList[i];
                        });
                        Navigator.pop(c);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSAPActionButton(
    String label, {
    bool isPrimary = false,
    bool isDanger = false,
    Color? customColor,
  }) {
    Color bgColor = isDanger
        ? Colors.red
        : (isPrimary ? primaryIndigo : (customColor ?? Colors.white));
    return ElevatedButton(
      onPressed: () => debugPrint("Klik $label"),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFloatingSidePanel() => Container(
        width: 380,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(-2, 0)),
          ],
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: primaryIndigo,
              title: const Text(
                "Sales Order",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () => setState(() => showSidePanel = false),
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildChooseFromListField("Return Date", "cfg_bu", [""]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("No Kendaraan", "No_ken"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Departemen", "Departemen"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Request By", "Request_by"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Driver", "Driver"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Create By", "cfg_by", [""]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "Send To Subcont",
                    "sendtoSub",
                    isTextArea: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Cutting Laser", "cfg_laser", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Punching", "cfg_punch", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Bending", "cfg_bend", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Assy", "cfg_assy", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("SubCont", "cfg_sub", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "Internal Memo",
                    "cfg_memo",
                    isTextArea: true,
                  ),
                  const Divider(height: 45, thickness: 3),
                  _buildHeaderDate("Production\nDue date", "cfg_prod_date", ""),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "Internal Memo",
                    "Internal_memo",
                    isTextArea: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Delivered To", "Delivered_to", [
                    "",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("AP FP Number", "AP_FP_num"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "AP FP tax Amount",
                    "f_tax_amount",
                    isDecimal: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("E faktur AP Date", "E_faktur"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                    "E faktur AP Date Creditable",
                    "ap_date_credit",
                    [""],
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("DO reject Number", "do_reject_numb"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("ETD Delivery", "etd_del"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("AR FP Number", "AR FP Number", [
                    "",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRowPrecision("Tax Rate", "tax_rate"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("PPBJNO", "ppbjno", isTextArea: true),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("PO number", "po_numb"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Request Due Date", "req_due_date"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Upload Status", "upload_status", [
                    "",
                    "Yes",
                    "No",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("SO No", "so_no"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("DO No", "do_no"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("PDO No", "pdo_no"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Kode Faktur Pajak", "code_tax"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Area", "area", [""]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                      "Credit Note Number", "Credit_note_numb"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("AR FP Number E Faktur", "ar_fp_numb"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                    "Number Series Faktur",
                    "numb_s_faktur",
                    [""],
                  ),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Business Unit ", "business_unit", [
                    "",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("DO Receipt Date", "receipt_date"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("GI Type", "gi_type", [""]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("GR Type", "gr_type", [""]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Customer Code", "cust_cod"),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => setState(() => showSidePanel = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "APPLY",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBpCurrencyRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 150,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues["h_curr_type"] ?? "BP Currency",
                isDense: true,
                // --- PERUBAHAN ICON DISINI ---
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: primaryIndigo, // Menggunakan warna primaryIndigo
                ),
                style: const TextStyle(fontSize: 11, color: Colors.black),
                onChanged: (v) =>
                    setState(() => _dropdownValues["h_curr_type"] = v!),
                items: ["BP Currency", "Local Currency", "Foreign Currency"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 60,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: const Text(
              "IDR",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _getCtrl("h_curr_rate", initial: ""),
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 11, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
                onChanged: (val) => _fieldValues["h_curr_rate"] = val,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
