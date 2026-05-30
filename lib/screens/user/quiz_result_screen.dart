import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../core/constants.dart';
import 'quiz_review_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String quizTitle;
  
  const QuizResultScreen({super.key, required this.score, required this.total, required this.quizTitle});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.score / widget.total;
    String message = "Good Effort!";
    String subMessage = "You're making progress!";
    Color color = AppColors.primary;
    IconData icon = Icons.thumb_up;
    
    if (percentage == 1.0) {
      message = "Perfect Score! 🏆";
      subMessage = "Outstanding! You're a quiz master!";
      color = AppColors.success;
      icon = Icons.emoji_events;
    } else if (percentage >= 0.8) {
      message = "Excellent Work! 🌟";
      subMessage = "You're doing amazing! Keep it up!";
      color = AppColors.success;
      icon = Icons.star;
    } else if (percentage >= 0.6) {
      message = "Well Done! 👍";
      subMessage = "Good job! You're on the right track!";
      color = AppColors.primary;
      icon = Icons.check_circle;
    } else if (percentage >= 0.5) {
      message = "Not Bad! 💪";
      subMessage = "Keep practicing to improve!";
      color = Colors.orange;
      icon = Icons.trending_up;
    } else {
      message = "Keep Practicing! 💪";
      subMessage = "Don't give up! Review and try again!";
      color = AppColors.secondary;
      icon = Icons.refresh;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppGradients.primary)),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildResultCard(context, message, subMessage, color, percentage, icon),
                ),
                const Spacer(),
                _buildActionButtons(context),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, String message, String subMessage, Color color, double percentage, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScoreIcon(color, percentage, icon),
          const SizedBox(height: AppSpacing.l),
          Text(message, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(subMessage, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text("You completed '${widget.quizTitle}'", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          _buildScoreDisplay(color),
          const SizedBox(height: 8),
          Text("Questions Correct", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          _buildPointsBanner(),
        ],
      ),
    );
  }

  Widget _buildScoreIcon(Color color, double percentage, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: 64, color: color),
    );
  }

  Widget _buildScoreDisplay(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("${widget.score}", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color, height: 1)),
        Text("/${widget.total}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade400, height: 1.5)),
      ],
    );
  }

  Widget _buildPointsBanner() {
    final pointsEarned = widget.score * 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            "+$pointsEarned Points Earned!",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Back to Home"),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openReview(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Review Answers"),
            ),
          ),
        ],
      ),
    );
  }

  void _openReview(BuildContext context) {
    final quiz = context.read<QuizProvider>().quizzes.firstWhere(
      (q) => q.title == widget.quizTitle,
      orElse: () => throw StateError('Quiz with title "${widget.quizTitle}" not found'),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizReviewScreen(quizTitle: widget.quizTitle, questions: quiz.questions)));
  }
}
