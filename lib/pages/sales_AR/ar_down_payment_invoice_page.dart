import 'package:flutter/material.dart';

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
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  final ScrollController _horizontalScroll = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};

  // --- HELPER FORMAT RUPIAH (INDONESIA: Titik Ribuan, Koma Desimal) ---

  // Convert double ke String (250000.0 -> "250.000,00")
  String _formatToIdrStyle(double value, {bool isPercent = false}) {
    if (isPercent) return value.toStringAsFixed(0);

    // Ambil 2 desimal
    String str = value.toStringAsFixed(2);
    List<String> parts = str.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : "00";

    // Regex untuk menambah titik setiap 3 digit dari belakang
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]}.';
    String formattedInt = integerPart.replaceAllMapped(reg, mathFunc);

    return "$formattedInt,$decimalPart";
  }

  // Convert String Rupiah ke double ("250.000,00" -> 250000.0)
  double _parseIdrStyle(String value) {
    if (value.isEmpty) return 0.0;
    // Hapus titik ribuan, ganti koma desimal jadi titik
    String clean = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  // Focus Node untuk Auto-Format saat selesai mengetik
  FocusNode _getFn(
    String key, {
    bool isReadOnly = false,
    String defaultValue = "0,00",
    bool isPercent = false,
  }) {
    if (!_focusNodes.containsKey(key)) {
      final fn = FocusNode();
      fn.addListener(() {
        // SAAT HILANG FOKUS (SELESAI KETIK)
        if (!fn.hasFocus) {
          final controller = _getCtrl(key);
          // 1. Ambil angka murni dari input user
          double val = _parseIdrStyle(controller.text);

          if (mounted) {
            setState(() {
              if (val != 0 || controller.text.isNotEmpty) {
                // 2. Ubah jadi format Rupiah (ex: 100.000,00)
                controller.text = _formatToIdrStyle(val, isPercent: isPercent);
              } else {
                controller.text = defaultValue;
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

  double _getGrandTotal() {
    double parse(String key) {
      String val = _controllers[key]?.text ?? _fieldValues[key] ?? "0";
      return _parseIdrStyle(val);
    }

    double before = parse("f_before_disc");
    double dpm = parse("f_dpm_val");
    double tax = parse("f_tax");
    double rounding = parse("f_rounding");

    return before - dpm + tax + rounding;
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
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
                _buildHeaderField("Customer", "h_cust"),
                const SizedBox(height: 8),
                _buildSearchableHeaderRow("Name", "h_name"),
                _buildSmallDropdownRowModern("Contact Person", "h_cont", [""]),
                _buildHeaderField("Customer Ref. No.", "h_ref"),
                const SizedBox(height: 8),

                // Local Currency (Sesuai Gambar: Label -> Dropdown -> Input)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Local Currency",
                          style: TextStyle(
                            fontSize: 12,
                            color: secondarySlate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      // Dropdown IDR
                      Container(
                        width: 80,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: borderGrey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _dropdownValues["h_curr"] ?? "IDR",
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            onChanged: (v) =>
                                setState(() => _dropdownValues["h_curr"] = v!),
                            items: ["IDR", "USD", "SGD"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      // Input Rate
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: bgSlate,
                            border: Border.all(color: borderGrey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _getCtrl(
                              "h_curr_rate",
                              initial: "16.675,0000",
                            ), // Format Indo
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildModernNoFieldRow(
                  "No.",
                  "h_no_series",
                  [""],
                  "h_no_val",
                  initialNo: "",
                ),
                const SizedBox(height: 8),
                _buildHeaderField(
                  "Status",
                  "h_status",
                  initial: "Open",
                  isReadOnly: true,
                ),
                const SizedBox(height: 8),
                _buildHeaderDate("Posting Date", "h_post_date", ""),
                const SizedBox(height: 8),
                _buildHeaderDate("Delivery Date", "h_del_date", ""),
                const SizedBox(height: 8),
                _buildHeaderDate("Document Date", "h_doc_date", ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            color: Colors.black.withOpacity(0.12),
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
              _buildSmallDropdown("item_type_main", ["Item", "Service"]),
              const Spacer(),
              _buildAddRowButtons(),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 500),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 246, 246, 246),
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
                child: DataTable(
                  columnSpacing: 45,
                  horizontalMargin: 15,
                  headingRowHeight: 40,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF257575),
                  ),
                  border: const TableBorder(
                    verticalInside: BorderSide(
                      color: Color.fromARGB(208, 166, 164, 164),
                      width: 0.5,
                    ),
                    horizontalInside: BorderSide(
                      color: Color.fromARGB(208, 166, 164, 164),
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
      ],
    );
  }

  // --- DATA ROW SESUAI GAMBAR ---
  DataRow _buildDataRow(int index) {
    // Format Item No: AR-DownPayment_IN001-0001
    String autoItemNo =
        "AR-DP_IN001-${(index + 1).toString().padLeft(4, '0')}";

    return DataRow(
      cells: [
        DataCell(Text("${index + 1}", style: const TextStyle(fontSize: 12))),
        _buildModernTableCell("item_no_$index", initial: autoItemNo),
        _buildModernTableCell("desc_$index"), 
        _buildModernTableCell("details_$index"), 
        _buildModernTableCell("qty_$index", initial: "0"), 
        _buildModernTableCell("uom_$index"), 
        _buildModernTableCell("whse_$index"), 
        _buildModernTableCell(
          "price_$index",
          initial: "0,00",
        ), 
        _buildModernTableCell(
          "disc_$index",
          initial: "0",
        ), 
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

  DataCell _buildModernTableCell(String key, {String initial = ""}) {
    final controller = _getCtrl(key, initial: initial);

    bool isNumeric =
        key.contains("qty") ||
        key.contains("stock") ||
        key.contains("total") ||
        key.contains("disc") ||
        key.contains("price");

    final focusNode = _getFn(
      key,
      defaultValue: initial.isEmpty ? "0,00" : initial, // Default 0,00
    );

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
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
    );
  }

  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return [
      const DataColumn(label: Text("#", style: headerStyle)),
      const DataColumn(label: Text("Item No.", style: headerStyle)),
      const DataColumn(label: Text("Item Description", style: headerStyle)),
      const DataColumn(label: Text("Item Details", style: headerStyle)),
      const DataColumn(label: Text("Quantity", style: headerStyle)),
      const DataColumn(label: Text("UoM Name", style: headerStyle)),
      const DataColumn(label: Text("Whse", style: headerStyle)),
      const DataColumn(label: Text("Unit Price", style: headerStyle)),
      const DataColumn(label: Text("Discount %", style: headerStyle)),
      const DataColumn(label: Text("Tax Code", style: headerStyle)),
      const DataColumn(label: Text("WTax Liable", style: headerStyle)),
      const DataColumn(label: Text("Material", style: headerStyle)),
      const DataColumn(label: Text("Material From", style: headerStyle)),
      const DataColumn(label: Text("Project Line", style: headerStyle)),
      const DataColumn(label: Text("Optional", style: headerStyle)),
      const DataColumn(label: Text("Ref Item", style: headerStyle)),
    ];
  }

  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;
    for (int i = 0; i < _rowCount; i++) {
      // Total = Price * Qty (Simplified logic for now, using Total column directly for sum)
      String val = _controllers["total_$i"]?.text ?? "0";
      totalAllRows += _parseIdrStyle(val);
    }
    setState(() {
      String formattedTotal = _formatToIdrStyle(totalAllRows);
      _getCtrl("f_before_disc").text = formattedTotal;
      _fieldValues["f_before_disc"] = formattedTotal;
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
              _buildModernFieldRow("Ship To", "log_ship_to", isTextArea: true),
              const SizedBox(height: 12),
              _buildModernFieldRow("Bill To", "log_bill_to", isTextArea: true),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Shipping Type", "log_ship_type", [
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
              _buildSmallDropdownRowModern("Payment Terms", "acc_pay_terms", [
                "",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Payment Method", "acc_pay_method", [
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
              _buildSmallDropdownRowModern("Indicator", "acc_indicator", [""]),
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
    String totalStr = _formatToIdrStyle(grandTotal);
    _getCtrl("f_total_final").text = "IDR $totalStr";

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
                color: Colors.black.withOpacity(0.12),
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
                      "-No Sales Employee-",
                    ]),
                    const SizedBox(height: 8),
                    _buildHeaderField("Owner", "f_owner"),
                    const SizedBox(height: 8),
                    _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              SizedBox(
                width: 400,
                child: Column(
                  children: [
                    _buildSummaryRowWithAutoValue(
                      "Total Before Discount",
                      "f_before_disc",
                      isReadOnly: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 140,
                            child: Text(
                              "DPM",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: borderGrey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _getCtrl("f_dpm_pct", initial: "30"),
                              focusNode: _getFn("f_dpm_pct", isPercent: true),
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                              ),
                              onChanged: (val) {
                                double pct = double.tryParse(val) ?? 0;
                                double before = _parseIdrStyle(
                                  _getCtrl("f_before_disc").text,
                                );
                                double dpmVal = (before * pct / 100);
                                String newVal = _formatToIdrStyle(dpmVal);
                                _getCtrl("f_dpm_val").text = newVal;
                                setState(() {});
                              },
                            ),
                          ),
                          const Text("%", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryBox(
                              "f_dpm_val",
                              isReadOnly: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _checkStates["cb_round"] ?? false,
                              onChanged: (v) =>
                                  setState(() => _checkStates["cb_round"] = v!),
                            ),
                          ),
                          const Text(
                            "Rounding",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: _buildSummaryBox(
                              "f_round",
                              isReadOnly: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Tax",
                      "f_tax",
                      isReadOnly: false,
                    ),
                    _buildSummaryRowWithAutoValue(
                      "WTax Amount",
                      "f_wtax",
                      isReadOnly: false,
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
                      "f_applied",
                      isReadOnly: false,
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Balance Due",
                      "f_balance",
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

  Widget _buildHeaderField(
    String label,
    String key, {
    String initial = "",
    bool isReadOnly = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
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
            height: 32,
            decoration: BoxDecoration(
              color: isReadOnly ? bgSlate : bgSlate,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderGrey),
            ),
            child: TextField(
              controller: _getCtrl(key, initial: initial),
              readOnly: isReadOnly,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchableHeaderRow(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
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
              onTap: () =>
                  _showSearchDialog(label, key, ["Customer A", "Customer B"]),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: bgSlate,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderGrey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _controllers[key]?.text ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.search, size: 16, color: Colors.grey),
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

  Widget _buildHeaderDate(String label, String key, String initial) {
    return Row(
      children: [
        SizedBox(
          width: 100,
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
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderGrey),
              ),
              child: IgnorePointer(
                child: TextField(
                  controller: _getCtrl(key, initial: initial),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
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

  Widget _buildSummaryRowWithAutoValue(
    String label,
    String key, {
    String defaultValue = "0,00",
    bool isBold = false,
    bool isReadOnly = false,
  }) {
    final controller = _getCtrl(
      key,
      initial: _fieldValues[key] ?? defaultValue,
    );
    final focusNode = _getFn(
      key,
      isReadOnly: isReadOnly,
      defaultValue: defaultValue,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: isReadOnly ? bgSlate : Colors.white,
                border: Border.all(color: borderGrey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: isReadOnly,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
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
    String defaultValue = "0,00",
    bool isReadOnly = false,
    bool isPercent = false,
  }) {
    final controller = _getCtrl(
      key,
      initial: _fieldValues[key] ?? defaultValue,
    );
    final focusNode = _getFn(
      key,
      isReadOnly: isReadOnly,
      defaultValue: defaultValue,
      isPercent: isPercent,
    );
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: isReadOnly ? bgSlate : Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: isReadOnly,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        onChanged: (val) {
          if (!isReadOnly) setState(() => _fieldValues[key] = val);
        },
      ),
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
  }) => Padding(
    padding: EdgeInsets.zero,
    child: Row(
      children: [
        SizedBox(
          width: 100,
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
            height: isTextArea ? 80 : 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: bgSlate,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderGrey),
            ),
            child: Center(
              child: TextField(
                controller: _getCtrl(key, initial: initial),
                maxLines: isTextArea ? 3 : 1,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildModernNoFieldRow(
    String label,
    String dropdownKey,
    List<String> seriesOptions,
    String textKey, {
    String initialNo = "",
  }) => Padding(
    padding: EdgeInsets.zero,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
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
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderGrey),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: bgSlate,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5),
                    ),
                    border: Border(right: BorderSide(color: borderGrey)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          _dropdownValues[dropdownKey] ?? seriesOptions.first,
                      isDense: true,
                      style: const TextStyle(fontSize: 11, color: Colors.black),
                      onChanged: (v) =>
                          setState(() => _dropdownValues[dropdownKey] = v!),
                      items: seriesOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _getCtrl(textKey, initial: initialNo),
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildSmallDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.black),
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
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
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
                        setState(() => _getCtrl(key).text = filteredList[i]);
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

  Widget _buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _buildSAPActionButton("Add", isPrimary: true),
        const SizedBox(width: 8),
        _buildSAPActionButton(
          "Cancel",
          customColor: const Color.fromARGB(255, 255, 0, 0),
        ),
        const Spacer(),
        _buildSAPActionButton("Copy From", customColor: Colors.blue.shade700),
        const SizedBox(width: 8),
        _buildSAPActionButton("Copy To", customColor: Colors.orange.shade600),
      ],
    ),
  );

}
