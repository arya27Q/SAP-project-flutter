import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemMasterDataPage extends StatefulWidget {
  const ItemMasterDataPage({super.key});

  @override
  State<ItemMasterDataPage> createState() => _ItemMasterDataPageState();
}

class _ItemMasterDataPageState extends State<ItemMasterDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _horizontalScroll = ScrollController();

  // Note: _verticalScroll dihapus karena kita pakai scroll halaman utama (body)
  // agar tabel tampil full 10 baris.

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkStates = {};

  // ignore: unused_field
  final Map<String, String> _fieldValues = {};
  // ignore: unused_field
  final Map<String, FocusNode> _focusNodes = {};

  int _inventoryRowCount = 10; // Default 10 baris
  int _currentTabIndex = 0;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color.fromARGB(255, 255, 255, 255);
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
              unselectedLabelColor: Colors.white.withOpacity(0.9),
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
            border: Border(
            top: BorderSide(color: primaryIndigo, width: 2.5), 
             
            ),
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

        // TABEL (FULL WIDTH MENTOK KANAN & AUTO EXPAND CELL)
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 246, 246, 246),
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
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth, // Minimal selebar layar
                    ),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(primaryIndigo),
                      headingRowHeight: 40,
                      dataRowMinHeight:
                          40, // Tinggi baris agar pas dengan input
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

  // --- HELPER TABEL INVENTORY ---
  List<DataColumn> _buildInventoryColumns() {
    TextStyle headerStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );

    // Helper untuk header yang PASTI tengah
    DataColumn centeredHeader(String label) {
      return DataColumn(
        label: Expanded(
          child: Container(
            alignment: Alignment.center, // Paksa alignment center
            child: Text(label, style: headerStyle, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return [
      centeredHeader("#"),
      DataColumn(label: Text("Whse Code", style: headerStyle)),
      DataColumn(label: Text("Whse Name", style: headerStyle)),
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
    List<Map<String, String>> dummyWhse = [
      {"code": "01", "name": "General Warehouse"},
      {"code": "DBS", "name": "BAD STOCK"},
      {"code": "DCON", "name": "Whs Consumables"},
      {"code": "DCS", "name": "Whse Customer"},
      {"code": "DFG", "name": "Whs Finished Good", "bold": "true"},
      {"code": "DFP", "name": "Whs Finished Good"},
      {"code": "DPP", "name": "Whse Partial Part"},
      {"code": "DRJ", "name": "Whs Reject"},
      {"code": "DRM", "name": "WHS Raw Material"},
      {"code": "DRP", "name": "Whs Repair"},
      {"code": "DRS", "name": "Whse Ready Stock"},
      {"code": "DRT", "name": "Whse Raw Material"},
      {"code": "DSC", "name": "Whs Sub Cont"},
    ];

    String code = "";
    String name = "";
    bool isBold = false;
    if (index < dummyWhse.length) {
      code = dummyWhse[index]["code"]!;
      name = dummyWhse[index]["name"]!;
      isBold = dummyWhse[index]["bold"] == "true";
    }

    TextStyle rowStyle = TextStyle(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black87,
    );

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        if (index == 0 || index == 4)
          return const Color(0xFFFFF9C4).withOpacity(0.5);
        return Colors.white;
      }),
      cells: [
        DataCell(Center(child: Text("${index + 1}", style: rowStyle))),
        DataCell(
          Row(
            children: [
              if (code.isNotEmpty)
                const Icon(Icons.arrow_right, color: Colors.orange, size: 18),
              Text(code, style: rowStyle),
            ],
          ),
        ),
        DataCell(Text(name, style: rowStyle)),
        DataCell(
          Center(
            child: Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _checkStates["inv_locked_$index"] ?? false,
                onChanged: (v) =>
                    setState(() => _checkStates["inv_locked_$index"] = v!),
                activeColor: primaryIndigo,
              ),
            ),
          ),
        ),
        // Cell Input Angka
        _buildInvNumberCell("inv_stock_$index", bg: Colors.white),
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

  DataCell _buildInvNumberCell(String key, {Color? bg}) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: IntrinsicWidth(
          // Biarkan lebar mengikuti konten jika panjang
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80), // Minimal lebar 80
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: bg ?? Colors.transparent,
                border: bg != null
                    ? Border.all(color: Colors.grey.shade300)
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
              child: TextField(
                controller: _getCtrl(key),
                textAlign: TextAlign.start,
                textAlignVertical:
                    TextAlignVertical.center, // POSISI PAS TENGAH
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  // Reset padding bawaan agar textAlignVertical bekerja sempurna
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
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
                  bgColor: const Color(0xFFFFF9C4),
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
                _buildTaxRow("Customs Group", "purch_customs", [
                  "Customs Exempt",
                ], labelWidth: 140),
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
                _buildVolumeRow("Volume", "purch_vol", "purch_vol_uom", [
                  "cm",
                ], labelWidth: 90),
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
                  bgColor: const Color(0xFFFFF9C4),
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
                _buildVolumeRow("Volume", "sales_vol", "sales_vol_uom", [
                  "cm",
                ], labelWidth: 90),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderGrey),
                    ),
                    child: TextField(
                      controller: _getCtrl(key, initial: initial),
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 30,
                  width: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE68A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Center(
                    child: buttonIcon != null
                        ? Icon(buttonIcon, size: 16, color: Colors.black54)
                        : Text(
                            buttonText ?? "...",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
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
    if (!_dropdownValues.containsKey(dropKey))
      _dropdownValues[dropKey] = units.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderGrey),
                    ),
                    child: TextField(
                      controller: _getCtrl(key),
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dropdownValues[dropKey],
                      isDense: true,
                      style: const TextStyle(fontSize: 11, color: Colors.black),
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderGrey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dropdownValues[key],
                        isDense: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        onChanged: (v) =>
                            setState(() => _dropdownValues[key] = v!),
                        items: items
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    border: Border.all(color: borderGrey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    controller: _getCtrl("${key}_pct", initial: percentVal),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text("%", style: TextStyle(fontSize: 12)),
              ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
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
                color: bgColor ?? bgSlate,
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

  Widget _buildSmallDropdownRowModern(
    String label,
    String key,
    List<String> items, {
    double labelWidth = 130,
    Color? bgColor,
  }) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
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
                color: bgColor ?? const Color.fromARGB(255, 255, 255, 255),
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
                style: const TextStyle(fontSize: 11, color: Colors.black),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
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
                  right: BorderSide(color: borderGrey),
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(6),
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
  Widget _buildContactPersonsTab() =>
      const Center(child: Text("Contact Persons Data Placeholder"));
  Widget _buildAddressesTab() =>
      const Center(child: Text("Addresses Data Placeholder"));
  Widget _buildPaymentTermTab() =>
      const Center(child: Text("Production Data Placeholder"));
  Widget _buildPaymentRunTab() =>
      const Center(child: Text("Properties Placeholder"));
}
