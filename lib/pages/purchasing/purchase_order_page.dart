import 'package:flutter/material.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final Color bgPage = const Color(0xFFF3F4F6);
  final Color labelColor = const Color(0xFF5A6A85);
  final Color inputBorder = const Color(0xFFDFE5EF);
  final Color textDark = const Color(0xFF2A3547);
  final Color primaryIndigo = const Color(0xFF4F46E5);

  final TextEditingController _reqNameCtrl = TextEditingController();
  final TextEditingController _seriesCtrl = TextEditingController();
  final TextEditingController _docNumCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();

  final TextEditingController _postDateCtrl = TextEditingController();
  final TextEditingController _validDateCtrl = TextEditingController();
  final TextEditingController _docDateCtrl = TextEditingController();
  final TextEditingController _reqDateCtrl = TextEditingController();

  // --- DROPDOWN STATE ---
  String _requesterType = "User"; // Tetap User
  String _requesterValue = "";

  String? _branch;
  String? _dept;

  bool _sendEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- KOLOM KIRI ---
                Expanded(
                  child: Column(
                    children: [
                      _buildComboInput("Requester", _requesterType, [
                        "User",
                        "Emp",
                      ], _requesterValue),
                      const SizedBox(height: 10),

                      _buildTextInput(
                        "Req. Name",
                        _reqNameCtrl,
                        icon: Icons.search,
                      ),
                      const SizedBox(height: 10),

                      _buildDropdownInput("Branch", _branch, [
                        "Main",
                        "SBY",
                        "JKT",
                      ]),
                      const SizedBox(height: 10),

                      _buildDropdownInput("Department", _dept, [
                        "Produksi Orbit",
                        "IT",
                      ]),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 110),
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _sendEmail,
                              onChanged: (v) => setState(() => _sendEmail = v!),
                              activeColor: Color(0xFF4F46E5),
                              side: BorderSide(color: labelColor, width: 1),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Send E-Mail if PO Added",
                            style: TextStyle(fontSize: 10, color: labelColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildTextInput(
                        "E-Mail",
                        TextEditingController(),
                        isEnabled: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // --- KOLOM KANAN ---
                Expanded(
                  child: Column(
                    children: [
                      // No. -> SEKARANG TERBAGI DUA SAMA BESAR (Setengah-Setengah)
                      _buildSeriesInput("No.", _seriesCtrl, _docNumCtrl),
                      const SizedBox(height: 10),

                      _buildTextInput("Status", _statusCtrl, isEnabled: false),
                      const SizedBox(height: 10),

                      _buildTextInput("Posting Date", _postDateCtrl),
                      const SizedBox(height: 10),
                      _buildTextInput("Valid Until", _validDateCtrl),
                      const SizedBox(height: 10),
                      _buildTextInput("Doc. Date", _docDateCtrl),
                      const SizedBox(height: 10),
                      _buildTextInput("Req. Date", _reqDateCtrl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTextInput(
    String label,
    TextEditingController ctrl, {
    bool isEnabled = true,
    IconData? icon,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : const Color(0xFFF8F9FA),
              border: Border.all(color: inputBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: ctrl,
              enabled: isEnabled,
              style: TextStyle(fontSize: 11, color: textDark),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                suffixIcon: icon != null
                    ? Icon(icon, size: 14, color: Colors.grey)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInput(String label, String? value, List<String> items) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: inputBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                hint: const Text(""),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Colors.grey,
                ),
                style: TextStyle(fontSize: 11, color: textDark),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _dept = v),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComboInput(
    String label,
    String dropVal,
    List<String> dropItems,
    String textVal,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 30,
          width: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            border: Border.all(color: inputBorder),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(4),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropVal,
              isDense: true,
              style: TextStyle(
                fontSize: 11,
                color: textDark,
                fontWeight: FontWeight.bold,
              ),
              items: dropItems
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: inputBorder),
                bottom: BorderSide(color: inputBorder),
                right: BorderSide(color: inputBorder),
              ),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
            child: TextFormField(
              initialValue: textVal,
              style: TextStyle(fontSize: 11, color: textDark),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET SERIES (DIBAGI 2 SAMA BESAR) ---
  Widget _buildSeriesInput(
    String label,
    TextEditingController seriesCtrl,
    TextEditingController numCtrl,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // INPUT SERIES (Setengah) - Pakai Expanded
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: inputBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: seriesCtrl,
              style: TextStyle(fontSize: 11, color: textDark),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),

        const SizedBox(width: 6), // Jarak tengah
        // INPUT NOMOR (Setengah) - Pakai Expanded juga
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: inputBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: numCtrl,
              style: TextStyle(
                fontSize: 11,
                color: textDark,
                fontWeight: FontWeight.bold,
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
