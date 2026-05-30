import 'package:flutter/material.dart';

class AppColors {
  // Primary (Deep Purple -> Blue Gradient)
  static const Color primary = Color(0xFF6A11CB);
  static const Color primaryDark = Color(0xFF2575FC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary (Coral Gradient)
  static const Color secondary = Color(0xFFFF512F);
  static const Color secondaryDark = Color(0xFFDD2476);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Accent (Amber)
  static const Color accent = Color(0xFFFFB347);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Success
  static const Color success = Color(0xFF00B09B);
  static const Color successDark = Color(0xFF96C93D);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Error
  static const Color error = Color(0xFFFF416C);
  static const Color errorDark = Color(0xFFFF4B2B);
  static const Color onError = Color(0xFFFFFFFF);

  // Background & Surface
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF2D3436);
  static const Color onSurface = Color(0xFF2D3436);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // Legacy (Keeping for compatibility for now)
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  static const Color outline = Color(0xFF79747E);
  static const Color correct = success;
  static const Color wrong = error;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient success = LinearGradient(
    colors: [AppColors.success, AppColors.successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fire = LinearGradient(
    colors: [Color(0xFFf12711), Color(0xFFf5af19)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
