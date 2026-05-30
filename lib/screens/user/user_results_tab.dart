import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/quiz_attempt_model.dart';
import '../../core/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/shimmer_loading.dart';

class UserResultsTab extends StatelessWidget {
  const UserResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final user = authProvider.currentUser;

    if (user == null) return const Center(child: Text("Please login to see results"));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Results', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: StreamBuilder<List<QuizAttempt>>(
          stream: quizProvider.getUserResults(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  Container(
                    height: 240,
                    margin: const EdgeInsets.all(AppSpacing.l),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const ShimmerWidget.rectangular(height: double.infinity),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      itemCount: 3,
                      itemBuilder: (context, index) => const ResultCardSkeleton(),
                    ),
                  ),
                ],
              );
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text("No quiz results yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            final allAttempts = snapshot.data!;
            
            // Wait for quizzes to load to avoid showing empty states prematurely
            if (quizProvider.isLoadingQuizzes && quizProvider.quizzes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ShimmerWidget.circular(width: 50, height: 50),
                    const SizedBox(height: 16),
                    ShimmerWidget.rectangular(height: 14, width: 150),
                    const SizedBox(height: 8),
                    ShimmerWidget.rectangular(height: 14, width: 100),
                  ],
                ),
              );
            }

            final declaredAttempts = <QuizAttempt>[];
            final pendingAttempts = <QuizAttempt>[];
            bool hasMissingQuizData = false;

            for (var attempt in allAttempts) {
              final quiz = quizProvider.quizzes.where((q) => q.id == attempt.quizId).firstOrNull;
              if (quiz == null) {
                hasMissingQuizData = true;
                continue; 
              }
              
              if (quiz.isResultsDeclared) {
                declaredAttempts.add(attempt);
              } else {
                pendingAttempts.add(attempt);
              }
            }

            if (declaredAttempts.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(
                       pendingAttempts.isNotEmpty || hasMissingQuizData 
                           ? Icons.hourglass_empty_rounded 
                           : Icons.assignment_turned_in_outlined, 
                       size: 64, 
                       color: Colors.grey.shade300
                     ),
                     const SizedBox(height: 16),
                     Text(
                       pendingAttempts.isNotEmpty 
                           ? "Results for ${pendingAttempts.length} quizzes pending declaration." 
                           : hasMissingQuizData && quizProvider.isLoadingQuizzes
                             ? "Syncing latest quiz data..."
                             : "No results declared yet.", 
                       style: const TextStyle(color: Colors.grey, fontSize: 16),
                       textAlign: TextAlign.center,
                     ),
                     if (pendingAttempts.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text("Results will appear once declared by admin.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                   ],
                 ),
               );
            }

            // Sort by timestamp for the chart
            declaredAttempts.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            return Column(
              children: [
                _buildPerformanceChart(context, declaredAttempts),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    itemCount: declaredAttempts.length,
                    itemBuilder: (context, index) {
                      final attempt = declaredAttempts[index];
                      final dateStr = DateFormat('MMM dd, yyyy').format(attempt.timestamp);
                      final scorePercent = attempt.totalQuestions > 0 
                          ? (attempt.score / attempt.totalQuestions) * 100
                          : 0.0;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.m),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: _getScoreColor(scorePercent).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "${attempt.score}/${attempt.totalQuestions}",
                                  style: TextStyle(
                                    color: _getScoreColor(scorePercent),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attempt.quizTitle,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Completed on $dateStr",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getScoreColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPerformanceChart(BuildContext context, List<QuizAttempt> attempts) {
    final spots = attempts.asMap().entries.map((e) {
      final percent = e.value.totalQuestions > 0 
          ? (e.value.score / e.value.totalQuestions) * 100
          : 0.0;
      return FlSpot(e.key.toDouble(), percent);
    }).toList();

    return Container(
      height: 240,
      margin: const EdgeInsets.all(AppSpacing.l),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performance Trend",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            "Accuracy over last ${attempts.length} quizzes",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (attempts.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
