import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/quiz_attempt_model.dart';
import '../../core/constants.dart';
import '../../core/avatar_utils.dart';
import '../../widgets/modern_stat_card.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;
  
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.stars, color: Colors.amber),
            tooltip: "Adjust Points",
            onPressed: () => _showPointAdjustmentDialog(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                   Center(
                     child: AvatarGlow(
                       glowColor: AppColors.primary,
                       duration: const Duration(milliseconds: 2000),
                       repeat: true,
                       child: CircleAvatar(
                         radius: 50,
                         backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(user)),
                       ),
                     ),
                   ),
                   const SizedBox(height: AppSpacing.m),
                   Text(
                     user.displayName,
                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                   ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                   const SizedBox(height: AppSpacing.l),
                   _UserStatsGrid(userId: user.id),
                   const SizedBox(height: AppSpacing.l),
                   const Divider(),
                   const SizedBox(height: AppSpacing.m),
                   Align(
                     alignment: Alignment.centerLeft,
                     child: Text("Attempt History", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                   ),
                ],
              ),
            ),
          ),
          _AttemptList(userId: user.id), 
        ],
      ),
    );
  }

  void _showPointAdjustmentDialog(BuildContext context) {
    final pointController = TextEditingController();
    int adjustment = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Adjust Points"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Current Points: ${user.points}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text("Add or remove points for this student. Use negative values to deduct."),
                const SizedBox(height: 16),
                TextField(
                  controller: pointController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Points to add/subtract",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.exposure),
                  ),
                  onChanged: (val) {
                    adjustment = int.tryParse(val) ?? 0;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
              ElevatedButton(
                onPressed: () async {
                  if (adjustment == 0) return;
                  
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.id)
                        .update({'points': FieldValue.increment(adjustment)});
                    
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // Go back to refresh data or show success
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Points updated: ${adjustment > 0 ? '+' : ''}$adjustment")),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                       Navigator.pop(ctx);
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                child: const Text("UPDATE"),
              ),
            ],
          );
        }
      ),
    );
  }
}

class _UserStatsGrid extends StatelessWidget {
  final String userId;
  const _UserStatsGrid({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final docs = snapshot.data!.docs;
        final totalAttempts = docs.length;
        double totalScore = 0;
        int passed = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final score = (data['score'] ?? 0) as num;
          final total = (data['totalQuestions'] ?? 0) as num;
          if (total > 0) {
            final pct = (score / total) * 100;
            totalScore += pct;
            if (pct >= 50) passed++;
          }
        }

        final avgScore = totalAttempts > 0 ? (totalScore / totalAttempts).toStringAsFixed(1) : "0.0";

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.m,
          crossAxisSpacing: AppSpacing.m,
          childAspectRatio: 1.5,
          children: [
            _MiniStat(label: "Total Attempts", value: "$totalAttempts", icon: Icons.history, color: Colors.blue),
            _MiniStat(label: "Avg. Score", value: "$avgScore%", icon: Icons.percent, color: Colors.purple),
            _MiniStat(label: "Passed Quizzes", value: "$passed", icon: Icons.check_circle, color: Colors.green),
            _MiniStat(label: "Failed Quizzes", value: "${totalAttempts - passed}", icon: Icons.cancel, color: Colors.red),
          ],
        );
      }
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _AttemptList extends StatelessWidget {
  final String userId;
  const _AttemptList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load attempt history.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history_toggle_off, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No quizzes attempted yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            ),
          );
        }

        // Sort client-side by timestamp descending (avoids composite index requirement)
        final sortedDocs = List.of(docs)
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTs = aData['timestamp'];
            final bTs = bData['timestamp'];
            if (aTs == null || bTs == null) return 0;
            final aDate = aTs is Timestamp ? aTs.toDate() : DateTime.tryParse(aTs.toString()) ?? DateTime(0);
            final bDate = bTs is Timestamp ? bTs.toDate() : DateTime.tryParse(bTs.toString()) ?? DateTime(0);
            return bDate.compareTo(aDate);
          });

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = sortedDocs[index].data() as Map<String, dynamic>;
              final attempt = QuizAttempt.fromJson(data);
              final date = DateFormat('MMM d, y • h:mm a').format(attempt.timestamp);
              final total = attempt.totalQuestions;
              final percentage = total > 0
                  ? (attempt.score / total * 100).toInt()
                  : 0;
              final isPass = percentage >= 50;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPass ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPass ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: isPass ? Colors.green : Colors.red,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    attempt.quizTitle.isNotEmpty ? attempt.quizTitle : 'Unknown Quiz',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isPass ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${attempt.score}/${attempt.totalQuestions}',
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: sortedDocs.length,
          ),
        );
      }
    );
  }
}
