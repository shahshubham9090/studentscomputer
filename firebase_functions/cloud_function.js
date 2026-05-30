const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Cloud Function to process notification queue securely on Firebase backend.
 * Listens to new documents in the `notification_queue` collection.
 */
exports.sendQueuedNotification = functions.firestore
  .document('notification_queue/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const { title, body, topic, status } = data;

    // Only process notifications marked as pending
    if (status !== 'pending') {
      return null;
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      topic: topic || 'all',
      android: {
        priority: 'high',
        notification: {
          channelId: 'quiz_channel',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            sound: 'default',
            badge: 1,
            contentAvailable: 1,
          },
        },
        headers: {
          'apns-priority': '10',
        },
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        type: 'admin_broadcast',
      },
    };

    try {
      // Send the message using Firebase Admin SDK securely
      const response = await admin.messaging().send(message);
      console.log(`Successfully sent message for doc ${snap.id}:`, response);

      // Update status in Firestore to sent
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
      });
    } catch (error) {
      console.error(`Error sending message for doc ${snap.id}:`, error);
      
      // Update status in Firestore to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message || String(error),
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return null;
  });
