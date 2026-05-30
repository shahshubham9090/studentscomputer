import 'package:cloud_firestore/cloud_firestore.dart';

class Doubt {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final bool isResolved;
  final String? adminReply;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Doubt({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    this.isResolved = false,
    this.adminReply,
    required this.createdAt,
    this.resolvedAt,
  });

  Doubt copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    bool? isResolved,
    String? adminReply,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Doubt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      isResolved: isResolved ?? this.isResolved,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'isResolved': isResolved,
      'adminReply': adminReply,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  factory Doubt.fromJson(Map<String, dynamic> json) {
    return Doubt(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown User',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isResolved: json['isResolved'] ?? false,
      adminReply: json['adminReply'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      resolvedAt: json['resolvedAt'] != null ? (json['resolvedAt'] as Timestamp).toDate() : null,
    );
  }
}
