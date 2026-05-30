import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';

class QuizReviewScreen extends StatelessWidget {
  final String quizTitle;
  final List<Question> questions;
  final Map<String, int> userAnswers;

  const QuizReviewScreen({
    super.key, 
    required this.quizTitle, 
    required this.questions,
    this.userAnswers = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review: $quizTitle"),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: questions.length,
        itemBuilder: (context, index) => _buildReviewCard(context, questions[index], index),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Question q, int index) {
    final userAnswer = userAnswers[q.id];
    final isSkipped = userAnswer == null;
    final isCorrect = userAnswer == q.correctChoiceIndex;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionHeader(index, isCorrect, isSkipped),
            const SizedBox(height: 12),
            Text(q.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(q.choices.length, (i) => _buildChoiceTile(context, q, i, userAnswer)),
            if (q.explanation != null && q.explanation!.isNotEmpty) _buildExplanation(context, q.explanation!),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(int index, bool isCorrect, bool isSkipped) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isSkipped) {
      statusColor = Colors.orange;
      statusText = "Skipped";
      statusIcon = Icons.warning_amber_rounded;
    } else if (isCorrect) {
      statusColor = AppColors.success;
      statusText = "Correct";
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppColors.error;
      statusText = "Wrong";
      statusIcon = Icons.cancel;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text("${index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(width: 12),
            const Text("Question", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceTile(BuildContext context, Question q, int i, int? userAnswer) {
    final isCorrect = i == q.correctChoiceIndex;
    final isSelected = i == userAnswer;
    
    // Determine colors based on state
    Color linkColor = Colors.grey;
    Color bgColor = Colors.transparent;
    IconData icon = Icons.circle_outlined;
    
    if (isCorrect) {
      // Always highlight correct answer in green
      linkColor = AppColors.success;
      bgColor = AppColors.success.withOpacity(0.1);
      icon = Icons.check_circle;
    } else if (isSelected) {
      // Highlight wrong selection in red
      linkColor = AppColors.error;
      bgColor = AppColors.error.withOpacity(0.1);
      icon = Icons.cancel;
    } else {
      bgColor = Colors.grey.withOpacity(0.05);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCorrect || isSelected ? linkColor.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: linkColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              q.choices[i],
              style: TextStyle(
                color: isCorrect || isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), 
                fontWeight: isCorrect || isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
          if (isSelected && !isCorrect)
             const Text("Your Answer", style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
          if (isCorrect && !isSelected && userAnswer != null)
             const Text("Correct Answer", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExplanation(BuildContext context, String explanation) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text("Explanation", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Text(explanation, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), height: 1.4)),
          ],
        ),
      ),
    );
  }
}
