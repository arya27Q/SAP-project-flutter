import 'package:flutter/material.dart';

// ==========================================
// 1. CLASS MODEL DATA
// ==========================================
class SatuanModel {
  String code;
  String name;
  String uomSap;
  String jenis;

  SatuanModel({
    required this.code,
    required this.name,
    required this.uomSap,
    required this.jenis,
  });
}

// ==========================================
// 2. CLASS TAMPILAN HALAMAN (UI MODERN)
// ==========================================
class SatuanPage extends StatefulWidget {
  const SatuanPage({super.key});

  @override
  State<SatuanPage> createState() => _SatuanPageState();
}

class _SatuanPageState extends State<SatuanPage> {
  // --- WARNA TEMA MODERN ---
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  // --- CONTROLLER FORM ---
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _uomSapCtrl = TextEditingController();
  String _selectedJenis = 'Barang';

  final List<String> _jenisOptions = ['Barang', 'Jasa'];

  // --- DATA DUMMY ---
  List<SatuanModel> _satuanList = [
    SatuanModel(
        code: "UM.0001",
        name: "Metrik Ton",
        uomSap: "Metrik Ton",
        jenis: "Barang"),
    SatuanModel(
        code: "UM.0002", name: "Wet Ton", uomSap: "Wet Ton", jenis: "Barang"),
    SatuanModel(
        code: "UM.0003", name: "Kilogram", uomSap: "Kg", jenis: "Barang"),
    SatuanModel(code: "UM.0023", name: "Tahun", uomSap: "Year", jenis: "Jasa"),
  ];

  // 🔥 FUNGSI WARNA WARNI BADGE 3D 🔥
  Map<String, dynamic> _getBadgeStyle(String jenis) {
    if (jenis == 'Barang') {
      return {
        'bg': Colors.blue.shade100,
        'text': Colors.blue.shade900,
        'shadow': Colors.blue.withValues(alpha: 0.4)
      };
    } else {
      // Jasa
      return {
        'bg': Colors.orange.shade100,
        'text': Colors.orange.shade900,
        'shadow': Colors.orange.withValues(alpha: 0.4)
      };
    }
  }

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
      _satuanList.add(
        SatuanModel(
          code: _codeCtrl.text,
          name: _nameCtrl.text,
          uomSap: _uomSapCtrl.text,
          jenis: _selectedJenis,
        ),
      );
    });

    _codeCtrl.clear();
    _nameCtrl.clear();
    _uomSapCtrl.clear();
    _selectedJenis = 'Barang';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- FUNGSI HAPUS DATA ---
  void _hapusData(int index) {
    setState(() {
      _satuanList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _uomSapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate, // Background abu-abu kebiruan
      body: Padding(
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
                      Icon(Icons.add_circle_outline,
                          color: primaryIndigo, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Input Master Satuan Baru",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: _buildModernVerticalField("Code", _codeCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildModernVerticalField("Name", _nameCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildModernVerticalField(
                              "Uom SAP", _uomSapCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildModernVerticalDropdown(
                              "Jenis", _jenisOptions)),
                      const SizedBox(width: 20),

                      // Tombol Tambah Modern
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _tambahData,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Tambah",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryIndigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            shadowColor: primaryIndigo.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
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
            // BAGIAN TABEL DATA (KOTAK MODERN)
            // ==========================================
            Expanded(
              child: Container(
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
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- HEADER TABEL CUSTOM ---
                    Container(
                      color: primaryIndigo,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      child: const Row(
                        children: [
                          SizedBox(
                              width: 40,
                              child: Text("#",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          Expanded(
                              flex: 2,
                              child: Text("Code",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          Expanded(
                              flex: 4,
                              child: Text("Name",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          Expanded(
                              flex: 2,
                              child: Text("Uom SAP",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          Expanded(
                              flex: 3,
                              child: Text("Jenis Barang/Jasa",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          SizedBox(
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
                        itemCount: _satuanList.length,
                        // 🔥 KUNCI EFEK ROW SHADOW MELAYANG 🔥
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        itemBuilder: (context, index) {
                          final data = _satuanList[index];
                          final style = _getBadgeStyle(
                              data.jenis); // Ambil warna dari fungsi

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              // 🔥 EFEK SHADOW DI SETIAP BARIS (ROW) 🔥
                              boxShadow: [
                                BoxShadow(
                                  color: primaryIndigo.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(
                                      0, 3), // Bayangan jatuh ke bawah
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 40,
                                    child: Text('${index + 1}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: secondarySlate))),
                                Expanded(
                                    flex: 2,
                                    child: Text(data.code,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 4,
                                    child: Text(data.name,
                                        style: const TextStyle(fontSize: 12))),
                                Expanded(
                                    flex: 2,
                                    child: Text(data.uomSap,
                                        style: const TextStyle(fontSize: 12))),

                                // 🔥 BADGE JENIS DENGAN SHADOW MELAYANG 🔥
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: style['bg'],
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: style['shadow'],
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        data.jenis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: style['text'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () => _hapusData(index),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
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
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BANTUAN (STYLING MODERN)
  // ==========================================

  Widget _buildModernVerticalField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: secondarySlate, fontWeight: FontWeight.w600),
        ),
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
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernVerticalDropdown(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: secondarySlate, fontWeight: FontWeight.w600),
        ),
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
              value: _selectedJenis,
              isDense: true,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: primaryIndigo),
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
              onChanged: (val) => setState(() => _selectedJenis = val!),
              items: items
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
