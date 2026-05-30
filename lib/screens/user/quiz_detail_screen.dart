import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_model.dart';
import '../../models/quiz_attempt_model.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../widgets/gradient_button.dart';
import 'quiz_taking_screen.dart';
import 'quiz_review_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizDetailScreen({super.key, required this.quiz});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _isLoading = true;
  QuizAttempt? _previousAttempt;

  @override
  void initState() {
    super.initState();
    _checkAttemptStatus();
  }

  Future<void> _checkAttemptStatus() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final attempt = await context.read<QuizProvider>().getUserQuizAttempt(widget.quiz.id, userId);
    if (mounted) {
      setState(() {
        _previousAttempt = attempt;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(gradient: AppGradients.primary),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                  ],
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryBadge(),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          widget.quiz.title,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        _buildStatsRow(context),
                        const SizedBox(height: AppSpacing.xl),
                        Text("Description", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          widget.quiz.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          _buildStartButton(context),
                        const SizedBox(height: AppSpacing.m),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondaryDark.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category, color: AppColors.secondary, size: 16),
          SizedBox(width: 6),
          Text("General Knowledge", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
         _buildDetailBadge(Icons.help, "${widget.quiz.questions.length} Questions"),
         const SizedBox(width: 12),
         _buildDetailBadge(Icons.timer, "${widget.quiz.questions.length * 30} sec"),
         const SizedBox(width: 12),
         _buildDetailBadge(Icons.star, "100 Points"),
      ],
    );
  }

  Widget _buildDetailBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    final hasAttempted = _previousAttempt != null;

    if (hasAttempted) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 32),
                const SizedBox(height: 8),
                const Text(
                  "You have already completed this quiz!",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                ),
                Text(
                  "Score: ${_previousAttempt!.score}/${_previousAttempt!.totalQuestions}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: "Review Attempt",
              icon: Icons.history_edu,
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => QuizReviewScreen(
                    quizTitle: widget.quiz.title,
                    questions: widget.quiz.questions,
                    userAnswers: _previousAttempt!.userAnswers,
                  )),
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: "Start Quiz Now",
            icon: Icons.play_arrow,
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => QuizTakingScreen(quiz: widget.quiz)),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              "You can review answers after completion",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
