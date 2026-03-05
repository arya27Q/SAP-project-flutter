import 'package:flutter/material.dart';

class WarehouseSetupPage extends StatefulWidget {
  const WarehouseSetupPage({super.key});

  @override
  State<WarehouseSetupPage> createState() => _WarehouseSetupPageState();
}

class _WarehouseSetupPageState extends State<WarehouseSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ==========================================
  // COLORS & STYLES (Seragam dengan ERP)
  // ==========================================
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  final double _inputHeight = 35.0;
  final BorderRadius _inputRadius = BorderRadius.circular(8);

  // Tombol untuk nampilin Panel Kanan
  bool showSidePanel = true;

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: primaryIndigo.withValues(alpha: 0.08),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  Border get _thinBorder =>
      Border.all(color: primaryIndigo.withValues(alpha: 0.15), width: 1);

  // ==========================================
  // STATE MANAGEMENT
  // ==========================================
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, bool> _checkboxValues = {
    "cb_inactive": false,
    "cb_dropship": false,
    "cb_nettable": true,
    "cb_bin": false,
  };

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================
  // MAIN BUILD WIDGET
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: Stack(
        children: [
          // KONTEN UTAMA (KIRI)
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              bottom: 20.0,
              // Kasih jarak kanan biar nggak ketutupan panel kalau lagi kebuka
              right: showSidePanel ? 380 + 20.0 : 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Buka Panel (Muncul kalau panel ditutup)
                if (!showSidePanel)
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => showSidePanel = true),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text("item side"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (!showSidePanel) const SizedBox(height: 10),

                // 1. Header (Warehouse Code & Name)
                RepaintBoundary(child: _buildModernHeader()),
                const SizedBox(height: 16),

                // 2. Main Content (Tab)
                _buildTabSection(),
                const SizedBox(height: 16),

                // 3. Footer Buttons
                _buildFooter(),
              ],
            ),
          ),

          // PANEL KANAN (SIDE PANEL)
          if (showSidePanel)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: RepaintBoundary(child: _buildFloatingSidePanel()),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. HEADER (Code & Name)
  // ==========================================
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModernFieldRow("Warehouse Code", "whs_code",
                initial: "WIP KNB", labelWidth: 120),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: _buildModernFieldRow("Warehouse Name", "whs_name",
                initial: "WIP KANBAN SCI", labelWidth: 120),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. MAIN TABS SECTION
  // ==========================================
  Widget _buildTabSection() {
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
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: primaryIndigo,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              labelColor: primaryIndigo,
              unselectedLabelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text("General",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            height: 850,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Checkbox Atas
        Row(
          children: [
            _buildCheckbox("Inactive", "cb_inactive"),
            const SizedBox(width: 150),
            _buildCheckbox("Drop-Ship", "cb_dropship", isReadOnly: true),
          ],
        ),
        const SizedBox(height: 16),

        // Split Kiri & Kanan di dalam Tab
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KOLOM KIRI (Form Alamat) ---
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernDropdownRow("Location", "dd_loc", [""],
                        labelWidth: 140),
                    Row(
                      children: [
                        const SizedBox(width: 150),
                        _buildCheckbox("Nettable", "cb_nettable"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildModernFieldRow("Street/PO Box", "f_street_po",
                        labelWidth: 140),
                    _buildModernFieldRow("Street No.", "f_street_no",
                        labelWidth: 140),
                    _buildModernFieldRow("Block", "f_block", labelWidth: 140),
                    _buildModernFieldRow("Building/Floor/Room", "f_bldg",
                        labelWidth: 140),
                    _buildModernFieldRow("Zip Code", "f_zip", labelWidth: 140),
                    _buildModernFieldRow("City", "f_city", labelWidth: 140),
                    _buildModernFieldRow("County", "f_county", labelWidth: 140),
                    _buildModernDropdownRow("Country", "dd_country", [""],
                        labelWidth: 140),
                    _buildModernDropdownRow("State", "dd_state", [""],
                        labelWidth: 140),
                    _buildModernFieldRow("Federal Tax ID", "f_tax_id",
                        labelWidth: 140),
                    _buildModernFieldRow("GLN", "f_gln", labelWidth: 140),
                    const Spacer(),
                    _buildModernFieldRow("Tax Office", "f_tax_off",
                        labelWidth: 140),
                    _buildModernFieldRow("Address Name 2", "f_add2",
                        labelWidth: 140),
                    _buildModernFieldRow("Address Name 3", "f_add3",
                        labelWidth: 140),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // --- KOLOM KANAN (Enable Bin & Web Link) ---
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 90),
                    _buildCheckbox("Enable Bin Locations", "cb_bin"),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () {},
                        child: const Text(
                          "Show Location in Web Browser",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. FLOATING SIDE PANEL (Model GoodIssuePage)
  // ==========================================
  Widget _buildFloatingSidePanel() {
    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: primaryIndigo,
            title: const Text(
              "Warehouse Info",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() => showSidePanel = false),
                icon: const Icon(Icons.close),
                color: Colors.white,
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Isinya sesuai gambar panel kanan Warehouse Master Data
                _buildModernFieldRow("Location", "pnl_loc", initial: "DLM 1+"),
                const SizedBox(height: 8),
                _buildModernFieldRow("Item Group", "pnl_group",
                    initial: "Jobshop"),
                const SizedBox(height: 8),
                _buildModernFieldRow("Item Type", "pnl_type",
                    initial: "Intermediate"),

                const SizedBox(height: 30),

                // Tombol Apply (Khas Side Panel lu)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => setState(() => showSidePanel = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "APPLY",
                      style: TextStyle(
                        color: Colors.white,
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

  // ==========================================
  // 4. FOOTER BUTTONS
  // ==========================================
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildActionButton(
              "OK", const Color(0xFFFFD54F), Colors.black87), // Kuning SAP
          const SizedBox(width: 12),
          _buildActionButton("Cancel", const Color(0xFFE0E0E0), Colors.black87),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor) {
    return SizedBox(
      height: 30,
      width: 80,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Colors.black26),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS (Form UI)
  // ==========================================
  Widget _buildCheckbox(String label, String key, {bool isReadOnly = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _checkboxValues[key],
            onChanged: isReadOnly
                ? null
                : (val) {
                    setState(() {
                      _checkboxValues[key] = val ?? false;
                    });
                  },
            activeColor: primaryIndigo,
            side: BorderSide(color: isReadOnly ? Colors.grey : primaryIndigo),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isReadOnly ? Colors.grey : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    String initial = "",
    double labelWidth = 120,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                boxShadow: _softShadow,
                border: _thinBorder,
              ),
              child: TextField(
                controller: _getCtrl(key, initial: initial),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdownRow(String label, String key, List<String> items,
      {double labelWidth = 120}) {
    if (!_dropdownValues.containsKey(key)) {
      _dropdownValues[key] = items.isNotEmpty ? items.first : "";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                boxShadow: _softShadow,
                border: _thinBorder,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[key],
                  isDense: true,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: primaryIndigo,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _dropdownValues[key] = val!;
                    });
                  },
                  items: items.map((val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
