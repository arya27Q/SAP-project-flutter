import 'dart:async'; 
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentIncomingMeanPage extends StatefulWidget {
  const PaymentIncomingMeanPage({super.key});

  @override
  State<PaymentIncomingMeanPage> createState() =>
      _PaymentIncomingMeanPageState();
}

class _PaymentIncomingMeanPageState extends State<PaymentIncomingMeanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Warna Tema
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color bgSlate = const Color.fromARGB(255, 241, 245, 249);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color borderGrey = const Color.fromARGB(255, 208, 213, 220);

  // Controller untuk menyimpan nilai input
  final Map<String, TextEditingController> _controllers = {};

  // Total yang harus dibayar (Simulasi data)
  double totalAmountDue = 15000000.00;
  double totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  TextEditingController _getCtrl(String key, {String initial = ""}) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  // --- LOGIKA PEMBAYARAN (BARU) ---
  void _processPayment() {
    // 1. Tampilkan Loading Dialog dulu
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );

   
    Timer(const Duration(seconds: 2), () {
      Navigator.pop(context);
      bool isSuccess = Random().nextBool(); 
      _showResultDialog(isSuccess);
    });
  }

  void _showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
               
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_rounded : Icons.close_rounded,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  isSuccess ? "Payment Successful!" : "Payment Failed!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  isSuccess 
                    ? "Your transaction has been processed successfully."
                    : "Something went wrong. Please try again later.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      
                      if (isSuccess) {
                        Navigator.pop(context); 
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "OK", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SafeArea(
        child: Column(
          children: [
          
            _buildFloatingHeader(),
            _buildFloatingTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCheckTab(),        
                    _buildBankTransferTab(), 
                    _buildCreditCardTab(),   
                    _buildCashTab(),        
                  ],
                ),
              ),
            ),

           
            const SizedBox(height: 16),
            _buildFooterSummary(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS STRUKTUR UTAMA ---

  Widget _buildFloatingHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment_rounded, color: primaryIndigo),
              ),
              const SizedBox(width: 16),
              const Text(
                "Payment Means",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.grey),
            tooltip: "Close",
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6.0),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent, // Menghilangkan garis
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: primaryIndigo,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: primaryIndigo.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: secondarySlate,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: "Check"),
          Tab(text: "Bank Transfer"),
          Tab(text: "Credit Card"),
          Tab(text: "Cash"),
        ],
      ),
    );
  }

  // --- KONTEN PER TAB ---

  Widget _buildCheckTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Check Details"),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildModernFieldRow("Due Date", "chk_date", isDate: true),
                    _buildModernFieldRow("Amount", "chk_amount",
                        isCurrency: true),
                    _buildModernFieldRow("Bank Code", "chk_bank_code"),
                    _buildModernFieldRow("Bank Name", "chk_bank_name"),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildModernFieldRow("Check No.", "chk_number"),
                    _buildModernFieldRow("Account No.", "chk_acc_no"),
                    _buildModernFieldRow("Country", "chk_country"),
                    _buildModernFieldRow("Endorsable", "chk_endors",
                        isCheckbox: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Bank Transfer Information"),
          const SizedBox(height: 16),
          _buildModernFieldRow("G/L Account", "tf_gl_acc"),
          _buildModernFieldRow("Transfer Date", "tf_date", isDate: true),
          _buildModernFieldRow("Reference", "tf_ref"),
          const Divider(height: 30),
          _buildModernFieldRow("Total Amount", "tf_amount", isCurrency: true),
          const SizedBox(height: 12),
          const Text(
            "* Ensure the transfer date matches the bank statement date.",
            style: TextStyle(
                fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  Widget _buildCreditCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Credit Card Details"),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildModernFieldRow("Card Name", "cc_name"),
                    _buildModernFieldRow("Card Number", "cc_number"),
                    _buildModernFieldRow("Valid Until", "cc_valid",
                        isDate: true),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildModernFieldRow("Payment Method", "cc_method"),
                    _buildModernFieldRow("Voucher No.", "cc_voucher"),
                    _buildModernFieldRow("Amount", "cc_amount",
                        isCurrency: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Cash Payment"),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildModernFieldRow("G/L Account", "cash_gl"),
                const SizedBox(height: 10),
                _buildModernFieldRow("Total Amount", "cash_amount",
                    isCurrency: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER & COMPONENTS ---

  Widget _buildFooterSummary() {
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID', symbol: 'IDR ', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4), 
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Total Amount Due",
                style: TextStyle(color: secondarySlate, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(totalAmountDue),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // PANGGIL FUNGSI LOGIKA DI SINI
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: primaryIndigo.withOpacity(0.4),
            ),
            child: const Text("Confirm Payment",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primaryIndigo,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildModernFieldRow(
    String label,
    String key, {
    bool isDate = false,
    bool isCurrency = false,
    bool isCheckbox = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondarySlate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: isCheckbox
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                        value: true, onChanged: (v) {}, activeColor: primaryIndigo),
                  )
                : Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _getCtrl(key),
                      textAlign: isCurrency ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        suffixIcon: isDate
                            ? const Icon(Icons.calendar_today_outlined,
                                size: 16, color: Color(0xFF818CF8))
                            : null,
                        prefixText: isCurrency ? "IDR " : null,
                        prefixStyle: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                        suffixIconConstraints:
                            const BoxConstraints(minHeight: 20, minWidth: 20),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}