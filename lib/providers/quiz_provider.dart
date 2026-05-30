import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/quiz_attempt_model.dart';
import '../core/error_handler.dart';
import '../core/notification_sender.dart';

class QuizProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Quiz> _quizzes = [];
  List<Quiz> get quizzes => _quizzes;

  String? _error;
  String? get error => _error;

  bool _isLoadingQuizzes = false;
  bool get isLoadingQuizzes => _isLoadingQuizzes;

  // Rate limiting: Track last submission time per user-quiz combination
  final Map<String, DateTime> _lastSubmissionTimes = {};
  static const int _submissionCooldownSeconds = 5;

  QuizProvider() {
    _initListeners();
  }

  void _initListeners() {
    _isLoadingQuizzes = true;
    _firestore.collection('quizzes').snapshots().listen((snapshot) {
      _quizzes = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id; 
        return Quiz.fromJson(data);
      }).toList();
      
      // Sort by publishDate descending (newest first)
      _quizzes.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      _isLoadingQuizzes = false;
      notifyListeners();
    }, onError: (e) {
      _error = AppErrorHandler.getErrorMessage(e);
      _isLoadingQuizzes = false;
      notifyListeners();
    });
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  List<Quiz> get publishedQuizzes => _quizzes.where((q) => q.isPublished).toList();

  Quiz? get todaysQuiz {
    if (publishedQuizzes.isEmpty) return null;
    // Return the latest published quiz
    final sorted = List<Quiz>.from(publishedQuizzes)
      ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return sorted.first;
  }

  Future<void> addQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
    } catch (e) {
      debugPrint("QuizProvider: Add Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> togglePublishStatus(String quizId) async {
    try {
      final quiz = _quizzes.firstWhere(
        (q) => q.id == quizId,
        orElse: () => throw StateError('Quiz with id $quizId not found'),
      );
      final newStatus = !quiz.isPublished;
      
      // Optimistic update
      final index = _quizzes.indexWhere((q) => q.id == quizId);
      if (index != -1) {
        _quizzes[index] = _quizzes[index].copyWith(isPublished: newStatus);
        notifyListeners();
      }

      await _firestore.collection('quizzes').doc(quizId).update({'isPublished': newStatus});
    } catch (e) {
      debugPrint("QuizProvider: Toggle Publish Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).delete();
    } catch (e) {
      debugPrint("QuizProvider: Delete Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).update(quiz.toJson());
    } catch (e) {
      debugPrint("QuizProvider: Update Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<bool> hasAttempted(String quizId, String userId) async {
    try {
      final doc = await _firestore.collection('quiz_attempts').doc('${userId}_${quizId}').get();
      return doc.exists;
    } catch (e) {
      debugPrint("QuizProvider: Check Attempt Error: $e");
      return false;
    }
  }

  Future<void> declareResults(String quizId) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({'isResultsDeclared': true});
      
      // Send notification to all users
      final quiz = _quizzes.firstWhere(
        (q) => q.id == quizId,
        orElse: () => throw StateError('Quiz with id $quizId not found'),
      );
      await NotificationSender.sendNotification(
        title: "Result Declared! 🏆",
        body: "The results for '${quiz.title}' are now live. Check your score now!",
      );
    } catch (e) {
      debugPrint("QuizProvider: Declare Results Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
      notifyListeners();
    }
  }

  Future<QuizAttempt?> getUserQuizAttempt(String quizId, String userId) async {
    try {
      final doc = await _firestore.collection('quiz_attempts').doc('${userId}_${quizId}').get();
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        return QuizAttempt.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("QuizProvider: Get User Attempt Error: $e");
      return null;
    }
  }

  Stream<List<QuizAttempt>> getAttemptsForQuiz(String quizId) {
    return _firestore
        .collection('quiz_attempts')
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return QuizAttempt.fromJson(data);
            })
            .toList());
  }

  Stream<List<QuizAttempt>> getUserResults(String userId) {
    return _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return QuizAttempt.fromJson(data);
            })
            .toList());
  }

  Future<int> submitQuiz({
    required String quizId,
    required String userId,
    required String userName,
    required String quizTitle,
    required Map<String, int> answers,
  }) async {
    // Rate Limiting Check
    final submissionKey = '${userId}_$quizId';
    final now = DateTime.now();
    
    if (_lastSubmissionTimes.containsKey(submissionKey)) {
      final lastSubmission = _lastSubmissionTimes[submissionKey]!;
      final secondsSinceLastSubmit = now.difference(lastSubmission).inSeconds;
      
      if (secondsSinceLastSubmit < _submissionCooldownSeconds) {
        final remainingSeconds = _submissionCooldownSeconds - secondsSinceLastSubmit;
        throw Exception('Please wait $remainingSeconds seconds before submitting again');
      }
    }

    // Record this submission attempt
    _lastSubmissionTimes[submissionKey] = now;

    final quiz = _quizzes.firstWhere(
      (q) => q.id == quizId,
      orElse: () => throw StateError('Quiz with id $quizId not found'),
    );
    int score = 0;
    
    for (var question in quiz.questions) {
      final userAnswer = answers[question.id];
      if (userAnswer != null && userAnswer == question.correctChoiceIndex) {
        score += 1; 
      }
    }

    final attempt = QuizAttempt(
      id: '${userId}_${quizId}',
      userId: userId,
      userName: userName,
      quizId: quizId,
      quizTitle: quizTitle,
      score: score,
      totalQuestions: quiz.questions.length,
      timestamp: DateTime.now(),
      userAnswers: answers,
    );

    final batch = _firestore.batch();
    
    // 1. Record Attempt
    final attemptRef = _firestore.collection('quiz_attempts').doc(attempt.id);
    batch.set(attemptRef, attempt.toJson());

    // 2. Update User Points & Stats (Atomic Increment)
    if (score > 0) {
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'points': FieldValue.increment(score),
        'lastPlayedAt': DateTime.now().toIso8601String(),
      });
    }

    try {
      await batch.commit();
      return score;
    } catch (e) {
      debugPrint("QuizProvider: Batch Submit Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }
}
