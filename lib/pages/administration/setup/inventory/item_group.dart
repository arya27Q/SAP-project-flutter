import 'package:flutter/material.dart';

class ItemGroupPage extends StatefulWidget {
  const ItemGroupPage({super.key});

  @override
  State<ItemGroupPage> createState() => _ItemGroupPageState();
}

class _ItemGroupPageState extends State<ItemGroupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ==========================================
  // COLORS & STYLES (Seragam dengan ERP lu)
  // ==========================================
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  final double _inputHeight = 35.0;
  final BorderRadius _inputRadius = BorderRadius.circular(8);

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

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Item Group Name)
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
            flex: 6,
            child: _buildModernFieldRow(
              "Item Group Name",
              "ig_name",
              initial: "K Supporting MATL",
              labelWidth: 140,
              // Background kuning khas SAP Mandatory Field
              bgColor: Colors.yellow.shade50,
            ),
          ),
          const Spacer(flex: 4),
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
            height: 650,
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
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildModernDropdownRow("Default UoM Group", "dd_uom", [""],
                      labelWidth: 180),
                  const SizedBox(height: 24),
                  _buildModernDropdownRow(
                      "Planning Method", "dd_plan", ["None", "MRP"],
                      labelWidth: 180),
                  _buildModernDropdownRow(
                      "Procurement Method", "dd_proc", ["Buy", "Make"],
                      labelWidth: 180),
                  const SizedBox(height: 24),
                  _buildModernDropdownRow("Order Interval", "dd_interv", [""],
                      labelWidth: 180),
                  _buildFieldWithSuffixText("Order Multiple", "f_ord_mult", "",
                      initial: "0.00", labelWidth: 180),
                  _buildFieldWithSuffixText(
                      "Minimum Order Qty", "f_min_ord", "Inventory UoM",
                      initial: "0.00", labelWidth: 180),
                  const SizedBox(height: 24),
                  _buildFieldWithSuffixText("Lead Time", "f_lead", "Days",
                      labelWidth: 180),
                  _buildFieldWithSuffixText("Tolerance Days", "f_tol", "Days",
                      labelWidth: 180),
                  const SizedBox(height: 24),
                  _buildModernDropdownRow("Default Valuation Method", "dd_val",
                      ["Moving Average", "Standard", "FIFO"],
                      labelWidth: 180),
                ],
              ),
            ),
            const Spacer(flex: 5),
          ],
        )
      ],
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
  Widget _buildModernFieldRow(
    String label,
    String key, {
    String initial = "",
    double labelWidth = 120,
    Color bgColor = Colors.white,
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
                color: bgColor,
                borderRadius: _inputRadius,
                boxShadow: bgColor == Colors.white ? _softShadow : null,
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

  // Fungsi khusus untuk nambahin Text (Days / Inventory UoM) di kanan TextField
  Widget _buildFieldWithSuffixText(
    String label,
    String key,
    String suffixText, {
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
          const SizedBox(width: 10),
          SizedBox(
            width: 90, // Ruang untuk tulisan di sebelah kanannya
            child: Text(
              suffixText,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
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
          // Tambahin spacer ghoib biar sejajar sama TextField yang pake suffix
          const SizedBox(width: 10),
          const SizedBox(width: 90),
        ],
      ),
    );
  }
}
