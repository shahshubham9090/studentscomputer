import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_model.dart';

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String type; // 'pdf', 'link', 'video', 'mcq'
  final String? url;
  final List<Question>? questions;
  final String? category;
  final DateTime createdAt;
  final bool isHidden;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    this.questions,
    this.category,
    required this.createdAt,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'questions': questions?.map((q) => q.toJson()).toList(),
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'isHidden': isHidden,
    };
  }

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'link',
      url: json['url'],
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q))
          .toList(),
      category: json['category'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isHidden: json['isHidden'] ?? false,
    );
  }

  StudyMaterial copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? url,
    List<Question>? questions,
    String? category,
    DateTime? createdAt,
    bool? isHidden,
  }) {
    return StudyMaterial(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      url: url ?? this.url,
      questions: questions ?? this.questions,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
