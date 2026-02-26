import 'package:flutter/material.dart';

class ItemMasterDataPage extends StatefulWidget {
  const ItemMasterDataPage({super.key});

  @override
  State<ItemMasterDataPage> createState() => _ItemMasterDataPageState();
}

class _ItemMasterDataPageState extends State<ItemMasterDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _horizontalScroll = ScrollController();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkStates = {};

  // ignore: unused_field
  final Map<String, String> _fieldValues = {};
  // ignore: unused_field
  final Map<String, FocusNode> _focusNodes = {};

  int _inventoryRowCount = 10;
  int _currentTabIndex = 0;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color(0xFFF1F5F9);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color borderGrey = const Color.fromARGB(255, 208, 213, 220);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    _checkStates['is_inv_item'] = true;
    _checkStates['is_sales_item'] = true;
    _checkStates['is_purch_item'] = true;
    _checkStates['inv_manage_whse'] = true;
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
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: _buildHeaderSection(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTabSection(),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildActionArea(),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  // --- TAB SECTION ---
  Widget _buildTabSection() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              unselectedLabelColor: Colors.white.withValues(alpha: 0.9),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
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
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
            ),
          ),
          Container(height: 3, color: primaryIndigo),
          _buildCurrentTabContent(),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildGeneralTab();
      case 1:
        return _buildPurchasingDataTab();
      case 2:
        return _buildSalesDataTab();
      case 3:
        return _buildInventoryDataTab();
      case 4:
        return _buildPaymentTermTab();
      case 5:
        return _buildPaymentRunTab();
      case 6:
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text("Internal Remarks")),
        );
      case 7:
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text("Document Attachments")),
        );
      default:
        return Container();
    }
  }

  // ---------------------------------------------------------------------------
  // --- INVENTORY DATA TAB ---
  // ---------------------------------------------------------------------------
  Widget _buildInventoryDataTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern(
                      "Set Inv. Method By",
                      "inv_method_by",
                      ["Item Group", "Item Level"],
                      labelWidth: 140,
                      bgColor: const Color(0xFFFFF9C4),
                    ),
                    _buildModernFieldRow(
                      "UoM Name",
                      "inv_uom",
                      initial: "Unit",
                      labelWidth: 140,
                    ),
                    _buildModernFieldRow(
                      "Weight",
                      "inv_weight",
                      labelWidth: 140,
                    ),
                    const SizedBox(height: 12),
                    _buildSmallDropdownRowModern(
                      "Valuation Method",
                      "inv_val_method",
                      ["Moving Average", "Standard", "FIFO"],
                      labelWidth: 140,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckboxRow(
                      "Manage Inventory by Warehouse",
                      "inv_manage_whse",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Inventory Level",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildModernFieldRow(
                      "Required (Purchasing UoM)",
                      "inv_req_purch",
                      labelWidth: 160,
                    ),
                    _buildModernFieldRow("Minimum", "inv_min", labelWidth: 160),
                    _buildModernFieldRow("Maximum", "inv_max", labelWidth: 160),
                  ],
                ),
              ),
            ],
          ),
        ),

        // HEADER TABEL & TOMBOL
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: primaryIndigo, width: 2.5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                "Warehouse Inventory",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _inventoryRowCount++),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(
                        () => _inventoryRowCount > 1
                            ? _inventoryRowCount--
                            : null,
                      ),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 246, 246, 246),
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 1.0),
                  left: BorderSide(color: Colors.white, width: 1.0),
                  right: BorderSide(color: Colors.white, width: 1.0),
                ),
              ),
              child: Scrollbar(
                controller: _horizontalScroll,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(primaryIndigo),
                      headingRowHeight: 40,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 40,
                      columnSpacing: 20,
                      horizontalMargin: 12,
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                      columns: _buildInventoryColumns(),
                      rows: List.generate(
                        _inventoryRowCount,
                        (index) => _buildInventoryDataRow(index),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // TOMBOL SET DEFAULT
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDE68A),
                  foregroundColor: Colors.black,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: const Text(
                  "Set Default Whse",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildInventoryColumns() {
    TextStyle headerStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 11,
      letterSpacing: 0.5, // Biar header lebih lega dikit
    );

    DataColumn centeredHeader(String label) {
      return DataColumn(
        label: Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(label, style: headerStyle, textAlign: TextAlign.start),
          ),
        ),
      );
    }

    return [
      centeredHeader("#"),
      centeredHeader("Whse Code"),
      centeredHeader("Whse Name"),
      centeredHeader("Locked"),
      centeredHeader("In Stock"),
      centeredHeader("Committed"),
      centeredHeader("Ordered"),
      centeredHeader("Available"),
      centeredHeader("Min. Inventory"),
      centeredHeader("Max. Inventory"),
      centeredHeader("Req. Inv. Level"),
      centeredHeader("Item Cost"),
    ];
  }

  DataRow _buildInventoryDataRow(int index) {
    TextStyle rowStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500, // Agak tebal dikit biar kebaca
      color: Colors.black87,
    );

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        return Colors.transparent; // Biar background ngikut scaffold/container
      }),
      cells: [
        // Index Row
        DataCell(Center(child: Text("${index + 1}", style: rowStyle))),

        // Input Text
        _buildInvTextCell("inv_code_$index", initial: "", minWidth: 90),
        _buildInvTextCell("inv_name_$index", initial: "", minWidth: 180),

        // Checkbox Modern
        DataCell(
          Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: _checkStates["inv_locked_$index"] ?? false,
                onChanged: (v) =>
                    setState(() => _checkStates["inv_locked_$index"] = v!),
                activeColor: primaryIndigo, // Warna Tema
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),

        // Input Angka (Semua dikasih style box biar rapi rata)
        _buildInvNumberCell("inv_stock_$index"),
        _buildInvNumberCell("inv_commit_$index"),
        _buildInvNumberCell("inv_order_$index"),
        _buildInvNumberCell("inv_avail_$index"),
        _buildInvNumberCell("inv_min_$index"),
        _buildInvNumberCell("inv_max_$index"),
        _buildInvNumberCell("inv_req_$index"),
        _buildInvNumberCell("inv_cost_$index"),
      ],
    );
  }

  DataCell _buildInvTextCell(
    String key, {
    String initial = "",
    double minWidth = 80,
  }) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ), // Spasi atas bawah sel
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: Container(
              height: 30, // Tinggi Seragam
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6), // Rounded Modern
                // 🔥 SHADOW SAMA PERSIS KAYAK FORM ATAS 🔥
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                ],

                // Border Ungu Tipis
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _getCtrl(key, initial: initial),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8, // Padding kiri kanan teks
                    vertical: 9, // Padding atas bawah teks biar tengah
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildInvNumberCell(String key, {Color? bg}) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: bg ?? Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                ],

                // Style Border Seragam
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _getCtrl(key),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 9,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB LAIN ---
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildCheckboxRow("Withholding Tax Liable", "gen_wtax_liable"),
                const SizedBox(height: 16),
                _buildCheckboxRow(
                  "Do Not Apply Discount Groups",
                  "gen_no_disc",
                ),
                const SizedBox(height: 12),
                _buildSmallDropdownRowModern("Manufacturer", "gen_manuf", [
                  "- No Manufacturer -",
                  "Samsung",
                  "Apple",
                ]),
                _buildModernFieldRow("Additional Identifier", "gen_add_id"),
                _buildSmallDropdownRowModern("Shipping Type", "gen_ship_type", [
                  "",
                  "Air Cargo",
                  "Sea Freight",
                  "Land",
                ]),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                _buildSmallDropdownRowModern(
                  "Manage Item by",
                  "gen_manage_by",
                  ["None", "Serial Numbers", "Batches"],
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          const Expanded(child: Column(children: [])),
        ],
      ),
    );
  }

  Widget _buildPurchasingDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildFieldWithButton(
                  "Preferred Vendor",
                  "purch_vendor",
                  buttonIcon: Icons.more_horiz,
                  bgColor: const Color.fromARGB(255, 255, 255, 255),
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Mfr Catalog No.",
                  "purch_mfr_no",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Purchasing UoM Name",
                  "purch_uom",
                  initial: "Unit",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Items per Purchase Unit",
                  "purch_items_per",
                  initial: "1",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Packaging UoM Name",
                  "purch_pack_uom",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Quantity per Package",
                  "purch_qty_pack",
                  initial: "1",
                  labelWidth: 140,
                ),
                const SizedBox(height: 24),
                _buildTaxRow(
                    "Customs Group",
                    "purch_customs",
                    [
                      "Customs Exempt",
                    ],
                    labelWidth: 140),
                _buildTaxRow(
                  "Tax Group",
                  "purch_tax",
                  ["VAT IN 11%", "VAT 10%"],
                  percentVal: "11",
                  labelWidth: 140,
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                _buildFieldWithButton(
                  "Length",
                  "purch_length",
                  buttonText: ">>",
                  bgColor: Colors.white,
                  labelWidth: 90,
                ),
                _buildModernFieldRow("Width", "purch_width", labelWidth: 90),
                _buildModernFieldRow("Height", "purch_height", labelWidth: 90),
                _buildVolumeRow(
                    "Volume",
                    "purch_vol",
                    "purch_vol_uom",
                    [
                      "cm",
                    ],
                    labelWidth: 90),
                _buildModernFieldRow("Weight", "purch_weight", labelWidth: 90),
                const SizedBox(height: 80),
                _buildModernFieldRow(
                  "Factor 1",
                  "purch_fac1",
                  initial: "1",
                  labelWidth: 90,
                ),
                _buildModernFieldRow(
                  "Factor 2",
                  "purch_fac2",
                  initial: "1",
                  labelWidth: 90,
                ),
                _buildModernFieldRow(
                  "Factor 3",
                  "purch_fac3",
                  initial: "1",
                  labelWidth: 90,
                ),
                _buildModernFieldRow(
                  "Factor 4",
                  "purch_fac4",
                  initial: "1",
                  labelWidth: 90,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTaxRow(
                  "Tax Group",
                  "sales_tax",
                  ["VAT OUT 11%", "VAT 10%"],
                  percentVal: "11",
                  labelWidth: 140,
                ),
                const SizedBox(height: 24),
                _buildModernFieldRow(
                  "Sales UoM Name",
                  "sales_uom",
                  initial: "Unit",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Items per Sales Unit",
                  "sales_items_per",
                  initial: "1",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Packaging UoM Name",
                  "sales_pack_uom",
                  labelWidth: 140,
                ),
                _buildModernFieldRow(
                  "Quantity per Package",
                  "sales_qty_pack",
                  initial: "1",
                  labelWidth: 140,
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                _buildFieldWithButton(
                  "Length",
                  "sales_length",
                  buttonText: ">>",
                  bgColor: Colors.white,
                  labelWidth: 90,
                ),
                _buildModernFieldRow("Width", "sales_width", labelWidth: 90),
                _buildModernFieldRow("Height", "sales_height", labelWidth: 90),
                _buildVolumeRow(
                    "Volume",
                    "sales_vol",
                    "sales_vol_uom",
                    [
                      "cm",
                    ],
                    labelWidth: 90),
                _buildModernFieldRow("Weight", "sales_weight", labelWidth: 90),
                const SizedBox(height: 80),
                _buildModernFieldRow(
                  "Factor 1",
                  "sales_fac1",
                  initial: "1",
                  labelWidth: 90,
                ),
                _buildModernFieldRow(
                  "Factor 2",
                  "sales_fac2",
                  initial: "1",
                  labelWidth: 90,
                ),
                _buildModernFieldRow(
                  "Factor 3",
                  "sales_fac3",
                  initial: "1",
                  labelWidth: 90,
                ),
                _buildModernFieldRow(
                  "Factor 4",
                  "sales_fac4",
                  initial: "1",
                  labelWidth: 90,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildFieldWithButton(
    String label,
    String key, {
    IconData? buttonIcon,
    String? buttonText,
    Color bgColor = Colors.white,
    String initial = "",
    double labelWidth = 130,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Jarak antar row
      child: Row(
        children: [
          // --- LABEL ---
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // --- CONTAINER MENYATU (Input + Button) ---
          Expanded(
            child: Container(
              height: 35, // Tinggi standar
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),

                // Shadow Ungu Tipis (Seragam)
                boxShadow: [
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
                ],

                // Border Ungu Tipis
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // BAGIAN 1: TEXTFIELD
                  Expanded(
                    child: TextField(
                      controller: _getCtrl(key, initial: initial),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                      ),
                    ),
                  ),

                  // BAGIAN 2: GARIS PEMISAH (Opsional, biar makin rapi)
                  Container(
                    width: 1,
                    height: 35,
                    color: borderGrey.withValues(alpha: 0.5),
                  ),

                  // BAGIAN 3: BUTTON (Menyatu di kanan)
                  Container(
                    width: 40, // Lebar tombol
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFFFDE68A,
                      ), // Warna Kuning asli (dipertahankan)
                      // Rounded cuma di kanan biar nyatu
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(9),
                        bottomRight: Radius.circular(9),
                      ),
                    ),
                    child: Material(
                      // Efek ripple pas diklik
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(9),
                          bottomRight: Radius.circular(9),
                        ),
                        onTap: () {
                          // Tambahin logic tombol disini kalau butuh
                          debugPrint("Button $key clicked");
                        },
                        child: Center(
                          child: buttonIcon != null
                              ? Icon(
                                  buttonIcon,
                                  size: 16,
                                  color: Colors.black54,
                                )
                              : Text(
                                  buttonText ?? "...",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeRow(
    String label,
    String key,
    String dropKey,
    List<String> units, {
    double labelWidth = 130,
  }) {
    if (!_dropdownValues.containsKey(dropKey)) {
      _dropdownValues[dropKey] = units.first;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Jarak lebih lega
      child: Row(
        children: [
          // --- LABEL ---
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // --- CONTAINER MENYATU (Input + Dropdown Unit) ---
          Expanded(
            child: Container(
              height: 35, // Tinggi standar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // Rounded
                // Shadow Seragam
                boxShadow: [
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
                ],

                // Border Ungu Tipis
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // BAGIAN 1: TEXTFIELD (Angka Volume)
                  Expanded(
                    child: TextField(
                      controller: _getCtrl(key),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        hintText: "0", // Opsional hint
                        hintStyle: TextStyle(color: Colors.black26),
                      ),
                    ),
                  ),

                  // BAGIAN 2: GARIS PEMISAH VERTIKAL
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),

                  // BAGIAN 3: DROPDOWN UNIT (Kanan)
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dropdownValues[dropKey],
                        isDense: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight:
                              FontWeight.bold, // Bold biar unitnya jelas
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                        onChanged: (v) =>
                            setState(() => _dropdownValues[dropKey] = v!),
                        items: units
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRow(
    String label,
    String key,
    List<String> items, {
    String percentVal = "",
    double labelWidth = 130,
  }) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // --- LABEL ---
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // --- CONTAINER MENYATU ---
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
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
                ],
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // BAGIAN 1: DROPDOWN (Jenis Pajak)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dropdownValues[key],
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.black54,
                          ),
                          onChanged: (v) =>
                              setState(() => _dropdownValues[key] = v!),
                          items: items
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),

                  // BAGIAN 2: GARIS PEMISAH
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),

                  // BAGIAN 3: INPUT + PERSEN (Disatukan di tengah)
                  SizedBox(
                    width: 70, // Lebar area kanan fix
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // 🔥 KUNCI: Biar nempel di tengah
                      children: [
                        // Input Angka (Lebar secukupnya)
                        SizedBox(
                          width: 30,
                          child: TextField(
                            controller: _getCtrl(
                              "${key}_pct",
                              initial: percentVal,
                            ),
                            textAlign:
                                TextAlign.end, // Rata kanan (mendekati %)
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.zero, // Padding 0 biar presisi
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.black26),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ), // Jarak dikit antara angka dan %
                        // Simbol %
                        const Text(
                          "%",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    double labelWidth = 130,
    Color? bgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            isTextArea ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // --- BAGIAN LABEL ---
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: isTextArea ? 80 : 35,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bgColor ?? Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
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
                ],
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _getCtrl(key, initial: initial),
                maxLines: isTextArea ? 3 : 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
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
    List<String> items, {
    double labelWidth = 130,
    Color? bgColor,
  }) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Jarak antar row lebih lega
      child: Row(
        children: [
          // --- LABEL ---
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10), // Spacer
          // --- DROPDOWN CONTAINER ---
          Expanded(
            child: Container(
              height: 35, // Samakan tinggi dengan textfield
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bgColor ?? Colors.white,
                borderRadius: BorderRadius.circular(10),

                // Shadow Halus
                boxShadow: [
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
                ],

                // Border Tipis (Ungu/Abu)
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[key],
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.black54,
                  ),
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

  Widget _buildModernNoFieldRow(
    String label,
    String dropdownKey,
    List<String> series,
    String textKey, {
    String initialNo = "",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // --- LABEL ---
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // --- CONTAINER MENYATU (Dropdown + Input) ---
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // Rounded penuh
                // Shadow sama persis
                boxShadow: [
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
                ],

                // Border sama persis
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // BAGIAN 1: DROPDOWN (Series)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dropdownValues[dropdownKey] ?? series.first,
                        isDense: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Colors.black54,
                        ),
                        onChanged: (v) =>
                            setState(() => _dropdownValues[dropdownKey] = v!),
                        items: series
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  // BAGIAN 2: GARIS PEMISAH VERTIKAL
                  Container(
                    width: 1,
                    height: 20, // Tinggi garis
                    color: Colors.grey
                        .withValues(alpha: 0.3), // Warna garis pemisah
                  ),

                  // BAGIAN 3: TEXTFIELD (Nomor)
                  Expanded(
                    child: TextField(
                      controller: _getCtrl(textKey, initial: initialNo),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        hintText: "No.", // Opsional hint
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            bool current = _checkStates[key] ?? false;
            _checkStates[key] = !current;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(-6, 0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _checkStates[key] ?? false,
                  onChanged: (v) => setState(() => _checkStates[key] = v!),
                  activeColor: primaryIndigo,
                  side: BorderSide(color: borderGrey, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(-0.1, 0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondarySlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
      onSelected: (value) => debugPrint("Selected action: $value"),
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
      ],
    );
  }

  // --- PLACEHOLDERS UNTUK TAB LAIN ---

  Widget _buildPaymentTermTab() =>
      const Center(child: Text("Production Data Placeholder"));
  Widget _buildPaymentRunTab() =>
      const Center(child: Text("Properties Placeholder"));
}
