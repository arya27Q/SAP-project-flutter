import 'package:flutter/material.dart';
import '../../constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage>
    with SingleTickerProviderStateMixin {
  bool showSidePanel = false;
  late TabController _tabController;
  int _rowCount = 10;

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);
  final ScrollController _horizontalScroll = ScrollController();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkStates = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String?> _formValues = {};

  String formatPrice(String value) {
    String cleanText = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return "0,00";
    double parsed = double.tryParse(cleanText) ?? 0.0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    );

    return formatter.format(parsed);
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _fieldValues[key] ?? initial),
    );
  }

  FocusNode _getFn(
    String key, {
    bool isReadOnly = false,
    String defaultValue = "0,00",
    bool isPercent = false,
  }) {
    if (!_focusNodes.containsKey(key)) {
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus && !isReadOnly) {
          final controller = _getCtrl(key);

          if (controller.text.trim().isEmpty) {
            _fieldValues[key] = "";
            return;
          }

          bool isNumericField =
              key.contains("qty") ||
              key.contains("stock") ||
              key.contains("price") ||
              key.contains("total") ||
              key.contains("disc") ||
              key.contains("p_service") ||
              key.contains("p_ref") ||
              key.contains("f_before") ||
              key.contains("f_freight") ||
              key.contains("f_tax") ||
              key.contains("f_rounding");

          if (isNumericField) {
            // Bersihkan semua karakter non-angka termasuk % lama
            String cleanText = controller.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            double? parsed = double.tryParse(cleanText);

            if (mounted) {
              setState(() {
                if (parsed != null) {
                  if (isPercent) {
                    // UBAH DI SINI: Tambahkan simbol % setelah angka
                    controller.text = "${parsed.toStringAsFixed(0)}%";
                  } else {
                    controller.text = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: '',
                      decimalDigits: 2,
                    ).format(parsed);
                  }
                } else {
                  controller.text = defaultValue;
                }
                _fieldValues[key] = controller.text;

                _syncTotalBeforeDiscount();
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _fieldValues[key] = controller.text;
              });
            }
          }
        }
      });
      _focusNodes[key] = fn;
    }
    return _focusNodes[key]!;
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      String day = picked.day.toString().padLeft(2, '0');
      String month = picked.month.toString().padLeft(2, '0');
      String year = picked.year.toString();
      String formattedDate = "$day/$month/$year";

      setState(() {
        _getCtrl(key).text = formattedDate;
        _fieldValues[key] = formattedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    _focusNodes.forEach((_, f) => f.dispose());
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                RepaintBoundary(child: _buildModernHeader()),
                const SizedBox(height: 16),
                _buildTabSection(),
                const SizedBox(height: 16),
                _buildModernFooter(),
              ],
            ),
          ),
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

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
            decoration: BoxDecoration(
              color: primaryIndigo,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              labelColor: primaryIndigo,
              unselectedLabelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              tabs: const [
                Tab(text: "Contents"),
                Tab(text: "Logistics"),
                Tab(text: "Accounting"),
                Tab(text: "Attachments"),
              ],
              onTap: (index) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildContentsTab(),
                _buildLogisticsTab(),
                _buildAccountingTab(),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("Attachments Content"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: primaryIndigo, width: 2.5),
            ),
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
              _buildAddRowButtons(),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 500),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 246, 246, 246),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: borderGrey, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Scrollbar(
              controller: _horizontalScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScroll,
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: DataTable(
                    columnSpacing: 45,
                    horizontalMargin: 15,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.primaryIndigo,
                    ),
                    border: const TableBorder(
                      verticalInside: BorderSide(
                        color: Color.fromARGB(208, 166, 164, 164),
                        width: 0.5,
                      ),
                      horizontalInside: BorderSide(
                        color: Color.fromARGB(208, 166, 164, 164),
                        width: 0.5,
                      ),
                    ),
                    columns: _buildStaticColumns(),
                    rows: List.generate(_rowCount, (i) => _buildDataRow(i)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(int index) {
    return DataRow(
      cells: [
        DataCell(
          Center(
            child: Text("${index + 1}", style: const TextStyle(fontSize: 12)),
          ),
        ),
        _buildSearchableCell("item_no_$index"),
        _buildModernTableCell("desc_$index"),
        _buildModernTableCell("details_$index"),
        _buildModernTableCell("qty_$index", initial: "0"),
        _buildModernTableCell("uom_$index"),
        _buildModernTableCell("whse_$index"),
        _buildModernTableCell("price_$index", initial: "0,00"),
        _buildModernTableCell("disc_$index", initial: "0%", isPercent: true),
        _buildModernTableCell("tax_code_$index"),
        _buildModernTableCell("wtax_liable_$index"),
        _buildModernTableCell("material_$index"),
        _buildModernTableCell("material_from_$index"),
        _buildModernTableCell("project_line_$index"),
        _buildModernTableCell("optional_$index"),
        _buildModernTableCell("ref_item_$index"),
      ],
    );
  }

  Widget _buildAddRowButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => showSidePanel = true),
          style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo),
          child: const Text(
            "Add Item SO",
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _rowCount++),
          icon: const Icon(Icons.add_box, color: Colors.green),
        ),
        IconButton(
          onPressed: () => setState(() => _rowCount > 10 ? _rowCount-- : null),
          icon: const Icon(Icons.indeterminate_check_box, color: Colors.red),
        ),
      ],
    );
  }

  DataCell _buildModernTableCell(
    String key, {
    String initial = "",
    bool isPercent = false,
  }) {
    final controller = _getCtrl(key, initial: initial);

    bool isNumeric =
        key.contains("qty") ||
        key.contains("stock") ||
        key.contains("price") ||
        key.contains("total") ||
        key.contains("disc") ||
        key.contains("p_service") ||
        key.contains("p_ref") ||
        key.contains("f_before") ||
        key.contains("f_tax") ||
        key.contains("f_rounding");

    final focusNode = _getFn(
      key,
      defaultValue: isNumeric ? (isPercent ? "0%" : "0,00") : "",
      isPercent: isPercent,
    );

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: isNumeric ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
              ),
              onChanged: (val) {
                _fieldValues[key] = val;
                if (isNumeric) {
                  _syncTotalBeforeDiscount();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildStaticColumns() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    DataColumn centeredHeader(String label) {
      return DataColumn(
        label: Expanded(
          child: Center(child: Text(label, style: headerStyle)),
        ),
      );
    }

    return [
      centeredHeader("#"),
      centeredHeader("Item No."),
      centeredHeader("Item Description"),
      centeredHeader("Item Details"),
      centeredHeader("Quantity"),
      centeredHeader("UoM Name"),
      centeredHeader("Whse"),
      centeredHeader("Unit Price"),
      centeredHeader("Discount %"),
      centeredHeader("Tax Code"),
      centeredHeader("WTax Liable"),
      centeredHeader("Material"),
      centeredHeader("Material From"),
      centeredHeader("Project Line"),
      centeredHeader("Optional"),
      centeredHeader("Ref Item"),
    ];
  }

  DataCell _buildSearchableCell(String key) {
    return DataCell(
      InkWell(
        onTap: () {
          List<String> dummyData = [
            "Option A",
            "Option B",
            "Option C",
            "Option D",
          ];
          _showSearchDialog("Select Item", key, dummyData);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 120,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fieldValues[key] ?? _controllers[key]?.text ?? "",
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;
    for (int i = 0; i < _rowCount; i++) {
      String val =
          _fieldValues["total_$i"] ?? _controllers["total_$i"]?.text ?? "0";
      totalAllRows +=
          double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }
    setState(() {
      _getCtrl("f_before_disc").text = totalAllRows.toStringAsFixed(2);
      _fieldValues["f_before_disc"] = totalAllRows.toStringAsFixed(2);
    });
  }

  Widget _buildLogisticsTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildModernFieldRow("Ship To", "log_ship_to", isTextArea: true),
              const SizedBox(height: 12),
              _buildModernFieldRow("Bill To", "log_bill_to", isTextArea: true),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Shipping Type", "log_ship_type", [
                "",
              ]),
            ],
          ),
        ),
        const SizedBox(width: 60),
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
              const SizedBox(height: 20),
              _buildModernFieldRow("Pick and Pack Remarks", "log_pick_rem"),
              const SizedBox(height: 12),
              _buildModernFieldRow("BP Channel Name", "log_bp_name"),
              const SizedBox(height: 12),
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

  Widget _buildAccountingTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildModernFieldRow("Journal Remark", "acc_journal"),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Payment Terms", "acc_pay_terms", [
                "",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Payment Method", "acc_pay_method", [
                "",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern(
                "Central Bank Ind.",
                "acc_central_bank",
                [""],
              ),
              const SizedBox(height: 12),
              _buildModernFieldRow("Manually Due Date", "acc_manual_due"),
              const SizedBox(height: 12),
              _buildModernFieldRow(
                "Cash Discount Date Offset",
                "acc_cash_disc",
              ),
              const SizedBox(height: 12),
              _buildModernCheckbox(
                "Use Shipped Goods Account",
                "cb_shipped_acc",
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: Column(
            children: [
              _buildModernFieldRow("BP Project", "acc_bp_proj"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Cancellation Date", "acc_cancel_date"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Required Date", "acc_req_date"),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Indicator", "acc_indicator", [""]),
              const SizedBox(height: 12),
              _buildModernFieldRow("Federal Tax ID", "acc_tax_id"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Order Number", "acc_order_no"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Referenced Document", "acc_ref_doc"),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildModernHeader() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.white, width: 3.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 18,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildModernFieldRow("Customer", "h_cust"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Name", "h_name"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Contact Person", "h_cont"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Customer Ref. No.", "h_ref"),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Currency", "h_curr", [
                "IDR",
                "USD",
                "EUR",
              ]),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildModernNoFieldRow(
                "No.",
                "h_no_series",
                ["2025-COM"],
                "h_no_val",
                initialNo: "256100727",
              ),
              const SizedBox(height: 12),
              _buildModernFieldRow("Status", "h_stat", initial: "Open"),
              const SizedBox(height: 12),
              _buildHeaderDate("Posting Date", "h_post", ""),
              const SizedBox(height: 12),
              _buildHeaderDate("Delivery Date", "h_deliv", ""),
              const SizedBox(height: 12),
              _buildHeaderDate("Document Date", "h_doc", ""),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildModernFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SISI KIRI FOOTER (Sales Employee, Owner, Remarks)
              Expanded(
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern("Sales Employee", "f_employ", [
                      "",
                    ]),
                    const SizedBox(height: 12),
                    _buildModernFieldRow("Owner", "f_owner"),
                    const SizedBox(height: 12),
                    _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              // SISI KANAN FOOTER (KOSONG SESUAI PERMINTAAN)
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildActionButtons(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
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
  );

  Widget _buildSAPActionButton(
    String label, {
    bool isPrimary = false,
    bool isDanger = false,
    Color? customColor,
  }) {
    Color bgColor = isDanger
        ? Colors.red
        : (isPrimary ? primaryIndigo : (customColor ?? Colors.white));
    return ElevatedButton(
      onPressed: () => debugPrint("Klik $label"),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isTextArea = false,
    String initial = "",
  }) => Padding(
    padding: EdgeInsets.zero,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
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
            height: isTextArea ? 80 : 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderGrey),
            ),
            child: Center(
              child: TextField(
                controller: _getCtrl(key, initial: initial),
                maxLines: isTextArea ? 3 : 1,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (val) => _fieldValues[key] = val,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildModernNoFieldRow(
    String label,
    String dropdownKey,
    List<String> seriesOptions,
    String textKey, {
    String initialNo = "",
  }) => Padding(
    padding: EdgeInsets.zero,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
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
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderGrey),
            ),
            child: Row(
              children: [
                Container(
                  width: 110,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5),
                    ),
                    border: Border(right: BorderSide(color: borderGrey)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          _dropdownValues[dropdownKey] ?? seriesOptions.first,
                      isDense: true,
                      style: const TextStyle(fontSize: 11, color: Colors.black),
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
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _getCtrl(textKey, initial: initialNo),
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (val) => _fieldValues[textKey] = val,
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

  Widget _buildModernCheckbox(String label, String key) => Row(
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

  Widget _buildSmallDropdownRowModern(
    String label,
    String key,
    List<String> items,
  ) => Padding(
    padding: EdgeInsets.zero,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: secondarySlate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: _buildSmallDropdown(key, items)),
      ],
    ),
  );

  Widget _buildChooseFromListField(
    String label,
    String key,
    List<String> data,
  ) => Padding(
    padding: EdgeInsets.zero,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
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
          child: InkWell(
            onTap: () => _showSearchDialog(label, key, data),
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderGrey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getCtrl(key).text.isEmpty
                              ? (data.isNotEmpty ? data.first : "")
                              : _getCtrl(key).text,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
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

  void _showSearchDialog(String label, String key, List<String> data) {
    List<String> filteredList = List.from(data);
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Pilih $label", style: const TextStyle(fontSize: 14)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Cari data...",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setDialogState(
                    () => filteredList = data
                        .where((e) => e.toLowerCase().contains(v.toLowerCase()))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(filteredList[i]),
                      onTap: () {
                        setState(() {
                          _getCtrl(key).text = filteredList[i];
                          _fieldValues[key] = filteredList[i];
                        });
                        Navigator.pop(c);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadRow(String label, String key) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
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
          child: InkWell(
            onTap: () async {
              FilePickerResult? res = await FilePicker.platform.pickFiles();
              if (res != null)
                setState(() => _formValues[key] = res.files.first.name);
            },
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderGrey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formValues[key] ?? "No file selected",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.upload_file,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildHeaderDate(String label, String key, String initial) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: secondarySlate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, key),
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderGrey),
              ),
              child: IgnorePointer(
                child: TextField(
                  controller: _getCtrl(key, initial: initial),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingSidePanel() => Container(
    width: 380,
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(-2, 0)),
      ],
    ),
    child: Column(
      children: [
        AppBar(
          backgroundColor: primaryIndigo,
          title: const Text(
            "Sales Order",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () => setState(() => showSidePanel = false),
              icon: const Icon(Icons.close),
              color: Colors.white,
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildChooseFromListField("Business Unit", "cfg_bu", [""]),
              const SizedBox(height: 12),
              _buildFileUploadRow("File 1", "cfg_f1"),
              const SizedBox(height: 8),
              _buildFileUploadRow("File 2", "cfg_f2"),
              const SizedBox(height: 8),
              _buildFileUploadRow("File 3", "cfg_f3"),
              const SizedBox(height: 8),
              _buildFileUploadRow("File 4", "cfg_f4"),
              const SizedBox(height: 12),
              _buildModernFieldRow("Create By", "cfg_by"),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Upload Status", "cfg_up", [
                "No",
                "Yes",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Cutting Laser", "cfg_laser", [
                "No",
                "Yes",
                "N/A",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Punching", "cfg_punch", [
                "No",
                "Yes",
                "N/A",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Bending", "cfg_bend", [
                "No",
                "Yes",
                "N/A",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Assy", "cfg_assy", [
                "No",
                "Yes",
                "N/A",
              ]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("SubCont", "cfg_sub", [
                "No",
                "Yes",
                "N/A",
              ]),
              const SizedBox(height: 12),
              _buildModernFieldRow(
                "Internal Memo",
                "cfg_memo",
                isTextArea: true,
              ),
              const Divider(height: 45, thickness: 3),
              _buildModernFieldRow("Production Due date", "cfg_prod_date"),
              const SizedBox(height: 12),
              _buildModernFieldRow("AP Tax Date", "cfg_tax_date"),
              const SizedBox(height: 12),
              _buildChooseFromListField("Kode Faktur Pajak", "cfg_tax_code", [
                "010",
                "020",
              ]),
              const SizedBox(height: 12),
              _buildModernFieldRow("Area", "cfg_area"),
              const SizedBox(height: 12),
              _buildChooseFromListField("Kategori SO", "cfg_cat", [
                "SO Resmi",
                "SO Sample",
              ]),
              const SizedBox(height: 12),
              _buildModernFieldRow("Customer Name", "cfg_cust_name"),
              const SizedBox(height: 12),
              _buildModernFieldRow(
                "alasan rubah duedate",
                "cfg_duedate",
                isTextArea: true,
              ),
              const SizedBox(height: 12),
              _buildChooseFromListField("validasi PO", "cfg_validasi_po", [
                "Lengkap",
                "Tidak Lengkap",
              ]),
              const SizedBox(height: 12),
              _buildModernFieldRow(
                "PIC Engineering",
                "cfg_pic",
                isTextArea: true,
              ),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Transfer DLM", "TF_dlm", [""]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Transfer Dempo", "Tf_demp", [""]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("Status Pengiriman", "status", [""]),
              const SizedBox(height: 12),
              _buildSmallDropdownRowModern("kelengkapan Utama", "kelengkapan", [
                "",
              ]),
              const SizedBox(height: 30),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    ),
  );
}
