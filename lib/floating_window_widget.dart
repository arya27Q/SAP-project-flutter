// NAMA FILE: lib/floating_window_widget.dart

import 'package:flutter/material.dart';

class FloatingWindowWidget extends StatefulWidget {
  final String title;
  final Widget content;
  final VoidCallback onClose;
  final VoidCallback onFocus;
  final double initialX;
  final double initialY;
  final bool isFocused;

  const FloatingWindowWidget({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
    required this.onFocus,
    this.initialX = 50.0,
    this.initialY = 50.0,
    this.isFocused = false,
  });

  @override
  State<FloatingWindowWidget> createState() => _FloatingWindowWidgetState();
}

class _FloatingWindowWidgetState extends State<FloatingWindowWidget> {
  late double xPosition;
  late double yPosition;

  // Variabel untuk nyimpen posisi sebelum di-Maximize
  double savedX = 0;
  double savedY = 0;

  // State untuk Maximize dan Minimize
  bool isMaximized = false;
  bool isMinimized = false;

  // Ukuran default jendela
  double windowWidth = 1100.0;
  double windowHeight = 700.0;

  @override
  void initState() {
    super.initState();
    xPosition = widget.initialX;
    yPosition = widget.initialY;
  }

  void _toggleMaximize() {
    setState(() {
      if (!isMaximized) {
        // Simpan posisi saat ini sebelum diperbesar
        savedX = xPosition;
        savedY = yPosition;
        isMaximized = true;
        isMinimized = false; // Kalau lagi di-minimize, buka lagi
      } else {
        // Kembalikan ke posisi semula
        xPosition = savedX;
        yPosition = savedY;
        isMaximized = false;
      }
    });
  }

  void _toggleMinimize() {
    setState(() {
      isMinimized = !isMinimized;
      if (isMinimized)
        isMaximized = false; // Kalau di-minimize, batalkan maximize
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Kalau Maximized, tempel ke semua sudut (0). Kalau nggak, ikuti koordinat X & Y
      left: isMaximized ? 0 : xPosition,
      top: isMaximized ? 0 : yPosition,
      right: isMaximized ? 0 : null,
      bottom: isMaximized ? 0 : null,
      child: GestureDetector(
        onTapDown: (_) => widget.onFocus(), // Pindah ke depan saat di-klik
        // 🔥 PAKE ANIMATED CONTAINER BIAR EFEK MENGECIL/MEMBESARNYA MULUS
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250), // Kecepatan animasi
          curve: Curves.easeInOut,
          // Lebar & Tinggi menyesuaikan state Minimize / Maximize
          width: isMaximized ? null : windowWidth,
          height: isMinimized
              ? 48.0 // Kalau minimize, sisakan 45px (tinggi header aja)
              : (isMaximized ? null : windowHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMaximized
                ? 0
                : 8), // Hilangkan sudut melengkung kalau fullscreen
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: widget.isFocused ? 0.25 : 0.1),
                blurRadius: widget.isFocused ? 25 : 10,
                offset: Offset(0, widget.isFocused ? 10 : 4),
              )
            ],
            border: Border.all(
              color: widget.isFocused
                  ? const Color(0xFF4F46E5)
                  : Colors.grey.shade300,
              width: widget.isFocused ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              // --- HEADER JENDELA (Bisa di-Drag) ---
              GestureDetector(
                onPanUpdate: (details) {
                  widget.onFocus();
                  setState(() {
                    // Kalau lagi Maximize terus di-drag, otomatis kembali ke ukuran normal (kayak di Windows)
                    if (isMaximized) {
                      isMaximized = false;
                      xPosition = savedX;
                      yPosition = savedY;
                    }
                    xPosition += details.delta.dx;
                    yPosition += details.delta.dy;

                    if (yPosition < 0)
                      yPosition = 0; // Biar gak tembus ke atas layar
                  });
                },
                // Klik 2x di Header untuk Maximize/Restore
                onDoubleTap: _toggleMaximize,
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.isFocused
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(isMaximized ? 0 : 8)),
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- BAGIAN KIRI (Judul) ---
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              widget.title == "Dashboard"
                                  ? Icons.dashboard_rounded
                                  : Icons.article_rounded,
                              size: 16,
                              color: widget.isFocused
                                  ? const Color(0xFF4F46E5)
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: widget.isFocused
                                      ? const Color(0xFF312E81)
                                      : const Color(0xFF2D3748),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- BAGIAN KANAN (Tombol Window ala MacOS/Windows) ---
                      Row(
                        children: [
                          // 1. Tombol Minimize (Kuning)
                          InkWell(
                            onTap: () {
                              widget.onFocus();
                              _toggleMinimize();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isMinimized ? Icons.expand_more : Icons.remove,
                                size: 14,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 2. Tombol Maximize (Hijau)
                          InkWell(
                            onTap: () {
                              widget.onFocus();
                              _toggleMaximize();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isMaximized
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3. Tombol Close (Merah)
                          InkWell(
                            onTap: widget.onClose,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.red.shade400),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- ISI HALAMAN ---
              // 🔥 Tampilkan konten HANYA kalau tidak di-Minimize
              if (!isMinimized)
                Expanded(
                  child: ClipRect(
                    child: widget.content, // Form SAP kamu
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
