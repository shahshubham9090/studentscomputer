import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import '../../core/avatar_utils.dart';
import '../../widgets/quiz_card.dart';
import '../../widgets/modern_stat_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/banner_ad_widget.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../providers/material_provider.dart';
import 'quiz_detail_screen.dart';
import 'material_list_screen.dart';
import 'material_detail_screen.dart';
import 'doubts_list_screen.dart';
import 'student_groups_screen.dart';
import '../../providers/group_provider.dart';

class UserHomeTab extends StatefulWidget {
  const UserHomeTab({super.key});

  @override
  State<UserHomeTab> createState() => _UserHomeTabState();
}

class _UserHomeTabState extends State<UserHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<GroupProvider>(context, listen: false).fetchStudentGroups(user.id);
        Provider.of<GroupProvider>(context, listen: false).fetchPendingStudentGroups(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final materialProvider = context.watch<MaterialProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    
    // Filter quizzes to show global quizzes or those assigned to groups the student joined
    final joinedGroupIds = groupProvider.studentGroups.map((g) => g.id).toList();
    final quizzes = quizProvider.publishedQuizzes.where((q) {
      return q.groupId == null || q.groupId!.isEmpty || joinedGroupIds.contains(q.groupId);
    }).toList();
    
    final isLoading = quizProvider.isLoadingQuizzes || materialProvider.isLoading;

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          await Future.wait([
            Future.delayed(const Duration(milliseconds: 500)),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, user),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                 _buildSectionHeader(context, "Classrooms & Groups", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentGroupsScreen()));
                 }),
                 _buildGroupsCard(context),
                 const SizedBox(height: AppSpacing.xl),

                 _buildSectionHeader(context, "Study Materials", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialListScreen()));
                 }),
                 _buildMaterialQuickAccess(context, isLoading),

                const SizedBox(height: AppSpacing.xl),
                _buildSectionHeader(context, "Doubts & Support", () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const DoubtsListScreen()));
                }),
                _buildDoubtCard(context),

                const SizedBox(height: AppSpacing.xl),
                _buildProgressHeader(context),
                _buildStatsGrid(quizzes.length, isLoading),

                const SizedBox(height: AppSpacing.xl),
                _buildAvailableQuizzesHeader(context),
                const BannerAdWidget(),
                ..._buildAllQuizzes(context, quizProvider, quizzes, user, isLoading),
                
                if (quizzes.isEmpty && !isLoading)
                   Container(
                     margin: const EdgeInsets.only(top: 20),
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.surface,
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
                     ),
                     child: Column(
                       children: [
                         Icon(Icons.quiz_outlined, size: 56, color: Colors.grey.shade300),
                         const SizedBox(height: 16),
                         Text(
                           "No Quizzes Yet",
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           "Quizzes will appear here once published by the admin.",
                           textAlign: TextAlign.center,
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
                             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel? user) {
    return SliverAppBar(
      floating: true,
      expandedHeight: 80,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 12),
          _buildWelcomeText(context, user),
        ],
      ),
      actions: [_buildPointsBadge(user)],
    );
  }

  Widget _buildAvatar(UserModel? user) {
    return AvatarGlow(
      glowColor: AppColors.primary,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: ClipOval(
          child: user != null 
            ? Image.network(
                AvatarUtils.getAvatarUrl(user),
                width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey),
              )
            : Image.asset('assets/images/app_logo.jpg', width: 40, height: 40, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, UserModel? user) {
    final greeting = _getTimeBasedGreeting();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$greeting, ${user?.displayName ?? 'User'}! 👋",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(_getMotivationalMessage(), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 21) return "Good Evening";
    return "Good Night";
  }

  String _getMotivationalMessage() {
    final messages = [
      "Ready to ace today's challenge? 🚀",
      "Let's learn something amazing! ✨",
      "Time to level up your skills! 📚",
      "Every quiz makes you smarter! 🧠",
      "You're doing great! Keep going! 💪",
    ];
    return messages[DateTime.now().day % messages.length];
  }

  Widget _buildPointsBadge(UserModel? user) {
    final points = user?.points ?? 0;
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            "$points",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProgressHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: AppGradients.success,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Your Progress",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int quizCount, bool isLoading) {
    if (isLoading) {
      return const Row(
        children: [
          Expanded(child: StatCardSkeleton()),
          SizedBox(width: AppSpacing.m),
          Expanded(child: StatCardSkeleton()),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: ModernStatCard(label: 'Quizzes', value: '$quizCount', icon: Icons.quiz_outlined, color: AppColors.primary)),
        const SizedBox(width: AppSpacing.m),
        const Expanded(child: ModernStatCard(label: 'Accuracy', value: '85%', icon: Icons.track_changes, color: AppColors.success)),
      ],
    );
  }

  Widget _buildAvailableQuizzesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.quiz_outlined, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Available Quizzes",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Take any quiz to earn points!",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllQuizzes(BuildContext context, QuizProvider provider, List<Quiz> quizzes, UserModel? user, bool isLoading) {
    if (isLoading) {
      return List.generate(3, (index) => const QuizCardSkeleton());
    }
    if (quizzes.isEmpty) {
      return [_buildEmptyState(context)];
    }
    return quizzes.map((q) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: FutureBuilder<bool>(
        future: provider.hasAttempted(q.id, user?.id ?? ''),
        builder: (context, snapshot) {
          final hasTaken = snapshot.data ?? false;
          return QuizCard(
            quiz: q, 
            onTap: hasTaken 
                ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You have already completed this quiz!")))
                : () => _openQuiz(context, q),
          );
        }
      ),
    )).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.05), AppColors.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            "No Quiz Available Yet",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "New quizzes are added regularly.\nCheck back soon for exciting challenges! 🎯",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              // Refresh action
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text("See All"),
        ),
      ],
    );
  }

  Widget _buildMaterialQuickAccess(BuildContext context, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) => const SizedBox(
            width: 150,
            child: MaterialCardSkeleton(),
          ),
        ),
      );
    }
    final materialProvider = context.watch<MaterialProvider>();
    final materials = materialProvider.visibleMaterials.take(3).toList();

                if (materials.isEmpty) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, color: Colors.grey.shade400, size: 32),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Study Materials",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Materials will appear here",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          IconData icon;
          Color color;

          switch (material.type) {
            case 'mcq': icon = Icons.quiz; color = Colors.green; break;
            case 'pdf': icon = Icons.picture_as_pdf; color = Colors.red; break;
            case 'video': icon = Icons.play_circle; color = Colors.orange; break;
            default: icon = Icons.link; color = Colors.blue;
          }

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  if (material.type == 'mcq') {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialDetailScreen(material: material)));
                  } else {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialListScreen()));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        material.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoubtCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoubtsListScreen())),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Stuck on a question?",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ask your doubt and get expert help.",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentGroupsScreen())),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.school_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Join a Classroom",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Connect with teachers and classmates.",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openQuiz(BuildContext context, Quiz quiz) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizDetailScreen(quiz: quiz)));
  }
}
