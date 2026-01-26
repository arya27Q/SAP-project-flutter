import 'package:flutter/material.dart';

class ItemMasterDataPage extends StatefulWidget {
  const ItemMasterDataPage({super.key});

  @override
  State<ItemMasterDataPage> createState() => _ItemMasterDataPageState();
}

class _ItemMasterDataPageState extends State<ItemMasterDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};

  int _contactRowCount = 10;
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color.fromARGB(255, 255, 255, 255);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color borderGrey = const Color.fromARGB(255, 208, 213, 220);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);

    // Default Checkbox values for Header Item Master Data
    _checkStates['is_inv_item'] = true;
    _checkStates['is_sales_item'] = true;
    _checkStates['is_purch_item'] = true;
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
            _buildTabSection(),
            const SizedBox(height: 20),
            _buildActionArea(),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION (UPDATED: ITEM MASTER DATA STYLE) ---
  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SISI KIRI (Item Info)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildModernNoFieldRow(
                  "Item No.",
                  "item_series",
                  ["Manual", "Primary"],
                  "item_code",
                  initialNo: "A00001",
                ),
                _buildModernFieldRow(
                  "Description",
                  "item_desc",
                  initial: "IBM Infoprint 1312",
                ),
                _buildModernFieldRow("Foreign Name", "item_frgn_name"),
                _buildSmallDropdownRowModern("Item Type", "item_type", [
                  "Items",
                  "Labor",
                  "Travel",
                ]),
                _buildSmallDropdownRowModern("Item Group", "item_group", [
                  "Printers",
                  "Servers",
                  "PC",
                ]),
                _buildSmallDropdownRowModern("Price List", "item_price_list", [
                  "Base Price",
                  "Discount Price",
                ]),
              ],
            ),
          ),

          const SizedBox(width: 60),

          // SISI KANAN (Checkboxes: Inventory, Sales, Purchased)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRightCheckbox("Inventory Item", "is_inv_item"),
                const SizedBox(height: 8),
                _buildRightCheckbox("Sales Item", "is_sales_item"),
                const SizedBox(height: 8),
                _buildRightCheckbox("Purchased Item", "is_purch_item"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Checkbox di Header Kanan
  Widget _buildRightCheckbox(String label, String key) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _checkStates[key] ?? false,
            onChanged: (v) => setState(() => _checkStates[key] = v!),
            activeColor: primaryIndigo,
            side: const BorderSide(color: Colors.grey, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // --- EXISTING CODE BELOW (TIDAK DIUBAH) ---

  Widget _buildAccountFieldRow(
    String label,
    String key,
    String accCode,
    String accName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Icon(Icons.play_arrow, size: 12, color: Colors.orange.shade400),
          const SizedBox(width: 4),
          Container(
            width: 90,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey, width: 0.8),
            ),
            child: TextField(
              controller: _getCtrl("${key}_code", initial: accCode),
              style: const TextStyle(fontSize: 10),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            "=",
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              accName,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRadioSmall(String label, String groupKey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          child: Radio<String>(
            value: label,
            activeColor: primaryIndigo,
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            groupValue: _dropdownValues[groupKey] ?? "Accrual",
            onChanged: (v) => setState(() => _dropdownValues[groupKey] = v!),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE68A),
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
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "House Bank",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSmallDropdownRowModern(
                          "Country",
                          "bank_country",
                          ["Indonesia", "Singapore"],
                        ),
                        _buildSmallDropdownRowModern("Bank", "bank_name", [
                          "Bank OCBC NISP",
                          "BCA",
                          "Mandiri",
                        ]),
                        _buildSmallDropdownRowModern(
                          "Account",
                          "bank_account",
                          ["528.010.00197-2"],
                        ),
                        _buildModernFieldRow("Branch", "bank_branch"),
                        _buildSmallDropdownRowModern("IBAN", "bank_iban", [""]),
                        _buildModernFieldRow("BIC/SWIFT Code", "bank_swift"),
                        _buildModernFieldRow("Control No.", "bank_control_no"),
                        const SizedBox(height: 10),
                        _buildModernFieldRow("DME Identification", "bank_dme"),
                        _buildModernFieldRow(
                          "Instruction Key",
                          "bank_instruction",
                        ),
                        _buildModernFieldRow("Reference Details", "bank_ref"),
                        _buildPaymentCheckbox(
                          "Payment Block",
                          "bank_pay_block",
                        ),
                        _buildPaymentCheckbox(
                          "Single Payment",
                          "bank_single_pay",
                        ),
                        const SizedBox(height: 20),
                        _buildSmallDropdownRowModern(
                          "Bank Charges Allocation Code",
                          "bank_charges_code",
                          [""],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment Methods",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              height: 25,
              color: const Color.fromARGB(255, 177, 205, 156),
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
          return Container(
            height: 22,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color.fromARGB(255, 188, 204, 115),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                _simpleCell("$index", 30, isHeader: true),
                _simpleCell("", 80, key: "pm_code_$index"),
                _simpleCell("", 200, key: "pm_desc_$index"),
                _buildSpecialInputCell(60, "pm_inc_$index"),
                _buildSpecialInputCell(60, "pm_act_$index"),
              ],
            ),
          );
        },
      ),
    );
  }

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
          color: const Color.fromARGB(255, 181, 203, 220),
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
  Widget _simpleCell(
    String text,
    double width, {
    bool isHeader = false,
    String? key,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderGrey, width: 0.5)),
      ),
      alignment: Alignment.centerLeft,
      child: isHeader
          ? Text(
              text,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            )
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

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            color: primaryIndigo,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              labelColor: primaryIndigo,
              unselectedLabelColor: const Color.fromARGB(
                255,
                255,
                255,
                255,
              ).withOpacity(0.9),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 4,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: const [
                Tab(text: "General"),
                Tab(text: "Purchasing Data"),
                Tab(text: "Sales Data"),
                Tab(text: "Inventory Data"),
                Tab(text: "Production Data"),
                Tab(text: "Properties"),
                Tab(text: "Remarks"),
                Tab(text: "Attachments"),
              ],
            ),
          ),

          // AREA ISI (Garis biru tebal pemisah header & konten)
          Container(height: 3, color: primaryIndigo),

          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildContactPersonsTab(),
                _buildAddressesTab(),
                _buildPaymentTermTab(),
                _buildPaymentRunTab(),

                const Center(child: Text("BP Properties")),
                const Center(child: Text("Internal Remarks")),
                const Center(child: Text("Document Attachments")),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          // 1. Dropdown Kiri (Manual / System)
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
                style: const TextStyle(fontSize: 11, color: Colors.black),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                onChanged: (v) =>
                    setState(() => _dropdownValues[dropdownKey] = v!),
                items: series
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          // 2. TextField Tengah
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: borderGrey),
                  bottom: BorderSide(color: borderGrey),
                  right: BorderSide(color: borderGrey), // Ditutup kanan juga
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(6), // Rounded kanan
                ),
              ),
              child: TextField(
                controller: _getCtrl(textKey, initial: initialNo),
                style: const TextStyle(fontSize: 12, color: Colors.black),
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
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border.all(color: borderGrey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[key],
                  isDense: true,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  iconEnabledColor: Colors.black54,
                  onChanged: (v) => setState(() => _dropdownValues[key] = v!),
                  items: items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowWithArrow(
    String label,
    String key, {
    String value = "0.00",
  }) {
    final TextEditingController _controller = _getCtrl(
      key,
      initial: _fieldValues[key] ?? value,
    );

    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
      _focusNodes[key]!.addListener(() {
        if (!_focusNodes[key]!.hasFocus) {
          String text = _controller.text;
          double? parsedValue = double.tryParse(text.replaceAll(',', ''));
          if (parsedValue != null) {
            _controller.text = parsedValue.toStringAsFixed(2);
          } else if (text.isEmpty) {
            _controller.text = "0.00";
          }
          _fieldValues[key] = _controller.text;

          if (mounted) setState(() {});
        }
      });
    }
    final FocusNode _focusNode = _focusNodes[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Icon(Icons.play_arrow, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 24,
            decoration: BoxDecoration(
              color: bgSlate,
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.right, // Angka rata kanan khas SAP
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                isDense: true,
                // Padding disesuaikan agar teks tetap di tengah container 24px
                contentPadding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                _fieldValues[key] = val;
              },
            ),
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                  border: Border.all(color: const Color(0xFFD1D9E6)),
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
                              ? const Color.fromARGB(255, 255, 255, 255)
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

  Widget _buildPaymentTermTab() {
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallDropdownRowModern(
                            "Payment Terms",
                            "paymentTerm",
                            [""],
                          ),
                        ),
                      ],
                    ),
                    _buildModernFieldRow("Interest on Arreas %", "Interest"),
                    const SizedBox(height: 20),
                    _buildSmallDropdownRowModern("Price List", "PriceList", [
                      "",
                    ]),
                    _buildModernFieldRow("Total Discount %", "total disc"),
                    _buildSimpleFieldRow("Credit Limit", "Credit Limit"),
                    _buildSimpleFieldRow("Commitmen Limit", "commitmen Limit"),
                    const SizedBox(height: 30),
                    _buildSmallDropdownRowModern(
                      "Effective Discount Group",
                      "Effective Discount Group",
                      [""],
                    ),
                    _buildSmallDropdownRowModern(
                      "Effective Price",
                      "Effective Price",
                      [""],
                    ),
                    const SizedBox(height: 10),
                    _buildModernFieldRow("Bank Country", "bank country"),
                    _buildModernFieldRow("Bank Name", "Bank Name"),
                    _buildModernFieldRow("bank Code", "Bank code"),
                    _buildModernFieldRow("Account", "Account"),

                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 0.0,
                        ),
                        child: Text(
                          "Business Partner Bank",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildModernFieldRow("BIC/SWIFT code", "BIC/SWIFT code"),
                    _buildModernFieldRow("Account", "Account"),
                    _buildModernFieldRow(
                      "Bank Account Name",
                      "Bank Account Name",
                    ),
                    _buildModernFieldRow("Account", "Account"),
                    _buildModernFieldRow("Branch", "Branch"),
                    _buildModernFieldRow("Ctrl Int ID", "Control Int ID"),
                    _buildModernFieldRow("IBAN", "iban"),
                    _buildModernFieldRow("Mandate ID", "Mandate ID"),
                    _buildSmallDropdownRowModern(
                      "Date Of Signature",
                      "Date OF Signature",
                      [""],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern(
                      "Credit Card Type",
                      "Credit Card Type",
                      [""],
                    ),
                    _buildModernFieldRow("Credit Card No", "Credit Card No"),
                    _buildModernFieldRow("Expiration Date", "Expiration Date"),
                    _buildModernFieldRow("ID number", "Id number"),
                    _buildModernFieldRow("Expiration Date", "Expiration Date"),
                    _buildModernFieldRow("Average Delay", "Average Delay"),
                    _buildSmallDropdownRowModern("Priority", "priority", [""]),
                    _buildModernFieldRow("Default IBAN", " Default IBAN"),
                    _buildSmallDropdownRowModern("Hollidays", "Hollidays", [
                      "",
                    ]),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDE68A),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.amber.shade200),
                            ),
                          ),
                          child: const Text(
                            "UPDATE INFO",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showPaymentTermsSetup(),
                          icon: const Icon(
                            Icons.settings_suggest_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            "SETUP PAYMENT TERMS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade400,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.redAccent.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentTermsSetup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                width: 550,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      color: primaryIndigo,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Payment Terms Setup",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildModernFieldRow(
                            "PT Code",
                            "pt_code",
                            initial: "COD",
                          ),
                          const SizedBox(height: 4),
                          _buildSmallDropdownRowModern(
                            "Due Date Based on",
                            "pt_due",
                            ["Document Date"],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text(
                                  "Start From",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildSmallDropdown("ptTSart", [
                                        "",
                                      ]),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // Input Months
                                    SizedBox(
                                      width: 45,
                                      child: _buildSmallBox("pt_m"),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        right: 6,
                                      ),
                                      child: Text(
                                        "Mos",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const Text("+"),

                                    // Input Days
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 45,
                                      child: _buildSmallBox("pt_d"),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Text(
                                        "Days",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          _buildModernFieldRow(
                            "Tolerance Days",
                            "pt_tol",
                            initial: "0",
                          ),
                          const SizedBox(height: 4),
                          _buildModernFieldRow(
                            "Installments",
                            "pt_inst",
                            initial: "0",
                          ),
                          const SizedBox(height: 4),
                          _buildSmallDropdownRowModern(
                            "Open Inc. Pay",
                            "pt_open",
                            ["No"],
                          ),
                          const SizedBox(height: 4),
                          _buildSmallDropdownRowModern(
                            "Cash Disc. Name",
                            "pt_cash",
                            [""],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(
                              color: Color(0xFFEEEEEE),
                              thickness: 1.5,
                            ),
                          ),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "BUSINESS PARTNER FIELDS",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.indigo,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSimpleFieldRow("Disc %", "pt_disc"),
                          const SizedBox(height: 4),
                          _buildSimpleFieldRow("Interest %", "pt_int"),
                          const SizedBox(height: 4),
                          _buildSmallDropdownRowModern(
                            "Price List",
                            "pt_plist",
                            ["Price List 01"],
                          ),
                          const SizedBox(height: 4),
                          _buildSimpleFieldRow("Max. Credit", "pt_max"),
                          const SizedBox(height: 4),
                          _buildSimpleFieldRow("Comm. Limit", "pt_com"),

                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "CANCEL",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryIndigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4,
                                  shadowColor: primaryIndigo.withOpacity(0.4),
                                ),
                                child: const Text(
                                  "SAVE CHANGES",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 30, // Tinggi standar agar lurus dengan TextField
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
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          onChanged: (val) => setState(() => _dropdownValues[key] = val!),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSimpleFieldRow(
    String label,
    String key, {
    String value = "0.00",
  }) {
    final TextEditingController _controller = TextEditingController(
      text: _fieldValues[key] ?? value,
    );
    final FocusNode _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        String text = _controller.text;
        double? parsedValue = double.tryParse(text.replaceAll(',', ''));
        if (parsedValue != null) {
          _controller.text = parsedValue.toStringAsFixed(2);
        } else if (text.isEmpty) {
          _controller.text = "0.00";
        }
        _fieldValues[key] = _controller.text;
      }
    });

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
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
              decoration: BoxDecoration(
                color: bgSlate,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderGrey),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  _fieldValues[key] = val;
                },
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
              // --- SISI KIRI (Sesuai Gambar 2) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox 1
                    _buildCheckboxRow(
                      "Withholding Tax Liable",
                      "gen_wtax_liable",
                    ),

                    const SizedBox(height: 16), // Jarak pemisah
                    // Checkbox 2
                    _buildCheckboxRow(
                      "Do Not Apply Discount Groups",
                      "gen_no_disc",
                    ),

                    const SizedBox(height: 12),

                    // Manufacturer
                    _buildSmallDropdownRowModern("Manufacturer", "gen_manuf", [
                      "- No Manufacturer -",
                      "Samsung",
                      "Apple",
                    ]),

                    // Additional Identifier
                    _buildModernFieldRow("Additional Identifier", "gen_add_id"),

                    // Shipping Type
                    _buildSmallDropdownRowModern(
                      "Shipping Type",
                      "gen_ship_type",
                      ["", "Air Cargo", "Sea Freight", "Land"],
                    ),

                    const SizedBox(height: 12),

                    // Header Text: Serial and Batch Numbers
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        "Serial and Batch Numbers",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Manage Item by
                    _buildSmallDropdownRowModern(
                      "Manage Item by",
                      "gen_manage_by",
                      ["None", "Serial Numbers", "Batches"],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // --- SISI KANAN (Dikosongkan sesuai Gambar 2) ---
              const Expanded(child: Column(children: [])),
            ],
          ),
          _buildBottomStatusArea(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Helper Checkbox Modern (Tambahkan ini di dalam class) ---
  Widget _buildCheckboxRow(String label, String key) {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _checkStates[key] ?? false,
            onChanged: (v) => setState(() => _checkStates[key] = v!),
            activeColor: primaryIndigo,
            side: const BorderSide(color: Colors.grey, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildBottomStatusArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 130, child: _buildStatusRadio("Active")),
              Expanded(
                child: Row(
                  children: [
                    const Text("From", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),

                    _buildSmallBox("act_from", width: 80),

                    const SizedBox(width: 12),
                    const Text("To", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    _buildSmallBox("act_to", width: 80),

                    const Spacer(), // Dorong Remarks ke Kanan

                    const Text("Remarks", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    SizedBox(width: 150, child: _buildSmallBox("act_rem")),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(width: 130, child: _buildStatusRadio("Inactive")),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(width: 130, child: _buildStatusRadio("Advanced")),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const SizedBox(
                width: 130,
                child: Text(
                  "Advanced Rule Type",
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
              Container(
                width: 150,
                height: 25,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderGrey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _dropdownValues["adv_rule"] ?? "General",
                    isDense: true,
                    style: const TextStyle(fontSize: 11, color: Colors.black),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    onChanged: (v) =>
                        setState(() => _dropdownValues["adv_rule"] = v!),
                    items: ["General", "Warehouse", "Item Group"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ],
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
            activeColor: primaryIndigo,
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
      // Tambahkan horizontal padding agar sejajar dengan box di atasnya (margin 16)
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        // Menggunakan spaceBetween untuk mendorong satu grup ke kiri dan satu ke kanan
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GRUP TOMBOL KIRI (Add / Update & Cancel)
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Add / Update",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildSmallIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {}, // Sekarang bisa menerima fungsi klik
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
