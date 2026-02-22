import 'package:flutter/material.dart';

class ChartOfAccountsPage extends StatefulWidget {
  const ChartOfAccountsPage({super.key});

  @override
  State<ChartOfAccountsPage> createState() => _ChartOfAccountsPageState();
}

class _ChartOfAccountsPageState extends State<ChartOfAccountsPage> {
  // --- WARNA STANDAR DARI SALES ORDER ---
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondarySlate = const Color(0xFF64748B);
  final Color bgSlate = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFD0D5DC);

  // --- STATE UNTUK FILTER & SELEKSI ---
  String activeCategory = '1';
  String selectedAccountId = '';

  // --- CONTROLLER UNTUK FORM KIRI ---
  final TextEditingController _glAccountCtrl = TextEditingController();
  final TextEditingController _glAccountSeg2Ctrl =
      TextEditingController(); // Kotak tengah
  final TextEditingController _glAccountSeg3Ctrl =
      TextEditingController(text: '00'); // Kotak kanan
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _extCodeCtrl = TextEditingController();
  final TextEditingController _balanceCtrl =
      TextEditingController(text: '0.00');
  final TextEditingController _levelCtrl = TextEditingController(text: '5');
  final TextEditingController _projectCtrl = TextEditingController();

  // --- STATE UNTUK INPUTAN BARU (Sesuai Gambar Asli) ---
  String accountTypeRadio = 'Active'; // Title atau Active
  String currencyValue = 'All Currencies';
  String balanceCurrencyValue = 'USD';
  String accountTypeValue = 'Other';

  bool isConfidential = false;
  bool isControlAccount = false;
  bool isBlockManual = false;
  bool isCashAccount = false;
  bool isIndexed = false;
  bool isReval = false;
  bool isCashFlow = false;
  bool isProject = false;

  // --- DUMMY DATA ---
  final List<Map<String, dynamic>> coaData = [
    {
      'id': '1',
      'name': 'Assets',
      'level': 1,
      'children': [
        {
          'id': '11',
          'name': '11 - Aktiva Lancar',
          'level': 2,
          'children': [
            {
              'id': '111',
              'name': '111 - Kas dan Bank',
              'level': 3,
              'children': [
                {
                  'id': '1111',
                  'name': '1111 - Kas Kecil',
                  'level': 4,
                  'children': []
                },
                {
                  'id': '12',
                  'name': '12 - Bank',
                  'level': 4,
                  'children': [
                    {
                      'id': '1112101',
                      'name':
                          '1112101-0-0-00 - OCBC NISP Giro Glodok IDR (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112102',
                      'name': '1112102-0-0-00 - BCA Payroll (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112103',
                      'name': '1112103-0-0-00 - BCA Arjuna ESCROW(GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112104',
                      'name': '1112104-0-0-00 - BCA IDR (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112105',
                      'name': '1112105-0-0-00 - BCA Inactive (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112106',
                      'name': '1112106-0-0-00 - Bank BRI IDR (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112107',
                      'name':
                          '1112107-0-0-00 - Bank Mandiri INACTIVE (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112108',
                      'name':
                          '1112108-0-0-00 - Bank Mandiri ESCROW Inactive (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112202',
                      'name':
                          '1112202-0-0-00 - OCBC NISP Multicurrency USD (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1112203',
                      'name': '1112203-0-0-00 - Bank Resona USD (GN, GN, GN)',
                      'level': 5
                    },
                  ]
                },
              ]
            },
            {
              'id': '112',
              'name': '112 - Deposito Berjangka',
              'level': 3,
              'children': [
                {
                  'id': '1121',
                  'name': '1121 - Deposito Berjangka - IDR',
                  'level': 4,
                  'children': [
                    {
                      'id': '1121101',
                      'name':
                          '1121101-0-0-00 - Deposito Berjangka OCBC 1 Bulan (GN, GN, GN)',
                      'level': 5
                    },
                    {
                      'id': '1121102',
                      'name':
                          '1121102-0-0-00 - Deposito Berjangka OCBC 2 Bulan (GN, GN, GN)',
                      'level': 5
                    },
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      'id': '2',
      'name': 'Liabilities',
      'level': 1,
      'children': [
        {'id': '21', 'name': '21 - Hutang Lancar', 'level': 2, 'children': []}
      ]
    },
  ];

  // --- STYLING KOTAK UTAMA ---
  final BoxDecoration mainCardStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(color: Colors.white, width: 3.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 18,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: SafeArea(
        // KUNCI ANTI OVERFLOW: Bikin seluruh halaman bisa di-scroll
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // KOLOM KIRI: FORM MODERN (Style Sales Order)
                // ==========================================
                Container(
                  width: 440,
                  padding: const EdgeInsets.all(24),
                  decoration: mainCardStyle,
                  child: _buildModernLeftForm(),
                ),

                const SizedBox(width: 24),

                // ==========================================
                // KOLOM TENGAH: TREE VIEW (List Akun)
                // ==========================================
                Expanded(
                  child: Container(
                    height:
                        850, // Fix height biar ListView di dalamnya nggak crash pas di-scroll
                    decoration: mainCardStyle,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getCategoryName(activeCategory),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF2D3748))),
                              const Text('Level 10',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              visualDensity: VisualDensity.compact,
                              dividerColor: Colors.transparent,
                            ),
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: _buildFilteredTree(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // ==========================================
                // KOLOM KANAN: TAB KATEGORI
                // ==========================================
                SizedBox(
                  width: 160,
                  child: _buildRightTabsPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: FORM KIRI (SAMA PERSIS DENGAN SAP ASLI)
  // ==========================================
  Widget _buildModernLeftForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. G/L Account dengan 3 Kotak Input
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  child: Text('G/L Account',
                      style: TextStyle(
                          fontSize: 12,
                          color: secondarySlate,
                          fontWeight: FontWeight.w500))),
              const SizedBox(width: 28),
              Expanded(child: _buildModernInputContainer(_glAccountCtrl)),
              const SizedBox(width: 8),
              Text('-',
                  style: TextStyle(
                      color: secondarySlate, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              SizedBox(
                  width: 40,
                  child: _buildModernInputContainer(_glAccountSeg2Ctrl,
                      textAlign: TextAlign.center)),
              const SizedBox(width: 8),
              Text('-',
                  style: TextStyle(
                      color: secondarySlate, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              SizedBox(
                  width: 40,
                  child: _buildModernInputContainer(_glAccountSeg3Ctrl,
                      textAlign: TextAlign.center)),
            ],
          ),
        ),

        // 2. Name
        _buildModernFieldRow('Name', _nameCtrl),

        const SizedBox(height: 12),
        Text('G/L Account Details',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondarySlate,
                decoration: TextDecoration.underline)),
        const SizedBox(height: 8),

        // 3. Radio Buttons (Title / Active Account)
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Title',
                    style: TextStyle(
                        fontSize: 12,
                        color: secondarySlate,
                        fontWeight: FontWeight.w500)),
                value: 'Title',
                groupValue: accountTypeRadio,
                onChanged: (val) => setState(() => accountTypeRadio = val!),
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: primaryIndigo,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('Active Account',
                    style: TextStyle(
                        fontSize: 12,
                        color: secondarySlate,
                        fontWeight: FontWeight.w500)),
                value: 'Active',
                groupValue: accountTypeRadio,
                onChanged: (val) => setState(() => accountTypeRadio = val!),
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: primaryIndigo,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        _buildModernFieldRow('External Code', _extCodeCtrl),
        _buildSmallDropdownRowModern(
            'Currency',
            currencyValue,
            ['All Currencies', 'IDR', 'USD'],
            (v) => setState(() => currencyValue = v!)),

        // 4. Confidential (Checkbox) + Level (Input)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: _buildInlineCheckbox('Confidential', isConfidential,
                    (v) => setState(() => isConfidential = v!)),
              ),
              const SizedBox(width: 28),
              Text('Level',
                  style: TextStyle(
                      fontSize: 12,
                      color: secondarySlate,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildModernInputContainer(_levelCtrl,
                      isReadOnly: true, textAlign: TextAlign.center)),
            ],
          ),
        ),

        // 5. Balance Input (Ada icon panah kuning & dropdown USD)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  child: Text('Balance',
                      style: TextStyle(
                          fontSize: 12,
                          color: secondarySlate,
                          fontWeight: FontWeight.w500))),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_right_alt,
                  color: Colors.amber, size: 24), // Panah kuning SAP
              Expanded(
                  child: _buildModernInputContainer(_balanceCtrl,
                      isReadOnly: true, textAlign: TextAlign.right)),
              const SizedBox(width: 8),
              SizedBox(
                  width: 80,
                  child: _buildDropdownOnly(
                      balanceCurrencyValue,
                      ['USD', 'IDR', 'EUR'],
                      (v) => setState(() => balanceCurrencyValue = v!))),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Text('G/L Account Properties',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondarySlate,
                decoration: TextDecoration.underline)),
        const SizedBox(height: 12),

        _buildSmallDropdownRowModern(
            'Account Type',
            accountTypeValue,
            ['Other', 'Sales', 'Expenditure'],
            (v) => setState(() => accountTypeValue = v!)),

        _buildModernCheckbox('Control Account', isControlAccount,
            (v) => setState(() => isControlAccount = v!)),
        _buildModernCheckbox('Block Manual Posting', isBlockManual,
            (v) => setState(() => isBlockManual = v!)),

        // 6. Cash Account & Indexed Sejajar (Presisi dengan left: 170)
        Padding(
          padding: const EdgeInsets.only(bottom: 4), // Jarak dipepetin
          child: Stack(
            children: [
              _buildInlineCheckbox('Cash Account', isCashAccount,
                  (v) => setState(() => isCashAccount = v!)),
              Padding(
                padding: const EdgeInsets.only(left: 170),
                child: _buildInlineCheckbox('Indexed', isIndexed,
                    (v) => setState(() => isIndexed = v!)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 7. Reval (Indentasi disamakan persis posisi SAP yaitu 170)
        Padding(
          padding: const EdgeInsets.only(
              bottom: 12, left: 170), // Indentasi disamakan posisi SAP
          child: _buildInlineCheckbox('Reval. (Currency)', isReval,
              (v) => setState(() => isReval = v!)),
        ),

        _buildModernCheckbox('Cash Flow Relevant', isCashFlow,
            (v) => setState(() => isCashFlow = v!)),

        const SizedBox(height: 12),
        Text('Relevant for Cost Accounting',
            style: TextStyle(fontSize: 12, color: secondarySlate)),
        const SizedBox(height: 8),

        // 8. Project
        Row(
          children: [
            SizedBox(
              width: 120,
              child: _buildInlineCheckbox(
                  'Project', isProject, (v) => setState(() => isProject = v!)),
            ),
            const SizedBox(width: 28),
            Expanded(child: _buildModernInputContainer(_projectCtrl)),
          ],
        ),

        const SizedBox(height: 32),

        // 9. Tombol Bawah Ala SAP
        Row(
          children: [
            SizedBox(
              height: 36,
              width: 70,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF4F46E5), // Kuning pudar tombol SAP
                    foregroundColor: const Color.fromARGB(221, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 79, 70, 229))),
                    elevation: 0,
                    padding: EdgeInsets.zero),
                child: const Text('OK',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              width: 80,
              child: ElevatedButton(
                onPressed: () {
                  _glAccountCtrl.clear();
                  _nameCtrl.clear();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: const Color.fromARGB(221, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 255, 0, 0))),
                    elevation: 0,
                    padding: EdgeInsets.zero),
                child: const Text('Cancel',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 166, 0),
                  foregroundColor: const Color.fromARGB(221, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 255, 166, 0))),
                  elevation: 0,
                ),
                child: const Text('Account Details',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        )
      ],
    );
  }

  // --- KOMPONEN INPUT YANG SAMA PERSIS DARI SALES ORDER ---

  Widget _buildModernInputContainer(TextEditingController controller,
      {bool isReadOnly = false, TextAlign textAlign = TextAlign.left}) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -2),
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 2),
              blurRadius: 4),
        ],
        border: Border.all(
            color: const Color(0xFF4F46E5).withOpacity(0.15), width: 1),
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        textAlign: textAlign,
        style: TextStyle(
            fontSize: 12,
            color: isReadOnly ? Colors.grey.shade600 : Colors.black87),
        decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 9)),
      ),
    );
  }

  Widget _buildModernFieldRow(String label, TextEditingController controller,
      {bool isReadOnly = false, Widget? rightWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120, // Lebar label
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: secondarySlate,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 28), // Spacing
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: _buildModernInputContainer(controller,
                        isReadOnly: isReadOnly)),
                if (rightWidget != null)
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: rightWidget)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown polosan (tanpa label)
  Widget _buildDropdownOnly(
      String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -2),
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 2),
              blurRadius: 4),
        ],
        border: Border.all(
            color: const Color(0xFF4F46E5).withOpacity(0.15), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: primaryIndigo),
          style: const TextStyle(
              fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
          onChanged: onChanged,
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSmallDropdownRowModern(String label, String value,
      List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: secondarySlate,
                      fontWeight: FontWeight.w500))),
          const SizedBox(width: 28),
          Expanded(child: _buildDropdownOnly(value, items, onChanged)),
        ],
      ),
    );
  }

  // Checkbox sejajar / inline
  Widget _buildInlineCheckbox(
      String label, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              activeColor: primaryIndigo,
              onChanged: onChanged,
              side: BorderSide(color: borderGrey, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondarySlate)),
        ],
      ),
    );
  }

  Widget _buildModernCheckbox(
          String label, bool value, Function(bool?) onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildInlineCheckbox(label, value, onChanged),
      );

  // ==========================================
  // TREE VIEW (TENGAH) - RATA KIRI
  // ==========================================
  List<Widget> _buildFilteredTree() {
    var filteredData = coaData
        .where((node) => node['id'].toString().startsWith(activeCategory))
        .toList();
    if (filteredData.isEmpty)
      return [
        const Padding(
            padding: EdgeInsets.all(16), child: Text('No data found.'))
      ];
    return filteredData.map((node) => _buildTreeNode(node)).toList();
  }

  Widget _buildTreeNode(Map<String, dynamic> node) {
    bool hasChildren =
        node['children'] != null && (node['children'] as List).isNotEmpty;
    bool isSelected = node['id'] == selectedAccountId;

    int level = node['level'] ?? 1;
    double baseIndent = (level - 1) * 16.0;

    if (!hasChildren) {
      return InkWell(
        onTap: () {
          setState(() {
            selectedAccountId = node['id'];
            _glAccountCtrl.text = node['id'];
            _nameCtrl.text = node['name'].toString().split(' - ').last;
          });
        },
        child: Container(
          width: double.infinity, // Paksa lebar maksimal
          alignment: Alignment.centerLeft, // Teks dikunci rata kiri merata
          color: isSelected ? const Color(0xFFFFF3C4) : Colors.transparent,
          // Jarak padding atas & bawah (top/bottom) dipepetin jadi 2, geser kanan (+ 40.0)
          padding: EdgeInsets.only(
              left: baseIndent + 40.0, top: 2, bottom: 2, right: 16),
          child: Text(node['name'],
              style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.black : Colors.grey.shade800)),
        ),
      );
    }

    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.only(left: baseIndent, right: 16.0),
      leading: const Icon(Icons.keyboard_arrow_down,
          size: 20, color: Colors.black87),
      title: Align(
        // Judul mapel dipastikan merata kiri
        alignment: Alignment.centerLeft,
        child: Text(node['name'],
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF3182CE),
                fontWeight: FontWeight.w600)),
      ),
      children: (node['children'] as List)
          .map((child) => _buildTreeNode(child))
          .toList(),
    );
  }

  Widget _buildRightTabsPanel() {
    return Column(
      children: [
        _tabButton('Assets', '1'),
        _tabButton('Liabilities', '2'),
        _tabButton('Capital and Reserves', '3'),
        _tabButton('Turnover', '4'),
        _tabButton('Cost of sales', '5'),
        _tabButton('Operating costs', '6'),
      ],
    );
  }

  Widget _tabButton(String title, String categoryId) {
    bool isActive = activeCategory == categoryId;
    return GestureDetector(
      onTap: () => setState(() => activeCategory = categoryId),
      child: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
          border: isActive
              ? Border.all(color: Colors.blue.shade100)
              : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryIndigo : secondarySlate)),
      ),
    );
  }

  String _getCategoryName(String catId) {
    switch (catId) {
      case '1':
        return 'Assets';
      case '2':
        return 'Liabilities';
      case '3':
        return 'Capital';
      default:
        return 'Accounts';
    }
  }
}
