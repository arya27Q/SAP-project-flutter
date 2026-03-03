import 'package:flutter/material.dart';

class InventoryTransferPage extends StatefulWidget {
  const InventoryTransferPage({super.key});

  @override
  State<InventoryTransferPage> createState() => _InventoryTransferPageState();
}

class _InventoryTransferPageState extends State<InventoryTransferPage>
    with SingleTickerProviderStateMixin {
  // STATE BUAT SIDE PANEL
  bool showSidePanel = false;

  late TabController _tabController;
  int _rowCount = 10; // Logic dinamis row table

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  final ScrollController _horizontalScroll = ScrollController();

  // Gudang State & Controller
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};

  final double _inputHeight = 35.0;
  final BorderRadius _inputRadius = BorderRadius.circular(8);

  // --- STYLE REUSABLE ---
  // Shadow Ungu Soft buat Input Field Utama
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

  // 🔥 SHADOW TAJAM KHUSUS INPUT UDF
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

  // --- LOGIC CONTROLLER ---
  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
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
      setState(() {
        _getCtrl(key).text = "$day/$month/$year";
        _fieldValues[key] = "$day/$month/$year";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rowCount < 5) _rowCount = 5;

    return Scaffold(
      backgroundColor: bgSlate,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildMainHeader(),
                const SizedBox(height: 16),
                _buildTabSection(),
                const SizedBox(height: 16),
                _buildFooterSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (showSidePanel)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingSidePanel(),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET MAIN HEADER (KIRI)
  // ==========================================
  Widget _buildMainHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            flex: 5,
            child: Column(
              children: [
                // 🔥 SEMUA LABEL SEKARANG TEKS POLOS BIASA
                _buildSearchableHeaderRow("Business Partner", "h_bp"),
                const SizedBox(height: 12),
                _buildHeaderField("Name", "h_name"),
                const SizedBox(height: 12),
                _buildHeaderField("Contact Person", "h_contact"),
                const SizedBox(height: 12),
                _buildHeaderField("Ship To", "h_shipto", isTextArea: true),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "Price List",
                        style: TextStyle(
                            fontSize: 12,
                            color: secondarySlate,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _buildCustomDropdown("h_pricelist", [
                        "Last Purchase Price",
                        "Regular Price",
                        "Distributor Price"
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text("Number",
                          style: TextStyle(
                              fontSize: 12,
                              color: secondarySlate,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 4,
                      child: _buildCustomDropdown(
                          "h_series", ["2026", "2025", "Primary"]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: _buildHeaderField("", "h_docnum",
                          initial: "267302043", hideLabel: true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildHeaderDate("Posting Date", "h_postdate", ""),
                const SizedBox(height: 12),
                _buildHeaderDate("Document Date", "h_docdate", ""),
                const SizedBox(height: 20),
                _buildSearchableHeaderRow("From Warehouse", "h_fromwhs",
                    bgColor: Colors.yellow.shade50),
                _buildSearchableHeaderRow("To Warehouse", "h_towhs"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET TAB & TABLE
  // ==========================================
  Widget _buildTabSection() {
    return Container(
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
              indicatorPadding: const EdgeInsets.all(8),
              tabs: const [Tab(text: "Contents"), Tab(text: "Attachments")],
              onTap: (index) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildContentsTab(),
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text("Attachments Content"))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              IconButton(
                onPressed: () => setState(() => _rowCount++),
                icon: const Icon(Icons.add_box, color: Colors.green, size: 28),
                tooltip: "Add Row",
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _rowCount > 1 ? _rowCount-- : null),
                icon: const Icon(Icons.indeterminate_check_box,
                    color: Colors.red, size: 28),
                tooltip: "Remove Row",
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white,
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
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 15,
                      headingRowHeight: 40,
                      headingRowColor: WidgetStateProperty.all(primaryIndigo),
                      border: TableBorder(
                        verticalInside: BorderSide(
                            color: primaryIndigo.withValues(alpha: 0.2),
                            width: 0.5),
                        horizontalInside: BorderSide(
                            color: primaryIndigo.withValues(alpha: 0.2),
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

  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(
        fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white);

    // 🔥 FIX: Hapus Center(), langsung pakai Text dengan textAlign.center!
    DataColumn col(String label) => DataColumn(
          label: Expanded(
            child: Text(
              label,
              style: headerStyle,
              textAlign: TextAlign.center, // 🔥 Kunci biar rata tengah
            ),
          ),
        );

    return [
      col("#"),
      col("Item No."),
      col("Item Description"),
      col("Jasa Subcont"),
      col("Jenis Item"),
      col("From Warehouse"),
      col("To Warehouse"),
      col("Quantity"),
    ];
  }

  DataRow _buildDataRow(int index) {
    return DataRow(
      cells: [
        DataCell(Center(
            child: Text("${index + 1}", style: const TextStyle(fontSize: 12)))),
        _buildSearchableCell("itemno_$index"),
        _buildTableCell("desc_$index"),
        _buildTableCell("jasa_$index"),
        DataCell(_buildCustomDropdown(
            "jenis_$index", ["Select", "Raw Material", "Finished Goods"])),
        _buildSearchableCell("fromwhs_$index"),
        _buildSearchableCell("towhs_$index"),
        _buildTableCell("qty_$index", initial: "1.00", isNumeric: true),
      ],
    );
  }

  // ==========================================
  // WIDGET FOOTER
  // ==========================================
  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text("Sales Employee",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: secondarySlate,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                            child: _buildCustomDropdown("f_salesemp",
                                ["-No Sales Employee-", "Employee 1"])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSearchableHeaderRow("Journal Remarks", "f_jrnlrem",
                        initial: "Inventory Transfers - "),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                child: _buildHeaderField("Remarks", "f_rem", isTextArea: true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFooterButton("Add", primaryIndigo),
              const SizedBox(width: 8),
              _buildFooterButton("Cancel", Colors.red),
              const Spacer(),
              _buildFooterButton("Copy From", Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLOATING SIDE PANEL WIDGET (UDF)
  // ==========================================
  Widget _buildFloatingSidePanel() {
    return Container(
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
                _buildUDFDate("Request Due Date", "udf_reqdate"),
                const SizedBox(height: 12),
                _buildUDFField("PO Number", "udf_ponum"),
                const SizedBox(height: 12),
                _buildUDFField("Request By", "udf_reqby"),
                const SizedBox(height: 12),
                _buildUDFSearchable("Send To Subcont", "udf_sendto"),
                const SizedBox(height: 12),
                _buildUDFDropdown(
                    "Create By", "udf_createby", ["", "User A", "User B"]),
                const SizedBox(height: 12),
                _buildUDFField("Internal Memo", "udf_memo", isTextArea: true),
                const SizedBox(height: 12),
                _buildUDFField("SO No", "udf_sono"),
                const SizedBox(height: 12),
                _buildUDFSearchable("Customer Code", "udf_custcode"),
                const SizedBox(height: 12),
                _buildUDFField("Customer Name", "udf_custname"),
                const SizedBox(height: 12),
                _buildUDFDropdown(
                    "Status TTF", "udf_status", ["Unapproved", "Approved"]),
                const SizedBox(height: 12),
                _buildUDFField("Approved By", "udf_appby"),
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

  // ==========================================
  // HELPER COMPONENT MAIN & FOOTER
  // ==========================================

  Widget _buildHeaderField(String label, String key,
      {String initial = "", bool hideLabel = false, bool isTextArea = false}) {
    return Row(
      crossAxisAlignment:
          isTextArea ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (!hideLabel)
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: secondarySlate,
                    fontWeight: FontWeight.w500)),
          ),
        if (!hideLabel) const SizedBox(width: 28),
        Expanded(
          child: Container(
            height: isTextArea ? 80 : _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _inputRadius,
              boxShadow: _inputSoftShadow,
              border: _thinBorder,
            ),
            child: TextField(
              controller: _getCtrl(key, initial: initial),
              maxLines: isTextArea ? 3 : 1,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchableHeaderRow(String label, String key,
      {String initial = "", Color? bgColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: secondarySlate,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: InkWell(
              onTap: () =>
                  _showSearchDialog(label, key, ["Option A", "Option B"]),
              child: Container(
                height: _inputHeight,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: bgColor ?? Colors.white,
                  borderRadius: _inputRadius,
                  border: _thinBorder,
                  boxShadow: _inputSoftShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(_controllers[key]?.text ?? initial,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis)),
                    Icon(Icons.search,
                        size: 16, color: primaryIndigo.withValues(alpha: 0.6)),
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
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: secondarySlate,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: InkWell(
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
          ),
        ),
      ],
    );
  }

  DataCell _buildTableCell(String key,
      {String initial = "", bool isNumeric = false}) {
    return DataCell(
      Container(
        height: 30,
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: _getCtrl(key, initial: initial),
          textAlign: isNumeric ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero),
        ),
      ),
    );
  }

  DataCell _buildSearchableCell(String key) {
    return DataCell(
      InkWell(
        onTap: () => _showSearchDialog(
            "Search", key, ["Item 1", "Item 2", "Whs 01", "Whs 02"]),
        child: Container(
          // 🔥 1. NAIKIN LEBARNYA JADI 160!
          // Biar dia ngalahin lebar judul kolomnya dan bisa full mentok kanan
          width: 160,
          alignment: Alignment.centerLeft,
          // 🔥 2. Padding kanan dikasih 8 biar iconnya ga nabrak garis border banget
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              Expanded(
                  child: Text(_controllers[key]?.text ?? "",
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
              Icon(Icons.search,
                  size: 14, color: primaryIndigo.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Container(
      height: _inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _inputRadius,
          border: _thinBorder,
          boxShadow: _inputSoftShadow),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isExpanded: true,
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          icon: Icon(Icons.arrow_drop_down,
              size: 20, color: primaryIndigo.withValues(alpha: 0.6)),
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  // ==========================================
  // UDF HELPERS (Label Teks Biasa, Input ber-Shadow Tajam)
  // ==========================================
  Widget _buildUDFField(String label, String key, {bool isTextArea = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Label Teks Biasa
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
            boxShadow: _sharpShadow, // 🔥 Input field pake shadow tajam
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

  Widget _buildUDFSearchable(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Label Teks Biasa
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showSearchDialog(label, key, ["UDF Data 1"]),
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _inputRadius,
              border: _thinBorder,
              boxShadow: _sharpShadow, // 🔥 Input field pake shadow tajam
            ),
            child: Row(
              children: [
                Expanded(
                    child: Text(_controllers[key]?.text ?? "",
                        style: const TextStyle(fontSize: 11))),
                Icon(Icons.search, size: 14, color: primaryIndigo),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUDFDate(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Label Teks Biasa
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
              boxShadow: _sharpShadow, // 🔥 Input field pake shadow tajam
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

  Widget _buildUDFDropdown(String label, String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Label Teks Biasa
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: _inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _inputRadius,
            border: _thinBorder,
            boxShadow: _sharpShadow, // 🔥 Input field pake shadow tajam
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _dropdownValues[key],
              isExpanded: true,
              isDense: true,
              style: const TextStyle(fontSize: 11, color: Colors.black),
              icon: Icon(Icons.arrow_drop_down, size: 18, color: primaryIndigo),
              onChanged: (val) => setState(() => _dropdownValues[key] = val!),
              items: items
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
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
