import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. TAMBAH INI
import 'login_page.dart'; // Pastikan import ini sesuai nama file login kamu
import 'dart:math';

class LbtsFormPage extends StatefulWidget {
  const LbtsFormPage({super.key});

  @override
  State<LbtsFormPage> createState() => _LbtsFormPageState();
}

class _LbtsFormPageState extends State<LbtsFormPage> {
  final _formKey = GlobalKey<FormState>();

  final Color indigo600 = const Color(0xFF4F46E5);
  final Color purple600 = const Color.fromARGB(168, 19, 2, 53);
  final Color green50 = const Color(0xFFF0FDF4);
  final Color green500 = const Color(0xFF22C55E);
  final Color red50 = const Color(0xFFFEF2F2);
  final Color red500 = const Color(0xFFEF4444);
  final Color gray800 = const Color(0xFF1F2937);
  final Color gray200 = const Color(0xFF9CA3AF);

  // --- CONTROLLERS (MAPPING DATABASE) ---
  final TextEditingController _noLbtsController = TextEditingController();
  final TextEditingController _tglLbtsController = TextEditingController();
  final TextEditingController _noPenggantiController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _noSoController = TextEditingController();

  // --- STATE VARIABLES (MAPPING DATABASE) ---
  String? _selectedProduct;
  String? _selectedDivisi;
  String? _status;
  String? _selectedCustomer;
  File? _pickedImage;
  String _loggedInName = "Inspector"; // 2. VARIABLE BUAT NAMA

  // --- DATA DUMMY (CUSTOMER) ---
  final List<String> _customerList = [
    "PT. Sejahtera Bersama",
    "CV. Maju Jaya",
    "PT. Global Indonesia",
    "UD. Karya Mandiri",
    "PT. Teknologi Nusantara",
    "PT. Dempo Laser Metalindo",
    "PT. Senzo",
    "PT. ATMI",
  ];

  final List<String> _productOptions = [
    "Elektronik",
    "Furniture",
    "Alat Berat",
    "Komponen",
    "Material",
    "Lainnya"
  ];
  final List<String> _divisiOptions = [
    "Quality Assurance",
    "Produksi",
    "Maintenance",
    "Engineering",
    "Warehouse"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 3. PANGGIL FUNGSI LOAD NAMA

    _noLbtsController.text =
        "LBTS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    String yearShort = DateTime.now().year.toString().substring(2);
    int randomSeven = 1000000 + Random().nextInt(9000000);

    _noSoController.text = "$yearShort$randomSeven";
    _tglLbtsController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // 4. FUNGSI AMBIL NAMA DARI STORAGE
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ambil 'tablet_user' yg disimpan pas login tadi
      _loggedInName = prefs.getString('tablet_user') ?? "Inspector";
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context)
                .copyWith(colorScheme: ColorScheme.light(primary: indigo600)),
            child: child!);
      },
    );
    if (picked != null) {
      setState(() =>
          _tglLbtsController.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) setState(() => _pickedImage = File(image.path));
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ambil Foto Produk",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: gray800)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionBtn(
                    icon: Icons.camera_alt_rounded,
                    label: "Kamera",
                    color: indigo600,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    }),
                _buildOptionBtn(
                    icon: Icons.photo_library_rounded,
                    label: "Galeri",
                    color: purple600,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color)),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, color: gray800)),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _noPenggantiController.clear();
    _qtyController.clear();
    _remarkController.clear();
    setState(() {
      _selectedCustomer = null;
      _selectedProduct = null;
      _selectedDivisi = null;
      _status = null;
      _pickedImage = null;
    });
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      if (_status == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pilih Status Pengecekan!")));
        return;
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content: const Text(
              "Data form & gambar berhasil disiapkan untuk dikirim ke API."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
          ],
        ),
      );
    }
  }

  // --- REUSABLE SHADOW DECORATION ---
  BoxDecoration _fieldShadowDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: indigo600.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 5),
          spreadRadius: -2,
        ),
      ],
    );
  }

  // KOLOM KIRI (SESUAI DATABASE + FIX DROPDOWN V6 + SHADOW)
  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildInputGroup("No Sales Order (SO)", _noSoController,
            isRequired: true,
            hint: "Auto Generated",
            isNumber: true,
            onTap: () {}),
        const SizedBox(height: 28),
        _buildInputGroup("No LBTS", _noLbtsController,
            isRequired: true, hint: "Masukkan nomor LBTS"),
        const SizedBox(height: 28),
        _buildInputGroup("Tanggal LBTS", _tglLbtsController,
            isRequired: true,
            icon: Icons.calendar_today,
            onTap: () => _selectDate(context)),
        const SizedBox(height: 28),

        // SEARCHABLE DROPDOWN (CUSTOMER)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nama Customer", isRequired: true),
            const SizedBox(height: 10),
            Container(
              decoration: _fieldShadowDecoration(),
              child: DropdownSearch<String>(
                // ✅ V6 Fix: Items pakai fungsi logic
                items: (filter, loadProps) {
                  if (filter.isEmpty) return _customerList;
                  return _customerList
                      .where((element) =>
                          element.toLowerCase().contains(filter.toLowerCase()))
                      .toList();
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Cari PT...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  menuProps: MenuProps(borderRadius: BorderRadius.circular(12)),
                ),
                // ✅ V6 Fix: Pakai decoratorProps
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    hintText: "Pilih Customer...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: indigo600, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCustomer = value;
                  });
                },
                selectedItem: _selectedCustomer,
                validator: (value) =>
                    value == null ? "Customer wajib dipilih" : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),
        _buildInputGroup("No Pengganti", _noPenggantiController,
            hint: "Masukkan nomor pengganti"),
        const SizedBox(height: 28),
        _buildDropdownGroup("Jenis Produk", _selectedProduct, _productOptions,
            (v) => setState(() => _selectedProduct = v)),
        const SizedBox(height: 28),
        _buildInputGroup("Quantity", _qtyController,
            isRequired: true, hint: "0", isNumber: true),
      ],
    );
  }

  // 🔥 KOLOM KANAN (SESUAI DATABASE)
  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildLabel("Status Pengecekan", isRequired: true),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildStatusButton("Lolos", "lolos",
                    Icons.check_circle_outline, green500, green50)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatusButton(
                    "Reject", "reject", Icons.cancel_outlined, red500, red50)),
          ],
        ),
        const SizedBox(height: 28),
        _buildDropdownGroup("Divisi Penunjang Reject", _selectedDivisi,
            _divisiOptions, (v) => setState(() => _selectedDivisi = v),
            isRequired: false),
        const SizedBox(height: 28),
        _buildInputGroup("Remark / Catatan", _remarkController,
            hint: "Tulis catatan...", maxLines: 4),
        const SizedBox(height: 28),
        _buildLabel("Foto Produk", isRequired: true),
        const SizedBox(height: 10),
        _buildPhotoUploadArea(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEF2FF), Colors.white, Color(0xFFFAF5FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [indigo600, purple600]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: indigo600.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6))
                              ]),
                          child: const Icon(
                              Icons
                                  .account_circle_outlined, // Ganti icon biar cocok
                              color: Colors.white,
                              size: 26),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 5. GANTI TEKS DI SINI
                              Text("Selamat Datang, $_loggedInName",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: gray800)),
                              const SizedBox(height: 4),
                              Text("Form Input Pengecekan Produk - LBTS",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        // TOMBOL CLOSE (LOGOUT/BACK)
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10)
                              ]),
                          child: IconButton(
                            onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => const TabletLoginPage())),
                            icon: const Icon(Icons
                                .logout), // Ganti jadi icon logout biar make sense
                            color: Colors.redAccent,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 35),

                    // MAIN CARD
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.08),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 20))
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 28),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [indigo600, purple600])),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Data Pengecekan",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                SizedBox(height: 6),
                                Text("Silakan lengkapi semua informasi produk",
                                    style: TextStyle(
                                        color: Color(0xFFE0E7FF),
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Form(
                              key: _formKey,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  bool isWideScreen =
                                      constraints.maxWidth > 900;

                                  if (isWideScreen) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _buildLeftColumn()),
                                        const SizedBox(width: 50),
                                        Expanded(child: _buildRightColumn()),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        _buildLeftColumn(),
                                        const SizedBox(height: 30),
                                        _buildRightColumn(),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                                border:
                                    Border(top: BorderSide(color: gray200))),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _resetForm,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 22),
                                      side:
                                          BorderSide(color: gray200, width: 2),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      foregroundColor: gray800,
                                    ),
                                    child: const Text("Reset Form",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _submitData,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text("Submit Data",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 22),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ).copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => null),
                                      backgroundBuilder:
                                          (context, states, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [
                                                indigo600,
                                                purple600
                                              ]),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: indigo600
                                                        .withOpacity(0.3),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 8))
                                              ]),
                                          child: child,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildInputGroup(String label, TextEditingController controller,
      {bool isRequired = false,
      String? hint,
      IconData? icon,
      bool isNumber = false,
      int maxLines = 1,
      VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 10),
        // WRAPPER CONTAINER UNTUK SHADOW
        Container(
          decoration: _fieldShadowDecoration(),
          child: TextFormField(
            controller: controller,
            readOnly: onTap != null,
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              suffixIcon:
                  icon != null ? Icon(icon, color: Colors.grey[400]) : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: indigo600, width: 2)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            validator:
                isRequired ? (v) => v!.isEmpty ? "Required" : null : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownGroup(String label, String? value, List<String> items,
      Function(String?) onChanged,
      {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 10),
        // WRAPPER CONTAINER UNTUK SHADOW
        Container(
          decoration: _fieldShadowDecoration(),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((e) =>
                    DropdownMenuItem(value: e.toLowerCase(), child: Text(e)))
                .toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              hintText: "Pilih opsi...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: indigo600, width: 2)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
          ),
        ),
        if (label == "Jenis Produk")
          Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("Data diambil dari aplikasi eksternal",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic))),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: gray800,
            letterSpacing: 0.3),
        children: isRequired
            ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  Widget _buildStatusButton(String label, String value, IconData icon,
      Color activeColor, Color activeBg) {
    bool isSelected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.white,
            border: Border.all(
                color: isSelected ? activeColor : gray200,
                width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: indigo600.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? activeColor : Colors.grey[500], size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: isSelected ? activeColor : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return GestureDetector(
      onTap: _showPickerOptions,
      // CONTAINER UPLOAD JUGA DIKASIH SHADOW
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.indigo.shade200,
              width: 2,
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: indigo600.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _pickedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_pickedImage!, fit: BoxFit.cover)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4)
                              ]),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18)),
                    ),
                  )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          shape: BoxShape.circle),
                      child:
                          Icon(Icons.camera_alt, color: indigo600, size: 36)),
                  const SizedBox(height: 16),
                  Text("Upload Foto Produk",
                      style: TextStyle(
                          color: indigo600,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("JPG, PNG (Max 5MB)",
                      style: TextStyle(
                          color: indigo600.withOpacity(0.7), fontSize: 13)),
                ],
              ),
      ),
    );
  }
}
