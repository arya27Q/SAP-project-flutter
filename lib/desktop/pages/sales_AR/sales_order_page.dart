import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({super.key});

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage>
    with SingleTickerProviderStateMixin {
  bool showSidePanel = false;
  late TabController _tabController;
  int _rowCount = 10;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);
  final ScrollController _horizontalScroll = ScrollController();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String?> _formValues = {};

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
            String cleanText = controller.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            double? parsed = double.tryParse(cleanText);

            if (mounted) {
              setState(() {
                if (parsed != null) {
                  if (isPercent) {
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

  double _getGrandTotal() {
    double parseValue(String key) {
      String val = _controllers[key]?.text ?? _fieldValues[key] ?? "0";

      String cleanVal =
          val.replaceAll('.', '').replaceAll(',', '.').replaceAll('%', '');

      return double.tryParse(cleanVal) ?? 0.0;
    }

    double before = parseValue("f_before_disc");
    double discVal = parseValue("f_disc_val");
    double freight = parseValue("f_freight");
    double tax = parseValue("f_tax");
    double rounding = parseValue("f_rounding");

    return (before - discVal) + freight + rounding + tax;
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
                const SizedBox(height: 100), // Space bawah
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
                  _buildSmallDropdownRowModern("Local Currency", "h_curr", [
                    "IDR",
                    "USD",
                    "EUR",
                  ]),
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
                    ["2025-COM", "2024-REG"],
                    "h_no_val",
                    initialNo: "256100727",
                  ),
                  _buildModernFieldRow("Status", "h_stat", initial: "Open"),
                  _buildHeaderDate("Posting Date", "h_post_date", ""),
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

  // --- LOGIKA TABLE TIDAK DIUBAH (Sesuai Request) ---
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
                    headingRowColor: MaterialStateProperty.all(primaryIndigo),
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
        _buildModernTableCell("jenis_brg_$index"),
        _buildModernTableCell("desc_$index"),
        _buildModernTableCell("jenis_item_$index"),
        _buildModernTableCell("orbit_$index"),
        _buildModernTableCell("details_$index"),
        _buildModernTableCell("qty_$index", initial: "0"),
        _buildModernTableCell("stock_$index", initial: "0"),
        _buildModernTableCell("price_$index", initial: "0,00"),
        _buildModernTableCell("p_service_$index", initial: "0,00"),
        _buildModernTableCell("p_ref_$index", initial: "0,00"),
        _buildModernTableCell("uom_$index"),
        _buildModernTableCell("free_text_$index"),
        _buildModernTableCell("proj_$index"),
        _buildModernTableCell("line_$index"),
        _buildModernTableCell("disc_$index", initial: "0%", isPercent: true),
        _buildModernTableCell("total_$index", initial: "0,00"),
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

  // --- CELL BUILDER (LOGIKA LAMA) ---
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
        key.contains("f_tax") ||
        key.contains("f_rounding");

    final focusNode = _getFn(
      key,
      defaultValue: isNumeric ? (isPercent ? "0%" : "0,00") : "",
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
      centeredHeader("Jenis Barang dan Jasa"),
      centeredHeader("Item Description"),
      centeredHeader("Jenis Item"),
      centeredHeader("Klasifikasi Orbit"),
      centeredHeader("Item Details"),
      centeredHeader("Quantity"),
      centeredHeader("Quantity Stock"),
      centeredHeader("Unit Price"),
      centeredHeader("Price Service"),
      centeredHeader("Price Reference"),
      centeredHeader("UoM Name"),
      centeredHeader("Free Text"),
      centeredHeader("Project Line"),
      centeredHeader("LineID"),
      centeredHeader("Discount %"),
      centeredHeader("Total (LC)"),
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
      String cleanVal =
          val.replaceAll('.', '').replaceAll(',', '.').replaceAll('%', '');
      totalAllRows += double.tryParse(cleanVal) ?? 0;
    }

    setState(() {
      String formatted = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 2,
      ).format(totalAllRows);

      _getCtrl("f_before_disc").text = formatted;
      _fieldValues["f_before_disc"] = formatted;
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
                  _buildModernFieldRow("Bill To", "log_bill_to",
                      isTextArea: true),
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
                  _buildModernFieldRow("BP Channel Name", "log_bp_name"),
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
                  _buildSmallDropdownRowModern(
                      "Payment Terms", "acc_pay_terms", [
                    "",
                  ]),
                  _buildSmallDropdownRowModern(
                      "Payment Method", "acc_pay_method", [
                    "",
                  ]),
                  _buildSmallDropdownRowModern(
                    "Central Bank Ind.",
                    "acc_central_bank",
                    [""],
                  ),
                  _buildModernFieldRow(
                    "Manually\nRecalculate Due Date",
                    "acc_manual_due",
                  ),
                  _buildModernFieldRow(
                    "Cash Discount\nDate Offset",
                    "acc_cash_disc",
                  ),
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
                  _buildModernFieldRow("Cancellation Date", "acc_cancel_date"),
                  _buildModernFieldRow("Required Date", "acc_req_date"),
                  _buildSmallDropdownRowModern(
                      "Indicator", "acc_indicator", [""]),
                  _buildModernFieldRow("Federal Tax ID", "acc_tax_id"),
                  _buildModernFieldRow("Order Number", "acc_order_no"),
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
                    const SizedBox(height: 2),
                    _buildSummaryRowWithAutoValue("Freight", "f_freight"),
                    const SizedBox(height: 2),
                    _buildRoundingRow(),
                    const SizedBox(height: 2),
                    _buildSummaryRowWithAutoValue("Tax", "f_tax"),
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

  // --- STYLING BARU: SHADOW & FLOATING ---

  Widget _buildDiscountRow() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 120,
              child: Text("Discount", style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 28),
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
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _getCtrl("f_disc_pct", initial: "0"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 9),
                        ),
                        onChanged: (val) =>
                            setState(() => _fieldValues["f_disc_pct"] = val),
                      ),
                    ),
                    Text(
                      "%",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _getCtrl("f_disc_val", initial: "0.00"),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                        onChanged: (val) =>
                            setState(() => _fieldValues["f_disc_val"] = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.calendar_month_rounded,
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
  }

  Widget _buildRoundingRow() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              child: InkWell(
                onTap: () {
                  setState(() {
                    bool val = _checkStates["cb_rounding"] ?? false;
                    _checkStates["cb_rounding"] = !val;
                  });
                },
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(-5, 0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _checkStates["cb_rounding"] ?? false,
                          onChanged: (v) =>
                              setState(() => _checkStates["cb_rounding"] = v!),
                          activeColor: primaryIndigo,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          side: BorderSide(color: borderGrey, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-1, 0),
                      child: Text(
                        "Rounding",
                        style: TextStyle(
                          fontSize: 12,
                          color: secondarySlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
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
                  controller: _getCtrl("f_rounding", initial: "0.00"),
                  readOnly: !(_checkStates["cb_rounding"] ?? false),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (_checkStates["cb_rounding"] ?? false)
                        ? Colors.black87
                        : Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                  onChanged: (val) =>
                      setState(() => _fieldValues["f_rounding"] = val),
                ),
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

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
    bool isDecimal = false,
  }) {
    String effectiveInitial = (isDecimal && initial.isEmpty) ? "0.00" : initial;
    final controller = _getCtrl(key, initial: effectiveInitial);
    FocusNode? focusNode = isDecimal ? _getFn(key, defaultValue: "0.00") : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            isTextArea ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
            child: Container(
              height: isTextArea ? 80 : 35,
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
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.black54,
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

  Widget _buildModernCheckbox(String label, String key) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            setState(() {
              bool val = _checkStates[key] ?? false;
              _checkStates[key] = !val;
            });
          },
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(-10, 0),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Checkbox(
                    value: _checkStates[key] ?? false,
                    activeColor: primaryIndigo,
                    onChanged: (val) =>
                        setState(() => _checkStates[key] = val!),
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    side: BorderSide(color: borderGrey, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );

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
          isExpanded: true,
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
        padding: const EdgeInsets.only(bottom: 12),
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
                ),
              ),
            ),
            const SizedBox(width: 28),
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
          title: Text("Pilih $label", style: const TextStyle(fontSize: 14)),
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

  Widget _buildFileUploadRow(String label, String key) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
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
                ),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: InkWell(
                onTap: () async {
                  FilePickerResult? res = await FilePicker.platform.pickFiles();
                  if (res != null) {
                    setState(() => _formValues[key] = res.files.first.name);
                  }
                },
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formValues[key] ?? "No file selected",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.upload_file,
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
                  _buildChooseFromListField("Business Unit", "cfg_bu", [""]),
                  const SizedBox(height: 8),
                  _buildFileUploadRow("File 1", "cfg_f1"),
                  _buildFileUploadRow("File 2", "cfg_f2"),
                  _buildFileUploadRow("File 3", "cfg_f3"),
                  _buildFileUploadRow("File 4", "cfg_f4"),
                  _buildModernFieldRow("Create By", "cfg_by"),
                  _buildSmallDropdownRowModern("Upload Status", "cfg_up", [
                    "No",
                    "Yes",
                  ]),
                  _buildSmallDropdownRowModern("Cutting Laser", "cfg_laser", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  _buildSmallDropdownRowModern("Punching", "cfg_punch", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  _buildSmallDropdownRowModern("Bending", "cfg_bend", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  _buildSmallDropdownRowModern("Assy", "cfg_assy", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  _buildSmallDropdownRowModern("SubCont", "cfg_sub", [
                    "No",
                    "Yes",
                    "N/A",
                  ]),
                  _buildModernFieldRow(
                    "Internal Memo",
                    "cfg_memo",
                    isTextArea: true,
                  ),
                  const Divider(height: 45, thickness: 3),
                  _buildHeaderDate("Production\nDue date", "cfg_prod_date", ""),
                  _buildHeaderDate("AP Tax Date", "cfg_tax_date", ""),
                  _buildChooseFromListField(
                      "Kode Faktur Pajak", "cfg_tax_code", [
                    "010",
                    "020",
                  ]),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Area", "cfg_area"),
                  _buildChooseFromListField("Kategori SO", "cfg_cat", [
                    "SO Resmi",
                    "SO Sample",
                  ]),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Customer Name", "cfg_cust_name"),
                  _buildModernFieldRow(
                    "alasan rubah duedate",
                    "cfg_duedate",
                    isTextArea: true,
                  ),
                  _buildChooseFromListField("validasi PO", "cfg_validasi_po", [
                    "Lengkap",
                    "Tidak Lengkap",
                  ]),
                  const SizedBox(height: 8),
                  _buildModernFieldRow(
                    "PIC Engineering",
                    "cfg_pic",
                    isTextArea: true,
                  ),
                  _buildSmallDropdownRowModern("Transfer DLM", "TF_dlm", [""]),
                  _buildSmallDropdownRowModern(
                      "Transfer Dempo", "Tf_demp", [""]),
                  _buildSmallDropdownRowModern(
                      "Status Pengiriman", "status", [""]),
                  _buildSmallDropdownRowModern(
                      "kelengkapan Utama", "kelengkapan", [
                    "",
                  ]),
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
}
