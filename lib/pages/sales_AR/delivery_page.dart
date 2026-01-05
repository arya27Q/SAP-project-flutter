import 'package:flutter/material.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage>
    with SingleTickerProviderStateMixin {
  bool showSidePanel = false;
  late TabController _tabController;
  int _rowCount = 10;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _dropdownValues = {};

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);
  final ScrollController _horizontalScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _rowCount = 10;
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rowCount < 10) _rowCount = 10;
    return Scaffold(
      backgroundColor: bgSlate,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildModernHeader(),
                const SizedBox(height: 16),
                _buildModernTabNavigation(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderGrey),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildContentsTab(),
                        _buildLogisticsTab(),
                        _buildAccountingTab(),
                        const Center(child: Text("Attachments")),
                      ],
                    ),
                  ),
                ),
                _buildModernFooter(),
              ],
            ),
          ),
          if (showSidePanel)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingSidePanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    return SingleChildScrollView(
      // Memungkinkan seluruh halaman di-scroll ke bawah
      child: Column(
        children: [
          // --- CONTAINER 1
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: borderGrey)),
            ),
            child: Row(
              children: [
                const Text(
                  "Item/Service Type",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                _buildSmallDropdown("item_type_main", ["Item", "Service"]),
                const Spacer(),

                PopupMenuButton<String>(
                  onSelected: (value) =>
                      debugPrint("Filter berdasarkan: $value"),
                  offset: const Offset(0, 40),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: "item_no",
                      child: Text("Item No.", style: TextStyle(fontSize: 11)),
                    ),
                    const PopupMenuItem(
                      value: "desc",
                      child: Text(
                        "Description",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const PopupMenuItem(
                      value: "qty",
                      child: Text(
                        "Quantity > 0",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: "reset",
                      child: Text(
                        "Reset Filter",
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 32, 151, 164),
                      border: Border.all(color: borderGrey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list, size: 14, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Filter",
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: () => setState(() => showSidePanel = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Add Item SO",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: () => setState(() => _rowCount++),
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: const Text(
                    "Add Row",
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: () {
                    if (_rowCount > 1) setState(() => _rowCount--);
                  },
                  icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                  label: const Text(
                    "Remove Row",
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- CONTAINER 2: TENGAH (TABEL) ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey, width: 0.5),
            ),
            child: Scrollbar(
              controller: _horizontalScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScroll,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 45,
                  horizontalMargin: 15,
                  headingRowHeight: 40,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 40,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF1F5F9),
                  ),
                  border: TableBorder.all(color: borderGrey, width: 0.5),
                  columns: _buildStaticColumns(),
                  rows: List.generate(
                    _rowCount,
                    (index) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "${index + 1}",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        _buildModernTableCell("in_stock_$index"),
                        _buildModernTableCell("item_no_$index"),
                        _buildModernTableCell("desc_$index"),
                        _buildModernTableCell("details_$index"),
                        _buildModernTableCell("ordered_qty_$index"),
                        _buildModernTableCell("open_qty_$index"),
                        _buildModernTableCell("qty_$index", initial: "0"),
                        _buildModernTableCell("whse_$index", initial: "0"),
                        _buildModernTableCell(
                          "inventory_uom_$index",
                          initial: "0.00",
                        ),
                        _buildModernTableCell(
                          "unit_price_$index",
                          initial: "0.00",
                        ),
                        _buildModernTableCell(
                          "discount_$index",
                          initial: "0.00",
                        ),
                        _buildModernTableCell("total_$index", initial: "0.00"),
                        _buildModernTableCell("account_$index"),
                        _buildModernTableCell("uom_code_$index"),
                        _buildModernTableCell("no_code_$index"),
                        _buildModernTableCell("p_line_$index"),
                        _buildModernTableCell(
                          "material_$index",
                          initial: "0.00",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildStaticColumns() {
    return const [
      DataColumn(
        label: Text(
          "#",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "In Stock.",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Item No",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Item Description",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Item Details",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Ordered Qty",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Open_Qty",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Quantity",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Whse",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Inventory UoM",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Unit Price",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Discount %",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Total (LC)",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "G/L Account",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "UoM Code",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "No Code",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Project Line",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          "Material From",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  Widget _buildLogisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildModernFieldRow(
                  "Ship To",
                  "log_ship_to",
                  isTextArea: true,
                ),
                _buildModernFieldRow(
                  "Bill To",
                  "log_bill_to",
                  isTextArea: true,
                ),
                _buildSmallDropdownRowModern("Shipping Type", "log_ship_type", [
                  "",
                ]),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernCheckbox("Print Picking Sheet", "cb_print"),
                _buildModernCheckbox(
                  "Proc. Doc. For Non Drop-Ship",
                  "cb_non_drop",
                ),
                _buildModernCheckbox("Proc. Doc. For Drop-Ship", "cb_drop"),
                _buildModernCheckbox("Approved", "cb_approved"),
                _buildModernCheckbox("Allow Partial Delivery", "cb_partial"),
                const SizedBox(height: 12),
                _buildModernFieldRow("Pick and Pack Remarks", "log_pick_rem"),
                _buildModernFieldRow("BP Channel Name", "log_bp_name"),
                _buildSmallDropdownRowModern(
                  "BP Channel Contact",
                  "log_bp_cont",
                  [""],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildModernFieldRow("Journal Remark", "acc_journal"),
                const SizedBox(height: 10),
                _buildSmallDropdownRowModern("Payment Terms", "acc_pay_terms", [
                  "",
                ]),
                _buildSmallDropdownRowModern(
                  "Payment Method",
                  "acc_pay_method",
                  [""],
                ),
                _buildSmallDropdownRowModern(
                  "Central Bank Ind.",
                  "acc_central_bank",
                  [""],
                ),
                const SizedBox(height: 10),
                _buildModernFieldRow(
                  "Manually Recalculate Due Date",
                  "acc_manual_due",
                ),
                _buildModernFieldRow(
                  "Cash Discount Date Offset",
                  "acc_cash_disc",
                ),
                _buildModernCheckbox(
                  "Use Shipped Goods Account",
                  "cb_shipped_acc",
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                _buildModernFieldRow("BP Project", "acc_bp_proj"),
                _buildModernFieldRow("Cancellation Date", "acc_cancel_date"),
                _buildModernFieldRow("Required Date", "acc_req_date"),
                const SizedBox(height: 10),
                _buildSmallDropdownRowModern("Indicator", "acc_indicator", [
                  "",
                ]),
                _buildModernFieldRow("Federal Tax ID", "acc_tax_id"),
                const SizedBox(height: 10),
                _buildModernFieldRow("Order Number", "acc_order_no"),
                _buildModernFieldRow("Referenced Document", "acc_ref_doc"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildModernFieldRow("Customer", "h_cust"),
                _buildModernFieldRow("Name", "h_name"),
                _buildModernFieldRow("Contact Person", "h_cont"),
                _buildSmallDropdownRowModern("Customer Ref. No.", "h_ref", [
                  "",
                ]),
                _buildModernFieldRow(
                  "Local Currency",
                  "h_curr",
                  initial: "IDR",
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                _buildModernNoFieldRow(
                  "No.",
                  "h_no_series",
                  ["2025-COM", "2024-REG"],
                  "h_no_val",
                  initialNo: "256100727",
                ),
                _buildModernFieldRow("Status", "h_stat", initial: "Open"),
                _buildModernFieldRow(
                  "Posting Date",
                  "h_post",
                  initial: "28/Dec/2025",
                ),
                _buildModernFieldRow("Delivery Date", "h_deliv"),
                _buildModernFieldRow(
                  "Document Date",
                  "h_doc",
                  initial: "28/Dec/2025",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderGrey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern("Sales Employe", "f_employ", [
                      "",
                    ]),
                    _buildModernFieldRow("Owner", "f_owner"),
                    const SizedBox(height: 8),
                    _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
                  ],
                ),
              ),
              const Spacer(),

              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    _buildSummaryRowWithAutoValue(
                      "Total Before Discount",
                      "0.00",
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 140,
                            child: Text(
                              "Discount",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          _buildSmallInputBox("f_disc_pct"),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text("%", style: TextStyle(fontSize: 12)),
                          ),
                          Expanded(
                            child: _buildSummaryBox("0.00", isReadOnly: true),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 140,
                            child: Text(
                              "Freight",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_right_alt,
                            size: 18,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildSummaryBox("0.00", isReadOnly: true),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _checkStates["cb_rounding"] ?? false,
                                    onChanged: (v) => setState(
                                      () => _checkStates["cb_rounding"] = v!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Rounding",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryBox(
                              "IDR 0.00",
                              isReadOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSummaryRowWithAutoValue("Tax", "0.00"),
                    const Divider(height: 20),
                    _buildSummaryRowWithAutoValue(
                      "Total",
                      "IDR 0.00",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            _buildSAPActionButton("Add", isPrimary: true),
            const SizedBox(width: 8),

            _buildSAPActionButton("Delete", isDanger: true),

            const Spacer(),
            // Copy From: Biru
            _buildSAPActionButton(
              "Copy From",
              customColor: Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            // Copy To: Kuning (Gold)
            _buildSAPActionButton(
              "Copy To",
              customColor: Colors.orange.shade600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSAPActionButton(
    String label, {
    bool isPrimary = false,
    bool isDanger = false,
    Color? customColor,
  }) {
    Color bgColor;
    if (isDanger) {
      bgColor = Colors.red;
    } else if (isPrimary) {
      bgColor = primaryIndigo;
    } else if (customColor != null) {
      bgColor = customColor;
    } else {
      bgColor = Colors.white;
    }

    Color textColor;
    if (isPrimary || isDanger || customColor != null) {
      textColor = Colors.white;
    } else {
      textColor = secondarySlate;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          if (isDanger) {
            debugPrint("Peringatan: Yakin data $label mau dihapus?");
          } else {
            debugPrint("Tombol $label diklik");
          }
        },
        style:
            ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: textColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: (isPrimary || isDanger || customColor != null)
                      ? Colors.transparent
                      : borderGrey,
                  width: 1,
                ),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(
                (isPrimary || isDanger || customColor != null)
                    ? Colors.white.withValues(alpha: 0.1)
                    : primaryIndigo.withValues(alpha: 0.05),
              ),
            ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRowWithAutoValue(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 58),
          Expanded(
            child: _buildSummaryBox(value, isReadOnly: true, isBold: isBold),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInputBox(String key) {
    return Container(
      width: 50,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _getCtrl(key),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSummaryBox(
    String val, {
    bool isBold = false,
    bool isReadOnly = true,
  }) {
    return Container(
      height: 24,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isReadOnly ? bgSlate : Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        val,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: isTextArea ? 100 : 30,
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

  Widget _buildModernNoFieldRow(
    String label,
    String dropdownKey,
    List<String> seriesOptions,
    String textKey, {
    String initialNo = "",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Container(
                  width: 110,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: bgSlate,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(6),
                    ),
                    border: Border.all(color: borderGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          _dropdownValues[dropdownKey] ?? seriesOptions.first,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color.fromARGB(255, 45, 45, 45),
                        fontWeight: FontWeight.normal,
                      ),
                      onChanged: (v) =>
                          setState(() => _dropdownValues[dropdownKey] = v!),
                      items: seriesOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(6),
                      ),
                      border: Border(
                        top: BorderSide(color: borderGrey),
                        bottom: BorderSide(color: borderGrey),
                        right: BorderSide(color: borderGrey),
                      ),
                    ),
                    child: TextField(
                      controller: _getCtrl(textKey, initial: initialNo),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildModernTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: borderGrey),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryIndigo,
        unselectedLabelColor: secondarySlate,
        indicatorColor: primaryIndigo,
        tabs: const [
          Tab(text: "Contents"),
          Tab(text: "Logistics"),
          Tab(text: "Accounting"),
          Tab(text: "Attachments"),
        ],
      ),
    );
  }

  DataCell _buildModernTableCell(String key, {String initial = ""}) {
    return DataCell(
      TextField(
        controller: _getCtrl(key, initial: initial),
        style: const TextStyle(fontSize: 11),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildModernCheckbox(String label, String key) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 32,
          child: Checkbox(
            value: _checkStates[key] ?? false,
            activeColor: primaryIndigo,
            onChanged: (val) => setState(() => _checkStates[key] = val!),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSmallDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 30,
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
          onChanged: (val) => setState(() => _dropdownValues[key] = val!),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingSidePanel() {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: primaryIndigo,
            elevation: 0,
            title: const Text(
              "Sales Order",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => setState(() => showSidePanel = false),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSmallDropdownRowModern("Business Unit", "cfg_bu", [""]),
                _buildModernFieldRow("No Kendaraan", "cfg_no_kend"),
                _buildModernFieldRow("Do Receive Date", " cfg_do_date"),
                _buildChooseFromListField("Driver", "cfg_driver", [""]),
                _buildModernFieldRow("ETD Delivery", "cfg_ETD"),
                _buildModernFieldRow("File 1", "cfg_f1"),
                _buildModernFieldRow("File 2", "cfg_f2"),
                _buildModernFieldRow("File 3", "cfg_f3"),
                _buildModernFieldRow("File 4", "cfg_f4"),
                _buildSmallDropdownRowModern("Create By", "cfg_by", [""]),
                _buildModernFieldRow("Delivery To", "cfg_up"),
                _buildChooseFromListField("Series Draft", "cfg_series", [""]),
                _buildChooseFromListField("No Do ", "cfg_no_do", [""]),

                const Divider(height: 30),
                ElevatedButton(
                  onPressed: () => setState(() => showSidePanel = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
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
              ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(child: _buildSmallDropdown(key, items)),
        ],
      ),
    );
  }

  Widget _buildChooseFromListField(
    String label,
    String key,
    List<String> data,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140, 
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: InkWell(
              // Sekarang klik bebas (teks atau icon)  karena nyatu
              onTap: () => showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(
                    "Pilih $label",
                    style: const TextStyle(fontSize: 14),
                  ),
                  content: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: data
                          .map(
                            (e) => ListTile(
                              dense: true,
                              title: Text(
                                e,
                                style: const TextStyle(fontSize: 13),
                              ),
                              onTap: () {
                                setState(() => _getCtrl(key).text = e);
                                Navigator.pop(c);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              child: Container(
                height: 30, 
                decoration: BoxDecoration(
                  color: bgSlate,
                  border: Border.all(color: borderGrey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          _getCtrl(key).text.isEmpty
                              ? data.first
                              : _getCtrl(key).text,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Icon search sekarang menyatu (tanpa kotak background)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.search, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
