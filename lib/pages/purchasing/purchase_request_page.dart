import 'package:flutter/material.dart';

class PurchaseRequestPage extends StatefulWidget {
  const PurchaseRequestPage({super.key});

  @override
  State<PurchaseRequestPage> createState() => _PurchaseRequestPageState();
}

class _PurchaseRequestPageState extends State<PurchaseRequestPage> {
  // --- COLORS ---
  final Color bgPage = const Color(0xFFF3F4F6);
  final Color labelColor = const Color(0xFF5A6A85);
  final Color inputBorder = const Color(0xFFDFE5EF);
  final Color textDark = const Color(0xFF2A3547);
  final Color primaryIndigo = const Color(0xFF4F46E5);

  // --- CONTROLLERS ---
  final TextEditingController _reqNameCtrl = TextEditingController();
  final TextEditingController _seriesCtrl = TextEditingController();
  final TextEditingController _docNumCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();
  final TextEditingController _postDateCtrl = TextEditingController();
  final TextEditingController _validDateCtrl = TextEditingController();
  final TextEditingController _docDateCtrl = TextEditingController();
  final TextEditingController _reqDateCtrl = TextEditingController();

  // --- STATE VARIABLES ---
  String _requesterType = "User";
  String _requesterValue = "";
  String? _branch;
  String? _dept;
  bool _sendEmail = false;

  // Dummy Search Data
  final List<String> _requesterList = [
    "Ahmad Dahlan", "Budi Santoso", "Citra Kirana", "Dewi Sartika", "Eko Patrio"
  ];

  // --- SEARCH METHOD ---
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = "";
        List<String> filteredList = _requesterList;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text("Select Requester", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 350, height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Search...", prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchQuery = value.toLowerCase();
                          filteredList = _requesterList.where((name) => name.toLowerCase().contains(searchQuery)).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredList.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) => ListTile(
                          title: Text(filteredList[i], style: TextStyle(fontSize: 13, color: textDark)),
                          onTap: () {
                            setState(() => _reqNameCtrl.text = filteredList[i]);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Colors.red)))],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MAIN BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah Tab
      child: Scaffold(
        backgroundColor: bgPage,
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                // 1. HEADER
                _buildModernHeader(),
                const SizedBox(height: 25),
                
                // 2. TABS & CONTENT
                _buildTabSection(), 
                const SizedBox(height: 25),
                
                // 3. FOOTER (UPDATED)
                _buildModernFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. WIDGET: MODERN HEADER
  // ==========================================
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KIRI
          Expanded(
            child: Column(
              children: [
                _buildComboInput("Requester", _requesterType, ["User", "Emp"], _requesterValue),
                const SizedBox(height: 10),
                _buildTextInput("Req. Name", _reqNameCtrl, icon: Icons.search, onTap: _showSearchDialog),
                const SizedBox(height: 10),
                _buildDropdownInput("Branch", _branch, ["Main", "SBY", "JKT"], (v) => setState(() => _branch = v)),
                const SizedBox(height: 10),
                _buildDropdownInput("Department", _dept, ["Produksi Orbit", "IT"], (v) => setState(() => _dept = v)),
                const SizedBox(height: 12),
                Row(children: [
                  const SizedBox(width: 110),
                  SizedBox(height: 24, width: 24, child: Checkbox(value: _sendEmail, onChanged: (v) => setState(() => _sendEmail = v!), activeColor: primaryIndigo, side: BorderSide(color: labelColor))),
                  const SizedBox(width: 8),
                  Text("Send E-Mail if PO Added", style: TextStyle(fontSize: 10, color: labelColor)),
                ]),
                const SizedBox(height: 12),
                _buildTextInput("E-Mail", TextEditingController(), isEnabled: false),
              ],
            ),
          ),
          const SizedBox(width: 40),
          // KANAN
          Expanded(
            child: Column(
              children: [
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
    );
  }

  // ==========================================
  // 2. WIDGET: TAB SECTION
  // ==========================================
  Widget _buildTabSection() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Header Tab Ungu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: primaryIndigo,
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              labelColor: primaryIndigo,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: "Contents"),
                Tab(text: "Attachments"),
              ],
            ),
          ),
          
          // Isi Content Tab
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                // Tab 1: Contents
                const Center(
                  child: Text("Contents Table Here", style: TextStyle(color: Colors.grey)),
                ),
                // Tab 2: Attachments
                const Center(
                  child: Text("File Uploads Here", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. WIDGET: MODERN FOOTER (SESUAI GAMBAR)
  // ==========================================
  Widget _buildModernFooter() {
    return Column(
      children: [
        // --- BAGIAN 1: FORM DATA (Owner, Remarks, Totals) ---
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KOLOM KIRI (Owner & Remarks)
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildDropdownInput("Owner", null, ["- No Owner -"], (v){}),
                    const SizedBox(height: 12),
                    
                    // CUSTOM REMARKS (Text Area)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 110, child: Text("Remarks", style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600))),
                        Expanded(
                          child: Container(
                            height: 80, // Tinggi untuk multiline
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: inputBorder), borderRadius: BorderRadius.circular(4)),
                            child: const TextField(
                              maxLines: 5, 
                              style: TextStyle(fontSize: 11, color: Color(0xFF2A3547)),
                              decoration: InputDecoration.collapsed(hintText: ""),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(width: 40),
              
              // KOLOM KANAN (Totals)
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildTextInput("Total Before Discount", TextEditingController(), isEnabled: false),
                    const SizedBox(height: 10),
                    // Freight
                    _buildTextInput("Freight", TextEditingController()), 
                    const SizedBox(height: 10),
                    _buildTextInput("Tax", TextEditingController(), isEnabled: false),
                    const SizedBox(height: 10),
                    const Divider(),
                    _buildTextInput("Total Payment Due", TextEditingController(text: "IDR 0.00"), isEnabled: false),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- BAGIAN 2: TOMBOL WARNA-WARNI ---
        Row(
          children: [
            // TOMBOL KIRI
            // 1. ADD (BIRU INDIGO)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5), // Indigo
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            
            // 2. CANCEL (MERAH - SEPERTI GAMBAR DELETE)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), // Red
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const Spacer(), 

            // TOMBOL KANAN
            // 3. COPY FROM (BIRU MUDA)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Blue
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Copy From", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            
            // 4. COPY TO (ORANYE)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B), // Orange
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Copy To", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildTextInput(String label, TextEditingController ctrl, {bool isEnabled = true, IconData? icon, VoidCallback? onTap}) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600))),
        Expanded(
          child: GestureDetector(
            onTap: isEnabled ? onTap : null,
            child: Container(
              height: 30,
              decoration: BoxDecoration(color: isEnabled ? Colors.white : const Color(0xFFF8F9FA), border: Border.all(color: inputBorder), borderRadius: BorderRadius.circular(4)),
              child: TextField(
                controller: ctrl, readOnly: onTap != null || !isEnabled, enabled: isEnabled, onTap: onTap,
                style: TextStyle(fontSize: 11, color: textDark), textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), suffixIcon: icon != null ? Icon(icon, size: 14, color: Colors.grey) : null),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInput(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600))),
        Expanded(
          child: Container(
            height: 30, padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: inputBorder), borderRadius: BorderRadius.circular(4)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value, isDense: true, hint: const Text(""), icon: const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey), style: TextStyle(fontSize: 11, color: textDark),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComboInput(String label, String dropVal, List<String> dropItems, String textVal) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600))),
        Container(
          height: 30, width: 70, padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: inputBorder), borderRadius: const BorderRadius.horizontal(left: Radius.circular(4))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropVal, isDense: true, style: TextStyle(fontSize: 11, color: textDark, fontWeight: FontWeight.bold),
              items: dropItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) {},
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30, decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: inputBorder), bottom: BorderSide(color: inputBorder), right: BorderSide(color: inputBorder)), borderRadius: const BorderRadius.horizontal(right: Radius.circular(4))),
            child: TextFormField(initialValue: textVal, style: TextStyle(fontSize: 11, color: textDark), textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0))),
          ),
        ),
      ],
    );
  }

  Widget _buildSeriesInput(String label, TextEditingController seriesCtrl, TextEditingController numCtrl) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600))),
        Expanded(
          child: Container(
            height: 30, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: inputBorder), borderRadius: BorderRadius.circular(4)),
            child: TextField(controller: seriesCtrl, style: TextStyle(fontSize: 11, color: textDark), textAlign: TextAlign.center, textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 30, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: inputBorder), borderRadius: BorderRadius.circular(4)),
            child: TextField(controller: numCtrl, style: TextStyle(fontSize: 11, color: textDark, fontWeight: FontWeight.bold), textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0))),
          ),
        ),
      ],
    );
  }
}