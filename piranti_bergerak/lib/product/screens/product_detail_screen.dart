import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // [TAMBAH] State Management

// [TAMBAH] Import providers yang dibutuhkan
import '../../cart/providers/cart_provider.dart';
import '../../cart/utils/format_utils.dart';
import '../models/product_model.dart';
import '../providers/favorite_provider.dart';
import '../widgets/cart_notification_overlay.dart';

/// ProductDetailScreen — desain UI kamu dipertahankan, logika diinjeksi.
///
/// [UBAH] StatelessWidget → StatefulWidget karena:
///   1. State _quantity (jumlah produk yang akan dibeli)
///   2. State _showFullDesc (toggle deskripsi panjang/pendek)
///
/// [UBAH] Tambah required parameter `product` (ProductModel)
///        sehingga screen bisa menampilkan data produk yang nyata
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product; // [TAMBAH] data produk yang ditampilkan

  const ProductDetailScreen({
    super.key,
    required this.product, // [TAMBAH] wajib dikirim dari screen pemanggil
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // [TAMBAH] State jumlah produk yang dipilih user (default 1)
  int _quantity = 1;

  // [TAMBAH] State untuk toggle panjang/pendek deskripsi produk
  bool _showFullDesc = false;

  // [TAMBAH] Getter untuk memudahkan akses data produk
  ProductModel get product => widget.product;

  /// [TAMBAH] Tambah kuantitas (batas maksimum = stok produk)
  void _increment() {
    if (_quantity < product.stock) {
      setState(() => _quantity++);
    }
  }

  /// [TAMBAH] Kurangi kuantitas (batas minimum = 1)
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// [TAMBAH] Fungsi "Add to Cart" — integrasi dengan CartProvider Fiji
  ///
  /// Proses:
  ///   1. Konversi ProductModel → CartItemModel via toCartItem()
  ///   2. Kirim ke CartProvider.addItem() milik Fiji
  ///   3. Tampilkan SnackBar konfirmasi
  /// ─────────────────────────────────────────────────────────────────────────
  void _addToCart(BuildContext context) {
    // [FIJI INTEGRATION] Konversi product → CartItemModel dengan quantity yg dipilih
    final cartItem = product.toCartItem(quantity: _quantity);

    // [FIJI INTEGRATION] Panggil addItem() dari CartProvider milik Fiji
    // CartProvider ada di: lib/cart/providers/cart_provider.dart
    context.read<CartProvider>().addItem(cartItem);

    // [LOGIKA] Tampilkan konfirmasi berhasil ditambahkan
    CartNotificationOverlay.show(
      context,
      message: '${product.name} (x$_quantity) ditambahkan ke keranjang',
      onViewCart: () => Navigator.of(context).pushNamed('/cart'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [TAMBAH] Pantau state favorit dari FavoriteProvider
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFav = favoriteProvider.isFavorite(product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar (desain dipertahankan) ──────────────────────────
          SliverAppBar(
            expandedHeight: 300, // [TETAP]
            pinned: true, // [TETAP]
            // [TAMBAH] Tombol favorit di AppBar kanan atas
            actions: [
              IconButton(
                icon: Icon(
                  // [LOGIKA] Icon berubah sesuai state isFav
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                // [FIJI INTEGRATION] Toggle favorit via FavoriteProvider
                onPressed: () => favoriteProvider.toggleFavorite(product),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              // [TAMBAH] Judul produk muncul di AppBar saat di-scroll
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: product.imageUrl.isNotEmpty
                  // [UBAH] Tampilkan gambar produk nyata dari URL
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      // [LOGIKA] Fallback placeholder jika gambar gagal dimuat
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  // [LOGIKA] Placeholder jika imageUrl kosong (desain kamu)
                  : Container(
                      color: Colors.grey[300], // [TETAP] warna placeholder sama
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey,
                      ), // [TETAP]
                    ),
            ),
          ),

          // ── Konten Detail (desain dipertahankan) ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // [TETAP]
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [UBAH] Nama produk dari ProductModel (bukan hardcode)
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ), // [TETAP] style sama
                  ),
                  const SizedBox(height: 8), // [TETAP]
                  // [UBAH] Harga dengan format Rupiah (bukan hardcode)
                  Row(
                    children: [
                      Text(
                        'Rp ${formatNumber(product.price)}',
                        style: const TextStyle(
                          fontSize: 20, // [TETAP]
                          fontWeight: FontWeight.bold, // [TETAP]
                          color: Color(0xFF0A5EB0), // [TETAP]
                        ),
                      ),
                      const SizedBox(width: 8),
                      // [TAMBAH] Tampilkan harga coret jika ada diskon
                      if (product.isOnSale)
                        Text(
                          'Rp ${formatNumber(product.originalPrice)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8), // [TETAP]
                  // [UBAH] Rating dari data ProductModel (bukan hardcode 4.8)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ), // [TETAP]
                      const SizedBox(width: 4), // [TETAP]
                      Text(
                        // [UBAH] Rating & review count dari ProductModel
                        '${product.rating.toStringAsFixed(1)} (${product.reviewCount} Review)',
                      ),
                      const Spacer(),
                      // [TAMBAH] Badge stok produk
                      Text(
                        product.stock > 0
                            ? 'Stok: ${product.stock}'
                            : 'Stok Habis',
                        style: TextStyle(
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // [TAMBAH] Pilih jumlah produk sebelum Add to Cart
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Jumlah:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      // [LOGIKA] Tombol kurangi quantity
                      IconButton(
                        onPressed: _decrement,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: const Color(0xFF0A5EB0),
                      ),
                      // [LOGIKA] Tampilkan quantity saat ini
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // [LOGIKA] Tombol tambah quantity
                      IconButton(
                        onPressed: _increment,
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF0A5EB0),
                      ),
                    ],
                  ),

                  // [TAMBAH] Kotak total harga realtime
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A5EB0).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(color: Colors.black54),
                        ),
                        // [LOGIKA] Total = harga × quantity (update realtime)
                        Text(
                          'Rp ${formatNumber(product.price * _quantity)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A5EB0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 32), // [TETAP]
                  // [TETAP] Label Deskripsi
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // [TETAP]
                  ),
                  const SizedBox(height: 12), // [TETAP]
                  // [UBAH] Deskripsi dari ProductModel (bukan lorem ipsum)
                  // [LOGIKA] Toggle antara teks singkat dan penuh
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _showFullDesc
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(
                      product.description,
                      maxLines: 3, // [LOGIKA] maks 3 baris saat collapsed
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ), // [TETAP] style sama
                    ),
                    secondChild: Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ), // [TETAP]
                    ),
                  ),

                  // [TAMBAH] Tombol toggle "Selengkapnya / Tutup"
                  TextButton(
                    onPressed: () =>
                        setState(() => _showFullDesc = !_showFullDesc),
                    child: Text(
                      _showFullDesc ? 'Tutup' : 'Selengkapnya',
                      style: const TextStyle(color: Color(0xFF0A5EB0)),
                    ),
                  ),

                  const SizedBox(height: 100), // [TETAP] ruang untuk bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Bar "Add to Cart" (desain dipertahankan) ──────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16), // [TETAP]
        decoration: const BoxDecoration(
          color: Colors.white, // [TETAP]
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ), // [TETAP]
          ],
        ),
        child: Row(
          children: [
            // [TAMBAH] Tombol "Beli Langsung" (outlined)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: Color(0xFF0A5EB0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // [LOGIKA] Tambah ke cart lalu langsung navigasi ke halaman cart
                onPressed: product.stock > 0
                    ? () {
                        _addToCart(context);
                        Navigator.of(context).pushNamed('/cart');
                      }
                    : null, // [LOGIKA] Disable jika stok habis
                child: const Text(
                  'Beli',
                  style: TextStyle(color: Color(0xFF0A5EB0)),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // [TETAP] Tombol "Add to Cart" — desain sama persis
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0A5EB0,
                  ), // [TETAP] warna biru
                  minimumSize: const Size(double.infinity, 50), // [TETAP]
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // [TETAP]
                ),
                // [UBAH] onPressed dulu kosong → kini panggil _addToCart()
                // [LOGIKA] Disable tombol jika stok produk habis
                onPressed: product.stock > 0
                    ? () =>
                          _addToCart(context) // [FIJI INTEGRATION]
                    : null,
                child: Text(
                  product.stock > 0 ? 'Add to Cart' : 'Stok Habis',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ), // [TETAP]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
