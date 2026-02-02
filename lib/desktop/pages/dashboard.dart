import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
    this.currentDatabase = "Selamat Datang Administrator",
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
 
  int touchedPieIndex = -1; 

  
  final Color bgPage = const Color.fromARGB(255, 255, 255, 255);

  
  final List<BoxShadow> floatingShadow = [
    const BoxShadow(
      color: Color(0x26000000), 
      blurRadius: 30,
      offset: Offset(0, 15),
      spreadRadius: 2,
    ),
  ];

  final Color cardTeal = const Color(0xFF00BFA5);
  final Color cardRed = const Color(0xFFFF1744);
  final Color cardPurple = const Color(0xFFD500F9);
  final Color darkHeader1 = const Color(0xFF0D1B2A);
  final Color darkHeader2 = const Color(0xFF1E2749);

  Color _getStatusColor(String status) {
    if (status == "ONLINE") return const Color(0xFF00C853);
    if (status == "SYNCING") return const Color(0xFFFF9100);
    return const Color(0xFFD50000);
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    bool isMobile = w < 1200;

    return Scaffold(
      backgroundColor: bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),

            _buildSectionTitle("GROUP SUBSIDIARY SYNC STATUS"),
            const SizedBox(height: 15),
            _buildSyncStatusList(),
            const SizedBox(height: 40),

            _buildSectionTitle("CRITICAL ALERTS & APPROVALS"),
            const SizedBox(height: 15),
            _buildAlertsGrid(w < 900),
            const SizedBox(height: 40),

            _buildSectionTitle("FINANCIAL SUMMARY"),
            const SizedBox(height: 15),
            _buildFinancialGrid(w < 900),
            const SizedBox(height: 40),

            _buildSectionTitle("STRATEGIC INTELLIGENCE HUB"),
            const SizedBox(height: 15),
            isMobile
                ? Column(children: [
                    _buildAnnualBarChart(),
                    const SizedBox(height: 30),
                    _buildResourcePieChart()
                  ])
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: _buildAnnualBarChart()),
                        const SizedBox(width: 30),
                        Expanded(flex: 2, child: _buildResourcePieChart()),
                      ],
                    ),
                  ),
            const SizedBox(height: 40),

            _buildSectionTitle("MONTHLY REVENUE VS EXPENSE ANALYSIS"),
            const SizedBox(height: 15),
            _buildRevenueLineChart(),
            const SizedBox(height: 40),

            _buildSectionTitle("INVENTORY & WAREHOUSE MONITORING"),
            const SizedBox(height: 15),
            isMobile
                ? Column(children: [
                    _buildInventoryCard(),
                    const SizedBox(height: 20),
                    _buildWarehouseCard(),
                  ])
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: _buildInventoryCard()),
                        const SizedBox(width: 30),
                        Expanded(flex: 2, child: _buildWarehouseCard()),
                      ],
                    ),
                  ),
            const SizedBox(height: 40),

            _buildSectionTitle("OPERATIONAL METRICS"),
            const SizedBox(height: 15),
            _buildRadarChart(),
            const SizedBox(height: 40),

            _buildSectionTitle("OPERATIONAL AGING & PIPELINE"),
            const SizedBox(height: 15),
            isMobile
                ? Column(children: [
                    _buildAgingAnalysisCard(),
                    const SizedBox(height: 30),
                    _buildPipelineCard()
                  ])
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildAgingAnalysisCard()),
                        const SizedBox(width: 30),
                        Expanded(child: _buildPipelineCard()),
                      ],
                    ),
                  ),
            const SizedBox(height: 50),

            // AUDIT LOG
            _buildAuditTerminal(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Row(
        children: [
          Container(
              height: 24,
              width: 6,
              decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(5))),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }



  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
            colors: [darkHeader1, darkHeader2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        boxShadow: floatingShadow,
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.dns_rounded,
                  color: Colors.cyanAccent, size: 32)),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("ENTERPRISE SYSTEM HUB",
                style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const SizedBox(height: 5),
            Text(widget.currentDatabase,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
          ]),
          const Spacer(),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0x334CAF50)), // 0.2 opacity
              child: const Row(children: [
                Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text("ONLINE",
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11))
              ])),
        ],
      ),
    );
  }

  // --- SYNC STATUS ---
  Widget _buildSyncStatusList() {
    final data = [
      {
        "name": "PT. Dempo Laser Metalindo Surabaya",
        "status": "ONLINE",
        "val": 1.0
      },
      {"name": "PT. Duta Laserindo Metal", "status": "ONLINE", "val": 1.0},
      {"name": "PT. Senzo Feinmetal", "status": "SYNCING", "val": 0.67},
      {"name": "PT. ATMI Duta Engineering", "status": "OFFLINE", "val": 0.0},
    ];
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          final item = data[index];
          final color = _getStatusColor(item['status'] as String);
          return Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: floatingShadow),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['name'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF2D3436),
                          height: 1.2)),
                  Row(children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 8),
                    Text(item['status'].toString(),
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))
                  ]),
                  Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sync",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          Text("${((item['val'] as double) * 100).toInt()}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))
                        ]),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: item['val'] as double,
                        backgroundColor: Colors.grey.shade100,
                        color: color,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4))
                  ])
                ]),
          );
        },
      ),
    );
  }

  Widget _buildAlertsGrid(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 1 : 3,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      childAspectRatio: isMobile ? 2.5 : 2.2,
      children: [
        _buildColorCard(cardTeal, "PENDING APPROVALS", "12",
            "Requires immediate action", Icons.check_circle_outline),
        _buildColorCard(cardRed, "CRITICAL STOCK", "3", "Items below minimum",
            Icons.warning_amber_rounded),
        _buildColorCard(cardPurple, "A/R OVERDUE", "Rp 450M", "Over 60 days",
            Icons.access_time),
      ],
    );
  }

  Widget _buildColorCard(
      Color color, String title, String val, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Stack(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(val,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(sub,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ]),
        Positioned(
            right: 0,
            top: 0,
            child: Icon(icon, color: const Color(0x40FFFFFF), size: 48))
      ]),
    );
  }

  // --- FINANCIALS ---
  Widget _buildFinancialGrid(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
            "NET PROFIT", "Rp 2.1B", "+12.5%", Colors.green, Icons.trending_up),
        _buildStatCard("TOTAL INCOME", "Rp 8.4B", "+8.2%", Colors.blueAccent,
            Icons.attach_money),
        _buildStatCard("TOTAL EXPENSE", "Rp 6.3B", "-3.1%", Colors.redAccent,
            Icons.trending_down),
        _buildStatCard("TOTAL ASSETS", "Rp 42B", "+5.8%",
            const Color(0xFF2C3E50), Icons.account_balance_wallet_outlined),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String val, String trend, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const Spacer(),
        Text(title,
            style: const TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(val,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(trend,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _buildAnnualBarChart() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("ANNUAL REVENUE PERFORMANCE",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 30),
        Expanded(
            child: BarChart(BarChartData(
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => const FlLine(
                  color: Color(0xFFEEEEEE), strokeWidth: 1, dashArray: [5, 5])),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text((2021 + val.toInt()).toString(),
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 11))))),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (val, _) => Text("${val.toInt()}M",
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 10)))),
          ),
          borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFBDBDBD), width: 1),
                left: BorderSide(color: Color(0xFFBDBDBD), width: 1),
              )),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Color(0xCC000000), // 0.8 opacity
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${2021 + group.x}\n',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Rev: ${rod.toY.toInt()}M', // Isi Angka
                      style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            _makeBar(0, 42),
            _makeBar(1, 58),
            _makeBar(2, 65),
            _makeBar(3, 78),
            _makeBar(4, 90)
          ],
        ))),
      ]),
    );
  }

  BarChartGroupData _makeBar(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y,
          color: const Color(0xFF536DFE),
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))
    ]);
  }

  Widget _buildResourcePieChart() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("RESOURCE UTILIZATION",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 30),
        Expanded(
            child: Row(children: [
          Expanded(
              child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedPieIndex = -1;
                      return;
                    }
                    touchedPieIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _showingSections(),
            ),
          )),
          const SizedBox(width: 20),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legend("Production", "35%", const Color(0xFF00BFA5)),
                const SizedBox(height: 8),
                _legend("Sales", "25%", const Color(0xFF536DFE)),
                const SizedBox(height: 8),
                _legend("Logistics", "20%", const Color(0xFFFFA000)),
                const SizedBox(height: 8),
                _legend("Admin", "12%", const Color(0xFF7C4DFF)),
                const SizedBox(height: 8),
                _legend("Other", "8%", const Color(0xFF607D8B)),
              ])
        ])),
      ]),
    );
  }

  // Logika Pie Chart Interaktif (Membesar & Muncul Angka)
  List<PieChartSectionData> _showingSections() {
    return List.generate(5, (i) {
      final isTouched = i == touchedPieIndex;
      final fontSize = isTouched ? 16.0 : 0.0;
      final radius = isTouched ? 60.0 : 50.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
              color: const Color(0xFF00BFA5),
              value: 35,
              title: "35%",
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        case 1:
          return PieChartSectionData(
              color: const Color(0xFF536DFE),
              value: 25,
              title: "25%",
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        case 2:
          return PieChartSectionData(
              color: const Color(0xFFFFA000),
              value: 20,
              title: "20%",
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        case 3:
          return PieChartSectionData(
              color: const Color(0xFF7C4DFF),
              value: 12,
              title: "12%",
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        case 4:
          return PieChartSectionData(
              color: const Color(0xFF607D8B),
              value: 8,
              title: "8%",
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        default:
          throw Error();
      }
    });
  }

  Widget _legend(String title, String pct, Color color) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436))),
      const SizedBox(width: 5),
      Text(pct,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))
    ]);
  }

  Widget _buildRevenueLineChart() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("MONTHLY REVENUE VS EXPENSE",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Color(0xFF2D3436))),
          Row(children: [
            _legendDot(const Color(0xFF5C6BC0), "Rev"),
            const SizedBox(width: 12),
            _legendDot(const Color(0xFFEF5350), "Exp"),
            const SizedBox(width: 12),
            _legendDot(const Color(0xFF26A69A), "Profit")
          ]),
        ]),
        const SizedBox(height: 30),
        Expanded(
            child: LineChart(LineChartData(
          gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (v) => const FlLine(
                  color: Color(0xFFE0E0E0), strokeWidth: 1, dashArray: [6, 6]),
              getDrawingVerticalLine: (v) => const FlLine(
                  color: Color(0xFFE0E0E0), strokeWidth: 1, dashArray: [6, 6])),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (val, _) {
                      const m = [
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
                        'Dec'
                      ];
                      if (val.toInt() >= 0 && val.toInt() < 12) {
                        return Text(m[val.toInt()],
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold));
                      }
                      return const Text("");
                    })),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 3,
                    getTitlesWidget: (val, _) => Text("${val.toInt()}M",
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)))),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFBDBDBD), width: 1),
                left: BorderSide(color: Color(0xFFBDBDBD), width: 1),
              )),
          lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: const Color(0xFF1E293B),
                  tooltipRoundedRadius: 12,
                  getTooltipItems: (spots) => spots.map((spot) {
                        Color c = Colors.white;
                        String l = "";
                        if (spot.barIndex == 0) {
                          l = "Revenue";
                          c = const Color(0xFF5C6BC0);
                        } else if (spot.barIndex == 1) {
                          l = "Expense";
                          c = const Color(0xFFEF5350);
                        } else {
                          l = "Profit";
                          c = const Color(0xFF26A69A);
                        }
                        return LineTooltipItem(
                            "$l : Rp ${spot.y}M\n",
                            TextStyle(
                                color: c,
                                fontWeight: FontWeight.bold,
                                fontSize: 12));
                      }).toList())),
          lineBarsData: [
            _lineData([4, 5.5, 4.5, 6.5, 6, 7.5, 8.2, 7.5, 8.5, 9.2, 8.8, 10],
                const Color(0xFF5C6BC0), true),
            _lineData([3, 3.5, 3, 4.2, 3.8, 4.8, 5.2, 4.5, 5.0, 5.5, 5.2, 6.2],
                const Color(0xFFEF5350), false),
            _lineData([1, 2, 1.5, 2.3, 2.2, 2.7, 3, 3, 3.5, 3.7, 3.6, 4],
                const Color(0xFF26A69A), false),
          ],
        ))),
      ]),
    );
  }

  LineChartBarData _lineData(List<double> yValues, Color color, bool fill) {
    return LineChartBarData(
      spots: yValues
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
          show: fill,
          color: color.withValues(alpha: 0.15),
          gradient: LinearGradient(colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.0)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Icon(Icons.circle, size: 8, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))
    ]);
  }

  // --- INVENTORY LIST (KIRI) ---
  Widget _buildInventoryCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("CRITICAL INVENTORY",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 25),
        _invItem("Plat Besi 5mm", "3 Unit", 0.3, Colors.red),
        _invItem("Oxygen Gas", "12 Tabung", 0.6, Colors.orange),
        _invItem("Hydraulic Oil", "5 Liter", 0.2, Colors.red),
        _invItem("Welding Rod", "45 Kg", 0.8, Colors.teal),
        _invItem("Steel Pipe 2\"", "18 Unit", 0.5, Colors.orange),
      ]),
    );
  }

  Widget _invItem(String name, String val, double pct, Color color) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: color),
              const SizedBox(width: 10),
              Text(name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3436)))
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(val,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900)),
              const Text("Min: 10",
                  style: TextStyle(fontSize: 10, color: Colors.grey))
            ]),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade100,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4)),
        ]));
  }

  // --- WAREHOUSE CARD (DARK) ---
  Widget _buildWarehouseCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: const Color(0xFF141E30),
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("WAREHOUSE CAPACITY",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.white)),
        const SizedBox(height: 35),
        _whItem("Warehouse A - Surabaya", "85%", 0.85, Colors.tealAccent,
            "Safe Zone"),
        const SizedBox(height: 30),
        _whItem("Warehouse B - Jakarta", "92%", 0.92, Colors.orangeAccent,
            "Near Capacity"),
        const SizedBox(height: 30),
        _whItem("Warehouse C - solo", "45%", 0.45, Colors.greenAccent,
            "Plenty Space"),
        const SizedBox(height: 30),
        _whItem("Warehouse C - cikarang", "70%", 0.70,
            const Color.fromARGB(255, 105, 127, 240), " Lots Capacity"),
      ]),
    );
  }

  Widget _whItem(
      String name, String val, double pct, Color color, String status) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        Text(val,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 13))
      ]),
      const SizedBox(height: 10),
      LinearProgressIndicator(
          value: pct,
          backgroundColor: Colors.white10,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5)),
      const SizedBox(height: 6),
      Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    ]);
  }

  // --- CHART 4: RADAR CHART ---
  Widget _buildRadarChart() {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("OPERATIONAL PERFORMANCE METRICS",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 30),
        Expanded(
          child: RadarChart(RadarChartData(
            titleTextStyle: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.bold),
            tickCount: 3,
            ticksTextStyle: const TextStyle(color: Colors.transparent),
            gridBorderData: const BorderSide(color: Colors.black12, width: 1.5),
            titlePositionPercentageOffset: 0.2,
            getTitle: (index, angle) {
              const t = [
                'Quality',
                'Efficiency',
                'Delivery',
                'Cost',
                'Safety',
                'Innovation'
              ];
              return RadarChartTitle(text: t[index], angle: 0);
            },
            dataSets: [
              RadarDataSet(
                fillColor: const Color(0x4D3F51B5), // 0.3 opacity
                borderColor: const Color(0xFF3F51B5),
                entryRadius: 4,
                borderWidth: 3,
                dataEntries: const [
                  RadarEntry(value: 90),
                  RadarEntry(value: 75),
                  RadarEntry(value: 80),
                  RadarEntry(value: 60),
                  RadarEntry(value: 85),
                  RadarEntry(value: 70)
                ],
              )
            ],
          )),
        ),
      ]),
    );
  }

  Widget _buildAgingAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("A/R AGING ANALYSIS",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 25),
        _agingItem("Current", "Rp 1.2B", "45%", 0.45, Colors.teal),
        _agingItem("1-30 Days", "Rp 0.8B", "32%", 0.32, Colors.orange),
        _agingItem("31-60 Days", "Rp 0.4B", "15%", 0.15, Colors.deepOrange),
        _agingItem("> 60 Days", "Rp 0.2B", "8%", 0.08, Colors.red),
        const Divider(height: 35),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Total Outstanding",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Text("Rp 2.66B",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3436)))
        ]),
      ]),
    );
  }

  Widget _agingItem(
      String label, String val, String pct, double progress, Color color) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(children: [
          Row(children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 10),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Spacer(),
            Text(val,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(width: 6),
            Text("($pct)",
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4)),
        ]));
  }

  Widget _buildPipelineCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: floatingShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("OPERATIONAL PIPELINE",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 25),
        _pipelineBox("Sales Orders", "24", "Open: 18", "Processing: 6",
            Colors.blue.shade50, Colors.blue),
        const SizedBox(height: 18),
        _pipelineBox("Purchase Orders", "31", "Pending: 12", "Approved: 19",
            Colors.purple.shade50, Colors.purple),
        const SizedBox(height: 18),
        _pipelineBox("Production Orders", "15", "In Progress: 9",
            "Completed: 6", Colors.teal.shade50, Colors.teal),
      ]),
    );
  }

  Widget _pipelineBox(String title, String total, String s1, String s2,
      Color bgColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.3))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: accentColor.withValues(alpha: 0.8))),
          Text(total,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: accentColor))
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s1,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436))),
          Text(s2,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436)))
        ]),
      ]),
    );
  }

  Widget _buildAuditTerminal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          boxShadow: floatingShadow),
      child:
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.circle, size: 10, color: Colors.red),
          SizedBox(width: 6),
          Icon(Icons.circle, size: 10, color: Colors.yellow),
          SizedBox(width: 6),
          Icon(Icons.circle, size: 10, color: Colors.green),
          SizedBox(width: 15),
          Text(">_ AUDIT_LOG_V6",
              style: TextStyle(
                  color: Colors.tealAccent,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12))
        ]),
        SizedBox(height: 20),
        Text("[SYSTEM] Data Sync Complete with Oracle/SQLServer",
            style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 11,
                fontFamily: 'monospace')),
        SizedBox(height: 5),
        Text("[AUTH] Session Verified for Admin Hub - User: ADMIN_001",
            style: TextStyle(
                color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
        SizedBox(height: 5),
        Text("[SYNC] Subsidiary PT. Dempo Laser: Status OK - 100%",
            style: TextStyle(
                color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
        SizedBox(height: 5),
        Text("[WARN] Subsidiary PT. Senzo Feinmetal: Sync in progress - 67%",
            style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 11,
                fontFamily: 'monospace')),
        SizedBox(height: 5),
        Text(
            "[ERROR] Subsidiary PT. ATMI Duta: Connection failed - Retrying...",
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontFamily: 'monospace')),
        SizedBox(height: 5),
        Text("[INFO] Dashboard metrics updated - 16.10.18",
            style: TextStyle(
                color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
      ]),
    );
  }
}
