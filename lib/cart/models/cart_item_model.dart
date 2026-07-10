class CartItemModel {
  CartItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;
  final String category;

  double get subtotal => price * quantity;
}
