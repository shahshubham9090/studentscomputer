import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String id;
  final String userId;
  final String userName;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.userName,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
    this.userAnswers = const {},
  });

  final Map<String, int> userAnswers;

  QuizAttempt copyWith({
    String? id,
    String? userId,
    String? userName,
    String? quizId,
    String? quizTitle,
    int? score,
    int? totalQuestions,
    DateTime? timestamp,
    Map<String, int>? userAnswers,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      quizId: quizId ?? this.quizId,
      quizTitle: quizTitle ?? this.quizTitle,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timestamp: timestamp ?? this.timestamp,
      userAnswers: userAnswers ?? this.userAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': Timestamp.fromDate(timestamp),
      'userAnswers': userAnswers,
    };
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    DateTime date;
    if (json['timestamp'] is Timestamp) {
      date = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      date = DateTime.tryParse(json['timestamp']) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return QuizAttempt(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown User',
      quizId: json['quizId'] ?? '',
      quizTitle: json['quizTitle'] ?? 'Unknown Quiz',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      timestamp: date,
      userAnswers: (json['userAnswers'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ) ?? {},
    );
  }
}
