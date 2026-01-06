import 'package:flutter/material.dart';

class BpMasterDataPage extends StatefulWidget {
  const BpMasterDataPage({super.key});

  @override
  State<BpMasterDataPage> createState() => _BpMasterDataPageState();
}

class _BpMasterDataPageState extends State<BpMasterDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkStates = {};

  int _contactRowCount = 10;
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color borderGrey = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
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

            const SizedBox(height: 20),
            _buildActionArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountingTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            width: 300,
            alignment: Alignment.center,
            child: const TabBar(
              isScrollable: false,
              labelColor: Color.fromARGB(255, 72, 0, 255),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color.fromRGBO(74, 47, 255, 1),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(child: Text("General", style: TextStyle(fontSize: 12))),
                Tab(child: Text("Tax", style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: TabBarView(
              children: [
                _buildAccountingGeneralSubTab(),
                _buildAccountingTaxSubTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountingGeneralSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField("Consolidating BP", "acc_con_bp", []),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 140),
              _buildStatusRadioSmall("Payment Consolidation", "acc_con_type"),
              const SizedBox(width: 24),
              _buildStatusRadioSmall("Delivery Consolidation", "acc_con_type"),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(
                width: 140,
                child: Text("Control Accounts", style: TextStyle(fontSize: 12)),
              ),
              _buildSmallIconButton(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 8),
          _buildAccountFieldRow(
            "Accounts Payable",
            "acc_payable",
            "2113102-0-0-00",
            "Hutang Dagang (Lokal)",
          ),
          _buildAccountFieldRow(
            "Down Payment Clearing",
            "acc_dp_clear",
            "1171101-0-0-00",
            "Uang Muka Pembelian",
          ),
          _buildAccountFieldRow(
            "Down Payment Interim",
            "acc_dp_interim",
            "1171101-0-0-00",
            "Uang Muka Pembelian",
          ),
          const SizedBox(height: 24),
          _buildSearchField("Connected Customer", "acc_conn_cust", []),
          const SizedBox(height: 24),
          _buildModernFieldRow("Planning Group", "acc_plan_grp"),
          const SizedBox(height: 32),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _checkStates["acc_affiliate"] ?? false,
                  onChanged: (v) =>
                      setState(() => _checkStates["acc_affiliate"] = v!),
                ),
              ),
              const SizedBox(width: 8),
              const Text("Affiliate", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountFieldRow(
    String label,
    String key,
    String accCode,
    String accName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Icon(Icons.play_arrow, size: 14, color: Colors.orange.shade300),
          const SizedBox(width: 4),
          Container(
            width: 110,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _getCtrl("${key}_code", initial: accCode),
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                border: Border.all(color: borderGrey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _getCtrl("${key}_name", initial: accName),
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text("=", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusRadioSmall(String label, String groupKey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: _dropdownValues[groupKey] ?? "Payment Consolidation",
          onChanged: (v) => setState(() => _dropdownValues[groupKey] = v!),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildAccountingTaxSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern("Tax Status", "tax_status", [
                      "Liable",
                      "Exempt",
                    ]),
                    _buildAccountFieldRow("Tax Group", "tax_group", "", ""),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(
                          width: 130,
                          child: Text(
                            "WTax Codes Allowed",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        _buildSmallIconButton(Icons.more_horiz),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 130),
                      child: Column(
                        children: [
                          _buildStatusRadioSmall("Accrual", "wtax_type"),
                          _buildStatusRadioSmall("Cash", "wtax_type"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _checkStates["tax_subject_wht"] ?? true,
                          onChanged: (v) => setState(
                            () => _checkStates["tax_subject_wht"] = v!,
                          ),
                        ),
                        const Text(
                          "Subject to Withholding Tax",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildModernFieldRow("Certificate No.", "tax_cert_no"),
                    _buildModernFieldRow("Expiration Date", "tax_exp_date"),
                    _buildModernFieldRow("NI Number", "tax_ni_no"),
                    const SizedBox(height: 40),
                    _buildSmallDropdownRowModern(
                      "Type for WTax Rpt",
                      "tax_rpt_type",
                      ["Company", "Individual"],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            children: [
              Checkbox(
                value: _checkStates["tax_deferred"] ?? false,
                onChanged: (v) =>
                    setState(() => _checkStates["tax_deferred"] = v!),
              ),
              const Text("Deferred Tax", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 250,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderGrey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView(
                      children: [
                        _buildExpandableAddressItem("Pay to", isSelected: true),
                        _buildExpandableAddressItem(
                          "Ship To",
                          isSelected: true,
                        ), // Sesuai pilihan di gambar
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE68A), // Kuning SAP
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "Set as Default",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildModernFieldRow(
                    "Address ID",
                    "addr_id",
                    initial: "Ship To",
                  ),
                  _buildModernFieldRow("Address Name 2", "addr_name2"),
                  _buildModernFieldRow("Address Name 3", "addr_name3"),
                  _buildModernFieldRow("Street 1 (*Pajak)", "addr_street1"),
                  _buildModernFieldRow("Street 2 (*Pajak)", "addr_street2"),
                  _buildModernFieldRow("Street (*BI)", "addr_street_bi"),
                  _buildModernFieldRow("RT - RW (*BI)", "addr_rtrw"),
                  _buildModernFieldRow("Kelurahan (*BI)", "addr_kel"),
                  _buildModernFieldRow("Kecamatan (*BI)", "addr_kec"),
                  _buildSmallDropdownRowModern("State (*BI)", "addr_state", [
                    "Jawa Timur",
                    "DKI Jakarta",
                  ]),
                  _buildSearchField("City (*BI)", "addr_city_bi", [
                    "Surabaya",
                    "Jakarta",
                  ]),
                  _buildModernFieldRow("Zip Code (*BI)", "addr_zip"),
                  _buildSmallDropdownRowModern(
                    "Country (*Pajak/*BI)",
                    "addr_country",
                    ["Indonesia"],
                  ),
                  _buildModernFieldRow("ID TKU", "addr_tku", initial: "000000"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSubRow(String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 30,
        padding: const EdgeInsets.only(left: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: borderGrey, width: 0.5)),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ),
    );
  }

  void _resetAddressForm() {
    setState(() {
      _controllers['addr_id']?.clear();
      _controllers['addr_name2']?.clear();
      _controllers['addr_name3']?.clear();
      _controllers['addr_street1']?.clear();
      _controllers['addr_street2']?.clear();
      _controllers['addr_street_bi']?.clear();
      _controllers['addr_rtrw']?.clear();
      _controllers['addr_kel']?.clear();
      _controllers['addr_kec']?.clear();
      _controllers['addr_zip']?.clear();
      _controllers['addr_tku']?.text = "000000";

      _buildSmallDropdownRowModern("State (*BI)", "addr_state", [
        "",
        "Jawa Timur",
        "DKI Jakarta",
      ]);
    });
  }

  Widget _buildExpandableAddressItem(String label, {bool isSelected = false}) {
    bool _isExpanded = isSelected;

    return StatefulBuilder(
      builder: (context, setTileState) {
        return Column(
          children: [
            InkWell(
              onTap: () => setTileState(() => _isExpanded = !_isExpanded),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? const Color(0xFFFFF9C4)
                      : Colors.transparent, // Warna SAP
                  border: Border(
                    bottom: BorderSide(color: borderGrey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: _isExpanded ? 0 : -0.25, // Animasi panah halus
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                constraints: _isExpanded
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 0),
                child: Column(
                  children: [
                    // --- HUBUNGKAN DISINI ---
                    _buildAddressSubRow(
                      "Define New",
                      onTap: () {
                        _resetAddressForm(); // Kosongkan form kanan
                        debugPrint("Define New clicked: Form Reset");
                      },
                    ),
                    _buildAddressSubRow(""),
                    _buildAddressSubRow(""),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }




Widget _buildPaymentRunTab() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SISI KIRI: HOUSE BANK ---
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("House Bank", 
                        style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      const SizedBox(height: 10),
                      _buildSmallDropdownRowModern("Country", "bank_country", ["Indonesia", "Singapore"]),
                      _buildSmallDropdownRowModern("Bank", "bank_name", ["Bank OCBC NISP", "BCA", "Mandiri"]),
                      _buildSmallDropdownRowModern("Account", "bank_account", ["528.010.00197-2"]),
                      _buildModernFieldRow("Branch", "bank_branch"),
                      _buildSmallDropdownRowModern("IBAN", "bank_iban", [""]),
                      _buildModernFieldRow("BIC/SWIFT Code", "bank_swift"),
                      _buildModernFieldRow("Control No.", "bank_control_no"),
                      const SizedBox(height: 10),
                      _buildModernFieldRow("DME Identification", "bank_dme"), 
                      _buildModernFieldRow("Instruction Key", "bank_instruction"),
                      _buildModernFieldRow("Reference Details", "bank_ref"),
                      _buildPaymentCheckbox("Payment Block", "bank_pay_block"),
                      _buildPaymentCheckbox("Single Payment", "bank_single_pay"),
                      const SizedBox(height: 20),
                      _buildSmallDropdownRowModern("Bank Charges Allocation Code", "bank_charges_code", [""]),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 40),

              // --- SISI KANAN: PAYMENT METHODS TABLE ---
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Payment Methods", 
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    const SizedBox(height: 10),
                    Expanded(child: _buildPaymentMethodsTable()),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildYellowButtonSmall("Clear Default"),
                        _buildYellowButtonSmall("Set as Default"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildPaymentMethodsTable() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: borderGrey),
      color: const Color(0xFFF2F2F2),
    ),
    child: ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header Tetap
          return Container(
            height: 25,
            color: const Color(0xFFE5E7EB),
            child: Row(
              children: [
                _simpleCell("#", 30, isHeader: true),
                _simpleCell("Code", 80, isHeader: true),
                _simpleCell("Description", 200, isHeader: true),
                _simpleCell("Include", 60, isHeader: true),
                _simpleCell("Active", 60, isHeader: true),
              ],
            ),
          );
        }
        // Baris yang bisa diketik dengan Key unik
        return Container(
          height: 22,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderGrey, width: 0.5)),
          ),
          child: Row(
            children: [
              _simpleCell("$index", 30, isHeader: true), // Nomor urut teks saja
              _simpleCell("", 80, key: "pm_code_$index"),
              _simpleCell("", 200, key: "pm_desc_$index"),
              _buildSpecialInputCell(60, "pm_inc_$index"), // Kotak putih interaktif
              _buildSpecialInputCell(60, "pm_act_$index"), // Kotak putih interaktif
            ],
          ),
        );
      },
    ),
  );
}


// Cell khusus kotak putih yang bisa diketik (Garis Khusus)
Widget _buildSpecialInputCell(double width, String key) {
  return Container(
    width: width,
    height: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: borderGrey, width: 0.5)),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(color: borderGrey, width: 0.5),
      ),
      child: TextField(
        controller: _getCtrl(key),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ),
  );
}

// Cell standar yang bisa diketik
Widget _simpleCell(String text, double width, {bool isHeader = false, String? key}) {
  return Container(
    width: width,
    height: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      border: Border(right: BorderSide(color: borderGrey, width: 0.5)),
    ),
    alignment: Alignment.centerLeft,
    child: isHeader
        ? Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
        : TextField(
            controller: key != null ? _getCtrl(key) : null,
            style: const TextStyle(fontSize: 10),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
  );
}

Widget _buildPaymentCheckbox(String label, String key) {
  return Row(
    children: [
      SizedBox(
        height: 28, 
        width: 28,
        child: Checkbox(
          // Menggunakan _checkStates yang sudah ada di class kamu
          value: _checkStates[key] ?? false,
          onChanged: (v) => setState(() => _checkStates[key] = v!),
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

Widget _buildYellowButtonSmall(String label) {
  return ElevatedButton(
    onPressed: () {
      debugPrint("$label clicked");
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFDE68A), // Kuning SAP
      foregroundColor: Colors.black,
      minimumSize: const Size(120, 30),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.black38, width: 0.5),
      ),
    ),
    child: Text(label, style: const TextStyle(fontSize: 11)),
  );
}



  // --- SISA WIDGET BUILDER BAWAANMU (HEADER, GENERAL, CONTACTS, DLL) ---
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
                _buildModernNoFieldRow(
                  "Code",
                  "bp_series",
                  ["Manual", "System"],
                  "bp_code_val",
                  initialNo: "VJS-481",
                ),
                _buildModernFieldRow(
                  "Name",
                  "bp_name",
                  initial: "Dinamika Polimerindo, PT",
                ),
                _buildModernFieldRow("Foreign Name", "bp_f_name"),
                _buildSmallDropdownRowModern("Group", "bp_group", [
                  "General",
                  "Suppliers",
                  "Customers",
                ]),
                _buildSmallDropdownRowModern("Currency", "bp_curr", [
                  "Indonesian Rupiah",
                  "USD",
                  "EUR",
                ]),
                _buildModernFieldRow("Federal Tax ID", "bp_tax_id"),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSmallDropdownRowModern("BP Currency", "bp_curr_view", [
                  "All Currencies",
                ]),
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

  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: borderGrey),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: primaryIndigo,
        unselectedLabelColor: secondarySlate,
        indicatorColor: primaryIndigo,
        tabs: const [
          Tab(text: "General"),
          Tab(text: "Contact Persons"),
          Tab(text: "Addresses"),
          Tab(text: "Payment Terms"),
          Tab(text: "Payment Run"),
          Tab(text: "Accounting"),
          Tab(text: "Properties"),
          Tab(text: "Remarks"),
          Tab(text: "Attachments"),
        ],
      ),
    );
  }

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
          _buildContactPersonsTab(),
          _buildAddressesTab(),
          const Center(child: Text("Payment Terms Configuration")),
          _buildPaymentRunTab(),
          _buildAccountingTab(), // Memanggil tab accounting yang baru
          const Center(child: Text("BP Properties")),
          const Center(child: Text("Internal Remarks")),
          const Center(child: Text("Document Attachments")),
        ],
      ),
    );
  }

  // --- SISI WIDGET FIELD BUILDER (MODERN FIELD, SEARCH, DLL) ---
  Widget _buildModernNoFieldRow(
    String label,
    String dropdownKey,
    List<String> series,
    String textKey, {
    String initialNo = "",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Container(
            width: 100,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: bgSlate,
              border: Border.all(color: borderGrey),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(6),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues[dropdownKey] ?? series.first,
                isDense: true,
                style: const TextStyle(fontSize: 11),
                onChanged: (v) =>
                    setState(() => _dropdownValues[dropdownKey] = v!),
                items: series
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: borderGrey),
                  bottom: BorderSide(color: borderGrey),
                ),
              ),
              child: TextField(
                controller: _getCtrl(textKey, initial: initialNo),
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
          Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(6),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues["bp_type_header"] ?? "Vendor",
                isDense: true,
                isExpanded: true,
                style: const TextStyle(fontSize: 11, color: Colors.black),
                onChanged: (v) =>
                    setState(() => _dropdownValues["bp_type_header"] = v!),
                items: ["Vendor", "Customer"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(e),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDropdownRowModern(
    String label,
    String key,
    List<String> items,
  ) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Expanded(
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderGrey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[key],
                  isDense: true,
                  style: const TextStyle(fontSize: 12),
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

  Widget _buildSummaryRowWithArrow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Icon(Icons.play_arrow, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 24,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: bgSlate,
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(val, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Expanded(
            child: Container(
              height: isTextArea ? 80 : 30,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: bgSlate,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderGrey),
              ),
              child: TextField(
                controller: _getCtrl(key, initial: initial),
                maxLines: isTextArea ? 3 : 1,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(String label, String key, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // List awal untuk menampung hasil filter
                List<String> filteredOptions = List.from(options);

                final String? selected = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          // --- BAGIAN INPUT PENCARIAN ---
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select $label",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Search here...",
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                // Logic filter saat diketik
                                onChanged: (value) {
                                  setDialogState(() {
                                    filteredOptions = options
                                        .where(
                                          (opt) => opt.toLowerCase().contains(
                                            value.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                                  });
                                },
                              ),
                            ],
                          ),
                          // --- BAGIAN LIST HASIL ---
                          content: SizedBox(
                            width: 300,
                            height: 300,
                            child: filteredOptions.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No results found",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: filteredOptions.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                          filteredOptions[index],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        onTap: () => Navigator.pop(
                                          context,
                                          filteredOptions[index],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                if (selected != null) {
                  setState(() => _dropdownValues[key] = selected);
                }
              },
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderGrey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dropdownValues[key] ?? "Search...",
                        style: TextStyle(
                          fontSize: 12,
                          color: _dropdownValues[key] == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.search, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildModernFieldRow("Telp 1", "gen_telp1"),
                    _buildModernFieldRow("Telp 2", "gen_telp2"),
                    _buildModernFieldRow("Mobile Phone", "gen_hp"),
                    _buildModernFieldRow("Fax", "gen_fax"),
                    _buildModernFieldRow("E-Mail", "gen_email"),
                    _buildModernFieldRow("Web Site", "gen_web"),
                    _buildSmallDropdownRowModern("Shipping Type", "gen_ship", [
                      "",
                    ]),
                    _buildModernFieldRow("Password", "gen_pass"),
                    _buildModernFieldRow("BP Project", "gen_proj"),
                    _buildSmallDropdownRowModern("Industry", "gen_ind", [""]),
                    _buildSmallDropdownRowModern("BP Type", "gen_type", [
                      "Company",
                      "Private",
                    ]),
                    _buildSearchField("Export", "gen_export", ["", ""]),
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
                    _buildModernFieldRow(
                      "Remarks / Kategori Vendor",
                      "gen_rem_kat",
                      isTextArea: true,
                    ),
                    _buildSmallDropdownRowModern("Buyer", "gen_buyer", [
                      "-No Sales Employee-",
                    ]),
                    _buildSmallDropdownRowModern("Territory", "gen_territory", [
                      "",
                    ]),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomStatusArea(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomStatusArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      onChanged: (v) =>
                          setState(() => _checkStates["block_marketing"] = v!),
                    ),
                    const Text(
                      "Block Sending Marketing Content",
                      style: TextStyle(fontSize: 11),
                    ),
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
          width: 28,
          height: 28,
          child: Radio<String>(
            value: label,
            groupValue: _dropdownValues["status_main"] ?? "Active",
            onChanged: (v) =>
                setState(() => _dropdownValues["status_main"] = v.toString()),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSmallBox(String key, {double? width}) {
    return Container(
      width: width,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: _getCtrl(key),
        style: const TextStyle(fontSize: 11),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Memisahkan tombol aksi (kiri) dan menu (kanan)
        children: [
          Row(
            children: [
              // Tombol Add / Update
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryIndigo, // Menggunakan variabel warna class
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Add / Update",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              // Tombol Cancel warna Merah sesuai request
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Tombol Kuning "You Can Also" di sebelah kanan
          _buildYouCanAlsoMenu(),
        ],
      ),
    );
  }

  Widget _buildYouCanAlsoMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        debugPrint("Selected action: $value");
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 204, 0),
          border: Border.all(color: borderGrey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You Can Also",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, size: 20, color: secondarySlate),
          ],
        ),
      ),
      // Daftar pilihan menu saat diklik
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: "add_activity",
          child: Row(
            children: [
              Icon(Icons.event, size: 18, color: Colors.blue),
              SizedBox(width: 10),
              Text("Add Activity", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "add_document",
          child: Row(
            children: [
              Icon(Icons.note_add, size: 18, color: Colors.green),
              SizedBox(width: 10),
              Text("Add New Document", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "view_report",
          child: Row(
            children: [
              Icon(Icons.analytics, size: 18, color: Colors.orange),
              SizedBox(width: 10),
              Text("View BP Report", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactPersonsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 250,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderGrey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView(
                      children: List.generate(
                        _contactRowCount,
                        (index) => _buildContactListItem(
                          "cp_list_key_$index",
                          initial: index == 0 ? "Define New" : "",
                          isSelected: index == 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _contactRowCount++),
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text(
                          "Add",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color.fromARGB(255, 95, 37, 255),
                          ),
                          backgroundColor: Color.fromARGB(255, 95, 37, 255),
                          foregroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_contactRowCount > 1)
                            setState(() => _contactRowCount--);
                        },
                        icon: const Icon(Icons.remove, size: 14),
                        label: const Text(
                          "Remove",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          backgroundColor: Color.fromARGB(255, 255, 0, 0),
                          foregroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 32, 153, 180),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "Set as Default",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildModernFieldRow(
                    "Contact ID",
                    "cp_id",
                    initial: "Define New",
                  ),
                  _buildModernFieldRow("First Name", "cp_fname"),
                  _buildModernFieldRow("Middle Name", "cp_mname"),
                  _buildModernFieldRow("Last Name", "cp_lname"),
                  _buildModernFieldRow("Title", "cp_title"),
                  _buildModernFieldRow("Position", "cp_pos"),
                  _buildModernFieldRow("Address", "cp_address"),
                  _buildModernFieldRow("Telephone 1", "cp_tel1"),
                  _buildModernFieldRow("Telephone 2", "cp_tel2"),
                  _buildModernFieldRow("Mobile Phone", "cp_hp"),
                  _buildModernFieldRow("Fax", "cp_fax"),
                  _buildModernFieldRow("E-Mail", "cp_email"),
                  _buildModernFieldRow("E-Mail Group", "cp_email_grp"),
                  _buildModernFieldRow("Pager", "cp_pager"),
                  _buildModernFieldRow("Remarks 1", "cp_rem1"),
                  _buildModernFieldRow("Remarks 2", "cp_rem2"),
                  _buildModernFieldRow("Password", "cp_pass"),
                  _buildModernFieldRow("Country of Birth", "cp_country"),
                  _buildModernFieldRow("Date of Birth", "cp_dob"),
                  _buildModernFieldRow("Gender", "cp_gender"),
                  _buildModernFieldRow("Profession", "cp_prof"),
                  _buildModernFieldRow("City of Birth", "cp_city"),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildContactStatusArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactStatusArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRadio("Active"),
              _buildStatusRadio("Inactive"),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _checkStates["cp_block_marketing"] ?? false,
                onChanged: (v) =>
                    setState(() => _checkStates["cp_block_marketing"] = v!),
              ),
              const Text(
                "Block Sending Marketing Content",
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(width: 8),
              _buildSmallIconButton(Icons.more_horiz),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderGrey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildContactListItem(
    String key, {
    String initial = "",
    bool isSelected = false,
  }) {
    return Container(
      width: double.infinity,
      height: 30,
      decoration: BoxDecoration(
        color: isSelected ? primaryIndigo.withOpacity(0.1) : Colors.transparent,
        border: Border(bottom: BorderSide(color: borderGrey, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _getCtrl(key, initial: initial),
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        ),
      ),
    );
  }
}
