import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class JournalEntryPage extends StatefulWidget {
  const JournalEntryPage({super.key});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage>
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

  // --- STYLE SETTINGS (UPDATED) ---
  final double _inputHeight = 40.0; // Tinggi 40 biar sama kayak referensi
  final BorderRadius _inputRadius = BorderRadius.circular(10); // Radius 10

  // Shadow Ungu Halus
  List<BoxShadow> get _softShadow => [
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
      ];

  // Border Tipis Indigo
  Border get _thinBorder => Border.all(
      color: const Color(0xFF4F46E5).withValues(alpha: 0.15), width: 1);

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
      String formattedDate = DateFormat('dd.MMMM.yyyy').format(picked);
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
                // 1. HEADER UTAMA
                RepaintBoundary(child: _buildModernHeader()),
                const SizedBox(height: 16),

                // 2. MIDDLE SECTION (CONTAINER "FOTO KETIGA")
                RepaintBoundary(child: _buildMiddleHeader()),
                const SizedBox(height: 16),

                // 3. TABS
                _buildTabSection(),
                const SizedBox(height: 16),

                // 4. FOOTER
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

  // --- HEADER UTAMA ---
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
            // --- KOLOM KIRI ---
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildModernNoFieldRow(
                          "Series",
                          "h_series",
                          ["26S", "25S"],
                          "h_no",
                          initialNo: "263301173",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildHeaderDate(
                          "Posting Date",
                          "h_post",
                          "21.January.2026",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                "Origin",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondarySlate,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: _buildSmallDropdown("h_origin", [
                                "IN",
                                "OUT",
                                "CN",
                              ]),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSimpleTextField(
                                "h_origin_no",
                                initial: "261300204",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildHeaderDate(
                          "Due Date",
                          "h_due",
                          "20.February.2026",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildModernFieldRow(
                          "Trans. No.",
                          "h_trans_no",
                          initial: "241251",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildHeaderDate(
                          "Doc. Date",
                          "h_doc_date",
                          "21.January.2026",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                "Trans. Code",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondarySlate,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: _buildSmallDropdown("h_trans_code", [
                                "",
                                "Code 1",
                                "Code 2",
                              ]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildModernFieldRow(
                          "Ref. 1",
                          "h_ref1",
                          initial: "261300204",
                          labelWidth: 90,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildModernFieldRow(
                          "Ref. 2",
                          "h_ref2",
                          initial: "7100003678",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildModernFieldRow(
                          "Ref. 3",
                          "h_ref3",
                          labelWidth: 90,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Blanket Agreement", "h_blanket"),
                ],
              ),
            ),
            const SizedBox(width: 40),

            // --- KOLOM KANAN ---
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Remarks",
                        style: TextStyle(
                          fontSize: 12,
                          color: secondarySlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: _inputHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4),
                          borderRadius: _inputRadius,
                          border: _thinBorder, // Border Ungu
                          boxShadow: _softShadow, // Shadow
                        ),
                        child: TextField(
                          controller: _getCtrl(
                            "h_remarks",
                            initial: "A/R Invoices - C-01058",
                          ),
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallDropdown("h_temp_type", [
                          "Template Type",
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallDropdown("h_template", ["Template"]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildSmallDropdown("h_indicator", ["Indicator"]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallDropdown("h_project", ["Project"]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCompactCheckbox(
                    "Revaluation Reporting Exch. Rate",
                    "cb_reval",
                  ),
                  _buildCompactCheckbox("Automatic Tax", "cb_auto_tax"),
                  _buildCompactCheckbox("Manage Deferred Tax", "cb_def_tax"),
                  _buildCompactCheckbox("Manage WTax", "cb_wtax"),
                ],
              ),
            ),
          ],
        ),
      );

  // --- MIDDLE HEADER ---
  Widget _buildMiddleHeader() => Container(
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- KOLOM KIRI ---
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildModernFieldRow(
                        "G/L Acct/BP Code",
                        "h_bp_code",
                        initial: "C-01058",
                      ),
                      const SizedBox(height: 12),
                      _buildModernFieldRow(
                        "G/L Acct/BP Name",
                        "h_bp_name",
                        initial: "PT REKAINDO GLOBAL JASA",
                      ),
                      const SizedBox(height: 12),
                      _buildModernFieldRow(
                        "Ref. 1",
                        "h_ref1",
                        initial: "261300204",
                      ),
                      const SizedBox(height: 12),
                      _buildModernFieldRow(
                        "Ref. 2",
                        "h_ref2",
                        initial: "7100003678",
                      ),
                      const SizedBox(height: 12),
                      _buildModernFieldRow("Ref. 3", "h_ref3", initial: "1"),
                      const SizedBox(height: 12),
                      _buildModernFieldRow(
                        "Offset Account",
                        "h_offset",
                        initial: "4111101-1-1-02",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // --- KOLOM KANAN ---
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildHeaderDate(
                          "Posting Date", "h_post", "21.January.2026"),
                      const SizedBox(height: 12),
                      _buildHeaderDate("Due Date", "h_due", "20.February.2026"),
                      const SizedBox(height: 12),
                      _buildHeaderDate(
                        "Doc. Date",
                        "h_doc_date",
                        "21.January.2026",
                      ),
                      const SizedBox(height: 12),
                      _buildFieldRow("Project", "h_project", initial: ""),
                      const SizedBox(height: 12),
                      _buildFieldRow("Tax Group", "h_tax_group", initial: ""),
                      const SizedBox(height: 12),
                      _buildFieldRow(
                        "Distr. Rule",
                        "h_distr_rule",
                        initial: "",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildModernFieldRow(
              "Primary Form Item",
              "h_primary_form",
              initial: "",
            ),
          ],
        ),
      );

  Widget _buildSimpleTextField(
    String key, {
    String initial = "",
    String? hint,
  }) {
    return Container(
      height: _inputHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _inputRadius,
        border: _thinBorder, // Border Ungu
        boxShadow: _softShadow, // Shadow
      ),
      child: TextField(
        controller: _getCtrl(key, initial: initial),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        onChanged: (val) => _fieldValues[key] = val,
      ),
    );
  }

  Widget _buildCompactCheckbox(String label, String key) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _checkStates[key] ?? false,
            activeColor: primaryIndigo,
            side: BorderSide(color: borderGrey, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) => setState(() => _checkStates[key] = val!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: secondarySlate),
          ),
        ),
      ],
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
                    columnSpacing: 45,
                    horizontalMargin: 15,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(primaryIndigo),
                    border: TableBorder(
                      verticalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                      horizontalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.2),
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
        _buildSearchableCell("G_L_Acc_Bp_code_$index"),
        _buildModernTableCell("G_L_Acc_Bp_name_$index"),
        _buildModernTableCell("debit-$index", initial: "0,00"),
        _buildModernTableCell("credit_$index", initial: "0,00"),
        _buildModernTableCell("remarks_template_$index"),
        _buildModernTableCell("tax_group_$index"),
        _buildModernTableCell("Federal_tax_id_$index", initial: "0,00"),
        _buildModernTableCell("tax_amount_$index"),
        _buildModernTableCell("receipt_number_$index"),
        _buildModernTableCell("gross_value_$index", initial: "0"),
        _buildModernTableCell("base_amount_$index", initial: "0,00"),
        _buildModernTableCell("primary_from_item_$index"),
        _buildModernTableCell("dimension_1_$index"),
        _buildModernTableCell("dimension_2_$index"),
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
              textAlign: isNumeric ? TextAlign.right : TextAlign.right,
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
      centeredHeader("G/L Acc/BP code."),
      centeredHeader("G/L Acc/BP Name"),
      centeredHeader("Debit"),
      centeredHeader("Credit"),
      centeredHeader("Remarks Template"),
      centeredHeader("Tax Group"),
      centeredHeader("Federal Tax ID"),
      centeredHeader("Tax Amount"),
      centeredHeader("receipt number"),
      centeredHeader("Gross Value"),
      centeredHeader("Base Amount"),
      centeredHeader("Primary From Item"),
      centeredHeader("Dimension 1"),
      centeredHeader("Dimension 2"),
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
                  color: primaryIndigo.withValues(alpha: 0.6), // Icon Indigo
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

    if (_getCtrl("f_total_final").text != "IDR $formattedTotal") {
      _getCtrl("f_total_final").text = "IDR $formattedTotal";
    }

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

  Widget _buildDiscountRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const SizedBox(
              width: 140,
              child: Text("Discount", style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 28),
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
    return Row(
      children: [
        SizedBox(
          width: 90,
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
            borderRadius: _inputRadius,
            child: Container(
              height: _inputHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IgnorePointer(
                        child: TextField(
                          controller: _getCtrl(key, initial: initial),
                          style: const TextStyle(fontSize: 12),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color:
                          primaryIndigo.withValues(alpha: 0.6), // Icon Indigo
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundingRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
                      activeColor: primaryIndigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: borderGrey, width: 1.5),
                      onChanged: (v) =>
                          setState(() => _checkStates["cb_rounding"] = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Rounding",
                    style: TextStyle(
                      fontSize: 12,
                      color: secondarySlate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),
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
          const SizedBox(width: 28),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: isReadOnly ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: TextField(
                controller: controller,
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
        border: _thinBorder, // Border Ungu
        boxShadow: _softShadow, // Shadow
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
    double? labelWidth,
  }) {
    String effectiveInitial = (isDecimal && initial.isEmpty) ? "0.00" : initial;
    final controller = _getCtrl(key, initial: effectiveInitial);
    FocusNode? focusNode = isDecimal ? _getFn(key, defaultValue: "0.00") : null;

    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth ?? 120,
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
              height: isTextArea ? 80 : _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: isTextArea ? 3 : 1,
                  textAlign: TextAlign.left,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
    bool isDecimal = false,
    double? labelWidth,
  }) {
    String effectiveInitial = (isDecimal && initial.isEmpty) ? "0.00" : initial;
    final controller = _getCtrl(key, initial: effectiveInitial);
    FocusNode? focusNode = isDecimal ? _getFn(key, defaultValue: "0.00") : null;

    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth ?? 90,
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
              height: isTextArea ? 80 : _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: isTextArea ? 3 : 1,
                  textAlign: TextAlign.left,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
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
        padding: EdgeInsets.zero,
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
                height: _inputHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _inputRadius,
                  border: _thinBorder, // Border Ungu
                  boxShadow: _softShadow, // Shadow
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: _inputHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10),
                        ),
                        border: Border(
                          right: _thinBorder.top,
                        ), // Border tipis kanan
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dropdownValues[dropdownKey] ??
                              seriesOptions.first,
                          isDense: true,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: primaryIndigo.withValues(
                                alpha: 0.6), // Icon Indigo
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
                    Expanded(
                      child: Container(
                        height: _inputHeight,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(10),
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
                            onChanged: (val) {
                              _fieldValues[textKey] = val;
                            },
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: _inputHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _inputRadius,
        border: _thinBorder, // Border Ungu
        boxShadow: _softShadow, // Shadow
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: primaryIndigo.withValues(alpha: 0.6), // Icon Indigo
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
        padding: EdgeInsets.zero,
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
        padding: EdgeInsets.zero,
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
                onTap: () => _showSearchDialog(label, key, data),
                child: Container(
                  height: _inputHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _inputRadius,
                    border: _thinBorder, // Border Ungu
                    boxShadow: _softShadow, // Shadow
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
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.search,
                          size: 16,
                          color: primaryIndigo.withValues(
                              alpha: 0.6), // Icon Indigo
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
        padding: const EdgeInsets.only(bottom: 8),
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
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgSlate,
                    border: Border.all(color: borderGrey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.upload_file,
                          size: 16,
                          color: primaryIndigo.withValues(
                              alpha: 0.6), // Icon Indigo
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
                  const SizedBox(height: 12),
                  _buildFileUploadRow("File 1", "cfg_f1"),
                  const SizedBox(height: 8),
                  _buildFileUploadRow("File 2", "cfg_f2"),
                  const SizedBox(height: 8),
                  _buildFileUploadRow("File 3", "cfg_f3"),
                  const SizedBox(height: 8),
                  _buildFileUploadRow("File 4", "cfg_f4"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Create By", "cfg_by"),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Upload Status", "cfg_up", [
                    "No",
                    "Yes",
                  ]),
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
                  _buildHeaderDate("AP Tax Date", "cfg_tax_date", ""),
                  const SizedBox(height: 12),
                  _buildChooseFromListField(
                      "Kode Faktur Pajak", "cfg_tax_code", [
                    "010",
                    "020",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Area", "cfg_area"),
                  const SizedBox(height: 12),
                  _buildChooseFromListField("Kategori SO", "cfg_cat", [
                    "SO Resmi",
                    "SO Sample",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Customer Name", "cfg_cust_name"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "alasan rubah duedate",
                    "cfg_duedate",
                    isTextArea: true,
                  ),
                  const SizedBox(height: 12),
                  _buildChooseFromListField("validasi PO", "cfg_validasi_po", [
                    "Lengkap",
                    "Tidak Lengkap",
                  ]),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "PIC Engineering",
                    "cfg_pic",
                    isTextArea: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern("Transfer DLM", "TF_dlm", [""]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Transfer Dempo", "Tf_demp", [""]),
                  const SizedBox(height: 12),
                  _buildSmallDropdownRowModern(
                      "Status Pengiriman", "status", [""]),
                  const SizedBox(height: 12),
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
