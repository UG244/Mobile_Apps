class OrderModel {
  OrderModel({
    this.id,
    required this.invoice,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.note,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.date,
  });

  int? id;
  String invoice;
  String customerName;
  String phone;
  String address;
  String note;
  String paymentMethod;
  String shippingMethod;
  double subtotal;
  double shippingCost;
  double discount;
  double tax;
  double grandTotal;
  DateTime date;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice': invoice,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'note': note,
      'paymentMethod': paymentMethod,
      'shippingMethod': shippingMethod,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'discount': discount,
      'tax': tax,
      'grandTotal': grandTotal,
      'date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> m) {
    return OrderModel(
      id: m['id'] as int?,
      invoice: m['invoice'] as String,
      customerName: m['customerName'] as String,
      phone: m['phone'] as String,
      address: m['address'] as String,
      note: m['note'] as String? ?? '',
      paymentMethod: m['paymentMethod'] as String,
      shippingMethod: m['shippingMethod'] as String,
      subtotal: (m['subtotal'] as num).toDouble(),
      shippingCost: (m['shippingCost'] as num).toDouble(),
      discount: (m['discount'] as num).toDouble(),
      tax: (m['tax'] as num).toDouble(),
      grandTotal: (m['grandTotal'] as num).toDouble(),
      date: DateTime.parse(m['date'] as String),
    );
  }
}
