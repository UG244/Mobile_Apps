class OrderDetailModel {
  OrderDetailModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    this.imageUrl = '',
  });

  int? id;
  int orderId;
  String productId;
  String name;
  double price;
  int quantity;
  double total;
  String imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'imageUrl': imageUrl,
    };
  }

  factory OrderDetailModel.fromMap(Map<String, dynamic> m) {
    return OrderDetailModel(
      id: m['id'] as int?,
      orderId: m['orderId'] as int,
      productId: m['productId'] as String,
      name: m['name'] as String,
      price: (m['price'] as num).toDouble(),
      quantity: m['quantity'] as int,
      total: (m['total'] as num).toDouble(),
      imageUrl: m['imageUrl'] as String? ?? '',
    );
  }
}
