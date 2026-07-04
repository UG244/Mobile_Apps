import 'package:flutter/material.dart';

// [LOGIKA] Import model produk sebagai sumber data tunggal
import '../models/product_model.dart';
// [LOGIKA] Import format angka untuk menampilkan harga (Rp xxx.xxx)
import '../../cart/utils/format_utils.dart';

/// ProductCard — desain UI dari kamu, logika ditambahkan.
///
/// Perubahan parameter:
///   • [product]       menggantikan imageUrl/title/price (sumber data tunggal)
///   • [isFavorite]    tetap ada, tapi kini datang dari FavoriteProvider (di screen)
///   • [onTap]         navigasi ke ProductDetailScreen
///   • [onFavoriteTap] toggle favorit via FavoriteProvider
///   • [onAddToCart]   mengirim produk ke CartProvider milik Fiji
class ProductCard extends StatelessWidget {
  final ProductModel product; // [UBAH] dari String imageUrl/title/price → ProductModel
  final bool isFavorite; // [TETAP] state favorit dikirim dari luar (Consumer di screen)
  final VoidCallback? onTap; // [TAMBAH] callback navigasi ke detail
  final VoidCallback? onFavoriteTap; // [TAMBAH] callback toggle favorit
  final VoidCallback? onAddToCart; // [TAMBAH] callback "Add to Cart" → CartProvider Fiji

  const ProductCard({
    super.key,
    required this.product, // [UBAH]
    required this.isFavorite,
    this.onTap, // [TAMBAH]
    this.onFavoriteTap, // [TAMBAH]
    this.onAddToCart, // [TAMBAH]
  });

  @override
  Widget build(BuildContext context) {
    // [LOGIKA] Bungkus seluruh card dengan GestureDetector untuk navigasi onTap
    return GestureDetector(
      onTap: onTap, // [TAMBAH] navigasi ke ProductDetailScreen
      child: Card(
        // ── DESAIN DIPERTAHANKAN ─────────────────────────────────────────
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // ─────────────────────────────────────────────────────────────────
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // ── Area Gambar (desain dipertahankan) ─────────────────
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                  ),
                  // [LOGIKA] Tampilkan gambar produk dari URL. Jika gagal,
                  // tampilkan placeholder icon (desain fallback tetap sama).
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl, // [UBAH] dari static icon
                            fit: BoxFit.cover,
                            // [LOGIKA] Tampilkan loading saat gambar dimuat
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0A5EB0)));
                            },
                            // [LOGIKA] Fallback jika URL gambar error
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey),
                          )
                        // [LOGIKA] Fallback jika imageUrl kosong
                        : const Icon(Icons.image,
                            size: 50, color: Colors.grey),
                  ),
                ),

                // ── Badge Diskon (TAMBAH — tidak ubah posisi lain) ──────
                // [TAMBAH] Tampilkan badge merah jika produk sedang diskon
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // ── Tombol Favorit (desain circle putih dipertahankan) ──
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, // [TETAP] lingkaran putih
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        // [LOGIKA] Ikon berubah sesuai state isFavorite
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        // [LOGIKA] Warna merah jika favorit, abu jika tidak
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      // [UBAH] onPressed kosong → kini memanggil onFavoriteTap
                      onPressed: onFavoriteTap,
                    ),
                  ),
                ),
              ],
            ),

            // ── Info Produk (desain padding & style dipertahankan) ──────
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // [UBAH] dari static String title
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  // [LOGIKA] Tampilkan harga coret jika ada diskon
                  if (product.isOnSale)
                    Text(
                      'Rp ${formatNumber(product.originalPrice)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  // [LOGIKA] Harga utama — format angka dari double
                  Text(
                    'Rp ${formatNumber(product.price)}', // [UBAH] dari static String price
                    style: const TextStyle(
                      color: Color(0xFF0A5EB0), // [TETAP] warna biru sama
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // ── Tombol "+" Add to Cart (TAMBAH) ──────────────────
                  // [TAMBAH] Tombol cepat tambah ke keranjang dari grid
                  if (onAddToCart != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        // [FIJI INTEGRATION] Panggil CartProvider.addItem()
                        onTap: onAddToCart,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A5EB0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
