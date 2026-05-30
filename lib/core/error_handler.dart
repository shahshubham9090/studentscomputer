import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'network-request-failed':
          return 'No internet connection. Please check your network.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again in 5 minutes.';
        default:
          final msg = error.message ?? '';
          if (msg.contains('credential') && msg.contains('incorrect')) {
            return 'Incorrect email or password. Please try again.';
          }
          return 'Authentication failed. Please try again.';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. You don\'t have permission for this.';
        case 'unavailable':
          return 'Server is busy. Please try again in a moment.';
        case 'not-found':
          return 'The requested information was not found.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }

    // Handle generic exceptions/errors
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || errorString.contains('network') || errorString.contains('failed host lookup')) {
      return 'Internet connection lost. Please check your data or Wi-Fi.';
    }

    if (errorString.contains('credential') && (errorString.contains('incorrect') || errorString.contains('malformed'))) {
      return 'Incorrect email or password. Please try again.';
    }
    
    if (errorString.contains('exception: ')) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'Something went wrong. Please try again later.';}
  
  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('failed host lookup') ||
           errorString.contains('socket');
  }

  /// Get user-friendly network error message
  static String getNetworkErrorMessage() {
    return 'No internet connection. Please check your network and try again.';
  }
}
