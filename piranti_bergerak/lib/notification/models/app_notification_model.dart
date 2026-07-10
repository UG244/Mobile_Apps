class AppNotificationModel {
  AppNotificationModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.userId,
    this.targetRole = 'user',
  });

  int? id;
  String title;
  String description;
  String type;
  bool isRead;
  DateTime createdAt;
  int? userId;
  String targetRole;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'targetRole': targetRole,
    };
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    final description =
        map['description'] as String? ?? map['message'] as String? ?? '';
    final createdAt = map['createdAt'] as String? ?? map['date'] as String?;

    return AppNotificationModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: description,
      type: map['type'] as String? ?? 'Pesanan',
      isRead: (map['isRead'] as int? ?? 0) == 1,
      createdAt: createdAt == null ? DateTime.now() : DateTime.parse(createdAt),
      userId: map['userId'] as int?,
      targetRole: map['targetRole'] as String? ?? 'user',
    );
  }
}
