import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'manage_quizzes_screen.dart';
import 'manage_users_screen.dart';
import 'manage_materials_screen.dart';
import 'leaderboard_screen.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';

class AdminManagementTab extends StatelessWidget {
  const AdminManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          if (isDesktop) {
            return GridView.count(
              padding: const EdgeInsets.all(AppSpacing.xl),
              crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
              mainAxisSpacing: AppSpacing.l,
              crossAxisSpacing: AppSpacing.l,
              childAspectRatio: 2.5,
              children: _buildItems(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: _buildItems(context),
          );
        }
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    return [
      _buildManageCard(
        context,
        'Quiz Management',
        'Edit, delete, and publish your quizzes',
        Icons.assignment_rounded,
        Colors.blue,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuizzesScreen())),
      ),
      const SizedBox(height: AppSpacing.m),
      _buildManageCard(
        context,
        'User Management',
        'View and manage registered students',
        Icons.people_rounded,
        Colors.indigo,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
      ),
      const SizedBox(height: AppSpacing.m),
      _buildManageCard(
        context,
        'Student Leaderboard',
        'View top performing students',
        Icons.emoji_events_rounded,
        Colors.amber,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
      ),
      const SizedBox(height: AppSpacing.m),
      _buildManageCard(
        context,
        'Material Management',
        'Upload study materials and MCQs',
        Icons.library_books_rounded,
        Colors.orange,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageMaterialsScreen())),
      ),
      const SizedBox(height: AppSpacing.m),
      _buildManageCard(
        context,
        'Logout',
        'Sign out from your admin account',
        Icons.logout_rounded,
        AppColors.error,
        () async {
          final authProvider = context.read<AuthProvider>();
          await authProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
          }
        },
      ),
    ];
  }

  Widget _buildManageCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
