import 'package:flutter/material.dart';

class CountriesSetupPage extends StatefulWidget {
  const CountriesSetupPage({super.key});

  @override
  State<CountriesSetupPage> createState() => _CountriesSetupPageState();
}

class _CountriesSetupPageState extends State<CountriesSetupPage> {
  int _rowCount = 20; // Default baris kayak di gambar

  // ==========================================
  // COLORS & STYLES (Seragam dengan ERP lu)
  // ==========================================
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  final ScrollController _horizontalScroll = ScrollController();

  // State Management buat isian tabel
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkboxValues = {};

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initial);
    }
    return _controllers[key]!;
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rowCount < 5) _rowCount = 5;

    // APPBAR DIHAPUS BIAR NGGAK DOUBLE HEADER
    return Scaffold(
      backgroundColor: bgSlate,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Table Section (Langsung tabel)
            _buildTableSection(),
            const SizedBox(height: 20),

            // 2. Footer Buttons
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MAIN TABLE SECTION
  // ==========================================
  Widget _buildTableSection() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar atas tabel buat nambah/kurang baris
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(color: primaryIndigo, width: 2.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => setState(() => _rowCount++),
                  icon: const Icon(Icons.add_box, color: Colors.green),
                  tooltip: "Add Row",
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _rowCount > 5 ? _rowCount-- : null),
                  icon: const Icon(Icons.indeterminate_check_box,
                      color: Colors.red),
                  tooltip: "Remove Row",
                ),
              ],
            ),
          ),

          // Tabel Data (Bisa di-scroll horizontal)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 500),
            color: Colors.white,
            child: Scrollbar(
              controller: _horizontalScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScroll,
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: DataTable(
                    columnSpacing: 25,
                    horizontalMargin: 15,
                    headingRowHeight: 45,
                    headingRowColor: WidgetStateProperty.all(primaryIndigo),
                    dataRowMinHeight: 35,
                    dataRowMaxHeight: 40,
                    border: TableBorder(
                      verticalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      horizontalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.3),
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
      ),
    );
  }

  // ==========================================
  // TABLE COLUMNS & ROWS
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

    // Persis urutan di gambar Countries Setup
    return [
      centeredColumn("#"),
      centeredColumn("Code"),
      centeredColumn("Name"),
      centeredColumn("Code for Reports"),
      centeredColumn("Address Format"),
      centeredColumn("EU"),
      centeredColumn("No. of Digits for Tax ID"),
      centeredColumn("No. of Digits for Bank Code"),
      centeredColumn("No. of Digits for Branch"),
      centeredColumn("No. of Digits for Account No."),
      centeredColumn("No. of Digits for Control No."),
      centeredColumn("Domestic Bank Acct. Validation"),
      centeredColumn("IBAN Validation"),
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
        _buildTextCell("code_$index", minWidth: 60),
        _buildTextCell("name_$index", minWidth: 150),
        _buildTextCell("rep_code_$index", minWidth: 100),
        _buildDropdownCell(
            "addr_fmt_$index",
            [
              "European Standard Address",
              "Zip Code Before City",
              "USA",
              "Blank"
            ],
            minWidth: 180),
        _buildCheckboxCell("eu_$index"),
        _buildTextCell("tax_id_$index", minWidth: 120),
        _buildTextCell("bank_code_$index", minWidth: 140),
        _buildTextCell("branch_$index", minWidth: 120),
        _buildTextCell("acc_no_$index", minWidth: 140),
        _buildTextCell("ctrl_no_$index", minWidth: 140),
        _buildDropdownCell("dom_bank_val_$index", ["", "Yes", "No"],
            minWidth: 180),
        _buildCheckboxCell("iban_val_$index"),
      ],
    );
  }

  // ==========================================
  // TABLE CELLS WIDGETS
  // ==========================================
  DataCell _buildTextCell(String key, {double minWidth = 100}) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: TextField(
            controller: _getCtrl(key),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildDropdownCell(String key, List<String> items,
      {double minWidth = 120}) {
    if (!_dropdownValues.containsKey(key)) {
      _dropdownValues[key] = items.first;
    }

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _dropdownValues[key],
              isDense: true,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: primaryIndigo.withValues(alpha: 0.6),
              ),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
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
    );
  }

  DataCell _buildCheckboxCell(String key) {
    if (!_checkboxValues.containsKey(key)) {
      _checkboxValues[key] = false;
    }

    return DataCell(
      Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _checkboxValues[key],
            activeColor: primaryIndigo,
            onChanged: (val) {
              setState(() {
                _checkboxValues[key] = val ?? false;
              });
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FOOTER BUTTONS
  // ==========================================
  Widget _buildFooter() {
    return Row(
      children: [
        SizedBox(
          height: 32,
          width: 90,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F), // Kuning SAP
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Colors.black26),
              ),
            ),
            child: const Text(
              "OK",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 32,
          width: 90,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0E0E0),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Colors.black26),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
