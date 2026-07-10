class CheckoutAddressModel {
  CheckoutAddressModel({
    this.id,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.note,
    required this.createdAt,
  });

  int? id;
  String recipientName;
  String phone;
  String address;
  String note;
  DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientName': recipientName,
      'phone': phone,
      'address': address,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CheckoutAddressModel.fromMap(Map<String, dynamic> map) {
    return CheckoutAddressModel(
      id: map['id'] as int?,
      recipientName: map['recipientName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
