import 'package:flutter/material.dart';

// NOTE: ini hanya skeleton supaya kebaca dulu di MainLayout.
// Nanti kamu pindahin isi UI kamu yang kemarin ke dalam build() di sini.
class CancelWritteOffPage extends StatefulWidget {
  const CancelWritteOffPage({super.key});

  @override
  State<CancelWritteOffPage> createState() => _CancelWritteOffPageState();
}

class _CancelWritteOffPageState extends State<CancelWritteOffPage> {
   @override
  Widget build(BuildContext context) {
    const seed = Colors.indigo;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE3E8F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: seed, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
       cardTheme: const CardThemeData(
  color: Colors.white,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    side: BorderSide(color: Color(0xFFE6ECF7)),
  ),
),

      ),
      home: const CancelWriteOffScreen(),
    );
  }
}

class CancelWriteOffScreen extends StatefulWidget {
  const CancelWriteOffScreen({super.key});

  @override
  State<CancelWriteOffScreen> createState() => _CancelWriteOffScreenState();
}

class _CancelWriteOffScreenState extends State<CancelWriteOffScreen> {
  // SEARCH
  final _docNumSearchCtrl = TextEditingController();
  final _soSearchCtrl = TextEditingController();

  // AUTO FIELDS
  final _docNumCtrl = TextEditingController();
  final _noSoCtrl = TextEditingController();
  final _customerNameCtrl = TextEditingController();
  final _totalSoCtrl = TextEditingController();
  final _totalOmzetCtrl = TextEditingController();
  final _materialCostCtrl = TextEditingController();
  final _supportingCostCtrl = TextEditingController();
  final _subcontCostCtrl = TextEditingController();

  // ACTION
  String _actionType = 'Cancel'; // Cancel | Write Off
  final _cancelAmountCtrl = TextEditingController();
  final _writeOffAmountCtrl = TextEditingController();

  // STATUS
  String _status = 'In Progress'; // Done | In Progress

  // REMARKS
  final _remarkUserCtrl = TextEditingController();
  final _remarkSystemCtrl = TextEditingController();

  // Dummy "DB"
  final Map<String, Map<String, dynamic>> _dummyByNoSo = {
    '251203581': {
      'docNum': '94',
      'noSo': '251203581',
      'customerName': 'ORDIANUS ALEKSANDER HAGUL',
      'totalSo': 2035000,
      'totalOmzet': 0,
      'materialCost': 0,
      'supportingCost': 0,
      'subcontCost': 0,
      'systemRemark': 'dibatalkan cust sesuai info mkt ...',
    },
    '251203718': {
      'docNum': '97',
      'noSo': '251203718',
      'customerName': 'ANDREAS MARTIN KUHN',
      'totalSo': 600000,
      'totalOmzet': 0,
      'materialCost': 0,
      'supportingCost': 825000,
      'subcontCost': 0,
      'systemRemark': 'dibatalkan sesuai info mkt ...',
    },
  };

  @override
  void initState() {
    super.initState();
    _syncActionAmounts();
  }

  @override
  void dispose() {
    _docNumSearchCtrl.dispose();
    _soSearchCtrl.dispose();

    _docNumCtrl.dispose();
    _noSoCtrl.dispose();
    _customerNameCtrl.dispose();
    _totalSoCtrl.dispose();
    _totalOmzetCtrl.dispose();
    _materialCostCtrl.dispose();
    _supportingCostCtrl.dispose();
    _subcontCostCtrl.dispose();

    _cancelAmountCtrl.dispose();
    _writeOffAmountCtrl.dispose();

    _remarkUserCtrl.dispose();
    _remarkSystemCtrl.dispose();
    super.dispose();
  }

  void _clearAutoFields() {
    _docNumCtrl.clear();
    _noSoCtrl.clear();
    _customerNameCtrl.clear();
    _totalSoCtrl.clear();
    _totalOmzetCtrl.clear();
    _materialCostCtrl.clear();
    _supportingCostCtrl.clear();
    _subcontCostCtrl.clear();
    _remarkSystemCtrl.clear();

    _cancelAmountCtrl.clear();
    _writeOffAmountCtrl.clear();
  }

  String _fmtNum(num? v) {
    if (v == null) return '';
    // Simple formatter: 1,234,567 (tanpa intl biar ringan)
    final s = v.toStringAsFixed(0);
    final chars = s.split('');
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      final idxFromEnd = chars.length - i;
      out.add(chars[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) out.add(',');
    }
    return out.join();
  }

  num _parseNum(String s) {
    final cleaned = s.replaceAll(',', '').trim();
    return num.tryParse(cleaned) ?? 0;
  }

  void _syncActionAmounts() {
    final totalSo = _parseNum(_totalSoCtrl.text);
    if (_actionType == 'Cancel') {
      _cancelAmountCtrl.text = _fmtNum(totalSo);
      _writeOffAmountCtrl.clear();
    } else {
      _writeOffAmountCtrl.text = _fmtNum(totalSo);
      _cancelAmountCtrl.clear();
    }
  }

  void _searchByNoSo() {
    final key = _soSearchCtrl.text.trim();
    if (key.isEmpty) return;

    final data = _dummyByNoSo[key];

    setState(() {
      _clearAutoFields();

      if (data == null) {
        // kalau mau benar-benar kosong (sesuai request), biarin kosong aja
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No. SO tidak ditemukan (dummy data).')),
        );
        return;
      }

      _docNumCtrl.text = (data['docNum'] ?? '').toString();
      _noSoCtrl.text = (data['noSo'] ?? '').toString();
      _customerNameCtrl.text = (data['customerName'] ?? '').toString();

      _totalSoCtrl.text = _fmtNum(data['totalSo'] as num?);
      _totalOmzetCtrl.text = _fmtNum(data['totalOmzet'] as num?);
      _materialCostCtrl.text = _fmtNum(data['materialCost'] as num?);
      _supportingCostCtrl.text = _fmtNum(data['supportingCost'] as num?);
      _subcontCostCtrl.text = _fmtNum(data['subcontCost'] as num?);

      _remarkSystemCtrl.text = (data['systemRemark'] ?? '').toString();

      _syncActionAmounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel & Write Off'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: const Color(0xFF0B1220),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE6ECF7)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    _buildSearchCard(isWide, cs),
                    const SizedBox(height: 14),
                    _buildDetailsCard(isWide),
                    const SizedBox(height: 14),
                    _buildActionCard(isWide, cs),
                    const SizedBox(height: 14),
                    _buildRemarksCard(isWide),
                    const SizedBox(height: 18),
                    _buildFooterButtons(cs),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard(bool isWide, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Search'),
            const SizedBox(height: 12),
            isWide
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _docNumSearchCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'DocNum (opsional)',
                            hintText: 'misal: 94',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _soSearchCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'No. SO (search)',
                            hintText: 'misal: 251203581',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (_) => _searchByNoSo(),
                        ),
                      ),
                      const SizedBox(width: 12),
  


                      FilledButton.icon(
                        onPressed: _searchByNoSo,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextField(
                        controller: _docNumSearchCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'DocNum (opsional)',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _soSearchCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'No. SO (search)',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _searchByNoSo(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _searchByNoSo,
                          icon: const Icon(Icons.search),
                          label: const Text('Search'),
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

 Widget _buildDetailsCard(bool isWide) {
  final fields = [
    _roField('Customer Name', _customerNameCtrl),
    _roField('Total SO', _totalSoCtrl, prefix: const Icon(Icons.payments_outlined)),
    _roField('Total Omzet', _totalOmzetCtrl, prefix: const Icon(Icons.stacked_line_chart)),
    _roField('Material Cost', _materialCostCtrl),
    _roField('Supporting Cost', _supportingCostCtrl),
    _roField('Subcont Cost', _subcontCostCtrl),
  ];

  return Column(
    children: [

      // ================= DETAIL CARD =================
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Detail SO (auto dari hasil search)'),
              const SizedBox(height: 12),
              
              
              isWide
                  ? Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: fields
                          .map((w) => SizedBox(width: 260, child: w))
                          .toList(),
                    )
                  : Column(
                      children: [
                        for (final f in fields) ...[
                          f,
                          const SizedBox(height: 12),
                        ]
                      ],
                    ),
            ],
          ),
        ),
      ),

      
    ],
  );
}


  Widget _buildActionCard(bool isWide, ColorScheme cs) {
    final actionItems = const ['Cancel', 'Write Off'];
    final statusItems = const ['In Progress', 'Done'];

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _actionType,
          items: actionItems
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Tipe',
            prefixIcon: Icon(Icons.rule_folder_outlined),
          ),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _actionType = v;
              _syncActionAmounts();
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cancelAmountCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Cancel (auto)',
            prefixIcon: const Icon(Icons.cancel_outlined),
            suffixIcon: _actionType == 'Cancel'
                ? Icon(Icons.check_circle, color: cs.primary)
                : const Icon(Icons.remove_circle_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _writeOffAmountCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Write Off (auto)',
            prefixIcon: const Icon(Icons.edit_note_outlined),
            suffixIcon: _actionType == 'Write Off'
                ? Icon(Icons.check_circle, color: cs.primary)
                : const Icon(Icons.remove_circle_outline),
          ),
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _status,
          items: statusItems
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Status',
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _status = v);
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FF),
            borderRadius: BorderRadius.circular(14),
            border: const Border.fromBorderSide(BorderSide(color: Color(0xFFE0E9FF))),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: cs.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Nominal Cancel/Write Off diisi otomatis dari Total SO (dummy rule). Nanti kamu bisa ganti logic sesuai kebutuhan bisnis.',
                  style: TextStyle(height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Action'),
            const SizedBox(height: 12),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 12),
                      Expanded(child: right),
                    ],
                  )
                : Column(
                    children: [
                      left,
                      const SizedBox(height: 12),
                      right,
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard(bool isWide) {
    final userRemark = TextField(
      controller: _remarkUserCtrl,
      maxLines: 6,
      decoration: const InputDecoration(
        labelText: 'Keterangan User',
        alignLabelWithHint: true,
        hintText: 'Tulis remark dari user (bebas panjang)...',
        prefixIcon: Icon(Icons.person_outline),
      ),
    );

    final systemRemark = TextField(
      controller: _remarkSystemCtrl,
      maxLines: 6,
      decoration: const InputDecoration(
        labelText: 'Keterangan System',
        alignLabelWithHint: true,
        hintText: 'Auto / dari sistem (remark panjang)...',
        prefixIcon: Icon(Icons.memory_outlined),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Remarks'),
            const SizedBox(height: 12),
            isWide
                ? Row(
                    children: [
                      Expanded(child: userRemark),
                      const SizedBox(width: 12),
                      Expanded(child: systemRemark),
                    ],
                  )
                : Column(
                    children: [
                      userRemark,
                      const SizedBox(height: 12),
                      systemRemark,
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _docNumSearchCtrl.clear();
                _soSearchCtrl.clear();
                _remarkUserCtrl.clear();
                _status = 'In Progress';
                _actionType = 'Cancel';
                _clearAutoFields();
                _syncActionAmounts();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFFD7E0F2)),
              foregroundColor: const Color(0xFF0B1220),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              // FRONTEND ONLY: nanti ganti jadi call API save.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulasi: data disimpan (frontend-only).')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1220),
          ),
        ),
      ],
    );
  }

  Widget _roField(String label, TextEditingController ctrl, {Widget? prefix}) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix,
      ),
    );
  }
}
