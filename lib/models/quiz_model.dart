import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String text;
  final List<String> choices;
  final int correctChoiceIndex;
  final String? imageUrl;
  final String? explanation;
  final int timeSeconds;

  Question({
    required this.id,
    required this.text,
    required this.choices,
    required this.correctChoiceIndex,
    this.imageUrl,
    this.explanation,
    this.timeSeconds = 30,
  });

  Question copyWith({
    String? id,
    String? text,
    List<String>? choices,
    int? correctChoiceIndex,
    String? imageUrl,
    String? explanation,
    int? timeSeconds,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      choices: choices ?? this.choices,
      correctChoiceIndex: correctChoiceIndex ?? this.correctChoiceIndex,
      imageUrl: imageUrl ?? this.imageUrl,
      explanation: explanation ?? this.explanation,
      timeSeconds: timeSeconds ?? this.timeSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'choices': choices,
      'correctChoiceIndex': correctChoiceIndex,
      'imageUrl': imageUrl,
      'explanation': explanation,
      'timeSeconds': timeSeconds,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      choices: json['choices'] != null ? List<String>.from(json['choices']) : [],
      correctChoiceIndex: json['correctChoiceIndex'] ?? 0,
      imageUrl: json['imageUrl'],
      explanation: json['explanation'],
      timeSeconds: json['timeSeconds'] ?? 30,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final DateTime publishDate;
  final List<Question> questions;
  final bool isPublished;
  final bool isResultsDeclared;
  final String? groupId;
  final String? creatorId;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.publishDate,
    required this.questions,
    this.isPublished = false,
    this.isResultsDeclared = false,
    this.groupId,
    this.creatorId,
  });

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? publishDate,
    List<Question>? questions,
    bool? isPublished,
    bool? isResultsDeclared,
    String? groupId,
    String? creatorId,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      publishDate: publishDate ?? this.publishDate,
      questions: questions ?? this.questions,
      isPublished: isPublished ?? this.isPublished,
      isResultsDeclared: isResultsDeclared ?? this.isResultsDeclared,
      groupId: groupId ?? this.groupId,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publishDate': Timestamp.fromDate(publishDate),
      'questions': questions.map((q) => q.toJson()).toList(),
      'isPublished': isPublished,
      'isResultsDeclared': isResultsDeclared,
      'groupId': groupId,
      'creatorId': creatorId,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    DateTime date;
    if (json['publishDate'] is Timestamp) {
      date = (json['publishDate'] as Timestamp).toDate();
    } else if (json['publishDate'] is String) {
      date = DateTime.tryParse(json['publishDate']) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      publishDate: date,
      questions: (json['questions'] as List?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
      isPublished: json['isPublished'] ?? false,
      isResultsDeclared: json['isResultsDeclared'] ?? false,
      groupId: json['groupId'],
      creatorId: json['creatorId'],
    );
  }
}
