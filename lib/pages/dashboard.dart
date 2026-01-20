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
  final Color borderGrey = const Color(0xFFE2E8F0);
  final Color softBg = const Color(0xFFF1F5F9);

  Color parseStatusColor(int id) {
    switch (id) {
      case 1:
        return Colors.teal;
      case 2:
        return Colors.orangeAccent;
      case 0:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String parseStatusText(int id) {
    switch (id) {
      case 1:
        return "ONLINE";
      case 2:
        return "SYNCING";
      case 0:
        return "OFFLINE";
      default:
        return "UNKNOWN";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil lebar layar untuk logika responsif manual jika diperlukan
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: softBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600
              ? 16
              : 24, // Padding lebih kecil di mobile
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalDatabaseHeader(screenWidth),
            const SizedBox(height: 32),

            _buildSectionHeader("Group Subsidiary Sync Status"),
            const SizedBox(height: 16),
            _buildBranchSyncStatusRow(),
            const SizedBox(height: 32),

            _buildSectionHeader("Critical Alerts & Approvals"),
            const SizedBox(height: 16),
            _buildApprovalAlertGrid(),
            const SizedBox(height: 32),

            _buildSectionHeader("Financials Summary"),
            const SizedBox(height: 16),
            _buildFinancialGrid(),
            const SizedBox(height: 32),

            _buildSectionHeader("Strategic Intelligence Hub"),
            const SizedBox(height: 16),
            // Responsif: Row berubah jadi Column di layar kecil
            screenWidth < 600
                ? Column(
                    children: [
                      _buildYearlyComparisonChart(),
                      const SizedBox(height: 20),
                      _buildModuleDistributionPie(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildYearlyComparisonChart()),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildModuleDistributionPie()),
                    ],
                  ),
            const SizedBox(height: 32),

            _buildSectionHeader("Inventory & Warehouse Monitoring"),
            const SizedBox(height: 16),
            _buildInventoryWarehouseGrid(screenWidth),
            const SizedBox(height: 32),

            _buildSectionHeader("Operational Aging & Pipeline"),
            const SizedBox(height: 16),
            // Responsif: Aging & Pipeline
            screenWidth < 600
                ? Column(
                    children: [
                      _buildAgingReportCard(),
                      const SizedBox(height: 20),
                      _buildSupplyChainCard(
                        "Operational Pipeline",
                        Icons.shopping_bag,
                        Colors.indigoAccent,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAgingReportCard()),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildSupplyChainCard(
                          "Operational Pipeline",
                          Icons.shopping_bag,
                          Colors.indigoAccent,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 32),

            _buildSectionHeader("Operational Monthly Revenue vs Expense"),
            const SizedBox(height: 16),
            _buildMonthlyDualChart(screenWidth),
            const SizedBox(height: 32),

            _buildAuditTerminal(),
          ],
        ),
      ),
    );
  }

  // --- HEADER RESPONSIVE ---
  Widget _buildGlobalDatabaseHeader(double width) {
    return Container(
      padding: EdgeInsets.all(width < 400 ? 16 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkSlate, const Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.hub_rounded,
            color: Colors.tealAccent,
            size: width < 400 ? 24 : 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SAP B1 ENTERPRISE HUB",
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: width < 400 ? 8 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.currentDatabase,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (width > 350) _statusBadge("ONLINE", Colors.tealAccent),
          IconButton(
            onPressed: widget.onLogout,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // --- SYNC STATUS (HORIZONTAL LIST tetap aman) ---
  Widget _buildBranchSyncStatusRow() {
    final List<Map<String, dynamic>> branchSyncData = [
      {"name": "PT. Dempo Laser Metalindo Surabaya", "status_id": 1},
      {"name": "PT. Duta Laserindo Metal", "status_id": 1},
      {"name": "PT. Senzo Feinmetal", "status_id": 2},
      {"name": "PT. ATMI Duta Engineering", "status_id": 0},
    ];

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: branchSyncData.length,
        itemBuilder: (context, index) {
          int sId = branchSyncData[index]['status_id'];
          return Container(
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
              children: [
                CircleAvatar(radius: 4, backgroundColor: parseStatusColor(sId)),
                const SizedBox(width: 12),
                Text(
                  branchSyncData[index]['name'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  parseStatusText(sId),
                  style: TextStyle(
                    fontSize: 10,
                    color: parseStatusColor(sId),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- ALERTS GRID ---
  Widget _buildApprovalAlertGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth < 600 ? 1 : 3, // 1 kolom di HP
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 600 ? 4 : 2.5,
          children: [
            _alertCard(
              "Approvals",
              "12",
              const Color(0xFF0D9488),
              Icons.fact_check,
            ),
            _alertCard(
              "Stock Low",
              "3",
              const Color(0xFFBE123C),
              Icons.inventory,
            ),
            _alertCard(
              "A/R Over",
              "Rp 450M",
              const Color(0xFF7E22CE),
              Icons.receipt,
            ),
          ],
        );
      },
    );
  }

  Widget _alertCard(String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  val,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FINANCIALS GRID ---
  Widget _buildFinancialGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth < 600 ? 2 : 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _kpiSmallCard("Profit", "Rp 0", Icons.insights, Colors.teal),
            _kpiSmallCard("Income", "Rp 0", Icons.file_download, Colors.indigo),
            _kpiSmallCard(
              "Expense",
              "Rp 0",
              Icons.file_upload,
              Colors.redAccent,
            ),
            _kpiSmallCard(
              "Assets",
              "Rp 0",
              Icons.account_balance,
              const Color(0xFF334155),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiSmallCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
          FittedBox(
            child: Text(
              val,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- INVENTORY WAREHOUSE ---
  Widget _buildInventoryWarehouseGrid(double width) {
    Widget criticalStock = Container(
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 18),
              const SizedBox(width: 10),
              Text(
                "Critical Stock",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const Spacer(),
          _stockLine("Plat Besi 5mm", "3 U", Colors.black87),
          _stockLine("Oxygen Gas", "12 U", Colors.black87),
          _stockLine("Hydraulic Oil", "5 L", Colors.black87),
        ],
      ),
    );

    Widget warehouse = Container(
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: darkSlate,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Warehouse A",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          const Text(
            "85% Occupied",
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.85,
            backgroundColor: Colors.white10,
            color: Colors.tealAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          const Spacer(),
          const Text(
            "Safe Zone",
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return width < 600
        ? Column(
            children: [criticalStock, const SizedBox(height: 20), warehouse],
          )
        : Row(
            children: [
              Expanded(child: criticalStock),
              const SizedBox(width: 20),
              Expanded(child: warehouse),
            ],
          );
  }

  Widget _stockLine(String name, String qty, Color txtColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 11, color: txtColor.withOpacity(0.7)),
          ),
          Text(
            qty,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: txtColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- CHARTS & KPI ---
  Widget _buildYearlyComparisonChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Annual Revenue",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF334155),
            ),
          ),
          const Spacer(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxH = constraints.maxHeight - 20;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (idx) {
                    double hRatio = [0.4, 0.6, 0.7, 0.85, 1.0][idx];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: maxH * hRatio * 0.8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primaryIndigo,
                                primaryIndigo.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (2021 + idx).toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyDualChart(double width) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    Widget rev = _buildBarBox("Revenue", primaryIndigo, months, [
      0.4,
      0.5,
      0.3,
      0.7,
      0.6,
      0.9,
      0.8,
      0.5,
      0.7,
      1.0,
      0.6,
      0.9,
    ]);
    Widget exp = _buildBarBox("Expenses", Colors.redAccent, months, [
      0.6,
      0.4,
      0.5,
      0.5,
      0.8,
      0.6,
      0.4,
      0.7,
      0.5,
      0.4,
      0.8,
      0.7,
    ]);

    return width < 600
        ? Column(children: [rev, const SizedBox(height: 20), exp])
        : Row(
            children: [
              Expanded(child: rev),
              const SizedBox(width: 20),
              Expanded(child: exp),
            ],
          );
  }

  Widget _buildBarBox(
    String title,
    Color color,
    List<String> labels,
    List<double> values,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF334155),
            ),
          ),
          const Spacer(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxH = constraints.maxHeight - 15;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    labels.length,
                    (i) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: maxH * values[i] * 0.8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labels[i],
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingReportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "A/R Aging",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF334155),
            ),
          ),
          const Divider(height: 24),
          _agingLine("Current", "Rp 1.2M", Colors.teal),
          _agingLine("1-30 Days", "Rp 450M", Colors.orange),
          _agingLine("> 60 Days", "Rp 45M", Colors.red),
        ],
      ),
    );
  }

  Widget _agingLine(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 3, backgroundColor: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyChainCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _statusLine("Open Orders", "24"),
          _statusLine("Closed", "102"),
        ],
      ),
    );
  }

  Widget _buildModuleDistributionPie() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Resources",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF334155),
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade100,
                  color: Colors.teal,
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "82%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "OEE",
                    style: TextStyle(color: Colors.grey, fontSize: 7),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _statusLine("Prod.", "High"),
          _statusLine("Log.", "Med"),
        ],
      ),
    );
  }

  Widget _buildAuditTerminal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ">_ AUDIT_LOG_V6",
            style: TextStyle(
              color: Colors.tealAccent,
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "[SYSTEM] Data Sync Complete with Oracle/SQLSrv",
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
          Text(
            "[AUTH] Session Verified for Admin Hub",
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: primaryIndigo,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _statusLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
