import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:studentscomputer/core/constants.dart';
import 'package:studentscomputer/core/error_handler.dart';

class AppFeedback {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showAwesomeSnackBar(
      title: 'Success!',
      message: message,
      contentType: ContentType.success,
    );
  }

  static void showError(dynamic error) {
    final message = AppErrorHandler.getErrorMessage(error);
    _showAwesomeSnackBar(
      title: 'Oh Snap!',
      message: message,
      contentType: ContentType.failure,
    );
  }

  static void showInfo(String message) {
    _showAwesomeSnackBar(
      title: 'Heads up!',
      message: message,
      contentType: ContentType.help,
    );
  }
  
  static void showWarning(String message) {
    _showAwesomeSnackBar(
      title: 'Warning!',
      message: message,
      contentType: ContentType.warning,
    );
  }

  static void _showAwesomeSnackBar({required String title, required String message, required ContentType contentType}) {
    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
          inMaterialBanner: true,
        ),
      ),
    );
  }
}
