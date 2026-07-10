/// Model untuk kategori produk.
/// Digunakan di Home (shortcut kategori) dan Product List (filter chip).
class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.color = 0xFF1565C0,
  });

  /// ID unik kategori (primary key di tabel `categories`)
  final String id;

  /// Nama kategori, contoh: "Laptop", "Aksesoris"
  final String name;

  /// Nama icon Material Icons, contoh: "laptop_mac", "headphones"
  final String iconName;

  /// Warna aksen kategori dalam format ARGB integer
  final int color;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'color': color,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> m) {
    return CategoryModel(
      id: m['id'] as String,
      name: m['name'] as String,
      iconName: m['iconName'] as String,
      color: m['color'] as int? ?? 0xFF1565C0,
    );
  }
}
