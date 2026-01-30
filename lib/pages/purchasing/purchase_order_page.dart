import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage>
    with SingleTickerProviderStateMixin {
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

  // --- STYLE SETTINGS (Shadow & Border Konsisten) ---
  final double _inputHeight = 36.0; // Tinggi 36 biar pas dengan vertical 8
  final BorderRadius _inputRadius = BorderRadius.circular(8); // Radius 8

  // Shadow Indigo Halus (Sesuai Gambar)
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

  Border get _thinBorder =>
      Border.all(color: const Color(0xFF4F46E5).withOpacity(0.15), width: 1);
  // --------------------------------------------------

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
          // Bersihkan format (hapus titik, ubah koma jadi titik buat parsing)
          String cleanText = controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .replaceAll(RegExp(r'[^0-9.]'), '');

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
              _syncTotalBeforeDiscount(); // Sync saat focus lost
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
      // Bersihkan format ID (1.000,00 -> 1000.00)
      String cleanVal = val
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll('%', '')
          .replaceAll(RegExp(r'[^0-9.-]'), ''); // Allow negative for discount

      return double.tryParse(cleanVal) ?? 0.0;
    }

    double before = parseValue("f_before_disc");
    double discount = parseValue("f_discount_val");
    double freight = parseValue("f_freight");
    double tax = parseValue("f_tax");
    double rounding = parseValue("f_rounding");

    return (before - discount) + freight + tax + rounding;
  }

  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;

    for (int i = 0; i < _rowCount; i++) {
      String val =
          _fieldValues["total_$i"] ?? _controllers["total_$i"]?.text ?? "0";

      String cleanVal = val
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll('%', '');

      double parsedRow = double.tryParse(cleanVal) ?? 0.0;
      totalAllRows += parsedRow;
    }

    // Update Controller langsung
    String formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    ).format(totalAllRows);

    _getCtrl("f_before_disc").text = formatted;
    _fieldValues["f_before_disc"] = formatted;

    // Trigger rebuild untuk update Grand Total di UI
    // setState(() {}); // Opsional, tergantung logic build
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
      body: SingleChildScrollView(
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
          // KIRI
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildHeaderField("Vendor", "vendor", initial: ""),
                const SizedBox(height: 12),
                _buildSearchableHeaderRow("Name", "h_name"),

                _buildDropdownRowModern("Contact Person", "C_person", [""]),

                _buildHeaderField("Department", "h_dept", initial: ""),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _checkStates["h_send_email"] ?? false,
                        activeColor: primaryIndigo,
                        onChanged: (v) =>
                            setState(() => _checkStates["h_send_email"] = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Send E-Mail if PO or GRPO is Added",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1.0,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                _buildHeaderField(
                  "E-Mail Address",
                  "h_email",
                  isReadOnly: false,
                  initial: "",
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),

          // KANAN
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "No.",
                        style: TextStyle(
                          fontSize: 12,
                          color: secondarySlate,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1.0,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    // Input No Series (KASIH SHADOW)
                    Container(
                      width: 60,
                      height: _inputHeight,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: _inputRadius,
                        border: _thinBorder,
                        boxShadow: _softShadow, // Shadow ditambahkan
                      ),
                      child: Center(
                        child: TextField(
                          controller: _getCtrl("h_no_series", initial: ""),
                          textAlign: TextAlign.center,
                          // FIX TENGAH
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontSize: 11, height: 1.0),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    // Input No Value (KASIH SHADOW)
                    Expanded(
                      child: Container(
                        height: _inputHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: _inputRadius,
                          border: _thinBorder,
                          boxShadow: _softShadow, // Shadow ditambahkan
                        ),
                        child: Center(
                          child: TextField(
                            controller: _getCtrl("h_no_val", initial: ""),
                            // FIX TENGAH
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(fontSize: 12, height: 1.0),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Field Status (KASIH SHADOW - sudah ada di _buildHeaderField)
                _buildHeaderField(
                  "Status",
                  "h_status",
                  initial: "",
                  isReadOnly: true,
                ),
                const SizedBox(height: 12),
                // Field Dates (KASIH SHADOW - sudah ada di _buildHeaderDate)
                _buildHeaderDate("Posting Date", "h_post_date", ""),
                const SizedBox(height: 12),
                _buildHeaderDate("Valid Until", "h_valid_date", ""),
                const SizedBox(height: 12),
                _buildHeaderDate("Document Date", "h_doc_date", ""),
                const SizedBox(height: 12),
                _buildHeaderDate("Required Date", "h_req_date", ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS (FIXED ALIGNMENT & SHADOW)
  // ==========================================

  Widget _buildSearchableHeaderRow(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                shadows: [
                  Shadow(
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: InkWell(
              onTap: () {
                List<String> dummyNames = ["Vendor A", "Vendor B", "Vendor C"];
                _showSearchDialog(label, key, dummyNames);
              },
              child: Container(
                height: _inputHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _inputRadius,
                  border: _thinBorder,
                  boxShadow: _softShadow,
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
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.search,
                        size: 16,
                        color: primaryIndigo.withOpacity(0.6),
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
              shadows: [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
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
              border: _thinBorder,
              boxShadow: _softShadow,
            ),
            child: TextField(
              controller: _getCtrl(key, initial: initial),
              readOnly: isReadOnly,
              // FIX TENGAH: textAlignVertical + height 1.0
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 12, height: 1.0),
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
              shadows: [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
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
                boxShadow: _softShadow, // Shadow ditambahkan
              ),
              child: IgnorePointer(
                child: TextField(
                  controller: _getCtrl(key, initial: initial),
                  // FIX TENGAH
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 12, height: 1.0),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
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
    // Helper lokal untuk Dropdown dengan Shadow & Width khusus
    Widget buildStyledDropdown(String key, List<String> items) {
      if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;

      return Container(
        width: 150, // LEBAR DITAMBAH (Sesuai Request)
        height: 36, // Tinggi disamakan dengan input header
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Radius 8
          // Border Ungu Tipis
          border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.15)),
          // Shadow Halus (Sesuai Request)
          boxShadow: [
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
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _dropdownValues[key],
            isDense: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            icon: Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: primaryIndigo.withOpacity(0.6),
            ),
            onChanged: (val) => setState(() => _dropdownValues[key] = val!),
            items: items
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
          ),
        ),
      );
    }

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
              // Panggil Helper Dropdown yang sudah diperlebar & ada shadow
              buildStyledDropdown("item_type_main", ["Service", "Item"]),

              const Spacer(),

              const Text(
                "Summary Type",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              // Panggil Helper yang sama biar konsisten
              buildStyledDropdown("summary_type", ["No Summary"]),

              const SizedBox(width: 20),
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
                child: IntrinsicWidth(
                  child: DataTable(
                    columnSpacing: 30,
                    horizontalMargin: 15,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(primaryIndigo),
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
        ),
      ],
    );
  }

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

    return [
      centeredColumn("#"),
      centeredColumn("Description"),
      centeredColumn("Required Date"),
      centeredColumn("Qty Service"),
      centeredColumn("Uom"),
      centeredColumn("Price Service"),
      centeredColumn("Unit Price"),
      centeredColumn("Discount %"),
      centeredColumn("Tax Code"),
      centeredColumn("Total (LC)"),
      centeredColumn("Divisi"),
      centeredColumn("Kategori"),
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
        _buildModernTableCell("desc_$index"),
        _buildModernTableCell("req_date_$index"),
        _buildModernTableCell("qty_$index", initial: "0"),
        _buildSearchableCell("uom_$index"),
        _buildModernTableCell("price_$index", initial: "0,00"),
        _buildModernTableCell("unit_price_$index", initial: "0,00"),
        _buildModernTableCell("disc_$index", initial: "0%", isPercent: true),
        _buildDropdownCell("tax_$index", ["VATin11", "VATin12", "Exempt"]),
        _buildModernTableCell("total_$index", initial: "0,00"),
        _buildSearchableCell("div_$index"),
        _buildDropdownCell("cat_$index", [
          "Alat-alat Kebersihan",
          "Perlengkapan Kerja",
          "Isolasi",
        ]),
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

  DataCell _buildModernTableCell(
    String key, {
    String initial = "",
    bool isPercent = false,
  }) {
    final controller = _getCtrl(key, initial: initial);
    bool isNumeric =
        key.contains("qty") ||
        key.contains("price") ||
        key.contains("total") ||
        key.contains("disc") ||
        key.contains("info_price");
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
                // --- PERUBAHAN DISINI (Warna Primary) ---
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

  // ==========================================
  Widget _buildModernFooter() {
    double grandTotal = _getGrandTotal();
    String formattedTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    ).format(grandTotal);

    // Perbaikan: Update text controller jika value berubah, tapi hindari loop
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
                    _buildSmallDropdownRowModern("Buyer", "f_buyer", [
                      "-No Sales Employee-",
                      "Sales A",
                    ]),
                    const SizedBox(height: 4),
                    _buildSmallDropdownRowModern("Owner", "f_owner", [
                      "Owner A",
                      "Owner B",
                    ]),
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
                width: 450,
                child: Column(
                  children: [
                    _buildSummaryRowWithAutoValue(
                      "Total Before Discount",
                      "f_before_disc",
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              "Discount",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0.5, 0.5),
                                    blurRadius: 1.0,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Container(
                            width: 50,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: _thinBorder,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: _softShadow,
                            ),
                            child: TextField(
                              controller: _getCtrl("f_disc_percent"),
                              focusNode: _getFn(
                                "f_disc_percent",
                                isPercent: true,
                              ),
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
                              onChanged: (val) => setState(
                                () => _fieldValues["f_disc_percent"] = val,
                              ),
                            ),
                          ),
                          const Text("%", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildSummaryBox("f_discount_val")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              "Freight",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0.5, 0.5),
                                    blurRadius: 1.0,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _buildSummaryBox("f_freight")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value:
                                        _checkStates["f_rounding_check"] ??
                                        false,
                                    activeColor: primaryIndigo,
                                    onChanged: (v) => setState(
                                      () =>
                                          _checkStates["f_rounding_check"] = v!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Rounding",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0.5, 0.5),
                                        blurRadius: 1.0,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(child: _buildSummaryBox("f_rounding")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
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
          child: _buildActionButtons(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _buildFooterButton("Add", const Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        _buildFooterButton("Delete", Colors.red),
        const Spacer(),
        _buildFooterButton("Copy From", const Color(0xFF1976D2)),
        const SizedBox(width: 8),
        _buildFooterButton("Copy To", Colors.orange),
      ],
    ),
  );

  Widget _buildSmallDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          onChanged: (val) => setState(() => _dropdownValues[key] = val!),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
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
                shadows: [
                  Shadow(
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: isReadOnly ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: _thinBorder, // Fixed Border
                boxShadow: _softShadow, // Fixed Shadow
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: isReadOnly,
                textAlign: TextAlign.right,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  height: 1.0,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
    final controller = _getCtrl(key, initial: defaultValue);
    final focusNode = _getFn(
      key,
      isReadOnly: isReadOnly,
      defaultValue: defaultValue,
      isPercent: isPercent,
    );
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        border: _thinBorder, // Fixed Border
        borderRadius: BorderRadius.circular(4),
        boxShadow: _softShadow, // Fixed Shadow
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: isReadOnly,
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
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
              shadows: [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
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
              border: _thinBorder, // Fixed Border
              boxShadow: _softShadow, // Fixed Shadow
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
                onChanged: (v) => _fieldValues[key] = v,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDropdownRowModern(
    String label,
    String key,
    List<String> items,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100, // Lebar sama dengan header kiri lainnya
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
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _inputRadius,
              border: _thinBorder, // Fixed Border
              boxShadow: _softShadow, // Fixed Shadow
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues[key],
                isDense: true,
                isExpanded: true,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: primaryIndigo.withOpacity(0.6),
                ),
                onChanged: (val) => setState(() => _dropdownValues[key] = val!),
                items: items
                    .map(
                      (val) => DropdownMenuItem(value: val, child: Text(val)),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSmallDropdownRowModern(
    String label,
    String key,
    List<String> items,
  ) => Padding(
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
              shadows: [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _inputRadius,
              border: _thinBorder, // Fixed Border
              boxShadow: _softShadow, // Fixed Shadow
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues[key],
                isDense: true,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: primaryIndigo.withOpacity(0.6),
                ),
                onChanged: (val) => setState(() => _dropdownValues[key] = val!),
                items: items
                    .map(
                      (val) => DropdownMenuItem(value: val, child: Text(val)),
                    )
                    .toList(),
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
}
