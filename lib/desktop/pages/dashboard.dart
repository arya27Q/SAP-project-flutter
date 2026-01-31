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
  // --- COLOR PALETTE ---
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color darkSlate = const Color(0xFF0F172A);
  final Color borderWhite = Colors.white; // Border Putih Bersih
  final Color softBg = const Color.fromARGB(
    255,
    255,
    255,
    255,
  ); // BODY TETEP PUTIH

  // --- UTILS ---
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

  // --- ANIMATION WRAPPER BIAR MUNCUL HALUS ---
  Widget _appearAnimation({required Widget child, int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delayMs),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: softBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600 ? 16 : 24,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _appearAnimation(child: _buildGlobalDatabaseHeader(screenWidth)),
            const SizedBox(height: 32),

            _buildSectionHeader("Group Subsidiary Sync Status"),
            const SizedBox(height: 16),
            _appearAnimation(child: _buildBranchSyncStatusRow(), delayMs: 100),
            const SizedBox(height: 32),

            _buildSectionHeader("Critical Alerts & Approvals"),
            const SizedBox(height: 16),
            _appearAnimation(
              child: _buildApprovalAlertGrid(screenWidth),
              delayMs: 200,
            ),
            const SizedBox(height: 32),

            _buildSectionHeader("Financials Summary"),
            const SizedBox(height: 16),
            _appearAnimation(child: _buildFinancialGrid(), delayMs: 300),
            const SizedBox(height: 32),

            _buildSectionHeader("Strategic Intelligence Hub"),
            const SizedBox(height: 16),
            _appearAnimation(
              delayMs: 400,
              child: screenWidth < 600
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
            ),
            const SizedBox(height: 32),

            _buildSectionHeader("Inventory & Warehouse Monitoring"),
            const SizedBox(height: 16),
            _appearAnimation(
              child: _buildInventoryWarehouseGrid(screenWidth),
              delayMs: 500,
            ),
            const SizedBox(height: 32),

            _buildSectionHeader("Operational Aging & Pipeline"),
            const SizedBox(height: 16),
            _appearAnimation(
              delayMs: 600,
              child: screenWidth < 600
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
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader("Operational Monthly Revenue vs Expense"),
            const SizedBox(height: 16),
            _appearAnimation(
              child: _buildMonthlyDualChart(screenWidth),
              delayMs: 700,
            ),
            const SizedBox(height: 32),

            _appearAnimation(child: _buildAuditTerminal(), delayMs: 800),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

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
        border: Border.all(color: borderWhite.withOpacity(0.5), width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
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
                const Text(
                  "SAP B1 ENTERPRISE HUB",
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 10,
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
                      fontWeight: FontWeight.w900,
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
            margin: const EdgeInsets.only(right: 14, bottom: 12, left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderWhite, width: 4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: parseStatusColor(sId)),
                const SizedBox(width: 12),
                Text(
                  branchSyncData[index]['name'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
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

  Widget _buildApprovalAlertGrid(double width) {
    return GridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 15),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: width < 600 ? 1 : 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: width < 600 ? 4 : 2.5,
      children: [
        _alertCard(
          "Approvals",
          "12",
          const Color(0xFF0D9488),
          Icons.fact_check,
        ),
        _alertCard("Stock Low", "3", const Color(0xFFBE123C), Icons.inventory),
        _alertCard(
          "A/R Over",
          "Rp 450M",
          const Color(0xFF7E22CE),
          Icons.receipt,
        ),
      ],
    );
  }

  Widget _alertCard(String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderWhite.withOpacity(0.6), width: 5.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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

  Widget _buildFinancialGrid() {
    return GridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 15),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _kpiSmallCard("Profit", "Rp 2.1B", Icons.insights, Colors.teal),
        _kpiSmallCard("Income", "Rp 8.4B", Icons.file_download, Colors.indigo),
        _kpiSmallCard(
          "Expense",
          "Rp 6.3B",
          Icons.file_upload,
          Colors.redAccent,
        ),
        _kpiSmallCard(
          "Assets",
          "Rp 42B",
          Icons.account_balance,
          const Color(0xFF0F172A),
        ),
      ],
    );
  }

  Widget _kpiSmallCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderWhite, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              fontWeight: FontWeight.w900,
            ),
          ),
          FittedBox(
            child: Text(
              val,
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyComparisonChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderWhite, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Annual Revenue Performance",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double chartHeight = constraints.maxHeight - 25;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (idx) {
                    double targetRatio = [0.4, 0.6, 0.7, 0.85, 1.0][idx];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: targetRatio),
                      duration: Duration(milliseconds: 1500 + (idx * 200)),
                      curve: Curves.easeOutBack,
                      builder: (context, animValue, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              // Clamp biar aman
                              height: (chartHeight * animValue).clamp(
                                0,
                                chartHeight,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    primaryIndigo,
                                    primaryIndigo.withOpacity(0.4),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (2021 + idx).toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildInventoryWarehouseGrid(double width) {
    Widget _card(Widget content, Color bg, {bool dark = false}) => Container(
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? borderWhite.withOpacity(0.3) : borderWhite,
          width: 5.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );

    return width < 600
        ? Column(
            children: [
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Critical Stock",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _stockLine("Plat Besi 5mm", "3 U", Colors.black),
                    _stockLine("Oxygen Gas", "12 U", Colors.black),
                    _stockLine("Hydraulic Oil", "5 L", Colors.black),
                  ],
                ),
                Colors.white,
              ),
              const SizedBox(height: 20),
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Warehouse A",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "85% Occupied",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                darkSlate,
                dark: true,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Critical Stock",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _stockLine("Plat Besi 5mm", "3 U", Colors.black),
                      _stockLine("Oxygen Gas", "12 U", Colors.black),
                      _stockLine("Hydraulic Oil", "5 L", Colors.black),
                    ],
                  ),
                  Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Warehouse A",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "85% Occupied",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  darkSlate,
                  dark: true,
                ),
              ),
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
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            qty,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: txtColor,
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderWhite, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "A/R Aging Analysis",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: Colors.black,
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
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Colors.black,
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderWhite, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.black,
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderWhite, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Resource Utilization",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 14,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.teal,
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "82%",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  Text(
                    "OEE",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _statusLine("Production", "High"),
          _statusLine("Logistics", "Med"),
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
      padding: const EdgeInsets.all(24),
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderWhite, width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // --- WRAP DENGAN EXPANDED + CLIP BIAR GAK OVERFLOW KUNING ---
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double availableHeight = constraints.maxHeight - 20;
                return ClipRRect(
                  // Potong bagian yang luber pas animasi
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      labels.length,
                      (i) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: values[i]),
                            duration: Duration(milliseconds: 1200 + (i * 100)),
                            curve: Curves.easeOutCubic,
                            builder: (context, animVal, child) {
                              return Container(
                                width: 8,
                                // Paksa clamp biar gak bisa ngelebihi batas tinggi sisa
                                height: (availableHeight * animVal).clamp(
                                  0.0,
                                  availableHeight,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            labels[i],
                            style: const TextStyle(
                              fontSize: 7,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildAuditTerminal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderWhite.withOpacity(0.15), width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
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
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "[SYSTEM] Data Sync Complete with Oracle/SQLSrv",
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "[AUTH] Session Verified for Admin Hub",
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 24,
          decoration: BoxDecoration(
            color: primaryIndigo,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _statusLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
