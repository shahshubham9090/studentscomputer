import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import 'quiz_results_detail_screen.dart';
import '../../core/app_feedback.dart';
import 'package:flutter_animate/flutter_animate.dart';


class AdminResultsTab extends StatelessWidget {
  const AdminResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final quizzes = quizProvider.quizzes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results Management', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
      ),
      body: quizzes.isEmpty
          ? const Center(child: Text("No quizzes found"))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: quizzes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildResultsSummary(quizzes);
                
                final quiz = quizzes[index - 1];
                return _buildResultDeclarationCard(context, quiz);
              },
            ),
    );
  }

  Widget _buildResultsSummary(List<Quiz> quizzes) {
    final declared = quizzes.where((q) => q.isResultsDeclared).length;
    final pending = quizzes.length - declared;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Declared", declared.toString(), Icons.check_circle_rounded),
          _buildSummaryItem("Pending", pending.toString(), Icons.pending_actions_rounded),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildResultDeclarationCard(BuildContext context, Quiz quiz) {
    final bool isDeclared = quiz.isResultsDeclared;
    final Color statusColor = isDeclared ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuizResultsDetailScreen(quiz: quiz)),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isDeclared ? Icons.check_circle : Icons.pending_actions,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDeclared ? "Results Declared & Live" : "Pending Declaration",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDeclared)
                ElevatedButton(
                  onPressed: () => _showDeclareDialog(context, quiz),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("DECLARE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  void _showDeclareDialog(BuildContext context, Quiz quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Declare Results?"),
        content: Text("Declare results for \"${quiz.title}\"? Once declared, students will see their individual scores. This action cannot be undone."),
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
}
