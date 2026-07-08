import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../cart/utils/format_utils.dart';

/// QrPaymentScreen — Halaman Pembayaran QRIS Dinamis & Modern.
///
/// Menggunakan [QrImageView] dari `qr_flutter` untuk menggenerate QRIS standar,
/// dilengkapi timer hitung mundur 5 menit, petunjuk pembayaran, dan tombol
/// simulasi pembayaran berhasil untuk demonstrasi fitur retail.
class QrPaymentScreen extends StatefulWidget {
  final double amount;
  final String invoiceNumber;
  final VoidCallback onPaymentSuccess;

  const QrPaymentScreen({
    super.key,
    required this.amount,
    required this.invoiceNumber,
    required this.onPaymentSuccess,
  });

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  late Timer _timer;
  int _remainingSeconds = 300; // 5 Menit
  bool _isChecking = false;
  late String _qrPayload;

  @override
  void initState() {
    super.initState();
    _generateQrPayload();
    _startTimer();
  }

  void _generateQrPayload() {
    // Generate standar string QRIS dengan nominal pembayaran nyata
    final nominal = widget.amount.toInt();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _qrPayload =
        '00020101021226600016ID.CO.BLUEMART.WWW01189360091800000000005204581253033605404${nominal}5802ID5914BlueMart Retail6008Denpasar62070703A016304$timestamp';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _simulatePaymentSuccess() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Tampilkan dialog/toast sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Pembayaran QRIS Berhasil Diterima!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    widget.onPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran QRIS'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card Utama QRIS ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.floatingShadow,
              ),
              child: Column(
                children: [
                  // Header Merchant & Logo QRIS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BlueMart Retail',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'NMID: ID1029384756 • Denpasar, Bali',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'QRIS',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.divider),

                  // Timer Hitung Mundur
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Selesaikan pembayaran dalam $_formattedTimer',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── QR CODE DYNAMIC GENERATOR ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _qrPayload,
                      version: QrVersions.auto,
                      size: 220.0,
                      gapless: false,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.primary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nomor Invoice & Total Nominal
                  Text(
                    widget.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${formatNumber(widget.amount)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Petunjuk Pembayaran ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara Pembayaran Mudah:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    1,
                    'Buka aplikasi m-Banking atau e-Wallet (BCA, Mandiri, BRI, GoPay, OVO, Dana, ShopeePay, dll).',
                  ),
                  _buildStep(2, 'Pilih menu Scan / Bayar QRIS.'),
                  _buildStep(
                    3,
                    'Arahkan kamera ke QR Code di atas atau upload screenshot QR ini.',
                  ),
                  _buildStep(
                    4,
                    'Periksa nama merchant "BlueMart Retail" dan nominal pembayaran, lalu masukkan PIN Anda.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Tombol Simulasi & Action ─────────────────────────────────
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 22),
              label: Text(
                _isChecking
                    ? 'Mengecek Pembayaran...'
                    : 'Simulasi Pembayaran Berhasil (Demo)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: _isChecking ? null : _simulatePaymentSuccess,
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: AppColors.accent,
              ),
              label: const Text(
                'Perbarui QR Code',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                setState(() {
                  _generateQrPayload();
                  _remainingSeconds = 300;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Code berhasil diperbarui.')),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
