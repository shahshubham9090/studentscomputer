import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../core/constants.dart';
import '../../core/avatar_utils.dart';
import '../../widgets/modern_stat_card.dart';
import 'create_quiz_screen.dart';
import 'send_notification_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/quiz_attempt_model.dart';
import '../../models/user_model.dart';

import 'admin_results_tab.dart';
import 'manage_quizzes_screen.dart';
import 'manage_users_screen.dart';
import 'admin_doubts_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';


class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final quizProvider = context.watch<QuizProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _AdminHeader(user: user),
        if (_isLoading) ...[
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.l),
            sliver: SliverToBoxAdapter(child: _ShimmerStatGrid()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: _ShimmerQuickActions(),
            ),
          ),
        ] else ...[
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.l),
            sliver: _AdminStatGrid(quizProvider: quizProvider),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: _QuickActionsList(),
            ),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

// ─── Shimmer Helpers ──────────────────────────────────────────────────────────

Widget _shimmerBox({double? width, double? height, double radius = 12, EdgeInsets? margin}) {
  return Container(
    width: width,
    height: height,
    margin: margin,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class _ShimmerStatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : 2);
    
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.m,
          crossAxisSpacing: AppSpacing.m,
          childAspectRatio: width > 800 ? 1.1 : 0.85,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _shimmerBox(width: 44, height: 44, radius: 14),
              const SizedBox(height: 16),
              _shimmerBox(width: double.infinity, height: 14, radius: 8),
              const SizedBox(height: 8),
              _shimmerBox(width: 60, height: 28, radius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.l),
          // Section title
          _shimmerBox(width: 140, height: 20, radius: 8),
          const SizedBox(height: AppSpacing.m),
          // Chart card
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 180, height: 16, radius: 8),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) {
                      final heights = [80.0, 110.0, 60.0, 130.0, 90.0];
                      return _shimmerBox(width: 28, height: heights[i], radius: 8);
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          // Hardest quizzes card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerBox(width: 36, height: 36, radius: 10),
                    const SizedBox(width: 12),
                    _shimmerBox(width: 130, height: 16, radius: 8),
                  ],
                ),
                const SizedBox(height: 20),
                ...List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(width: double.infinity, height: 14, radius: 6),
                            const SizedBox(height: 6),
                            _shimmerBox(width: 120, height: 12, radius: 6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _shimmerBox(width: 70, height: 28, radius: 20),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.l),
          _shimmerBox(width: 130, height: 20, radius: 8),
          const SizedBox(height: AppSpacing.m),
          ...List.generate(4, (_) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _shimmerBox(width: 56, height: 56, radius: 18),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: double.infinity, height: 16, radius: 8),
                      const SizedBox(height: 8),
                      _shimmerBox(width: 160, height: 12, radius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _shimmerBox(width: 30, height: 30, radius: 15),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final UserModel? user;
  const _AdminHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return SliverAppBar(
      expandedHeight: isDesktop ? 180 : 220,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: isDesktop ? 40 : 20, bottom: 20),
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Premium Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4A00E0)], // Deep Purple to Royal Blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Abstract decorative circles
            Positioned(
              top: -50, right: -50,
              child: Container(
                width: 250, height: 250, 
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: Colors.white.withOpacity(0.05)
                )
              ),
            ),
            Positioned(
              bottom: -80, left: -20,
              child: Container(
                width: 200, height: 200, 
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: Colors.white.withOpacity(0.08)
                )
              ),
            ),
            // User Profile Section
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isDesktop ? 40 : 24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: currentUser != null 
                                    ? NetworkImage(AvatarUtils.getAvatarUrl(currentUser))
                                    : const AssetImage('assets/images/app_logo.jpg') as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Admin', 
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9), 
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                                Text(
                                  currentUser?.displayName ?? 'Administrator', 
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 18, 
                                    fontWeight: FontWeight.w800
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SendNotificationScreen()),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStatGrid extends StatelessWidget {
  final QuizProvider quizProvider;
  const _AdminStatGrid({required this.quizProvider});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : 2);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.m,
        crossAxisSpacing: AppSpacing.m,
        childAspectRatio: width > 800 ? 1.1 : 0.85,
      ),
      delegate: SliverChildListDelegate([
        ModernStatCard(
          label: 'Total Quizzes',
          value: '${quizProvider.quizzes.length}',
          icon: Icons.assignment_rounded,
          color: Colors.blue,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuizzesScreen())),
        ),
        ModernStatCard(
          label: 'Published',
          value: '${quizProvider.publishedQuizzes.length}',
          icon: Icons.public,
          color: Colors.green,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuizzesScreen())),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return ModernStatCard(
              label: 'Students',
              value: '$count',
              icon: Icons.people_alt_rounded,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
            );
          }
        ),
        ModernStatCard(
          label: 'Pending Results',
          value: '${quizProvider.quizzes.where((q) => !q.isResultsDeclared).length}',
          icon: Icons.pending_actions,
          color: Colors.redAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminResultsTab())),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('quiz_attempts').snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return ModernStatCard(
              label: 'Total Attempts',
              value: '$count',
              icon: Icons.bar_chart_rounded,
              color: Colors.deepPurple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminResultsTab())),
            );
          }
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('doubts').where('isResolved', isEqualTo: false).snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return ModernStatCard(
              label: 'Pending Doubts',
              value: '$count',
              icon: Icons.live_help_rounded,
              color: Colors.pink,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDoubtsScreen())),
            );
          }
        ),
      ]),
    );
  }
}

class _AdminAnalyticsView extends StatelessWidget {
  const _AdminAnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Performance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            TextButton(onPressed: (){}, child: const Text("View All")),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('quiz_attempts').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text("No analytics data yet", style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final Map<String, int> popularity = {};
            final Map<String, List<int>> scores = {};
            final Map<String, String> titles = {};
            final quizProvider = context.read<QuizProvider>();

            for (var doc in docs) {
              final attempt = QuizAttempt.fromJson(doc.data() as Map<String, dynamic>);
              if (attempt.quizId.isEmpty || attempt.totalQuestions <= 0) continue;

              final percent = (attempt.score / attempt.totalQuestions * 100).toInt();
              popularity[attempt.quizId] = (popularity[attempt.quizId] ?? 0) + 1;
              scores[attempt.quizId] = (scores[attempt.quizId] ?? [])..add(percent);
              
              final quiz = quizProvider.quizzes.where((q) => q.id == attempt.quizId).firstOrNull;
              titles[attempt.quizId] = quiz?.title ?? attempt.quizTitle;
            }

            final sortedPop = popularity.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
            final top5 = sortedPop.take(5).toList();

            final difficulty = scores.entries.map((e) {
              final avg = e.value.reduce((a, b) => a + b) / e.value.length;
              return MapEntry(e.key, avg);
            }).toList()..sort((a, b) => a.value.compareTo(b.value));
            
            final top3Hard = difficulty.take(3).toList();

            return Column(
              children: [
                _PopularityChart(data: top5),
                const SizedBox(height: AppSpacing.m),
                _HardestQuizzesList(data: top3Hard, titles: titles, scores: scores),
              ],
            );
          }
        ),
      ],
    );
  }
}

class _PopularityChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  const _PopularityChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Most Attempted Quizzes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value.toDouble(),
                          color: AppColors.primary,
                          width: 12,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: data.map((d) => d.value).reduce((a, b) => a > b ? a : b).toDouble(),
                            color: AppColors.primary.withOpacity(0.05),
                          )
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HardestQuizzesList extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final Map<String, String> titles;
  final Map<String, List<int>> scores;

  const _HardestQuizzesList({required this.data, required this.titles, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20)
                ),
                const SizedBox(width: 12),
                Text("Needs Attention", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 20),
            ...data.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titles[e.key] ?? "Unknown Quiz", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("${scores[e.key]?.length} students struggled", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("${e.value.toStringAsFixed(0)}% Avg", style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsList extends StatelessWidget {
  const _QuickActionsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.l),
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.m),
        _buildActionTile(
          context,
          'Create Quiz',
          'Add a new challenge for students',
          Icons.add_task_rounded,
          AppColors.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQuizScreen())),
        ),
        _buildActionTile(
          context,
          'Notice Board',
          'Send important updates to everyone',
          Icons.campaign_rounded,
          AppColors.secondary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendNotificationScreen())),
        ),
        _buildActionTile(
          context,
          'Declare Results',
          'Publish scores for completed quizzes',
          Icons.emoji_events_rounded,
          Colors.blue,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminResultsTab())),
        ),
        _buildActionTile(
          context,
          'Student Doubts',
          'Resolve questions from students',
          Icons.support_agent_rounded,
          Colors.orange,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDoubtsScreen())),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
