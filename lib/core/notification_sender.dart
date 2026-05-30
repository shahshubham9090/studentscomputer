import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationSender {
  /// Queues a push notification in Firestore `notification_queue` to be sent securely by a backend/Cloud Function.
  static Future<bool> sendNotification({
    required String title,
    required String body,
    String topic = 'all',
  }) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      await firestore.collection('notification_queue').add({
        'title': title,
        'body': body,
        'topic': topic,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      debugPrint("✅ Notification queued successfully for topic: $topic");
      return true;
    } catch (e) {
      debugPrint("❌ Exception queueing notification: $e");
      return false;
    }
  }
}
