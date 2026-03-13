import 'package:flutter/material.dart';

// ==========================================
// 1. CLASS MODEL DATA MATA UANG
// ==========================================
class CurrencyModel {
  String code;
  String currency;
  String intCode;
  String intDesc;
  String hundredthName;
  String english;
  String engHundredth;
  String isoCode;
  String incAmtDiff;
  String outAmtDiff;
  String incPctDiff;
  String outPctDiff;
  String rounding;

  CurrencyModel({
    required this.code,
    required this.currency,
    required this.intCode,
    required this.intDesc,
    required this.hundredthName,
    required this.english,
    required this.engHundredth,
    required this.isoCode,
    required this.incAmtDiff,
    required this.outAmtDiff,
    required this.incPctDiff,
    required this.outPctDiff,
    required this.rounding,
  });
}

// ==========================================
// 2. CLASS TAMPILAN HALAMAN (UI MODERN)
// ==========================================
class CurrenciesPage extends StatefulWidget {
  const CurrenciesPage({super.key});

  @override
  State<CurrenciesPage> createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends State<CurrenciesPage> {
  // --- WARNA TEMA MODERN ---
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  // --- CONTROLLERS ---
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _currencyCtrl = TextEditingController();
  final TextEditingController _intCodeCtrl = TextEditingController();
  final TextEditingController _intDescCtrl = TextEditingController();
  final TextEditingController _hundredthCtrl = TextEditingController();
  final TextEditingController _englishCtrl = TextEditingController();
  final TextEditingController _engHundredthCtrl = TextEditingController();
  final TextEditingController _incAmtCtrl = TextEditingController();
  final TextEditingController _outAmtCtrl = TextEditingController();
  final TextEditingController _incPctCtrl = TextEditingController();
  final TextEditingController _outPctCtrl = TextEditingController();

  final ScrollController _horizontalScrollCtrl = ScrollController();

  String _selectedIso = 'IDR';
  String _selectedRounding = 'No Rounding';

  final List<String> _isoOptions = [
    'AUD',
    'CHF',
    'EUR',
    'GBP',
    'IDR',
    'JPY',
    'NZD',
    'CNY',
    'SGD',
    'USD'
  ];
  final List<String> _roundingOptions = [
    'No Rounding',
    'Round to Ten',
    'Round to Hundred'
  ];

  // --- DATA DUMMY (Sesuai Gambar SAP) ---
  List<CurrencyModel> _currencyList = [
    CurrencyModel(
        code: "AUD",
        currency: "Australian Dollar",
        intCode: "AUD",
        intDesc: "Australian Dollar",
        hundredthName: "cent",
        english: "USD",
        engHundredth: "cent",
        isoCode: "AUD",
        incAmtDiff: "0.00",
        outAmtDiff: "0.00",
        incPctDiff: "0.00",
        outPctDiff: "0.00",
        rounding: "No Rounding"),
    CurrencyModel(
        code: "EUR",
        currency: "Euro",
        intCode: "EUR",
        intDesc: "Euro",
        hundredthName: "Cent",
        english: "EUR",
        engHundredth: "Cent",
        isoCode: "EUR",
        incAmtDiff: "0.00",
        outAmtDiff: "0.00",
        incPctDiff: "0.00",
        outPctDiff: "0.00",
        rounding: "No Rounding"),
    CurrencyModel(
        code: "IDR",
        currency: "Indonesian Rupiah",
        intCode: "IDR",
        intDesc: "Indonesian Rupiah",
        hundredthName: "-",
        english: "IDR",
        engHundredth: "-",
        isoCode: "IDR",
        incAmtDiff: "0.00",
        outAmtDiff: "0.00",
        incPctDiff: "0.00",
        outPctDiff: "0.00",
        rounding: "No Rounding"),
    CurrencyModel(
        code: "USD",
        currency: "US Dollar",
        intCode: "USD",
        intDesc: "US Dollar",
        hundredthName: "cent",
        english: "USD",
        engHundredth: "cent",
        isoCode: "USD",
        incAmtDiff: "0.00",
        outAmtDiff: "0.00",
        incPctDiff: "0.00",
        outPctDiff: "0.00",
        rounding: "No Rounding"),
  ];

  // --- FUNGSI WARNA WARNI BADGE DENGAN SHADOW TEGAS ---
  Map<String, dynamic> _getBadgeStyle(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return {
          'bg': Colors.blue.shade100,
          'text': Colors.blue.shade800,
          'shadow': Colors.blue.shade300
        };
      case 'EUR':
        return {
          'bg': Colors.purple.shade100,
          'text': Colors.purple.shade800,
          'shadow': Colors.purple.shade300
        };
      case 'IDR':
        return {
          'bg': Colors.teal.shade100,
          'text': Colors.teal.shade800,
          'shadow': Colors.teal.shade300
        };
      case 'AUD':
        return {
          'bg': Colors.orange.shade100,
          'text': Colors.orange.shade900,
          'shadow': Colors.orange.shade300
        };
      case 'GBP':
        return {
          'bg': Colors.pink.shade100,
          'text': Colors.pink.shade800,
          'shadow': Colors.pink.shade300
        };
      case 'JPY':
        return {
          'bg': Colors.indigo.shade100,
          'text': Colors.indigo.shade900,
          'shadow': Colors.indigo.shade300
        };
      case 'SGD':
        return {
          'bg': Colors.red.shade100,
          'text': Colors.red.shade900,
          'shadow': Colors.red.shade300
        };
      default:
        return {
          'bg': Colors.grey.shade200,
          'text': Colors.grey.shade800,
          'shadow': Colors.grey.shade400
        };
    }
  }

  void _tambahData() {
    if (_codeCtrl.text.isEmpty || _currencyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code dan Currency harus diisi!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _currencyList.add(
        CurrencyModel(
          code: _codeCtrl.text,
          currency: _currencyCtrl.text,
          intCode: _intCodeCtrl.text,
          intDesc: _intDescCtrl.text,
          hundredthName: _hundredthCtrl.text,
          english: _englishCtrl.text,
          engHundredth: _engHundredthCtrl.text,
          isoCode: _selectedIso,
          incAmtDiff: _incAmtCtrl.text.isEmpty ? "0.00" : _incAmtCtrl.text,
          outAmtDiff: _outAmtCtrl.text.isEmpty ? "0.00" : _outAmtCtrl.text,
          incPctDiff: _incPctCtrl.text.isEmpty ? "0.00" : _incPctCtrl.text,
          outPctDiff: _outPctCtrl.text.isEmpty ? "0.00" : _outPctCtrl.text,
          rounding: _selectedRounding,
        ),
      );
    });

    _codeCtrl.clear();
    _currencyCtrl.clear();
    _intCodeCtrl.clear();
    _intDescCtrl.clear();
    _hundredthCtrl.clear();
    _englishCtrl.clear();
    _engHundredthCtrl.clear();
    _incAmtCtrl.clear();
    _outAmtCtrl.clear();
    _incPctCtrl.clear();
    _outPctCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mata uang berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hapusData(int index) {
    setState(() {
      _currencyList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _currencyCtrl.dispose();
    _intCodeCtrl.dispose();
    _intDescCtrl.dispose();
    _hundredthCtrl.dispose();
    _englishCtrl.dispose();
    _engHundredthCtrl.dispose();
    _incAmtCtrl.dispose();
    _outAmtCtrl.dispose();
    _incPctCtrl.dispose();
    _outPctCtrl.dispose();
    _horizontalScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      // 🔥 BUNGKUS HALAMAN DENGAN SCROLL VIEW AGAR BISA SCROLL KE BAWAH 🔥
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // HEADER FORM INPUT (KOTAK MODERN LURUS)
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
                        Icon(Icons.monetization_on_outlined,
                            color: primaryIndigo, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Setup Master Currencies",
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
                      children: [
                        Expanded(
                            child:
                                _buildModernVerticalField("Code", _codeCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Currency", _currencyCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Int. Code", _intCodeCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Int. Description", _intDescCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Hundredth Name", _hundredthCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- BARIS 2 ---
                    Row(
                      children: [
                        Expanded(
                            child: _buildModernVerticalField(
                                "English", _englishCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "English Hundredth", _engHundredthCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalDropdown(
                                "ISO Currency Code",
                                _selectedIso,
                                _isoOptions,
                                (val) => setState(() => _selectedIso = val!))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalDropdown(
                                "Rounding",
                                _selectedRounding,
                                _roundingOptions,
                                (val) =>
                                    setState(() => _selectedRounding = val!))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Inc. Amt Diff Allowed", _incAmtCtrl,
                                isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- BARIS 3 ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: _buildModernVerticalField(
                                "Out. Amt Diff Allowed", _outAmtCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Inc. % Diff Allowed", _incPctCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildModernVerticalField(
                                "Out. % Diff Allowed", _outPctCtrl,
                                isNumber: true)),
                        const SizedBox(width: 12),

                        const Expanded(child: SizedBox()),
                        const SizedBox(width: 12),

                        // TOMBOL TAMBAH
                        Expanded(
                          child: SizedBox(
                            height: 40,
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
                                    borderRadius: BorderRadius.circular(10)),
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
              //  GANTI EXPANDED MENJADI CONTAINER DENGAN HEIGHT PANJANG
              Container(
                height: 1000, // <--- BIKIN TABELNYA PANJANG KE BAWAH (TETAP)
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
                      width: 1600,
                      child: Column(
                        children: [
                          // --- HEADER TABEL CUSTOM ---
                          Container(
                            color: primaryIndigo,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            child: Row(
                              children: [
                                _buildHeaderCell("#", flex: 1),
                                _buildHeaderCell("Code", flex: 2),
                                _buildHeaderCell("Currency", flex: 3),
                                _buildHeaderCell("Int. Code", flex: 2),
                                _buildHeaderCell("Int. Description", flex: 3),
                                _buildHeaderCell("Hundredth Name", flex: 2),
                                _buildHeaderCell("English", flex: 2),
                                _buildHeaderCell("Eng. Hundredth Name",
                                    flex: 2),
                                _buildHeaderCell("ISO Currency Code", flex: 2),
                                _buildHeaderCell("Inc. Amt Diff.", flex: 2),
                                _buildHeaderCell("Rounding", flex: 3),
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
                              itemCount: _currencyList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 6),
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 20),
                              itemBuilder: (context, index) {
                                final data = _currencyList[index];
                                final style = _getBadgeStyle(data.code);

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
                                          flex: 1, isDim: true),

                                      //  BADGE CODE 3D TANPA BORDER
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: style['bg'],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: style['shadow'],
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
                                                  color: style['text']),
                                            ),
                                          ),
                                        ),
                                      ),

                                      _buildDataCell(data.currency, flex: 3),
                                      _buildDataCell(data.intCode, flex: 2),
                                      _buildDataCell(data.intDesc, flex: 3),
                                      _buildDataCell(data.hundredthName,
                                          flex: 2),
                                      _buildDataCell(data.english, flex: 2),
                                      _buildDataCell(data.engHundredth,
                                          flex: 2),

                                      //  ISO CODE BADGE 3D
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.indigo.shade300,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Text(data.isoCode,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors
                                                        .indigo.shade900)),
                                          ),
                                        ),
                                      ),

                                      _buildDataCell(data.incAmtDiff, flex: 2),
                                      _buildDataCell(data.rounding, flex: 3),

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

  Widget _buildHeaderCell(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }

  Widget _buildDataCell(String value,
      {required int flex, bool isBold = false, bool isDim = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
    );
  }

  Widget _buildModernVerticalField(
      String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: primaryIndigo.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -2),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4),
            ],
            border: Border.all(
                color: primaryIndigo.withValues(alpha: 0.3), width: 1.5),
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

  Widget _buildModernVerticalDropdown(String label, String value,
      List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: primaryIndigo.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -2),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4),
            ],
            border: Border.all(
                color: primaryIndigo.withValues(alpha: 0.3), width: 1.5),
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
}
