import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final int userLevel;
  final String userName;
  final String userDivision;
  final VoidCallback onLogout;
  final String currentDatabase;

  const DashboardPage({
    super.key,
    required this.userLevel,
    required this.userName,
    required this.userDivision,
    required this.onLogout,
    this.currentDatabase = "DB_UTAMA",
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryIndigo = const Color(0xFF6366F1);
  final Color darkSlate = const Color(0xFF1E293B);

  Color parseStatusColor(int id) {
    switch (id) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 0: return Colors.red;
      default: return Colors.grey;
    }
  }

  String parseStatusText(int id) {
    switch (id) {
      case 1: return "ONLINE";
      case 2: return "SYNCING";
      case 0: return "OFFLINE";
      default: return "UNKNOWN";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 244, 247),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalDatabaseHeader(),
            const SizedBox(height: 20),

            _buildSectionHeader("Group Subsidiary Sync Status"),
            const SizedBox(height: 10),
            _buildBranchSyncStatusRow(), 
            const SizedBox(height: 30),

            _buildSectionHeader("Critical Alerts & Approvals"),
            const SizedBox(height: 15),
            _buildApprovalAlertGrid(), // FIXED OVERFLOW FOR MOBILE
            const SizedBox(height: 30),

            _buildSectionHeader("Financials Summary"),
            const SizedBox(height: 15),
            _buildFinancialGrid(), // FIXED OVERFLOW FOR MOBILE
            const SizedBox(height: 30),

            _buildSectionHeader("Strategic Intelligence Hub"),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildYearlyComparisonChart()),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildModuleDistributionPie()),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionHeader("Inventory & Warehouse Monitoring"),
            const SizedBox(height: 15),
            _buildInventoryWarehouseGrid(),
            const SizedBox(height: 30),

            _buildSectionHeader("Operational Aging & Pipeline"),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAgingReportCard()),
                const SizedBox(width: 20),
                Expanded(child: _buildSupplyChainCard("Operational Pipeline", Icons.shopping_bag_rounded, Colors.blue)),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionHeader("Operational Monthly Revenue vs Expense"),
            const SizedBox(height: 15),
            _buildMonthlyDualChart(),
            const SizedBox(height: 30),

            _buildAuditTerminal(),
          ],
        ),
      ),
    );
  }

  // --- 1. SUBSIDIARY SYNC (DENGAN BORDER & SHADOW) ---
  Widget _buildBranchSyncStatusRow() {
    final List<Map<String, dynamic>> branchSyncData = [
      {"name": "PT. Dempo Laser Metalindo Surabaya", "status_id": 1},
      {"name": "PT. Duta Laserindo Metal", "status_id": 1},
      {"name": "PT. Senzo Feinmetal", "status_id": 2},
      {"name": "PT. ATMI Duta Engineering", "status_id": 0},
    ];

    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: branchSyncData.length,
        itemBuilder: (context, index) {
          int sId = branchSyncData[index]['status_id'];
          return Container(
            margin: const EdgeInsets.only(right: 12, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: parseStatusColor(sId)),
                const SizedBox(width: 10),
                Text(branchSyncData[index]['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text(parseStatusText(sId), style: TextStyle(fontSize: 10, color: parseStatusColor(sId), fontWeight: FontWeight.w900)),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 2. CRITICAL ALERTS (FIXED OVERFLOW MOBILE) ---
  Widget _buildApprovalAlertGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika layar kecil (mobile), gunakan 2 kolom atau kurangi rasio
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth < 600 ? 2 : 3, 
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 2.8, 
          children: [
            _alertCard("Approvals", "12", const Color.fromARGB(255, 0, 139, 126), Icons.fact_check),
            _alertCard("Stock Low", "3", const Color(0xFFE91E63), Icons.inventory),
            _alertCard("A/R Over", "Rp 450M", const Color(0xFF9C27B0), Icons.receipt),
          ],
        );
      }
    );
  }

  Widget _alertCard(String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded( // Menghindari teks nabrak batas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(child: Text(title, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold))),
                FittedBox(child: Text(val, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w900))),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 3. FINANCIALS GRID (FIXED OVERFLOW MOBILE) ---
  Widget _buildFinancialGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth < 600 ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _kpiSmallCard("Profit", "Rp 0", Icons.insights, Colors.teal),
            _kpiSmallCard("Income", "Rp 0", Icons.file_download, Colors.blue),
            _kpiSmallCard("Expense", "Rp 0", Icons.file_upload, Colors.red),
            _kpiSmallCard("Assets", "Rp 0", Icons.account_balance, Colors.indigo),
          ],
        );
      }
    );
  }

  Widget _kpiSmallCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const Spacer(),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold)),
          FittedBox(child: Text(val, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  // --- 4. INVENTORY (DENGAN BORDER & SHADOW) ---
  Widget _buildInventoryWarehouseGrid() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18), SizedBox(width: 8), Text("Critical Stock", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))]),
                const Spacer(),
                _stockLine("Plat Besi 5mm", "3 U", Colors.white),
                _stockLine("Oxygen Gas", "12 U", Colors.white),
                _stockLine("Hydraulic Oil", "5 L", Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            height: 160,
            decoration: BoxDecoration(
              color: darkSlate, 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Warehouse A", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const Spacer(),
                const Text("85% Occupied", style: TextStyle(color: Colors.white70, fontSize: 9)),
                const SizedBox(height: 5),
                LinearProgressIndicator(value: 0.85, backgroundColor: Colors.white10, color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
                const Spacer(),
                const Text("Safe Zone", style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stockLine(String name, String qty, Color txtColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: TextStyle(fontSize: 10, color: txtColor.withOpacity(0.9))),
        Text(qty, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: txtColor)),
      ]),
    );
  }

  // --- GRAFIK & LAINNYA (DENGAN BORDER & SHADOW) ---

  Widget _buildYearlyComparisonChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Annual Revenue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const Spacer(),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            double maxH = constraints.maxHeight - 20;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (idx) {
                double hRatio = [0.4, 0.6, 0.7, 0.85, 1.0][idx];
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 30, height: maxH * hRatio * 0.8, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primaryIndigo, primaryIndigo.withOpacity(0.1)]), borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))),
                  const SizedBox(height: 8),
                  Text((2021 + idx).toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ]);
              }),
            );
          }),
        ),
      ]),
    );
  }

  Widget _buildMonthlyDualChart() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Row(children: [
      Expanded(child: _buildBarBox("Revenue", primaryIndigo, months, [0.4, 0.5, 0.3, 0.7, 0.6, 0.9, 0.8, 0.5, 0.7, 1.0, 0.6, 0.9])),
      const SizedBox(width: 20),
      Expanded(child: _buildBarBox("Expenses", Colors.redAccent, months, [0.6, 0.4, 0.5, 0.5, 0.8, 0.6, 0.4, 0.7, 0.5, 0.4, 0.8, 0.7])),
    ]);
  }

  Widget _buildBarBox(String title, Color color, List<String> labels, List<double> values) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const Spacer(),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            double maxH = constraints.maxHeight - 15;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(labels.length, (i) => Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: maxH * values[i] * 0.8, decoration: BoxDecoration(color: color.withOpacity(0.6), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 4),
                Text(labels[i], style: const TextStyle(fontSize: 6, color: Colors.grey)),
              ])),
            );
          }),
        ),
      ]),
    );
  }

  Widget _buildAgingReportCard() {
    return Container(
      padding: const EdgeInsets.all(20), height: 180,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("A/R Aging", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const Divider(),
        _agingLine("Current", "Rp 1.2M", Colors.green),
        _agingLine("1-30 Days", "Rp 450M", Colors.blue),
        _agingLine("> 60 Days", "Rp 45M", Colors.red),
      ]),
    );
  }

  Widget _agingLine(String label, String val, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [CircleAvatar(radius: 2, backgroundColor: color), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 10))]),
      Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
    ]));
  }

  Widget _buildSupplyChainCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20), height: 180,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 5), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]),
        const Spacer(),
        _statusLine("Open Orders", "24"),
        _statusLine("Closed", "102"),
      ]),
    );
  }

  Widget _buildModuleDistributionPie() {
    return Container(
      padding: const EdgeInsets.all(20), height: 280,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        const Text("Resources", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const Spacer(),
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: 0.82, strokeWidth: 10, backgroundColor: Colors.grey.shade100, color: primaryIndigo)),
          const Column(mainAxisSize: MainAxisSize.min, children: [Text("82%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text("OEE", style: TextStyle(color: Colors.grey, fontSize: 7))]),
        ]),
        const Spacer(),
        _statusLine("Prod.", "High"),
        _statusLine("Log.", "Med"),
      ]),
    );
  }

  Widget _buildAuditTerminal() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(">_ LOG_V6", style: TextStyle(color: Colors.tealAccent, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text("[SYS] Data Sync Complete", style: TextStyle(color: Colors.white70, fontSize: 8)),
      ]),
    );
  }

  // --- BASIC HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(color: primaryIndigo, borderRadius: BorderRadius.circular(10))),
      const SizedBox(width: 10),
      Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
    ]);
  }

  Widget _buildGlobalDatabaseHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkSlate, const Color(0xFF334155)]), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Row(children: [
        const Icon(Icons.hub_rounded, color: Colors.blueAccent, size: 30),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("SAP B1 ENTERPRISE GROUP", style: TextStyle(color: Colors.blueAccent, fontSize: 8, fontWeight: FontWeight.w900)),
          Text(widget.currentDatabase, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ])),
        _statusBadge("ONLINE", Colors.greenAccent),
        const SizedBox(width: 10),
        IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout, color: Colors.white70, size: 20)),
      ]),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w900)),
    );
  }

  Widget _statusLine(String label, String val) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))]));
  }
}