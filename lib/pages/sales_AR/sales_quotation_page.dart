import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SalesQuotationPage extends StatefulWidget {
  const SalesQuotationPage({super.key});

  @override
  State<SalesQuotationPage> createState() => _SalesQuotationPageState();
}

class _SalesQuotationPageState extends State<SalesQuotationPage>
    with SingleTickerProviderStateMixin {
  bool showSidePanel = false;
  late TabController _tabController;
  int _rowCount = 10;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);
  final ScrollController _horizontalScroll = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String?> _formValues = {};

  String formatPrice(String value) {
  String cleanText = value.replaceAll(RegExp(r'[^0-9.]'), '');
  double parsed = double.tryParse(cleanText) ?? 0.0;
  return parsed.toStringAsFixed(2);
}

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initial);
    }
    return _controllers[key]!;
  }

 FocusNode _getFn(String key, {bool isReadOnly = false, String defaultValue = "0.00", bool isPercent = false}) {
  if (!_focusNodes.containsKey(key)) {
    _focusNodes[key] = FocusNode();
  }
  
  final fn = _focusNodes[key]!;

  
  fn.removeListener(() {}); 
  fn.addListener(() {
   
    if (!fn.hasFocus && !isReadOnly) {
      final controller = _getCtrl(key);
      String cleanText = controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
      double? parsed = double.tryParse(cleanText);

      if (mounted) {
        setState(() {
          if (parsed != null) {
           
            controller.text = isPercent ? parsed.toStringAsFixed(0) : parsed.toStringAsFixed(2);
          } else {
            controller.text = defaultValue;
          }
          _fieldValues[key] = controller.text;
        });
      }
    }
  });
  
  return fn;
}

  double _getGrandTotal() {
  double parse(String key) {
    
    String val = _controllers[key]?.text ?? _fieldValues[key] ?? "0";
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  double before = parse("f_before_disc");
  double discVal = parse("f_disc_val");
  double freight = parse("f_freight");
  double tax = parse("f_tax");
  double rounding = parse("f_rounding");

  return (before - discVal) + freight + rounding + tax;
}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    for (var f in _focusNodes.values) f.dispose();
    _tabController.dispose();
    _horizontalScroll.dispose();
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
      child: Column(
        children: [
          // --- CONTAINER 1: HEADER CONTROLS (TOMBOL-TOMBOL) ---
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

                // TOMBOL FILTER
                PopupMenuButton<String>(
                  onSelected: (value) => debugPrint("Filter berdasarkan: $value"),
                  offset: const Offset(0, 40),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: "item_no",
                      child: Text("Item No.", style: TextStyle(fontSize: 12)),
                    ),
                    const PopupMenuItem(
                      value: "desc",
                      child: Text("Description", style: TextStyle(fontSize: 11)),
                    ),
                    const PopupMenuItem(
                      value: "qty",
                      child: Text("Quantity > 0", style: TextStyle(fontSize: 11)),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: "reset",
                      child: Text("Reset Filter", style: TextStyle(fontSize: 11, color: Colors.red)),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Text("Filter", style: TextStyle(fontSize: 11, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: () => setState(() => showSidePanel = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text("Add Item SO", style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: () => setState(() => _rowCount++),
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: const Text("Add Row", style: TextStyle(fontSize: 11, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: () {
                    if (_rowCount > 1) setState(() => _rowCount--);
                  },
                  icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                  label: const Text("Remove Row", style: TextStyle(fontSize: 11, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),

          // --- CONTAINER 2: TENGAH (TABEL DATA) ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 175, 172, 172),
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
                  headingRowColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 117, 117)),
                  border: TableBorder.all(color: borderGrey, width: 0.5),
                  columns: _buildStaticColumns(),
                  rows: List.generate(
                    _rowCount,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text("${index + 1}", style: const TextStyle(fontSize: 12))),
                        _buildModernTableCell("item_no_$index"),
                        _buildModernTableCell("jenis_brg_$index"),
                        _buildModernTableCell("desc_$index"),
                        _buildModernTableCell("jenis_item_$index"),
                        _buildModernTableCell("orbit_$index"),
                        _buildModernTableCell("details_$index"),
                        _buildModernTableCell("qty_$index", initial: "0"),
                        _buildModernTableCell("stock_$index", initial: "0"),
                        _buildModernTableCell("price_$index", initial: "0.00"),
                        _buildModernTableCell("p_service_$index", initial: "0.00"),
                        _buildModernTableCell("p_ref_$index", initial: "0.00"),
                        _buildModernTableCell("uom_$index"),
                        _buildModernTableCell("free_text_$index"),
                        _buildModernTableCell("proj_$index"),
                        _buildModernTableCell("line_$index"),
                        _buildModernTableCell("disc_$index", initial: "0.00"),
                        _buildModernTableCell("total_$index", initial: "0.00"),
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

  // --- HELPER UNTUK ISI CELL TABEL ---
  DataCell _buildModernTableCell(String key, {String initial = ""}) {
    final controller = _getCtrl(key, initial: initial);
    
    // Cek apakah kolom ini butuh format angka/uang
    bool isNumeric = key.contains("qty") || key.contains("stock") || 
                     key.contains("price") || key.contains("p_") || 
                     key.contains("total") || key.contains("disc");

    // Gunakan _getFn agar otomatis .00 saat pindah kursor
    final focusNode = _getFn(key, defaultValue: initial.isEmpty ? "0.00" : initial);

    return DataCell(
      SizedBox(
        width: 120,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: isNumeric ? TextAlign.right : TextAlign.left,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (val) {
            _fieldValues[key] = val;
            
            // Jika kolom harga berubah, hitung ulang Grand Total di footer secara real-time
            if (isNumeric) {
              setState(() {
                _syncTotalBeforeDiscount();
              });
            }
          },
        ),
      ),
    );
  }

  // --- HEADER KOLOM TABEL ---
  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white);
    return [
      const DataColumn(label: Text("#", style: headerStyle)),
      const DataColumn(label: Text("Item No.", style: headerStyle)),
      const DataColumn(label: Text("Jenis Barang dan Jasa", style: headerStyle)),
      const DataColumn(label: Text("Item Description", style: headerStyle)),
      const DataColumn(label: Text("Jenis Item", style: headerStyle)),
      const DataColumn(label: Text("Klasifikasi Orbit", style: headerStyle)),
      const DataColumn(label: Text("Item Details", style: headerStyle)),
      const DataColumn(label: Text("Quantity", style: headerStyle)),
      const DataColumn(label: Text("Quantity Stock", style: headerStyle)),
      const DataColumn(label: Text("Unit Price", style: headerStyle)),
      const DataColumn(label: Text("Price Service", style: headerStyle)),
      const DataColumn(label: Text("Price Reference", style: headerStyle)),
      const DataColumn(label: Text("UoM Name", style: headerStyle)),
      const DataColumn(label: Text("Free Text", style: headerStyle)),
      const DataColumn(label: Text("Project Line", style: headerStyle)),
      const DataColumn(label: Text("LineID", style: headerStyle)),
      const DataColumn(label: Text("Discount %", style: headerStyle)),
      const DataColumn(label: Text("Total (LC)", style: headerStyle)),
    ];
  }

  // --- FUNGSI SYNC TABEL KE FOOTER ---
  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;
    for (int i = 0; i < _rowCount; i++) {
      // Mengambil data dari kolom "total_$i" di tabel
      String val = _controllers["total_$i"]?.text ?? "0";
      totalAllRows += double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }
    // Update kotak "Total Before Discount" di footer
    _getCtrl("f_before_disc").text = totalAllRows.toStringAsFixed(2);
    _fieldValues["f_before_disc"] = totalAllRows.toStringAsFixed(2);
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
                _buildModernFieldRow("Customer Ref. No.", "h_ref"),
                _buildSmallDropdownRowModern("Local Currency", "h_curr", [
                  "IDR",
                  "USD",
                  "EUR",
                ]),
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
  double grandTotal = _getGrandTotal();
  _getCtrl("f_total_final").text = "IDR ${grandTotal.toStringAsFixed(2)}";

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SISI KIRI ---
            Expanded(
              child: Column(
                children: [
                  _buildSmallDropdownRowModern("Sales Employee", "f_employ", [""]),
                  _buildModernFieldRow("Owner", "f_owner"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
                ],
              ),
            ),
            
            const SizedBox(width: 60), 

            // --- SISI KANAN: RINCIAN PERHITUNGAN ---
            SizedBox(
              width: 350,
              child: Column(
                children: [
                  // Before Discount (Read Only dari mesin hitung)
                  _buildSummaryRowWithAutoValue("Total Before Discount", "f_before_disc", isReadOnly: false),

                  // BARIS DISCOUNT (Persen & Nominal)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const SizedBox(width: 140, child: Text("Discount", style: TextStyle(fontSize: 12))),
                        
                        // KOTAK PERSEN (isPercent: true agar tetap bulat misal 10)
                        SizedBox(
                          width: 60, 
                          child: _buildSummaryBox("f_disc_pct", isPercent: true, defaultValue: "0")
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4), 
                          child: Text("%", style: TextStyle(fontSize: 12))
                        ),
                        
                        // KOTAK NOMINAL (Otomatis keganti pas Persen diisi)
                        Expanded(child: _buildSummaryBox("f_disc_val")),
                      ],
                    ),
                  ),

                  // BARIS FREIGHT
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const SizedBox(width: 140, child: Text("Freight", style: TextStyle(fontSize: 12))),
                        const Icon(Icons.arrow_right_alt, size: 18, color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                        Expanded(child: _buildSummaryBox("f_freight")),
                      ],
                    ),
                  ),

                  // BARIS ROUNDING (Sinkron dengan Checkbox & Auto .00)
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
                onChanged: (v) {
                  setState(() {
                    _checkStates["cb_rounding"] = v!;
                    final controller = _getCtrl("f_rounding");
                    
                    if (v) {
                      // Pas dicheck: nek kosong/0, dadekno 0.00 ben rapi
                      if (controller.text.isEmpty || controller.text == "0") {
                        controller.text = "0.00";
                        _fieldValues["f_rounding"] = "0.00";
                      }
                    } else {
                      // Pas centang dicopot: balekno dadi 0.00 ben Grand Total gak keleru
                      controller.text = "0.00";
                      _fieldValues["f_rounding"] = "0.00";
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text("Rounding", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      Expanded(
        child: _buildSummaryBox(
          "f_rounding",
          isReadOnly: !(_checkStates["cb_rounding"] ?? false),
        ),
      ),
    ],
  ),
),

                  // BARIS TAX (Sesuai hitungan)
                  _buildSummaryRowWithAutoValue("Tax", "f_tax"),

                  const Divider(height: 20, thickness: 1),

                  // BARIS TOTAL AKHIR (Bold & ReadOnly)
                  _buildSummaryRowWithAutoValue(
                    "Total",
                    "f_total_final",
                    isBold: true,
                    isReadOnly: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 16),

      // --- TOMBOL AKSI (FOOTER BUTTONS) ---
      Row(
        children: [
          _buildSAPActionButton("Add", isPrimary: true),
          const SizedBox(width: 8),
          _buildSAPActionButton("Delete", isDanger: true),
          const Spacer(),
          _buildSAPActionButton("Copy From", customColor: Colors.blue.shade700),
          const SizedBox(width: 8),
          _buildSAPActionButton("Copy To", customColor: Colors.orange.shade600),
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
  String key, {
  String defaultValue = "0.00",
  bool isBold = false,
  bool isReadOnly = false, // Tambahkan ini
}) {
  final TextEditingController controller = _getCtrl(key, initial: _fieldValues[key] ?? defaultValue);
  
  if (!_focusNodes.containsKey(key)) {
    _focusNodes[key] = FocusNode();
    _focusNodes[key]!.addListener(() {
      if (!_focusNodes[key]!.hasFocus && !isReadOnly) {
        String text = controller.text;
        setState(() {
          double? parsed = double.tryParse(text.replaceAll(',', ''));
          controller.text = (parsed ?? 0.0).toStringAsFixed(2);
          _fieldValues[key] = controller.text;
        });
      }
    });
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: TextStyle(fontSize: 12, color: secondarySlate))),
        const SizedBox(width: 58),
        Expanded(
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: isReadOnly ? bgSlate : Colors.white,
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: controller,
              focusNode: _focusNodes[key],
              readOnly: isReadOnly,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), border: InputBorder.none),
              onChanged: (val) {
                if (!isReadOnly) {
                  _fieldValues[key] = val;
                  // OBAT KURSOR LOMPAT: Kunci posisi kursor di akhir
                  controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                  setState(() {}); 
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}
 Widget _buildSmallInputBox(String key) {
  final controller = _getCtrl(key);
  final focusNode = _getFn(key);

  return Container(
    width: 50,
    height: 24,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: borderGrey),
      borderRadius: BorderRadius.circular(4),
    ),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 11),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6),
      ),
      onChanged: (val) {
        _fieldValues[key] = val;
        if (key == "f_disc_pct") {
          double pct = double.tryParse(val) ?? 0;
          double beforeDisc = double.tryParse(
            _fieldValues["f_before_disc"]?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0'
          ) ?? 0;
          double discAmount = beforeDisc * (pct / 100);
          setState(() {
            _fieldValues["f_disc_val"] = discAmount.toStringAsFixed(2);
            _getCtrl("f_disc_val").text = discAmount.toStringAsFixed(2);
          });
        }
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
    ),
  );
}

 Widget _buildSummaryBox(
  String key, {
  String defaultValue = "0.00",
  bool isBold = false,
  bool isReadOnly = false,
  bool isPercent = false,
}) {
  final TextEditingController controller = _getCtrl(key, initial: _fieldValues[key] ?? defaultValue);
  final focusNode = _getFn(key, isReadOnly: isReadOnly, defaultValue: defaultValue, isPercent: isPercent);

  return Container(
    height: 24,
    alignment: Alignment.centerRight,
    decoration: BoxDecoration(
      color: isReadOnly ? bgSlate : Colors.white,
      border: Border.all(color: borderGrey),
      borderRadius: BorderRadius.circular(4),
    ),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: isReadOnly,
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, height: 1.1),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        border: InputBorder.none,
      ),
      onChanged: (val) {
        if (!isReadOnly) {
          _fieldValues[key] = val;

          // --- LOGIKA OTOMATIS: Persen (Kiri) -> Nominal (Kanan) ---
          if (key == "f_disc_pct") {
            // 1. Ambil nilai persen yang baru diketik
            double pct = double.tryParse(val) ?? 0;
            
            // 2. Ambil nilai Total Before Discount
            String beforeText = _getCtrl("f_before_disc").text.replaceAll(RegExp(r'[^0-9.]'), '');
            double before = double.tryParse(beforeText) ?? 0;
            
            // 3. Hitung nominal diskonnya
            double resultNominal = before * (pct / 100);
            
            // 4. Update kotak nominal (f_disc_val) secara instan
            _getCtrl("f_disc_val").text = resultNominal.toStringAsFixed(2);
            _fieldValues["f_disc_val"] = resultNominal.toStringAsFixed(2);
          }
          
          // --- LOGIKA SEBALIKNYA: Nominal (Kanan) -> Persen (Kiri) ---
          if (key == "f_disc_val") {
             double nominal = double.tryParse(val) ?? 0;
             String beforeText = _getCtrl("f_before_disc").text.replaceAll(RegExp(r'[^0-9.]'), '');
             double before = double.tryParse(beforeText) ?? 1; // avoid div by zero
             
             double resultPct = (nominal / before) * 100;
             
             // Update kotak persen (tanpa desimal banyak)
             _getCtrl("f_disc_pct").text = resultPct.toStringAsFixed(0);
             _fieldValues["f_disc_pct"] = resultPct.toStringAsFixed(0);
          }

          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          setState(() {}); // Update Grand Total di bawah secara real-time
        }
      },
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

  // 2. FUNGSI UNTUK MEMBUAT BARIS UPLOAD FILE
  Widget _buildFileUploadRow(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width:
                140, 
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                // Menjalankan File Picker
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                );

                if (result != null) {
                  setState(() {
                    // Simpan nama file ke dalam Map menggunakan key (misal: 'cfg_f1')
                    _formValues[key] = result.files.first.name;
                  });
                }
              },
              child: Container(
                height: 28, // Tinggi disesuaikan dengan field input lainnya
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: borderGrey,
                  ), // Menggunakan variabel borderGrey kamu
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formValues[key] ?? "No file selected",
                        style: TextStyle(
                          fontSize: 11,
                          color: _formValues[key] != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.upload_file, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                _buildChooseFromListField("Business Unit", "cfg_bu", [""]),
                _buildFileUploadRow("File 1", "cfg_f1"),
                _buildFileUploadRow("File 2", "cfg_f2"),
                _buildFileUploadRow("File 3", "cfg_f3"),
                _buildFileUploadRow("File 4", "cfg_f4"),
                _buildModernFieldRow("Create By", "cfg_by"),
                _buildSmallDropdownRowModern("Upload Status", "cfg_up", [
                  "No",
                  "Yes",
                ]),
                _buildSmallDropdownRowModern("Cutting Laser", "cfg_laser", [
                  "No",
                  "Yes",
                  "N/A",
                ]),
                _buildSmallDropdownRowModern("Punching", "cfg_punch", [
                  "No",
                  "Yes",
                  "N/A",
                ]),
                _buildSmallDropdownRowModern("Bending", "cfg_bend", [
                  "No",
                  "Yes",
                  "N/A",
                ]),
                _buildSmallDropdownRowModern("Assy", "cfg_assy", [
                  "No",
                  "Yes",
                  "N/A",
                ]),
                _buildSmallDropdownRowModern("SubCont", "cfg_sub", [
                  "No",
                  "Yes",
                  "N/A",
                ]),
                _buildModernFieldRow(
                  "Internal Memo",
                  "cfg_memo",
                  isTextArea: true,
                ),
                const Divider(height: 30),
                _buildModernFieldRow("Production Due Date", "cfg_prod_date"),
                _buildModernFieldRow("AP Tax Date", "cfg_tax_date"),
                _buildChooseFromListField("Kode Faktur Pajak", "cfg_tax_code", [
                  "010",
                  "020",
                ]),
                _buildModernFieldRow("Area", "cfg_area"),
                _buildChooseFromListField("Kategori SO", "cfg_cat", [
                  "SO Resmi",
                  "SO Sample",
                ]),
                _buildModernFieldRow("Customer Name", "cfg_cust_name"),
                _buildModernFieldRow(
                  "alasan rubah duedate",
                  "cfg_duedate",
                  isTextArea: true,
                ),
                _buildChooseFromListField("validasi PO", "cfg_validasi_po", [
                  "Lengkap",
                  "Tidak Lengkap",
                ]),
                _buildModernFieldRow(
                  "PIC Engineering",
                  "cfg_pic",
                  isTextArea: true,
                ),
                _buildSmallDropdownRowModern("Transfer DLM", "TF_dlm", [""]),
                _buildSmallDropdownRowModern("Transfer Dempo", "Tf_demp", [""]),
                _buildSmallDropdownRowModern("Status Pengiriman", "status", [
                  "",
                ]),
                _buildSmallDropdownRowModern(
                  "kelengkapan Utama",
                  "kelengkapan",
                  [""],
                ),
                const SizedBox(height: 20),
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
            width: 140, // Lebar label tetap 140
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                // Copy data asli ke variabel temporary buat difilter
                List<String> filteredList = List.from(data);

                showDialog(
                  context: context,
                  builder: (c) => StatefulBuilder(
                    // WAJIB ada ini biar bisa ngetik & list berubah
                    builder: (context, setDialogState) {
                      return AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pilih $label",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            // INI TEMPAT NGETIKNYA
                            TextField(
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: "Cari data...",
                                prefixIcon: const Icon(Icons.search, size: 16),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onChanged: (value) {
                                // Setiap ngetik, list di bawah langsung berubah
                                setDialogState(() {
                                  filteredList = data
                                      .where(
                                        (e) => e.toLowerCase().contains(
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
                          child: filteredList.isEmpty
                              ? const Center(
                                  child: Text("Data tidak ditemukan"),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        filteredList[index],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      onTap: () {
                                        setState(
                                          () => _getCtrl(key).text =
                                              filteredList[index],
                                        );
                                        Navigator.pop(c);
                                      },
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 30, // Tinggi tetap 30
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
