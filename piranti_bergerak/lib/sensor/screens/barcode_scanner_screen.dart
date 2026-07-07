import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../product/providers/product_provider.dart';
import '../../product/screens/product_detail_screen.dart';

/// Halaman pemindai Barcode / QR Code menggunakan kamera smartphone.
///
/// Fitur:
/// - Memindai barcode produk atau QR code secara realtime.
/// - Tombol senter (torch) dan ganti kamera (depan/belakang).
/// - Penanganan ramah pengguna untuk pengujian/demo: jika barcode barang nyata
///   (misal botol minum atau buku) tidak ada di database dummy, aplikasi menawarkan
///   opsi untuk membuka contoh produk agar alur belanja tetap bisa diuji.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.stop(); // Hentikan kamera sementara agar tidak scan berulang

    _handleScannedCode(code.trim());
  }

  void _handleScannedCode(String code) {
    final productProvider = context.read<ProductProvider>();
    final foundProduct = productProvider.findByBarcode(code);

    if (foundProduct != null) {
      // Produk ditemukan! Buka halaman detail
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: foundProduct),
        ),
      );
    } else {
      // Produk tidak ada di katalog dummy -> Tampilkan dialog ramah pengujian/demo
      _showNotFoundDialog(code, productProvider);
    }
  }

  void _showNotFoundDialog(String code, ProductProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Color(0xFF0A5EB0)),
            SizedBox(width: 8),
            Text('Barcode Terdeteksi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode: "$code"',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Produk dengan barcode ini tidak ditemukan dalam katalog dummy BlueMart.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '💡 Tips Demo: Karena Anda mungkin men-scan barang fisik di sekitar Anda, Anda dapat memilih "Lihat Contoh Produk" untuk tetap menguji alur penambahan ke keranjang & checkout.',
                style: TextStyle(fontSize: 12, color: Color(0xFF0A5EB0)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _isProcessing = false);
              _controller.start(); // Lanjutkan pemindai
            },
            child: const Text('Scan Ulang'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Ambil produk pertama (misal ASUS VivoBook) sebagai contoh
              final sampleProduct = provider.products.isNotEmpty
                  ? provider.products.first
                  : null;
              if (sampleProduct != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: sampleProduct),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Lihat Contoh Produk'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Barcode / QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol senter (Torch / Flashlight)
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
                color: isOn ? Colors.yellow : Colors.white,
                onPressed: () => _controller.toggleTorch(),
                tooltip: 'Senter',
              );
            },
          ),
          // Tombol ganti kamera depan/belakang
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
            tooltip: 'Ganti Kamera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera pemindai
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay kotak pemindai visual
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF42A5F5), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Sudut-sudut hiasan scanner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(top: true, left: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(top: true, left: false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(top: false, left: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(top: false, left: false),
                  ),
                ],
              ),
            ),
          ),

          // Petunjuk di bawah kotak
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Arahkan kamera ke barcode produk atau kode QR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          // Loading indicator jika sedang memproses
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha(150),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF0A5EB0),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(12) : Radius.zero,
          topRight: top && !left ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(12) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}
