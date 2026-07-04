import 'package:flutter/material.dart';

class PaymentInstructionCard extends StatelessWidget {
  const PaymentInstructionCard({
    super.key,
    required this.method,
    required this.grandTotal,
  });

  final String method;
  final double grandTotal;

  @override
  Widget build(BuildContext context) {
    if (method == 'Transfer Bank') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E7F1)),
        ),
        child: Row(
          children: [
            _FakeQrCode(data: 'BLUEMART-$method-${grandTotal.round()}'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan QR Virtual Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gunakan aplikasi bank setelah pesanan dikonfirmasi.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (method == 'E-Wallet') {
      return const _PaymentMessage(
        icon: Icons.wallet_outlined,
        title: 'Pembayaran E-Wallet',
        message:
            'Setelah pesanan dibuat, lanjutkan pembayaran melalui aplikasi e-wallet pilihan Anda.',
      );
    }

    return const _PaymentMessage(
      icon: Icons.local_shipping_outlined,
      title: 'Bayar di Tempat',
      message: 'Bayar langsung ke kurir saat pesanan diterima.',
    );
  }
}

class _PaymentMessage extends StatelessWidget {
  const _PaymentMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E7F1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeQrCode extends StatelessWidget {
  const _FakeQrCode({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      height: 94,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8E2EF)),
      ),
      child: CustomPaint(painter: _QrPainter(data)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const cells = 21;
    final cell = size.width / cells;
    final seed = data.codeUnits.fold<int>(0, (sum, code) => sum + code);

    void finder(int x, int y) {
      canvas.drawRect(
        Rect.fromLTWH(x * cell, y * cell, cell * 7, cell * 7),
        paint,
      );
      final clear = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH((x + 1) * cell, (y + 1) * cell, cell * 5, cell * 5),
        clear,
      );
      canvas.drawRect(
        Rect.fromLTWH((x + 2) * cell, (y + 2) * cell, cell * 3, cell * 3),
        paint,
      );
    }

    finder(0, 0);
    finder(14, 0);
    finder(0, 14);

    for (var row = 0; row < cells; row++) {
      for (var col = 0; col < cells; col++) {
        final inTopLeft = row < 7 && col < 7;
        final inTopRight = row < 7 && col >= 14;
        final inBottomLeft = row >= 14 && col < 7;
        if (inTopLeft || inTopRight || inBottomLeft) continue;

        final value = (row * 31 + col * 17 + seed) % 5;
        if (value == 0 || value == 3) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell * 0.88, cell * 0.88),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
