import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_outgoing_mean_page.dart';

class OutgoingPaymentPage extends StatefulWidget {
  const OutgoingPaymentPage({super.key});

  @override
  State<OutgoingPaymentPage> createState() => _OutgoingPaymentPageState();
}

class _OutgoingPaymentPageState extends State<OutgoingPaymentPage>
    with SingleTickerProviderStateMixin {
  bool showSidePanel = false;
  late TabController _tabController;
  int _rowCount = 10;
  String? _selectedCategory = 'Customer'; // Nilai default

  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color(0xFFF8FAFC); // Update ke warna pucat
  final Color secondarySlate = const Color(0xFF64748B);
  final Color borderGrey = const Color(0xFFD0D5DC);
  final ScrollController _horizontalScroll = ScrollController();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String> _fieldValues = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, bool> _checkStates = {};

  // --- STYLE SETTINGS (UPDATED) ---
  final double _inputHeight = 40.0; // Tinggi 40 biar sama kayak referensi
  final BorderRadius _inputRadius = BorderRadius.circular(10); // Radius 10

  // Shadow Ungu Halus
  List<BoxShadow> get _softShadow => [
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
      ];

  // Border Tipis Indigo
  Border get _thinBorder => Border.all(
      color: const Color(0xFF4F46E5).withValues(alpha: 0.15), width: 1);

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

          bool isNumericField = key.contains("qty") ||
              key.contains("stock") ||
              key.contains("price") ||
              key.contains("total") ||
              key.contains("disc") ||
              key.contains("wtax") ||
              key.contains("overdue") ||
              key.contains("balance") ||
              key.contains("rounding") ||
              key.contains("pay") ||
              key.contains("val") ||
              key.contains("f_before") ||
              key.contains("f_freight") ||
              key.contains("f_tax") ||
              key.contains("Net_Total");

          if (isNumericField) {
            String cleanText = controller.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            double? parsed = double.tryParse(cleanText);

            if (mounted) {
              setState(() {
                if (parsed != null) {
                  if (isPercent) {
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

  double _getGrandTotal() {
    double parseValue(String key) {
      String val = _controllers[key]?.text ?? _fieldValues[key] ?? "0";
      String cleanVal = val
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll('IDR', '')
          .trim();
      return double.tryParse(cleanVal) ?? 0.0;
    }

    double netTotal = parseValue("Net_Total");
    double tax = parseValue("f_freight");

    return netTotal + tax;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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

  Widget _buildModernHeader() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernFieldRow("Code", "p_code"),
                  const SizedBox(height: 8),
                  _buildModernFieldRow("Name", "h_name"),
                  const SizedBox(height: 12),
                  _buildModernNoFieldRow(
                    "Bill to",
                    "p_no_series",
                    const [""],
                    "p_no_val",
                    initialNo:
                        "Desa Wonokoyo, Beji, Beji, Kab. Pasuruan, Jawa Timur, 67154",
                    isAddress: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Contact Person", "h_contact"),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("blanket agreement", "p_blanket"),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 148),
                    child: RadioGroup<String>(
                      groupValue: _selectedCategory,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedCategory = v);
                        }
                      },
                      child: Row(
                        children: [
                          _buildCategoryRadio("Customer"),
                          const SizedBox(width: 16),
                          _buildCategoryRadio("Vendor"),
                          const SizedBox(width: 16),
                          _buildCategoryRadio("Account"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildModernFieldRow("No", "h_no", initial: ""),
                  const SizedBox(height: 12),
                  _buildHeaderDate("Posting Date", "h_post_date", ""),
                  const SizedBox(height: 12),
                  _buildHeaderDate("Delivery Date", "h_deliv", ""),
                  const SizedBox(height: 12),
                  _buildHeaderDate("Document Date", "h_doc", ""),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Refrence", "ref", initial: ""),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Transaction No", "Trans_No",
                      initial: ""),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Wtax Code", "Wtax_code", initial: ""),
                  const SizedBox(height: 12),
                  _buildModernFieldRow("Wtax Base Sum", "Wtax_sum",
                      initial: ""),
                ],
              ),
            ),
          ],
        ),
      );

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
            color: Colors.black.withValues(alpha: 0.12),
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
              key: ValueKey(_tabController.length),
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
            color: const Color.fromARGB(255, 255, 255, 255),
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
                    headingRowColor: WidgetStateProperty.all(primaryIndigo),
                    border: TableBorder(
                      verticalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      horizontalInside: BorderSide(
                        color: primaryIndigo.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    columns: _buildStaticColumns(),
                    rows: List.generate(
                      _rowCount,
                      (index) => _buildDataRow(index),
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

  DataRow _buildDataRow(int index) {
    bool isSelected = _checkStates["row_sel_$index"] ?? false;

    return DataRow(
      selected: isSelected,
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (isSelected) return const Color(0xFFFFF29D);
        return null;
      }),
      cells: [
        DataCell(
          Center(
            child: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  _checkStates["row_sel_$index"] = value ?? false;
                });
              },
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_right_alt, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                _fieldValues["doc_no_$index"] ?? "",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        _buildModernTableCell("install_$index", initial: ""),
        _buildModernTableCell("doc_type_$index", initial: ""),
        _buildDateCell(index, "doc_date"),
        _buildModernTableCell("star_$index", initial: ""),
        _buildModernTableCell("overdue_$index", initial: ""),
        _buildModernTableCell("total_val_$index", initial: ""),
        _buildModernTableCell("wtax_$index", initial: ""),
        _buildModernTableCell("balance_$index", initial: ""),
        _buildModernTableCell("blocked_$index", initial: ""),
        _buildModernTableCell(
          "cash_disc_$index",
          initial: "0%",
          isPercent: true,
        ),
        _buildModernTableCell("rounding_$index", initial: ""),
        _buildModernTableCell("total_pay_$index", initial: ""),
        _buildModernTableCell("dim1_$index", initial: ""),
        DataCell(
          Center(
            child: Checkbox(
              value: _checkStates["pay_order_$index"] ?? false,
              onChanged: (v) =>
                  setState(() => _checkStates["pay_order_$index"] = v!),
            ),
          ),
        ),
      ],
    );
  }

  DataCell _buildDateCell(int index, String key) {
    return DataCell(
      InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            setState(() {
              String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
              _getCtrl("${key}_$index").text = formattedDate;
              _fieldValues["${key}_$index"] = formattedDate;
            });
          }
        },
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: TextField(
            controller: _getCtrl("${key}_$index"),
            enabled: false,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: "Select Date",
            ),
          ),
        ),
      ),
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

    bool isNumeric = key.contains("qty") ||
        key.contains("stock") ||
        key.contains("price") ||
        key.contains("total") ||
        key.contains("wtax") ||
        key.contains("overdue") ||
        key.contains("balance") ||
        key.contains("cash") ||
        key.contains("rounding") ||
        key.contains("val") ||
        key.contains("pay");

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

    DataColumn sapHeader(String label, {bool isCenter = true}) {
      return DataColumn(
        label: isCenter
            ? Expanded(
                child: Text(
                  label,
                  style: headerStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : Text(label, style: headerStyle),
      );
    }

    return [
      sapHeader("Selected", isCenter: true),
      sapHeader("Document No."),
      sapHeader("Installment"),
      sapHeader("Document Type"),
      sapHeader("Date"),
      sapHeader("*"),
      sapHeader("Overdue Days"),
      sapHeader("Total"),
      sapHeader("WTax Amount"),
      sapHeader("Balance Due"),
      sapHeader("Blocked"),
      sapHeader("Cash Discount %"),
      sapHeader("Total Rounding Amount"),
      sapHeader("Total Payment"),
      sapHeader("Dimension 1"),
      sapHeader("Payment Or...", isCenter: true),
    ];
  }

  void _syncTotalBeforeDiscount() {
    double totalAllRows = 0;
    for (int i = 0; i < _rowCount; i++) {
      String val = _controllers["total_val_$i"]?.text ??
          _fieldValues["total_val_$i"] ??
          "0";

      String cleanVal = val
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll('IDR', '')
          .trim();
      totalAllRows += double.tryParse(cleanVal) ?? 0;
    }

    setState(() {
      String formatted = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 2,
      ).format(totalAllRows);

      _getCtrl("Net_Total").text = formatted;
      _fieldValues["Net_Total"] = formatted;
    });
  }

  Widget _buildModernFooter() {
    double grandTotal = _getGrandTotal();

    String formattedTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    ).format(grandTotal);

    _getCtrl("f_total_final").text = "IDR $formattedTotal";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
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
                child: Column(
                  children: [
                    _buildSmallDropdownRowModern("Journal Remark", "f_employ", [
                      "",
                    ]),
                    const SizedBox(height: 12),
                    _buildModernFieldRow("Remarks", "f_rem", isTextArea: true),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 120),
                          const SizedBox(width: 28),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _checkStates["created_by_wizard"] ??
                                      false,
                                  activeColor: primaryIndigo,
                                  side: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkStates["created_by_wizard"] =
                                          value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Created by Payment Wizard",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
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
              const SizedBox(width: 60),
              SizedBox(
                width: 450,
                child: Column(
                  children: [
                    _buildSummaryRowWithAutoValue("Net Total ", "Net_Total"),
                    const SizedBox(height: 2),
                    _buildSummaryRowWithAutoValue("Total Tax", "f_freight"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 1),
                    ),
                    _buildSummaryRowWithAutoValue(
                      "Total Amount",
                      "f_total_final",
                      isBold: true,
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentOutgoingMeanPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text(
                          "Payment Means",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          shadowColor: Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildHeaderDate(String label, String key, String initial) {
    return Row(
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
        const SizedBox(width: 28),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, key),
            borderRadius: _inputRadius,
            child: Container(
              height: _inputHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IgnorePointer(
                        child: TextField(
                          controller: _getCtrl(key, initial: initial),
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color:
                          primaryIndigo.withValues(alpha: 0.6), // Icon Indigo
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildSAPActionButton("Add", isPrimary: true),
            const SizedBox(width: 8),
            _buildSAPActionButton("Cancel", isDanger: true),
          ],
        ),
      );

  Widget _buildSummaryRowWithAutoValue(
    String label,
    String key, {
    String defaultValue = "0.00",
    bool isBold = false,
    bool isReadOnly = false,
  }) {
    final controller = _getCtrl(
      key,
      initial: _fieldValues[key] ?? defaultValue,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: secondarySlate),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: isReadOnly ? bgSlate : Colors.white,
                border: _thinBorder, // Border Ungu
                borderRadius: BorderRadius.circular(10), // Radius 10
                boxShadow: _softShadow, // Shadow
              ),
              child: TextField(
                controller: controller,
                readOnly: isReadOnly,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                ),
                onChanged: (val) {
                  if (!isReadOnly) setState(() => _fieldValues[key] = val);
                },
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
    bool isDecimal = false,
  }) {
    String effectiveInitial = (isDecimal && initial.isEmpty) ? "0.00" : initial;
    final controller = _getCtrl(key, initial: effectiveInitial);
    FocusNode? focusNode = isDecimal ? _getFn(key, defaultValue: "0.00") : null;

    return Padding(
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
          const SizedBox(width: 28),
          Expanded(
            child: Container(
              height: isTextArea ? 80 : _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: isTextArea ? 3 : 1,
                  textAlign: TextAlign.left,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    _fieldValues[key] = val;
                  },
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
    bool isAddress = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondarySlate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
            Container(
              width: 110,
              height: _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _inputRadius,
                border: _thinBorder, // Border Ungu
                boxShadow: _softShadow, // Shadow
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValues[dropdownKey] ?? seriesOptions.first,
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: primaryIndigo.withValues(alpha: 0.6), // Icon Indigo
                  ),
                  style: const TextStyle(fontSize: 11, color: Colors.black),
                  onChanged: (v) =>
                      setState(() => _dropdownValues[dropdownKey] = v!),
                  items: seriesOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: isAddress ? 80 : _inputHeight,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _inputRadius,
                  border: _thinBorder, // Border Ungu
                  boxShadow: _softShadow, // Shadow
                ),
                child: TextField(
                  controller: _getCtrl(textKey, initial: initialNo),
                  maxLines: isAddress ? 4 : 1,
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
          ],
        ),
      );

  Widget _buildSmallDropdown(String key, List<String> items) {
    if (!_dropdownValues.containsKey(key)) _dropdownValues[key] = items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: _inputHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _inputRadius,
        border: _thinBorder, // Border Ungu
        boxShadow: _softShadow, // Shadow
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValues[key],
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          icon: Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: primaryIndigo.withValues(alpha: 0.6), // Icon Indigo
          ),
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
  ) =>
      Padding(
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
            const SizedBox(width: 28),
            Expanded(child: _buildSmallDropdown(key, items)),
          ],
        ),
      );

  Widget _buildChooseFromListField(
    String label,
    String key,
    List<String> data,
  ) =>
      Padding(
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
            const SizedBox(width: 28),
            Expanded(
              child: InkWell(
                onTap: () => _showSearchDialog(label, key, data),
                child: Container(
                  height: _inputHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _inputRadius,
                    border: _thinBorder, // Border Ungu
                    boxShadow: _softShadow, // Shadow
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
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.search,
                          size: 16,
                          color: primaryIndigo.withValues(
                              alpha: 0.6), // Icon Indigo
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

  Widget _buildFloatingSidePanel() => Container(
        width: 380,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(-2, 0)),
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
                  _buildModernFieldRow("FP No.", "cfg_fp_no"),
                  const SizedBox(height: 12),
                  _buildHeaderDate("FP Date", "cfg_fp_date", ""),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "Total Amount",
                    "cfg_total_amt",
                    isDecimal: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModernFieldRow(
                    "No kas bon",
                    "cfg_nokasbon",
                    isDecimal: true,
                  ),
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

  Widget _buildCategoryRadio(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Radio<String>(
            value: title,
            activeColor: primaryIndigo,
            //  groupValue dan onChanged SUDAH DIHAPUS DARI SINI
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: secondarySlate, // Pastikan variabel warna lu aman ya
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
