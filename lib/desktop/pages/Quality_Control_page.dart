import 'package:flutter/material.dart';

class DesktopQcPage extends StatefulWidget {
  const DesktopQcPage({super.key});

  @override
  State<DesktopQcPage> createState() => _DesktopQcPageState();
}

class _DesktopQcPageState extends State<DesktopQcPage> {
  // --- Theme Colors ---
  final Color primaryPurple = const Color(0xFF6366F1);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);
  final Color bgSlate = const Color.fromARGB(255, 255, 255, 255);
  final Color textDark = const Color(0xFF1E293B);

  // --- Stronger Shadows for "Floating" Effect ---
  List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 40,
          offset: const Offset(0, 15),
          spreadRadius: 2,
        ),
      ];

  List<BoxShadow> get labelShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quality Control Analytics",
                        style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)),
                    const SizedBox(height: 4),
                    Text("Overview data produksi dan reject terkini",
                        style: TextStyle(
                            color: textDark.withOpacity(0.5), fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        "Total Lolos",
                        "1,028",
                        "+8.2%",
                        successGreen,
                        Icons.check_circle,
                        const Color(0xFFECFDF5))),
                const SizedBox(width: 24),
                Expanded(
                    child: _buildStatCard("Total Reject", "138", "-3.5%",
                        dangerRed, Icons.cancel, const Color(0xFFFEF2F2))),
                const SizedBox(width: 24),
                Expanded(
                    child: _buildStatCard(
                        "Pass Rate",
                        "88.2%",
                        "Target: 95%",
                        primaryPurple,
                        Icons.inventory_2,
                        const Color(0xFFEEF2FF))),
                const SizedBox(width: 24),
                Expanded(
                    child: _buildStatCard(
                        "Total Check",
                        "1,166",
                        "+24 Hari ini",
                        Colors.orange,
                        Icons.assignment,
                        const Color(0xFFFFF7ED))),
              ],
            ),
            const SizedBox(height: 40),

            _buildShadowCard(
              title: "Tren Pengecekan Bulanan",
              child: _buildBarChartWithGuidelines(),
            ),
            const SizedBox(height: 40),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildShadowCard(
                    title: "Distribusi Status",
                    child: _buildDonutChartMock(),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _buildShadowCard(
                    title: "Top 5 Divisi Reject",
                    child: _buildTopRejectDivisi(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 4. HISTORY TABLE SECTION
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  // --- BAR CHART ---
  Widget _buildBarChartWithGuidelines() {
    final months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun"];
    final yValues = [250, 200, 150, 100, 50, 0];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              // Grid Guidelines
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: yValues.map((val) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text("$val",
                            style: TextStyle(
                                color: textDark.withOpacity(0.3),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Container(
                            height: 1.5, color: Colors.grey.withOpacity(0.1)),
                      ),
                    ],
                  );
                }).toList(),
              ),
              // Bars
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 20, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(6, (index) {
                    final double maxHeight = 300 - 12;
                    final hLolosValue =
                        [140.0, 155.0, 180.0, 165.0, 195.0, 215.0][index];
                    final hRejectValue =
                        [25.0, 18.0, 32.0, 28.0, 20.0, 24.0][index];

                    final hLolos = (hLolosValue / 250) * maxHeight;
                    final hReject = (hRejectValue / 250) * maxHeight;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: 28,
                                height: hLolos,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          successGreen,
                                          successGreen.withOpacity(0.7)
                                        ]),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)))),
                            const SizedBox(width: 6),
                            Container(
                                width: 28,
                                height: hReject,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          dangerRed,
                                          dangerRed.withOpacity(0.7)
                                        ]),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(months[index],
                            style: TextStyle(
                                color: textDark.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chartLegend(successGreen, "Lolos Produksi"),
            const SizedBox(width: 32),
            _chartLegend(dangerRed, "Reject / Defect"),
          ],
        )
      ],
    );
  }

  Widget _buildTopRejectDivisi() {
    final data = [
      {"name": "QC / QA", "val": 0.9},
      {"name": "Produksi", "val": 0.75},
      {"name": "Maintenance", "val": 0.6},
      {"name": "Engineering", "val": 0.45},
      {"name": "Warehouse", "val": 0.25},
    ];

    return Column(
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(item['name'] as String,
                    style: TextStyle(
                        color: textDark.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                        height: 12,
                        decoration: BoxDecoration(
                            color: bgSlate,
                            borderRadius: BorderRadius.circular(10))),
                    FractionallySizedBox(
                      widthFactor: item['val'] as double,
                      child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                primaryPurple,
                                primaryPurple.withOpacity(0.6)
                              ]),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: primaryPurple.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ])),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text("${((item['val'] as double) * 50).toInt()}",
                  style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: textDark.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: strongShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, primaryPurple.withAlpha(220)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("History Pengecekan Terbaru",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text("Data real-time pengecekan unit di lapangan",
                        style: TextStyle(
                            color: Color.fromARGB(237, 221, 219, 219),
                            fontSize: 14)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 22),
                  label: const Text("Export Report (.xlsx)",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryPurple,
                      elevation: 8,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 18)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: TextField(
              decoration: InputDecoration(
                hintText:
                    "Cari berdasarkan No LBTS, Customer, atau Jenis Produk...",
                hintStyle: TextStyle(
                    color: primaryPurple.withOpacity(0.3), fontSize: 15),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.search, color: primaryPurple, size: 28),
                ),
                filled: true,
                fillColor: bgSlate.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 24),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                      color: primaryPurple.withOpacity(0.1), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryPurple, width: 2.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1200),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1.6),
                    1: FlexColumnWidth(1.3),
                    2: FlexColumnWidth(2.4),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(0.8),
                    5: FlexColumnWidth(1.3),
                    6: FlexColumnWidth(1.4),
                    7: FixedColumnWidth(120),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: primaryPurple.withOpacity(0.06),
                        border: Border(
                            bottom: BorderSide(
                                color: primaryPurple.withOpacity(0.15),
                                width: 2)),
                      ),
                      children: [
                        _tableHeader("NO LBTS"),
                        _tableHeader("TANGGAL"),
                        _tableHeader("CUSTOMER"),
                        _tableHeader("JENIS PRODUK"),
                        _tableHeader("QTY"),
                        _tableHeader("STATUS"),
                        _tableHeader("DIVISI REJECT"),
                        _tableHeader("AKSI"),
                      ],
                    ),
                    _tableDataRow(
                        "LBTS-2026-001",
                        "2026-01-15",
                        "PT. Sejahtera Bersama",
                        "Elektronik",
                        "150",
                        "Lolos",
                        "-",
                        successGreen),
                    _tableDataRow(
                        "LBTS-2026-002",
                        "2026-01-16",
                        "CV. Maju Jaya",
                        "Furniture",
                        "50",
                        "Reject",
                        "Produksi",
                        dangerRed),
                    _tableDataRow(
                        "LBTS-2026-003",
                        "2026-01-18",
                        "PT. Global Indonesia",
                        "Komponen",
                        "300",
                        "Lolos",
                        "-",
                        successGreen),
                    _tableDataRow(
                        "LBTS-2026-004",
                        "2026-01-20",
                        "UD. Karya Mandiri",
                        "Material",
                        "200",
                        "Reject",
                        "QA / QC",
                        dangerRed),
                    _tableDataRow(
                        "LBTS-2026-005",
                        "2026-01-22",
                        "PT. Teknologi Nusantara",
                        "Elektronik",
                        "120",
                        "Lolos",
                        "-",
                        successGreen),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Text(text,
          style: TextStyle(
              color: primaryPurple,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.0)),
    );
  }

  TableRow _tableDataRow(String no, String tgl, String cust, String jenis,
      String qty, String status, String div, Color color) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: primaryPurple.withOpacity(0.05), width: 1.5)),
      ),
      children: [
        _tableCell(Text(no,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14))),
        _tableCell(Text(tgl,
            style: TextStyle(color: textDark.withOpacity(0.6), fontSize: 14))),
        _tableCell(Text(cust,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14))),
        _tableCell(Text(jenis,
            style: TextStyle(color: textDark.withOpacity(0.6), fontSize: 14))),
        _tableCell(Text(qty,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        _tableCell(
          UnconstrainedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.35), width: 1.5),
                boxShadow: labelShadow,
              ),
              child: Text(status,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5)),
            ),
          ),
        ),
        _tableCell(Text(div,
            style: TextStyle(color: textDark.withOpacity(0.6), fontSize: 14))),
        _tableCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove_red_eye_outlined,
                    color: primaryPurple.withOpacity(0.7), size: 22),
                onPressed: () {},
                tooltip: "Detail",
              ),
              IconButton(
                icon: Icon(Icons.edit_note_rounded,
                    color: Colors.blueAccent.withOpacity(0.7), size: 24),
                onPressed: () {},
                tooltip: "Edit",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: child,
    );
  }

  Widget _buildStatCard(String title, String val, String trend, Color color,
      IconData icon, Color cardBg) {
    return Container(
      // Padding dikurangi sedikit agar teks tidak terlalu mepet saat layar menyempit
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: strongShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(val,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -1)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, color: color, size: 12),
                      const SizedBox(width: 4),
                      Text(trend,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildShadowCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: strongShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
              Icon(Icons.more_horiz, color: textDark.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  Widget _buildDonutChartMock() {
    return SizedBox(
      height: 225,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 190,
              height: 190,
              child: CircularProgressIndicator(
                value: 0.88,
                strokeWidth: 26,
                color: successGreen,
                backgroundColor: bgSlate,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("88.2%",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -1)),
                const SizedBox(height: 4),
                Text("QC Passed",
                    style: TextStyle(
                        color: textDark.withOpacity(0.4),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
