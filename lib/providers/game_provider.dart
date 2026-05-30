import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studentscomputer/models/user_model.dart';
import 'package:studentscomputer/providers/auth_provider.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider _authProvider;

  GameProvider(this._authProvider);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> saveScore(String gameId, int score) async {
    final user = _authProvider.currentUser;
    if (user == null) return;

    final currentScore = user.gameScores[gameId] ?? 0;

    // Only update if the new score is higher
    if (score > currentScore) {
      _isLoading = true;
      notifyListeners();

      try {
        await _firestore.collection('users').doc(user.id).update({
          'gameScores.$gameId': score,
        });
        
        debugPrint("✅ Score saved: $gameId = $score");
        
      } catch (e) {
        debugPrint("Error saving game score: $e");
        // Don't throw, just log - game should still be playable
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Stream<List<UserModel>> getLeaderboard(String gameId) {
    return _firestore
        .collection('users')
        .orderBy('gameScores.$gameId', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return UserModel.fromJson(doc.data());
        } catch (e) {
          return null;
        }
      }).whereType<UserModel>().toList();
    });
  }
}
