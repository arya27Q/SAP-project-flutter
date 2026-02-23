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

  // Ukuran default jendela
  double windowWidth = 900.0;
  double windowHeight = 600.0;

  @override
  void initState() {
    super.initState();
    xPosition = widget.initialX;
    yPosition = widget.initialY;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onTapDown: (_) => widget.onFocus(), // Pindah ke depan saat di-klik
        child: Container(
          width: windowWidth,
          height: windowHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            // Bayangan lebih tebal kalau lagi aktif (isFocused)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isFocused ? 0.2 : 0.1),
                blurRadius: widget.isFocused ? 20 : 10,
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
                  widget.onFocus(); // Fokus saat mulai di-drag
                  setState(() {
                    xPosition += details.delta.dx;
                    yPosition += details.delta.dy;

                    // Batasi supaya nggak hilang ke atas layar
                    if (yPosition < 0) yPosition = 0;
                  });
                },
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.isFocused
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: widget.isFocused
                                  ? const Color(0xFF312E81)
                                  : const Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      // Tombol Close
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
                ),
              ),

              // --- ISI HALAMAN ---
              Expanded(
                child: ClipRect(
                  child: widget.content, // Form SAP kamu masuk ke sini
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
