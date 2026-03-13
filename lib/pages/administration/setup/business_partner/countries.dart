import 'package:flutter/material.dart';

// ==========================================
// 1. CLASS MODEL DATA NEGARA
// ==========================================
class CountryModel {
  String code;
  String name;
  String repCode;
  String addrFormat;
  bool isEU;
  String taxIdDigits;
  String bankCodeDigits;
  String branchDigits;
  String accNoDigits;
  String ctrlNoDigits;
  String domBankVal;
  bool ibanVal;

  CountryModel({
    required this.code,
    required this.name,
    required this.repCode,
    required this.addrFormat,
    required this.isEU,
    required this.taxIdDigits,
    required this.bankCodeDigits,
    required this.branchDigits,
    required this.accNoDigits,
    required this.ctrlNoDigits,
    required this.domBankVal,
    required this.ibanVal,
  });
}

// ==========================================
// 2. CLASS TAMPILAN HALAMAN (UI MODERN)
// ==========================================
class CountriesSetupPage extends StatefulWidget {
  const CountriesSetupPage({super.key});

  @override
  State<CountriesSetupPage> createState() => _CountriesSetupPageState();
}

class _CountriesSetupPageState extends State<CountriesSetupPage> {
  // --- WARNA TEMA MODERN ---
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  // --- CONTROLLERS ---
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _repCodeCtrl = TextEditingController();
  final TextEditingController _taxIdCtrl = TextEditingController();
  final TextEditingController _bankCodeCtrl = TextEditingController();
  final TextEditingController _branchCtrl = TextEditingController();
  final TextEditingController _accNoCtrl = TextEditingController();
  final TextEditingController _ctrlNoCtrl = TextEditingController();

  final ScrollController _horizontalScrollCtrl = ScrollController();

  // --- STATE DROPDOWN & CHECKBOX FORM ---
  String _selectedAddrFormat = 'European Standard Address';
  String _selectedDomBankVal = '';
  bool _isEU = false;
  bool _ibanVal = false;

  final List<String> _addrFormatOptions = [
    'European Standard Address',
    'Zip Code Before City',
    'USA',
    'Blank'
  ];
  final List<String> _domBankValOptions = ['', 'Yes', 'No'];

  // --- DATA DUMMY ---
  List<CountryModel> _countryList = [
    CountryModel(
        code: "DE",
        name: "Germany",
        repCode: "DE",
        addrFormat: "Zip Code Before City",
        isEU: true,
        taxIdDigits: "9",
        bankCodeDigits: "8",
        branchDigits: "",
        accNoDigits: "10",
        ctrlNoDigits: "",
        domBankVal: "Yes",
        ibanVal: true),
    CountryModel(
        code: "ID",
        name: "Indonesia",
        repCode: "ID",
        addrFormat: "Blank",
        isEU: false,
        taxIdDigits: "15",
        bankCodeDigits: "",
        branchDigits: "",
        accNoDigits: "",
        ctrlNoDigits: "",
        domBankVal: "",
        ibanVal: false),
  ];

  // --- FUNGSI TAMBAH DATA ---
  void _tambahData() {
    if (_codeCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code dan Name harus diisi!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _countryList.add(
        CountryModel(
          code: _codeCtrl.text,
          name: _nameCtrl.text,
          repCode: _repCodeCtrl.text,
          addrFormat: _selectedAddrFormat,
          isEU: _isEU,
          taxIdDigits: _taxIdCtrl.text,
          bankCodeDigits: _bankCodeCtrl.text,
          branchDigits: _branchCtrl.text,
          accNoDigits: _accNoCtrl.text,
          ctrlNoDigits: _ctrlNoCtrl.text,
          domBankVal: _selectedDomBankVal,
          ibanVal: _ibanVal,
        ),
      );
    });

    // Clear form
    _codeCtrl.clear();
    _nameCtrl.clear();
    _repCodeCtrl.clear();
    _taxIdCtrl.clear();
    _bankCodeCtrl.clear();
    _branchCtrl.clear();
    _accNoCtrl.clear();
    _ctrlNoCtrl.clear();
    _isEU = false;
    _ibanVal = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Negara berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hapusData(int index) {
    setState(() {
      _countryList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _repCodeCtrl.dispose();
    _taxIdCtrl.dispose();
    _bankCodeCtrl.dispose();
    _branchCtrl.dispose();
    _accNoCtrl.dispose();
    _ctrlNoCtrl.dispose();
    _horizontalScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // HEADER FORM INPUT (KOTAK MODERN)
              // ==========================================
              Container(
                padding: const EdgeInsets.all(24),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.public, color: primaryIndigo, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Setup Master Countries",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- BARIS 1 ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .end, // Memaksa semua sejajar di bawah
                      children: [
                        Expanded(
                            flex: 2,
                            child:
                                _buildModernVerticalField("Code", _codeCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 3,
                            child:
                                _buildModernVerticalField("Name", _nameCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 2,
                            child: _buildModernVerticalField(
                                "Code for Reports", _repCodeCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 3,
                            child: _buildModernVerticalDropdown(
                                "Address Format",
                                _selectedAddrFormat,
                                _addrFormatOptions,
                                (val) => setState(
                                    () => _selectedAddrFormat = val!))),
                        const SizedBox(width: 12),

                        // 🔥 CHECKBOX EU 🔥
                        Expanded(
                          flex: 1,
                          child: _buildCheckboxField("EU", _isEU,
                              (val) => setState(() => _isEU = val!)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- BARIS 2 ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: _buildModernVerticalField(
                                "Tax ID Digits", _taxIdCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Bank Code Digits", _bankCodeCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Branch Digits", _branchCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Account No. Digits", _accNoCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Control No. Digits", _ctrlNoCtrl,
                                isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- BARIS 3 ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildModernVerticalDropdown(
                              "Domestic Bank Acct. Validation",
                              _selectedDomBankVal,
                              _domBankValOptions,
                              (val) =>
                                  setState(() => _selectedDomBankVal = val!)),
                        ),
                        const SizedBox(width: 12),

                        // 🔥 CHECKBOX IBAN 🔥
                        Expanded(
                          flex: 2,
                          child: _buildCheckboxField(
                              "IBAN Validation",
                              _ibanVal,
                              (val) => setState(() => _ibanVal = val!),
                              sideLabel: "Enable"),
                        ),
                        const SizedBox(width: 12),

                        const Expanded(
                            flex: 3, child: SizedBox()), // Spasi kosong
                        const SizedBox(width: 12),

                        // TOMBOL TAMBAH
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height:
                                40, // Sama persis dengan tinggi container input
                            child: ElevatedButton.icon(
                              onPressed: _tambahData,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Tambah",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryIndigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 4,
                                shadowColor:
                                    primaryIndigo.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // BAGIAN TABEL DATA (HORIZONTAL SCROLL)
              // ==========================================
              Container(
                height: 650,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Scrollbar(
                  controller: _horizontalScrollCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1800, // Dilebarin karena kolomnya banyak
                      child: Column(
                        children: [
                          // --- HEADER TABEL CUSTOM ---
                          Container(
                            color: primaryIndigo,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            child: Row(
                              children: [
                                _buildHeaderCell("#",
                                    flex: 1, showDivider: true),
                                _buildHeaderCell("Code",
                                    flex: 2, showDivider: true),
                                _buildHeaderCell("Name",
                                    flex: 4, showDivider: true),
                                _buildHeaderCell("Report Code",
                                    flex: 3, showDivider: true),
                                _buildHeaderCell("Address Format",
                                    flex: 4, showDivider: true),
                                _buildHeaderCell("EU",
                                    flex: 1, showDivider: true),
                                _buildHeaderCell("Tax ID Digits",
                                    flex: 2, showDivider: true),
                                _buildHeaderCell("Bank Code Digits",
                                    flex: 2, showDivider: true),
                                _buildHeaderCell("Branch Digits",
                                    flex: 2, showDivider: true),
                                _buildHeaderCell("Acc No. Digits",
                                    flex: 2, showDivider: true),
                                _buildHeaderCell("Ctrl No. Digits",
                                    flex: 2, showDivider: true),
                                _buildHeaderCell("Dom. Bank Val.",
                                    flex: 3, showDivider: true),
                                _buildHeaderCell("IBAN Val.",
                                    flex: 2, showDivider: true),
                                const SizedBox(
                                    width: 60,
                                    child: Center(
                                        child: Text("Aksi",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)))),
                              ],
                            ),
                          ),

                          // --- ISI TABEL SCROLLABLE ---
                          Expanded(
                            child: ListView.separated(
                              itemCount: _countryList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 6),
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 20),
                              itemBuilder: (context, index) {
                                final data = _countryList[index];

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryIndigo.withValues(
                                            alpha: 0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell('${index + 1}',
                                          flex: 1,
                                          isDim: true,
                                          showDivider: true),

                                      // Badge Code Negara
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color:
                                                          Colors.grey.shade200,
                                                      width: 1))),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.teal
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                data.code,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        Colors.teal.shade900),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      _buildDataCell(data.name,
                                          flex: 4,
                                          showDivider: true,
                                          isBold: true),
                                      _buildDataCell(data.repCode,
                                          flex: 3, showDivider: true),
                                      _buildDataCell(data.addrFormat,
                                          flex: 4, showDivider: true),

                                      // Status EU dengan Icon/Text biar rapi
                                      _buildStatusCell(data.isEU,
                                          flex: 1, showDivider: true),

                                      _buildDataCell(data.taxIdDigits,
                                          flex: 2, showDivider: true),
                                      _buildDataCell(data.bankCodeDigits,
                                          flex: 2, showDivider: true),
                                      _buildDataCell(data.branchDigits,
                                          flex: 2, showDivider: true),
                                      _buildDataCell(data.accNoDigits,
                                          flex: 2, showDivider: true),
                                      _buildDataCell(data.ctrlNoDigits,
                                          flex: 2, showDivider: true),
                                      _buildDataCell(data.domBankVal,
                                          flex: 3, showDivider: true),

                                      // Status IBAN Val dengan Icon/Text
                                      _buildStatusCell(data.ibanVal,
                                          flex: 2, showDivider: true),

                                      // Aksi Hapus
                                      SizedBox(
                                        width: 60,
                                        child: Center(
                                          child: InkWell(
                                            onTap: () => _hapusData(index),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Icon(Icons.delete_outline,
                                                  color: Colors.red.shade500,
                                                  size: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BANTUAN
  // ==========================================

  Widget _buildHeaderCell(String title,
      {required int flex, bool showDivider = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    right: BorderSide(color: Colors.indigo.shade400, width: 1))
                : null),
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 4.0),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildDataCell(String value,
      {required int flex,
      bool isBold = false,
      bool isDim = false,
      bool showDivider = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    right: BorderSide(color: Colors.grey.shade200, width: 1))
                : null),
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 4.0),
          child: Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDim ? secondarySlate : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // Widget khusus untuk nampilin status boolean (Checkbox EU & IBAN di dalam tabel)
  Widget _buildStatusCell(bool status,
      {required int flex, bool showDivider = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    right: BorderSide(color: Colors.grey.shade200, width: 1))
                : null),
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 4.0),
          child: Text(
            status ? "Yes" : "No",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: status ? Colors.green.shade700 : Colors.red.shade400,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 WIDGET TEXTFIELD FLAT MODERN 🔥
  Widget _buildModernVerticalField(
      String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: secondarySlate,
                fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Container(
          height: 40, // Tinggi pasti 40px
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: primaryIndigo.withValues(alpha: 0.4), width: 1.0),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
      ],
    );
  }

  // 🔥 WIDGET DROPDOWN FLAT MODERN 🔥
  Widget _buildModernVerticalDropdown(String label, String value,
      List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: secondarySlate,
                fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Container(
          height: 40, // Tinggi pasti 40px
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: primaryIndigo.withValues(alpha: 0.4), width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: primaryIndigo),
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
              onChanged: onChanged,
              items: items
                  .map((val) => DropdownMenuItem(
                      value: val,
                      child: Text(val, overflow: TextOverflow.ellipsis)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 WIDGET KHUSUS CHECKBOX BIAR LURUS SAMA TEXTFIELD 🔥
  Widget _buildCheckboxField(
      String label, bool value, Function(bool?) onChanged,
      {String? sideLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment
          .end, // Paksa semua konten turun ke bawah (rata dengan textfield)
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: secondarySlate,
                fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Container(
          height:
              40, // Tingginya persis sama dengan TextField & Dropdown (40px)
          alignment: Alignment
              .centerLeft, // Posisikan checkbox di tengah vertikal box 40px
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24, // Kunci ukuran lebar checkbox
                height: 24, // Kunci ukuran tinggi checkbox
                child: Checkbox(
                  value: value,
                  activeColor: primaryIndigo,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize
                      .shrinkWrap, // Hilangkan padding gaib bawaan flutter
                  visualDensity: const VisualDensity(
                      horizontal: -4, vertical: -4), // Rapatkan checkbox
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              if (sideLabel != null) ...[
                const SizedBox(
                    width: 8), // Jarak antara checkbox dan teks "Enable"/"Yes"
                Text(sideLabel,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87)),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
