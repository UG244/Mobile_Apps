class CartItemModel {
  CartItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.category,
    required this.stock,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;
  final String category;
  final int stock;

  double get subtotal => price * quantity;
  bool get isAtMaxStock => stock > 0 && quantity >= stock;
}
