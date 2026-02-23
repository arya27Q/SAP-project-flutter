import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Hapus import ini kalau nanti masih merah, lalu pakai cara Ctrl + Titik (Auto Import)
import '../financials/journal_entry_page.dart';

class GoodIssuePage extends StatefulWidget {
  const GoodIssuePage({super.key});

  @override
  State<GoodIssuePage> createState() => _GoodIssuePageState();
}

class _GoodIssuePageState extends State<GoodIssuePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _rowCount = 10;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  final ScrollController _horizontalScroll = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};

  final double _inputHeight = 35.0;
  final BorderRadius _inputRadius = BorderRadius.circular(8);
  bool showSidePanel = false;

  // Shadow Ungu Halus (Reusable)
  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: const Color(0xFF4F46E5).withOpacity(0.08),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  // Border Ungu Tipis (Reusable)
  Border get _thinBorder =>
      Border.all(color: const Color(0xFF4F46E5).withOpacity(0.15), width: 1);
  // -------------------------------------------

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
      () => TextEditingController(text: initial),
    );
  }

  FocusNode _getFn(
    String key, {
    bool isReadOnly = false,
    String defaultValue = "0,00",
    bool isPercent = false,
    bool isNumeric = true,
  }) {
    if (!_focusNodes.containsKey(key)) {
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus && isNumeric && !isReadOnly) {
          final controller = _getCtrl(key);

          if (controller.text.trim().isEmpty) {
            controller.text = defaultValue;
            return;
          }
          String cleanText =
              controller.text.replaceAll('.', '').replaceAll(',', '');
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
        }
      });
      _focusNodes[key] = fn;
    }
    return _focusNodes[key]!;
  }

  double _getGrandTotal() {
    double parseValue(String key) {
      String val = _controllers[key]?.text ?? _fieldValues[key] ?? "0";
      String cleanVal = val
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^0-9.]'), '');

      return double.tryParse(cleanVal) ?? 0.0;
    }

    double before = parseValue("f_before_disc");
    double freight = parseValue("f_freight");
    double tax = parseValue("f_tax");

    return before + freight + tax;
  }

  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;
    for (int i = 0; i < _rowCount; i++) {
      String val =
          _fieldValues["total_$i"] ?? _controllers["total_$i"]?.text ?? "0";
      String cleanVal =
          val.replaceAll('.', '').replaceAll(',', '.').replaceAll('%', '');
      totalAllRows += double.tryParse(cleanVal) ?? 0.0;
    }

    if (mounted) {
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
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
  // HEADER SECTION
  // ==========================================
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
          // ================= KIRI =================
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      _buildLabelText("Number"),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Container(
                          height: _inputHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: _inputRadius,
                            border: _thinBorder,
                            boxShadow: _softShadow,
                          ),
                          child: TextField(
                            controller:
                                _getCtrl("h_number_val", initial: "262700470"),
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Series",
                        style: TextStyle(
                          fontSize: 12,
                          color: secondarySlate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: _inputHeight,
                        width: 90,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: _inputRadius,
                          border: _thinBorder,
                          boxShadow: _softShadow,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _dropdownValues["h_series"] ?? "2026",
                            isDense: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: primaryIndigo.withOpacity(0.6),
                            ),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                            onChanged: (v) => setState(
                                () => _dropdownValues["h_series"] = v!),
                            items: ["2026", "2027"]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildHeaderDropdown("Price List", "h_price_list",
                    ["Last Purchase Price", "Standard Price"]),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // ================= KANAN =================
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildHeaderDate("Posting Date", "h_post_date", "21/02/2026"),
                const SizedBox(height: 12),
                _buildHeaderDate("Document Date", "h_doc_date", "21/02/2026"),
                const SizedBox(height: 12),
                _buildHeaderField("Ref. 2", "h_ref2", initial: ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS (HEADER & MAIN)
  // ==========================================
  Widget _buildLabelText(String label) {
    return SizedBox(
      width: 100,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: secondarySlate,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeaderDropdown(String label, String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildLabelText(label),
          const SizedBox(width: 28),
          Expanded(
            child: Container(
              height: _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder,
                boxShadow: _softShadow,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[key],
                  isDense: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: primaryIndigo.withOpacity(0.6),
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  onChanged: (v) => setState(() => _dropdownValues[key] = v!),
                  items: items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderField(String label, String key,
      {String initial = "", bool isReadOnly = false}) {
    return Row(
      children: [
        _buildLabelText(label),
        const SizedBox(width: 28),
        Expanded(
          child: Container(
            height: _inputHeight,
            decoration: BoxDecoration(
              color: isReadOnly ? Colors.grey[50] : Colors.white,
              borderRadius: _inputRadius,
              boxShadow: _softShadow,
              border: _thinBorder,
            ),
            child: TextField(
              controller: _getCtrl(key, initial: initial),
              readOnly: isReadOnly,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDate(String label, String key, String initial) {
    return Row(
      children: [
        _buildLabelText(label),
        const SizedBox(width: 28),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, key),
            child: Container(
              height: _inputHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder,
                boxShadow: _softShadow,
              ),
              child: IgnorePointer(
                child: TextField(
                  controller: _getCtrl(key, initial: initial),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    suffixIcon: Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: primaryIndigo.withOpacity(0.6),
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

  // ==========================================
  // TAB & TABLE SECTION
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                        color: primaryIndigo.withOpacity(0.5),
                        width: 0.5,
                      ),
                      horizontalInside: BorderSide(
                        color: primaryIndigo.withOpacity(0.5),
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

  // ==========================================
  // UPDATED TABLE COLUMNS
  // ==========================================
  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    DataColumn centeredColumn(String label) {
      return DataColumn(
        label: Expanded(
          child: Text(label, style: headerStyle, textAlign: TextAlign.center),
        ),
      );
    }

    // Sesuai gambar yang diminta
    return [
      centeredColumn("#"),
      centeredColumn("Item No."),
      centeredColumn("Item Description"),
      centeredColumn("Quantity"),
      centeredColumn("UoM Name"),
      centeredColumn("Item Cost"),
      centeredColumn("In Stock"),
      centeredColumn("Inventory Offset - Decrease Account"),
      centeredColumn("Total"),
      centeredColumn("Whse"),
      centeredColumn("Dimension 1"),
      centeredColumn("Dem_nottf"),
      centeredColumn("Sales BoM"),
      centeredColumn("No. Permintaan"),
    ];
  }

  DataRow _buildDataRow(int index) {
    return DataRow(
      cells: [
        DataCell(
          Center(
            child: Text("${index + 1}", style: const TextStyle(fontSize: 12)),
          ),
        ),
        _buildItemNoCell("item_no_$index"), // Tanda panah kuning ada di sini
        _buildSearchableCell("desc_$index"),
        _buildModernTableCell("qty_$index", initial: "0"),
        _buildSearchableCell("uom_$index"),
        _buildModernTableCell("cost_$index", initial: "0,00"),
        _buildModernTableCell("stock_$index", initial: "0"),
        _buildSearchableCell("offset_$index"),
        _buildModernTableCell("total_$index", initial: "0,00"),
        _buildSearchableCell("whse_$index"),
        _buildSearchableCell("dim1_$index"),
        _buildSearchableCell("dem_$index"),
        // Dropdown khusus kolom Sales BoM
        _buildDropdownCell("sales_bom_$index", ["Header", "Component", "None"]),
        _buildSearchableCell("no_perm_$index"),
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

  // ==========================================
  // TABLE CELLS WIDGETS
  // ==========================================

  // Custom Widget Khusus Untuk Item No (Ada Panah Kuning)
  DataCell _buildItemNoCell(String key) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // MUNCULKAN SEBAGAI POP-UP DIALOG (MODAL) BIAR GAMPANG DITUTUP
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          // Atur ukuran Pop-up Journal Entry nya (Bisa dibesarkan/dikecilkan)
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.height * 0.85,
                            child: Column(
                              children: [
                                // Header Pop-up dengan tombol Close
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryIndigo,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Journal Entry Details",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () => Navigator.of(context)
                                            .pop(), // Tombol Kembali
                                      ),
                                    ],
                                  ),
                                ),
                                // Isi Halaman Journal Entry
                                Expanded(
                                  // Pastikan kamu meng-import JournalEntryPage dengan benar di atas
                                  child: JournalEntryPage(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.play_arrow, // Golden arrow khas SAP
                    size: 16,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _getCtrl(key),
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
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildModernTableCell(
    String key, {
    String initial = "",
    bool isPercent = false,
  }) {
    final controller = _getCtrl(key, initial: initial);
    bool isNumeric = key.contains("qty") ||
        key.contains("cost") ||
        key.contains("total") ||
        key.contains("stock");
    String defValue = isPercent ? "0%" : "0,00";
    final focusNode = _getFn(
      key,
      defaultValue: initial.isEmpty ? defValue : initial,
      isNumeric: isNumeric,
      isPercent: isPercent,
    );

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100),
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
                if (isNumeric) _syncTotalBeforeDiscount();
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildSearchableCell(String key) {
    return DataCell(
      InkWell(
        onTap: () {
          List<String> dummyData = [
            "Option A",
            "Option B",
            "Option C",
            "Option D"
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
                  color: primaryIndigo.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildDropdownCell(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IntrinsicWidth(
          child: Container(
            constraints: const BoxConstraints(minWidth: 120),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues[key],
                hint: const Text("", style: TextStyle(fontSize: 12)),
                isDense: true,
                isExpanded: false,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: primaryIndigo.withOpacity(0.6),
                ),
                onChanged: (newValue) =>
                    setState(() => _dropdownValues[key] = newValue!),
                items: items
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
                    _buildModernFieldRow("Owner", "f_owner", initial: ""),
                    const SizedBox(height: 12),
                    _buildModernFieldRow(
                      "Remarks",
                      "f_rem",
                      isTextArea: true,
                      initial: "",
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    _buildSummaryRowWithAutoValue(
                      "Total Before Discount",
                      "f_before_disc",
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Freight",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 58),
                        Expanded(child: _buildSummaryBox("f_freight")),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRowWithAutoValue("Tax", "f_tax"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 1),
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Total Payment Due",
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
          child: Row(
            children: [
              _buildFooterButton("Add", primaryIndigo),
              const SizedBox(width: 8),
              _buildFooterButton("Cancel", Colors.red),
              const Spacer(),
              _buildFooterButton("Copy From", const Color(0xFF1976D2)),
              const SizedBox(width: 8),
              _buildFooterButton("Copy To", Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFooterButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () => debugPrint("Klik $label"),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRowWithAutoValue(
    String label,
    String key, {
    String defaultValue = "0.00",
    bool isBold = false,
    bool isReadOnly = false,
  }) {
    final controller = _getCtrl(key, initial: defaultValue);
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
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
              ),
            ),
          ),
          const SizedBox(width: 58),
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: isReadOnly ? Colors.white : Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder,
                boxShadow: _softShadow,
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
                    vertical: 8,
                  ),
                ),
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
    final controller = _getCtrl(key, initial: defaultValue);
    final focusNode = _getFn(
      key,
      isReadOnly: isReadOnly,
      defaultValue: defaultValue,
      isPercent: isPercent,
    );
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _inputRadius,
        border: _thinBorder,
        boxShadow: _softShadow,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
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
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
  }) {
    String effectiveInitial = (isDecimal && initial.isEmpty) ? "0.00" : initial;
    final controller = _getCtrl(key, initial: effectiveInitial);
    FocusNode? focusNode;
    if (isDecimal) focusNode = _getFn(key, defaultValue: "0.00");

    return Padding(
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
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: isTextArea ? 80 : _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                boxShadow: _softShadow,
                border: _thinBorder,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: isTextArea ? 3 : 1,
                textAlign: TextAlign.start,
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

  // ==========================================
  // UPDATED SIDE PANEL
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
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Sesuai gambar ketiga
                  _buildModernFieldRow("Customer Code", "sp_cust_code"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("SO No.", "sp_so_no"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("GI Reason Code", "sp_gi_reason"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Item Group", "sp_item_group"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Create by", "sp_create_by"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("No Resi", "sp_no_resi"),

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
