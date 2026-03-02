import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class InventoryCountingPage extends StatefulWidget {
  const InventoryCountingPage({super.key});

  @override
  State<InventoryCountingPage> createState() => _InventoryCountingPageState();
}

class _InventoryCountingPageState extends State<InventoryCountingPage>
    with SingleTickerProviderStateMixin {
  // 🔥 STATE BUAT SIDE PANEL UDF
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

  final double _inputHeight = 35.0;
  final BorderRadius _inputRadius = BorderRadius.circular(8);

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
          bool isNumericField = key.contains("qty") || key.contains("variance");
          if (isNumericField) {
            String cleanText =
                controller.text.replaceAll(RegExp(r'[^0-9]'), '');
            double? parsed = double.tryParse(cleanText);
            if (mounted) {
              setState(() {
                if (parsed != null) {
                  controller.text = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: '',
                    decimalDigits: 2,
                  ).format(parsed);
                } else {
                  controller.text = defaultValue;
                }
                _fieldValues[key] = controller.text;
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

  // --- STYLE REUSABLE ---
  List<BoxShadow> get _inputSoftShadow => [
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

  List<BoxShadow> get _sharpShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(0, 4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];

  Border get _thinBorder => Border.all(
      color: const Color(0xFF4F46E5).withValues(alpha: 0.15), width: 1);

  @override
  void initState() {
    super.initState();
    // Di gambar cuma ada 1 tab: General
    _tabController = TabController(length: 1, vsync: this);
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
                const SizedBox(height: 100),
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

  // ==========================================
  // WIDGET MAIN HEADER (Inventory Counting)
  // ==========================================
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
            // KIRI
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  // Row Count Date & Time
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text("Count Date",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: secondarySlate,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 5,
                          child: _buildDateInputOnly(
                              "h_count_date", "01/March/2026"),
                        ),
                        const SizedBox(width: 16),
                        const Text("Time",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: _buildTextInputOnly("h_time", "10:09"),
                        ),
                      ],
                    ),
                  ),
                  _buildSmallDropdownRowModern("Counting Type", "h_count_type",
                      ["Single Counter", "Multiple Counters"]),
                  // Row Inventory Counter (Dropdown + Text)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text("Inventory Counter",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: secondarySlate,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 4,
                          child: _buildSmallDropdown(
                              "h_inv_counter_type", ["User", "Employee"]),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 6,
                          child: _buildTextInputOnly(
                              "h_inv_counter_name", "manager"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 60),
            // KANAN
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildModernNoFieldRow(
                    "No.",
                    "h_no_series",
                    ["2026", "2025"],
                    "h_no_val",
                    initialNo: "267500001",
                  ),
                  _buildModernFieldRow("Status", "h_stat"),
                  _buildModernFieldRow("Ref. 2", "h_ref2"),
                ],
              ),
            ),
          ],
        ),
      );

  // ==========================================
  // WIDGET TAB & TABLE
  // ==========================================
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
              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              tabs: const [
                Tab(text: "General"),
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
        // Baris Atas Tabel (Find Item No Warehouses dll)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(color: primaryIndigo, width: 2.5)),
          ),
          child: Row(
            children: [
              const Text("Find",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),

              const SizedBox(width: 12),
              SizedBox(
                  width: 120,
                  child: _buildSmallDropdown(
                      "t_find_type", ["Item No.", "Barcode"])),
              const SizedBox(width: 12),
              SizedBox(
                  width: 120,
                  child: _buildSmallDropdown("t_whse", ["Warehouses", "All"])),
              const Spacer(),
              // Tombol UDF panel di atas tabel
              ElevatedButton.icon(
                onPressed: () => setState(() => showSidePanel = true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.tune_rounded,
                    size: 16, color: Colors.white),
                label: const Text(
                  "Open UDF",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              _buildAddRowButtons(),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            border: Border.all(color: borderGrey, width: 0.5),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                controller: _horizontalScroll,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 15,
                      headingRowHeight: 40,
                      headingRowColor: WidgetStateProperty.all(primaryIndigo),
                      border: TableBorder(
                        verticalInside: BorderSide(
                            color: primaryIndigo.withValues(alpha: 0.5),
                            width: 0.5),
                        horizontalInside: BorderSide(
                            color: primaryIndigo.withValues(alpha: 0.5),
                            width: 0.5),
                      ),
                      columns: _buildStaticColumns(),
                      rows: List.generate(
                          _rowCount, (index) => _buildDataRow(index)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔥 UPDATE: TEXTALIGN.CENTER BIAR JUDUL TABEL DI TENGAH SEMUA
  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    DataColumn centeredHeader(String label) {
      return DataColumn(
        label: Expanded(
          child: Text(label, style: headerStyle, textAlign: TextAlign.center),
        ),
      );
    }

    return [
      centeredHeader("#"),
      centeredHeader("Item No."),
      centeredHeader("Item Description"),
      centeredHeader("Freeze"), // Di gambar ketutup "Fre..."
      centeredHeader("Whse"),
      centeredHeader("In-Whse Qty on Count Date"),
      centeredHeader("Counted"),
      centeredHeader("UoM Counted Qty"),
      centeredHeader("Counted Qty"),
      centeredHeader("Variance"),
      centeredHeader("UoM Code"),
      centeredHeader("Items per Unit"),
      centeredHeader("Qty In..."),
    ];
  }

  DataRow _buildDataRow(int index) {
    return DataRow(
      cells: [
        DataCell(Center(
            child: Text("${index + 1}", style: const TextStyle(fontSize: 12)))),
        _buildSearchableCell("item_no_$index"),
        _buildTableCell("desc_$index"),
        _buildCheckboxCell("freeze_$index"),
        _buildSearchableCell("whse_$index"),
        _buildTableCell("in_whse_qty_$index", initial: "0.00", isNumeric: true),
        _buildCheckboxCell("counted_$index"),
        _buildTableCell("uom_counted_qty_$index",
            initial: "0.00", isNumeric: true),
        _buildTableCell("counted_qty_$index", initial: "0.00", isNumeric: true),
        _buildTableCell("variance_$index", initial: "0.00", isNumeric: true),
        _buildSearchableCell("uom_code_$index"),
        _buildTableCell("items_per_unit_$index",
            initial: "1.00", isNumeric: true),
        _buildTableCell("qty_in_$index", initial: "0.00", isNumeric: true),
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
          onPressed: () => setState(() => _rowCount > 1 ? _rowCount-- : null),
          icon: const Icon(Icons.indeterminate_check_box, color: Colors.red),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET FOOTER
  // ==========================================
  Widget _buildModernFooter() {
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
                flex: 6,
                child:
                    _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
              ),
              const Expanded(
                  flex: 4, child: SizedBox()), // Kanan kosong sesuai gambar
            ],
          ),
        ),
        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildSAPActionButton("Add", isPrimary: true),
              const SizedBox(width: 8),
              _buildSAPActionButton("Cancel", isDanger: true),
              const SizedBox(width: 16),
              _buildSAPActionButton("Add Items",
                  customColor: Colors.orange.shade600),
              const SizedBox(width: 8),
              _buildSAPActionButton("Adjust Counted Quantities",
                  customColor: Colors.amber.shade700),
              const Spacer(),
              _buildSAPActionButton("Copy to Inventory Posting",
                  customColor: Colors.amber.shade700),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FLOATING SIDE PANEL WIDGET (UDF)
  // ==========================================
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
              automaticallyImplyLeading: false,
              title: const Text(
                "User Defined Fields",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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
                  _buildUDFDate("Count Reference Date", "udf_date"),
                  const SizedBox(height: 12),
                  _buildUDFField("Checker Name", "udf_checker"),
                  const SizedBox(height: 12),
                  _buildUDFField("Internal Memo", "udf_memo", isTextArea: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => setState(() => showSidePanel = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("APPLY",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ==========================================
  // HELPER COMPONENTS (Main & Cell)
  // ==========================================

  Widget _buildTextInputOnly(String key, String initial) {
    return Container(
      height: _inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _inputRadius,
        boxShadow: _inputSoftShadow,
        border: _thinBorder,
      ),
      child: TextField(
        controller: _getCtrl(key, initial: initial),
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  Widget _buildDateInputOnly(String key, String initial) {
    return InkWell(
      onTap: () => _selectDate(context, key),
      child: Container(
        height: _inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _inputRadius,
          border: _thinBorder,
          boxShadow: _inputSoftShadow,
        ),
        child: IgnorePointer(
          child: TextField(
            controller: _getCtrl(key, initial: initial),
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: Icon(Icons.calendar_month_rounded,
                  size: 14, color: primaryIndigo.withValues(alpha: 0.6)),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 20, minHeight: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
    bool isDecimal = false,
    bool isReadOnly = false,
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
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: secondarySlate,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Container(
              height: isTextArea ? 80 : 35,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isReadOnly ? Colors.grey.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: _inputSoftShadow,
                border: _thinBorder,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: isTextArea ? 3 : 1,
                readOnly: isReadOnly,
                keyboardType: isDecimal
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
                onChanged: (val) => _fieldValues[key] = val,
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
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: secondarySlate,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _inputSoftShadow,
                  border: _thinBorder,
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
                              fontWeight: FontWeight.bold),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18, color: Colors.black54),
                          onChanged: (v) =>
                              setState(() => _dropdownValues[dropdownKey] = v!),
                          items: seriesOptions
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
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
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        ),
                        onChanged: (val) => _fieldValues[textKey] = val,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        boxShadow: _inputSoftShadow,
        border: _thinBorder,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: primaryIndigo),
          style: const TextStyle(
              fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
          onChanged: (val) => setState(() => _dropdownValues[key] = val!),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSmallDropdownRowModern(
          String label, String key, List<String> items) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: secondarySlate,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 28),
            Expanded(child: _buildSmallDropdown(key, items)),
          ],
        ),
      );

  DataCell _buildTableCell(String key,
      {String initial = "", bool isNumeric = false}) {
    final controller = _getCtrl(key, initial: initial);
    final focusNode = isNumeric ? _getFn(key) : null;
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
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              onChanged: (val) => _fieldValues[key] = val,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 CHECKBOX CELL UNTUK TABEL (Freeze & Counted)
  DataCell _buildCheckboxCell(String key) {
    return DataCell(
      Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _checkStates[key] ?? false,
            onChanged: (val) => setState(() => _checkStates[key] = val!),
            activeColor: primaryIndigo,
            side: BorderSide(color: borderGrey, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }

  DataCell _buildSearchableCell(String key) {
    return DataCell(
      InkWell(
        onTap: () => _showSearchDialog("Search", key, ["Data 1", "Data 2"]),
        child: Container(
          width: 140, // Lebar ideal biar iconnya pas di kanan
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _fieldValues[key] ?? _controllers[key]?.text ?? "",
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.search,
                  size: 14, color: primaryIndigo.withValues(alpha: 0.6)),
            ],
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  // ==========================================
  // UDF HELPERS (Shadow Tajam)
  // ==========================================
  Widget _buildUDFField(String label, String key, {bool isTextArea = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: isTextArea ? 60 : _inputHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _inputRadius,
            border: _thinBorder,
            boxShadow: _sharpShadow,
          ),
          child: TextField(
            controller: _getCtrl(key),
            maxLines: isTextArea ? 3 : 1,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildUDFDate(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context, key),
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _inputRadius,
              border: _thinBorder,
              boxShadow: _sharpShadow,
            ),
            child: IgnorePointer(
              child: TextField(
                controller: _getCtrl(key),
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  suffixIcon: Icon(Icons.calendar_month_rounded,
                      size: 14, color: primaryIndigo),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(String label, String key, List<String> data) {
    List<String> filteredList = List.from(data);
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Search $label", style: const TextStyle(fontSize: 14)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                      hintText: "Search...", prefixIcon: Icon(Icons.search)),
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
}
