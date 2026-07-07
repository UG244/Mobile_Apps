import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget overlay yang muncul sebentar saat refresh via shake berhasil.
/// Menampilkan ikon guncangan dengan animasi dan pesan konfirmasi.
class ShakeRefreshToast extends StatelessWidget {
  const ShakeRefreshToast({super.key});

  /// Tampilkan toast shake-refresh di atas context saat ini.
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ShakeToastOverlay(
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ShakeToastOverlay extends StatefulWidget {
  const _ShakeToastOverlay({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  State<_ShakeToastOverlay> createState() => _ShakeToastOverlayState();
}

class _ShakeToastOverlayState extends State<_ShakeToastOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss setelah 2 detik
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A5EB0),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A5EB0).withAlpha(100),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, color: Colors.white, size: 20)
                    .animate(onPlay: (c) => c.repeat())
                    .rotate(
                      duration: 800.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 10),
                const Text(
                  'Produk diperbarui! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.3, end: 0, curve: Curves.easeOut),
        ),
      ),
    );
  }
}
