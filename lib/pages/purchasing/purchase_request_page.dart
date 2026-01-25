import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseRequestPage extends StatefulWidget {
  const PurchaseRequestPage({super.key});

  @override
  State<PurchaseRequestPage> createState() => _PurchaseRequestPageState();
}

class _PurchaseRequestPageState extends State<PurchaseRequestPage>
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
          String cleanText = controller.text
              .replaceAll('.', '')
              .replaceAll(',', '');
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
      // MEMBERSIHKAN FORMAT INDONESIA KE ANGKA MATEMATIKA
      String cleanVal = val
          .replaceAll('.', '') // Buang titik ribuan
          .replaceAll(',', '.') // Ganti koma jadi titik desimal
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
      // MEMBERSIHKAN HARGA PER BARIS BIAR BISA DITAMBAHIN
      String cleanVal = val
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll('%', '');
      totalAllRows += double.tryParse(cleanVal) ?? 0.0;
    }

    if (mounted) {
      setState(() {
        // FORMAT BALIK KE INDONESIA (1.000,00) BIAR GAK BALIK KE NOL
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Requester",
                          style: TextStyle(
                            fontSize: 12,
                            color: secondarySlate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      Container(
                        height: 32,
                        width: 110,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: borderGrey),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(6),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _dropdownValues["h_req_type"] ?? "User",
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            onChanged: (v) => setState(
                              () => _dropdownValues["h_req_type"] = v!,
                            ),
                            items: ["User", "Employee"]
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
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: borderGrey),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(6),
                            ),
                          ),
                          child: TextField(
                            controller: _getCtrl("h_req_type_val", initial: ""),
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
                  ),
                ),
                _buildSearchableHeaderRow("Requester Name", "h_req_name"),
                _buildHeaderField("Branch", "h_branch", initial: ""),
                const SizedBox(height: 12),
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
                    const Expanded(
                      child: Text(
                        "Send E-Mail if PO or GRPO is Added",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    Container(
                      width: 60,
                      height: 32,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderGrey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _getCtrl("h_no_series", initial: ""),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: borderGrey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _getCtrl("h_no_val", initial: ""),
                            style: const TextStyle(fontSize: 12),
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
                _buildHeaderField(
                  "Status",
                  "h_status",
                  initial: "",
                  isReadOnly: false,
                ),
                const SizedBox(height: 12),
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
              ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: InkWell(
              onTap: () {
                List<String> dummyNames = [
                  "Indra",
                  "Budi",
                  "Siti",
                  "Dewi",
                  "Agus",
                  "Rina",
                ];
                _showSearchDialog(label, key, dummyNames);
              },
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
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
              color: Colors.white,
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
            children: [
              const Text(
                "Item/Service Type",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              _buildSmallDropdown("item_type_main", ["Service", "Item"]),
              const Spacer(),
              const Text(
                "Summary Type",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              _buildSmallDropdown("summary_type", ["No Summary"]),
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

    // Header ke tengah otomatis
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
      centeredColumn("Info Price"),
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
        _buildModernTableCell("info_price_$index", initial: "0,00"),
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
                if (isNumeric) {
                  _syncTotalBeforeDiscount();
                }
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
          child: IntrinsicWidth(
            child: Container(
              constraints: const BoxConstraints(minWidth: 100),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _fieldValues[key] ?? _controllers[key]?.text ?? "",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.search, size: 14, color: Colors.grey),
                ],
              ),
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
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                onChanged: (newValue) {
                  setState(() {
                    _dropdownValues[key] = newValue!;
                  });
                },
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
                      isReadOnly: true, // ReadOnly karena otomatis dari tabel
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
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
    String defaultValue = "0,00",
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
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          const SizedBox(width: 58),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: isReadOnly ? Colors.white : Colors.white,
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
        border: Border.all(color: borderGrey, width: 1.0),
        borderRadius: BorderRadius.circular(4),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
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
        Expanded(
          child: Container(
            height: isTextArea ? 80 : 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
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
}
