import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_model.dart';
import '../../models/quiz_attempt_model.dart';
import '../../core/constants.dart';
import '../../core/app_feedback.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:share_plus/share_plus.dart';

class QuizResultsDetailScreen extends StatelessWidget {
  final Quiz quiz;
  const QuizResultsDetailScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Export Results",
            onPressed: () => _exportResults(context),
          ),
          if (!quiz.isResultsDeclared)
            TextButton(
              onPressed: () => _showDeclareDialog(context),
              child: Text(
                "DECLARE",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<QuizAttempt>>(
        stream: context.read<QuizProvider>().getAttemptsForQuiz(quiz.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ShimmerWidget.circular(width: 50, height: 50),
                  const SizedBox(height: 16),
                  ShimmerWidget.rectangular(height: 14, width: 120),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No attempts yet.",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            );
          }

          final attempts = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: attempts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final attempt = attempts[index];
              final dateStr = DateFormat('MMM dd, hh:mm a').format(attempt.timestamp);
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(attempt.userName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(attempt.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${attempt.score}/${attempt.totalQuestions}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                        ),
                        Text(
                          "Score",
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeclareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Declare Results?"),
        content: const Text("Once declared, students will be able to see their individual scores in their Results section. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              try {
                await context.read<QuizProvider>().declareResults(quiz.id);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  AppFeedback.showSuccess("Results declared successfully! 🎉");
                }
              } catch (e) {
                if (context.mounted) {
                  AppFeedback.showError(e);
                }
              }
            },
            child: const Text("DECLARE NOW", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportResults(BuildContext context) async {
    try {
      final attemptsStream = context.read<QuizProvider>().getAttemptsForQuiz(quiz.id);
      final attempts = await attemptsStream.first;
      
      if (attempts.isEmpty) {
        if (context.mounted) AppFeedback.showError("No attempts to export.");
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln("Student Name,Score,Total Questions,Date,Time");

      for (var attempt in attempts) {
        final date = DateFormat('yyyy-MM-dd').format(attempt.timestamp);
        final time = DateFormat('HH:mm:ss').format(attempt.timestamp);
        final name = attempt.userName.replaceAll(',', ' '); 
        
        buffer.writeln("$name,${attempt.score},${attempt.totalQuestions},$date,$time");
      }

      await Share.share(buffer.toString(), subject: "Results for ${quiz.title}");
    } catch (e) {
      if (context.mounted) AppFeedback.showError("Export failed: $e");
    }
  }
}
