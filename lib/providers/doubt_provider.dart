import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doubt_model.dart';
import '../core/error_handler.dart';
import '../core/notification_sender.dart';

class DoubtProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Doubt> _userDoubts = [];
  List<Doubt> get userDoubts => _userDoubts;

  List<Doubt> _allDoubts = [];
  List<Doubt> get allDoubts => _allDoubts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  StreamSubscription<QuerySnapshot>? _userDoubtsSubscription;

  @override
  void dispose() {
    _userDoubtsSubscription?.cancel();
    super.dispose();
  }

  // User Side: Listen to own doubts
  void listenToUserDoubts(String userId) {
    _userDoubtsSubscription?.cancel();
    _userDoubtsSubscription = _firestore
        .collection('doubts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _userDoubts = snapshot.docs.map((doc) => Doubt.fromJson(doc.data())).toList();
      // Client-side sort to avoid composite index requirement
      _userDoubts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }, onError: (e) {
      debugPrint("DoubtProvider: User Listen Error: $e");
    });
  }

  // Admin Side: Listen to all doubts
  void listenToAllDoubts() {
    _firestore
        .collection('doubts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allDoubts = snapshot.docs.map((doc) => Doubt.fromJson(doc.data())).toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint("DoubtProvider: Admin Listen Error: $e");
    });
  }

  Future<void> createDoubt(Doubt doubt) async {
    _setLoading(true);
    try {
      await _firestore.collection('doubts').doc(doubt.id).set(doubt.toJson());
    } catch (e) {
      _error = AppErrorHandler.getErrorMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> replyToDoubt(String doubtId, String reply) async {
    _setLoading(true);
    try {
      // 1. Update the doubt in Firestore
      await _firestore.collection('doubts').doc(doubtId).update({
        'adminReply': reply,
        'isResolved': true,
        'resolvedAt': DateTime.now(),
      });

      // 2. Fetch the doubt to get the userId for notification
      final doc = await _firestore.collection('doubts').doc(doubtId).get();
      if (doc.exists) {
        final doubt = Doubt.fromJson(doc.data()!);
        
        // 3. Send notification to the user
        await NotificationSender.sendNotification(
          title: "Doubt Solved ✅",
          body: "Teacher has replied to your doubt: ${doubt.title}",
          topic: "user_${doubt.userId}",
        );
      }
    } catch (e) {
      _error = AppErrorHandler.getErrorMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
