import 'package:flutter/material.dart';

class AddressFormatPage extends StatefulWidget {
  const AddressFormatPage({super.key});

  @override
  State<AddressFormatPage> createState() => _AddressFormatPageState();
}

// Bikin class data kecil buat nyimpen isi tiap baris tabel
class GridRowData {
  String col1;
  String col2;
  String col3;
  String col4;
  GridRowData({this.col1 = "", this.col2 = "", this.col3 = "", this.col4 = ""});
}

class _AddressFormatPageState extends State<AddressFormatPage> {
  // ==========================================
  // COLORS & STYLES (FULL INDIGO)
  // ==========================================
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF1F5F9);
  final Color borderGrey = const Color(0xFFD0D5DC);

  final double _inputHeight = 40.0;
  final BorderRadius _inputRadius = BorderRadius.circular(10);

  // State untuk Radio & Checkbox
  String _selectedTextFormat = 'None';
  bool _isDescriptionChecked = false;

  final ScrollController _listScrollController = ScrollController();

  // STATE UNTUK TABEL DINAMIS (Default ada 3 baris)
  List<GridRowData> tableData = [
    GridRowData(col1: "Street"),
    GridRowData(col1: "City", col2: '""', col3: "Zip Code"),
    GridRowData(col1: "Country"),
  ];

  List<BoxShadow> get _strongShadow => [
        BoxShadow(
          color: primaryIndigo.withValues(alpha: 0.15),
          offset: const Offset(0, 8),
          blurRadius: 18,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ];

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  void _scrollListUp() {
    if (_listScrollController.hasClients) {
      final currentPos = _listScrollController.offset;
      _listScrollController.animateTo(
        (currentPos - 60)
            .clamp(0.0, _listScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollListDown() {
    if (_listScrollController.hasClients) {
      final currentPos = _listScrollController.offset;
      _listScrollController.animateTo(
        (currentPos + 60)
            .clamp(0.0, _listScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // FUNGSI NAMBAH BARIS
  void _addRow() {
    setState(() {
      tableData.add(GridRowData()); // Nambah baris kosong di akhir
    });
  }

  // FUNGSI HAPUS BARIS
  void _removeRow(int index) {
    setState(() {
      tableData.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(),
            const SizedBox(height: 20),
            _buildMainWorkspace(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. HEADER
  // ==========================================
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
        boxShadow: _strongShadow,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: _buildModernFieldRow(
              "Format Name",
              initial: "Zip Code After City",
              labelWidth: 100,
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }

  // ==========================================
  // 2. MAIN WORKSPACE
  // ==========================================
  Widget _buildMainWorkspace() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + Tombol Add digabungin biar rapi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Address Layout Grid",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    TextButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text("Add Row",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryIndigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAddressGrid(),
                const SizedBox(height: 24),
                _buildPreviewBox(),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvailableFieldsList(),
                const SizedBox(height: 24),
                _buildFormattingOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: Address Grid ---
  Widget _buildAddressGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryIndigo, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: primaryIndigo,
              child: const Row(
                children: [
                  SizedBox(
                      width: 35,
                      child: Text("#",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white))),
                  Expanded(
                      child: Text("Col 1",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white))),
                  Expanded(
                      child: Text("Col 2",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white))),
                  Expanded(
                      child: Text("Col 3",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white))),
                  Expanded(
                      child: Text("Col 4",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white))),
                  SizedBox(width: 40), // Space buat tombol delete
                ],
              ),
            ),
            // LOOPING DINAMIS BACA DARI STATE tableData
            if (tableData.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                    child: Text("No layout added. Click 'Add Row' to start.",
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic))),
              )
            else
              ...tableData.asMap().entries.map((entry) {
                int index = entry.key;
                GridRowData rowData = entry.value;
                bool isLast = index == tableData.length - 1;
                // Baris pertama kuning aja buat contoh "Highlight"
                bool isHighlight = index == 0;

                return _buildGridRow(
                  (index + 1).toString(),
                  index, // Kirim index buat dihapus
                  col1: rowData.col1,
                  col2: rowData.col2,
                  col3: rowData.col3,
                  col4: rowData.col4,
                  isHighlight: isHighlight,
                  isLast: isLast,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow(String rowIndex, int listIndex,
      {String col1 = "",
      String col2 = "",
      String col3 = "",
      String col4 = "",
      bool isHighlight = false,
      bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFFFFDE7) : Colors.white,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: primaryIndigo.withValues(alpha: 0.2), width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 35,
              child: Text(rowIndex,
                  style: TextStyle(
                      color: secondarySlate,
                      fontSize: 13,
                      fontWeight: FontWeight.bold))),
          // Sekarang pake TextField tipis biar datanya bisa diedit beneran
          Expanded(
              child: _buildInvisibleTextField(
                  col1, (val) => tableData[listIndex].col1 = val)),
          Expanded(
              child: _buildInvisibleTextField(
                  col2, (val) => tableData[listIndex].col2 = val)),
          Expanded(
              child: _buildInvisibleTextField(
                  col3, (val) => tableData[listIndex].col3 = val)),
          Expanded(
              child: _buildInvisibleTextField(
                  col4, (val) => tableData[listIndex].col4 = val)),
          // Tombol Hapus Baris (X Merah)
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => _removeRow(listIndex),
              icon: Icon(Icons.remove_circle_outline,
                  color: Colors.red.shade400, size: 18),
              tooltip: "Remove Row",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          )
        ],
      ),
    );
  }

  // Textfield tipis buat di dalem grid biar bisa diketik
  Widget _buildInvisibleTextField(
      String initialValue, Function(String) onChanged) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // --- SUB-WIDGET: Preview Box ---
  Widget _buildPreviewBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
        boxShadow: _strongShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded,
                  size: 16, color: Colors.red.shade600),
              const SizedBox(width: 6),
              Text("Preview:",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade600,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Lombard",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text("San Francisco 80300",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700)),
          const Text("USA",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: Available Fields List ---
  Widget _buildAvailableFieldsList() {
    final fields = [
      "Street",
      "City",
      "Zip Code",
      "County",
      "State",
      "Country",
      "Block",
      "Building",
      "Floor"
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: primaryIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                  onPressed: _scrollListUp,
                  icon: Icon(Icons.arrow_upward_rounded,
                      color: primaryIndigo, size: 20)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: primaryIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                  onPressed: _scrollListDown,
                  icon: Icon(Icons.arrow_downward_rounded,
                      color: primaryIndigo, size: 20)),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
              boxShadow: _strongShadow,
            ),
            child: ListView.builder(
              controller: _listScrollController,
              itemCount: fields.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: primaryIndigo.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: primaryIndigo.withValues(alpha: 0.2))),
                  child: Text(
                    fields[index],
                    style: TextStyle(
                        fontSize: 13,
                        color: primaryIndigo,
                        fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- SUB-WIDGET: Formatting Options ---
  Widget _buildFormattingOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
        boxShadow: _strongShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Text Formatting",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryIndigo)),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: primaryIndigo.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  _buildCustomRadio("None"),
                  _buildCustomRadio("Capitalize"),
                  _buildCustomRadio("Upper Case"),
                  _buildCustomRadio("Lower Case"),
                ],
              )),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: primaryIndigo.withValues(alpha: 0.2))),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _isDescriptionChecked,
                  activeColor: primaryIndigo,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(
                      color: primaryIndigo.withValues(alpha: 0.5), width: 1.5),
                  onChanged: (val) {
                    setState(() => _isDescriptionChecked = val!);
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text("Description",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRadio(String title) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Radio<String>(
            value: title,
            groupValue: _selectedTextFormat,
            activeColor: primaryIndigo,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (val) {
              setState(() {
                _selectedTextFormat = val!;
              });
            },
          ),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _selectedTextFormat == title
                      ? primaryIndigo
                      : Colors.black87)),
        ],
      ),
    );
  }

  // ==========================================
  // 3. FOOTER BUTTONS
  // ==========================================
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // TOMBOL OK (IJO)
          _buildActionButton("OK", const Color(0xFF10B981), Colors.white),
          const SizedBox(width: 12),
          // TOMBOL CANCEL (MERAH)
          _buildActionButton("Cancel", const Color(0xFFEF4444), Colors.white),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor) {
    return SizedBox(
      height: 38,
      width: 100,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildModernFieldRow(String label,
      {String initial = "", double labelWidth = 120}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: secondarySlate,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _inputRadius,
              boxShadow: _strongShadow,
              border: Border.all(
                  color: primaryIndigo.withValues(alpha: 0.4), width: 1.5),
            ),
            child: TextField(
              controller: TextEditingController(text: initial),
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
