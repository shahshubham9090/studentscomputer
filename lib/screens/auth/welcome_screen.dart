import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToLogin(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(targetRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.primary,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 2),
                          // Logo/Icon
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/app_logo.jpg',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ).animate().fade(duration: 600.ms).scale(delay: 100.ms),
                          const SizedBox(height: AppSpacing.xl),
                          
                          Text(
                            "Welcome to\nQuiz Master",
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 42,
                              letterSpacing: 2,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                                Shadow(
                                  color: Colors.white.withOpacity(0.3),
                                  offset: const Offset(0, 0),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fade(delay: 300.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            "Choose your portal to continue",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fade(delay: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),
                          
                          const Spacer(flex: 3),

                          // Cards
                          _buildRoleCard(
                            context,
                            title: "I am a Student",
                            icon: Icons.person_outline,
                            onTap: () => _navigateToLogin(context, UserRole.user),
                          ).animate().fade(delay: 700.ms).slideX(begin: -0.2, curve: Curves.easeOutQuad),
                          const SizedBox(height: AppSpacing.l),
                          _buildRoleCard(
                            context,
                            title: "I am a Teacher",
                            icon: Icons.assignment_ind_outlined,
                            onTap: () => _navigateToLogin(context, UserRole.teacher),
                            isPrimary: false,
                          ).animate().fade(delay: 800.ms).slideX(begin: -0.2, curve: Curves.easeOutQuad),
                          const SizedBox(height: AppSpacing.l),
                          _buildRoleCard(
                            context,
                            title: "I am an Admin",
                            icon: Icons.admin_panel_settings_outlined,
                            onTap: () => _navigateToLogin(context, UserRole.admin),
                            isPrimary: false,
                          ).animate().fade(delay: 900.ms).slideX(begin: 0.2, curve: Curves.easeOutQuad),
                          
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isPrimary 
                    ? LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.15), AppColors.primaryDark.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isPrimary ? AppColors.primary : Colors.white).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isPrimary ? AppColors.primary : Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? AppColors.textPrimary : Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isPrimary ? AppColors.primary : Colors.white).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isPrimary ? AppColors.primary : Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
