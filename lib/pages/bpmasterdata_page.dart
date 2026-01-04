import 'package:flutter/material.dart';

class BpMasterDataPage extends StatefulWidget {
  const BpMasterDataPage({super.key});

  @override
  State<BpMasterDataPage> createState() => _BpMasterDataPageState();
}

class _BpMasterDataPageState extends State<BpMasterDataPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkStates = {}; 

  
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);
  final Color secondarySlate = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(key, () => TextEditingController(text: initial));
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) { ctrl.dispose(); }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildTabNavigation(),
            _buildTabContentArea(),
            // --- BAGIAN STATUS BAWAH (ACTIVE/INACTIVE) ---
            _buildBottomStatusArea(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER SECTION ---
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildModernNoFieldRow("Code", "bp_series", ["Manual", "System"], "bp_code_val", initialNo: "VJS-481"),
                _buildModernFieldRow("Name", "bp_name", initial: "Dinamika Polimerindo, PT"),
                _buildModernFieldRow("Foreign Name", "bp_f_name"),
                _buildSmallDropdownRowModern("Group", "bp_group", ["General", "Suppliers", "Customers"]),
                _buildSmallDropdownRowModern("Currency", "bp_curr", ["Indonesian Rupiah", "USD", "EUR"]),
                _buildModernFieldRow("Federal Tax ID", "bp_tax_id"),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSmallDropdownRowModern("BP Currency", "bp_curr_view", ["All Currencies"]),
                _buildSummaryRowWithArrow("Account Balance", "0.00"),
                _buildSummaryRowWithArrow("Goods Receipt POs", "0.00"),
                _buildSummaryRowWithArrow("Purchase Orders", "0.00"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. TAB NAVIGATION ---
  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), border: Border.all(color: borderGrey)),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: primaryIndigo,
        unselectedLabelColor: secondarySlate,
        indicatorColor: primaryIndigo,
        tabs: const [
          Tab(text: "General"), Tab(text: "Contact Persons"), Tab(text: "Addresses"),
          Tab(text: "Payment Terms"), Tab(text: "Payment Run"), Tab(text: "Accounting"),
          Tab(text: "Properties"), Tab(text: "Remarks"), Tab(text: "Attachments"),
        ],
      ),
    );
  }

  // --- 3. TAB CONTENT AREA ---
  Widget _buildTabContentArea() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          const Center(child: Text("Contact Persons Data")),
          const Center(child: Text("Address Details")),
          const Center(child: Text("Payment Terms Configuration")),
          const Center(child: Text("Payment Run Settings")),
          const Center(child: Text("Accounting Integration")),
          const Center(child: Text("BP Properties")),
          const Center(child: Text("Internal Remarks")),
          const Center(child: Text("Document Attachments")),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildModernFieldRow("Tel 1", "gen_tel1", initial: "0215806203"),
                _buildModernFieldRow("Tel 2", "gen_tel2"),
                _buildModernFieldRow("Mobile Phone", "gen_hp"),
                _buildModernFieldRow("Fax", "gen_fax"),
                _buildModernFieldRow("E-Mail", "gen_email"),
                _buildModernFieldRow("Web Site", "gen_web"),
                _buildSmallDropdownRowModern("Shipping Type", "gen_ship", [""]),
                _buildModernFieldRow("Password", "gen_pass"),
                _buildModernFieldRow("BP Project", "gen_proj"),
                _buildSmallDropdownRowModern("Industry", "gen_ind", [""]),
                _buildSmallDropdownRowModern("BP Type", "gen_type", ["Company", "Private"]),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                _buildModernFieldRow("Contact Person", "gen_cp"),
                _buildModernFieldRow("Passport", "gen_passp"),
                _buildModernFieldRow("No. NIK", "gen_nik"),
                const SizedBox(height: 12),
                _buildModernFieldRow("Remarks / Kategori Vendor", "gen_rem_kat", isTextArea: true),
                _buildSmallDropdownRowModern("Buyer", "gen_buyer", ["-No Sales Employee-"]),
                _buildSmallDropdownRowModern("Territory", "gen_territory", [""]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. STATUS AREA (ACTIVE/INACTIVE & ID KE 2) ---
  Widget _buildBottomStatusArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatusRadio("Active"),
                    const SizedBox(width: 20),
                    const Text("From", style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 8),
                    _buildSmallBox("act_from", width: 80),
                    const SizedBox(width: 8),
                    const Text("To", style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 8),
                    _buildSmallBox("act_to", width: 80),
                    const SizedBox(width: 8),
                    const Text("Remarks", style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSmallBox("act_rem")),
                  ],
                ),
                _buildStatusRadio("Inactive"),
                _buildStatusRadio("Advanced"),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildModernFieldRow("ID ke 2", "id_ke_2"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                      value: _checkStates["block_marketing"] ?? false,
                      onChanged: (v) => setState(() => _checkStates["block_marketing"] = v!),
                    ),
                    const Text("Block Sending Marketing Content", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStatusRadio(String label) {
    return Row(
      children: [
        SizedBox(
          width: 28, height: 28,
          child: Radio(
            value: label,
            groupValue: _dropdownValues["status_main"] ?? "Active",
            onChanged: (v) => setState(() => _dropdownValues["status_main"] = v.toString()),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget _buildSmallBox(String key, {double? width}) {
    return Container(
      width: width, height: 24,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderGrey)),
      child: TextField(
        controller: _getCtrl(key),
        style: const TextStyle(fontSize: 11),
        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6)),
      ),
    );
  }

  Widget _buildModernNoFieldRow(String label, String dropdownKey, List<String> series, String textKey, {String initialNo = ""}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(fontSize: 12, color: secondarySlate))),
          Container(
            width: 80, height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: bgSlate, border: Border.all(color: borderGrey), borderRadius: const BorderRadius.horizontal(left: Radius.circular(6))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues[dropdownKey] ?? series.first,
                isDense: true, style: const TextStyle(fontSize: 11),
                onChanged: (v) => setState(() => _dropdownValues[dropdownKey] = v!),
                items: series.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 30, decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: borderGrey), bottom: BorderSide(color: borderGrey))),
              child: TextField(controller: _getCtrl(textKey, initial: initialNo), style: const TextStyle(fontSize: 12), decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8))),
            ),
          ),
          Container(
            width: 90, height: 30,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderGrey), borderRadius: const BorderRadius.horizontal(right: Radius.circular(6))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues["bp_type_header"] ?? "Vendor",
                isDense: true, style: const TextStyle(fontSize: 11, color: Colors.black),
                onChanged: (v) => setState(() => _dropdownValues["bp_type_header"] = v!),
                items: ["Vendor", "Customer"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFieldRow(String label, String key, {bool isTextArea = false, String initial = ""}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(fontSize: 12, color: secondarySlate))),
          Expanded(
            child: Container(
              height: isTextArea ? 80 : 30, padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: bgSlate, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderGrey)),
              child: TextField(controller: _getCtrl(key, initial: initial), maxLines: isTextArea ? 3 : 1, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 6))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDropdownRowModern(String label, String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(fontSize: 12, color: secondarySlate))),
          Expanded(
            child: Container(
              height: 30, padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderGrey), borderRadius: BorderRadius.circular(6)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[key], isDense: true, style: const TextStyle(fontSize: 12),
                  onChanged: (v) => setState(() => _dropdownValues[key] = v!),
                  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowWithArrow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Icon(Icons.play_arrow, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Container(width: 100, height: 24, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: bgSlate, border: Border.all(color: borderGrey), borderRadius: BorderRadius.circular(4)), child: Text(val, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Add / Update")),
        const SizedBox(width: 12),
        OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Cancel")),
      ],
    );
  }
}