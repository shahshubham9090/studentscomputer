import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import 'create_quiz_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../core/app_feedback.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';


class ManageQuizzesScreen extends StatefulWidget {
  const ManageQuizzesScreen({super.key});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  String _searchQuery = "";
  String _filterStatus = "All"; // All, Published, Pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final allQuizzes = quizProvider.quizzes;
          
          // Filter logic
          final filteredQuizzes = allQuizzes.where((quiz) {
            final matchesSearch = quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                quiz.description.toLowerCase().contains(_searchQuery.toLowerCase());
            
            bool matchesFilter = true;
            if (_filterStatus == "Published") {
              matchesFilter = quiz.isPublished;
            } else if (_filterStatus == "Pending") {
              matchesFilter = !quiz.isResultsDeclared;
            }
            
            return matchesSearch && matchesFilter;
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              _buildFilters(),
              if (quizProvider.isLoadingQuizzes && allQuizzes.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const QuizCardSkeleton(),
                      childCount: 5,
                    ),
                  ),
                )
              else if (filteredQuizzes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, isSearch: _searchQuery.isNotEmpty || _filterStatus != "All"),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final quiz = filteredQuizzes[index];
                        return _QuizManagementCard(quiz: quiz);
                      },
                      childCount: filteredQuizzes.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 60),
        title: const Text(
          'Manage Quizzes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: Stack(
            children: [
              Positioned(
                top: -20, right: -20,
                child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search quizzes...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _filterChip("All"),
            _filterChip("Published"),
            _filterChip("Pending"),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _filterStatus = label);
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
        elevation: isSelected ? 4 : 0,
        pressElevation: 0,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {bool isSearch = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.assignment_late_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? "No matching quizzes" : "No quizzes found",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch 
                ? "Try adjusting your search or filters" 
                : "Create your first challenge to get started",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          if (!isSearch) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ).animate().fadeIn().scale(duration: 400.ms),
    );
  }
}

class _QuizManagementCard extends StatelessWidget {
  final Quiz quiz;

  const _QuizManagementCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final bool isLive = quiz.isResultsDeclared;
    final Color statusColor = isLive ? Colors.green : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Status
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quiz.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(
                  isLive ? 'LIVE' : 'PENDING',
                  statusColor,
                ),
              ],
            ),
          ),

          // Info Chips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  context,
                  '${quiz.questions.length} Questions',
                  Icons.quiz_outlined,
                  Colors.indigo,
                ),
                _buildInfoChip(
                  context,
                  quiz.isPublished ? 'Visible to Students' : 'Hidden from App',
                  quiz.isPublished ? Icons.visibility : Icons.visibility_off,
                  quiz.isPublished ? Colors.teal : Colors.orange,
                ),
                _buildInfoChip(
                  context,
                  DateFormat('MMM d, y • h:mm a').format(quiz.publishDate),
                  Icons.access_time_rounded,
                  Colors.blueGrey,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),

          // Actions Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              children: [
                if (!quiz.isResultsDeclared)
                  _buildActionButton(
                    context,
                    'Declare',
                    Icons.publish_rounded,
                    Colors.blue,
                    () => _showDeclareDialog(context),
                  ),
                _buildActionButton(
                  context,
                  quiz.isPublished ? 'Hide' : 'Show',
                  quiz.isPublished ? Icons.visibility_off : Icons.visibility,
                  Colors.orange,
                  () => _toggleVisibility(context),
                ),
                _buildActionButton(
                  context,
                  'Edit',
                  Icons.edit_rounded,
                  AppColors.primary,
                  () => _editQuiz(context),
                ),
                _buildActionButton(
                  context,
                  'Del',
                  Icons.delete_outline_rounded,
                  Colors.red,
                  () => _deleteQuiz(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateQuizScreen(quizToEdit: quiz)),
    );
  }

  void _toggleVisibility(BuildContext context) async {
    await context.read<QuizProvider>().togglePublishStatus(quiz.id);
  }

  void _deleteQuiz(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz?'),
        content: Text('Are you sure you want to delete "${quiz.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<QuizProvider>().deleteQuiz(quiz.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quiz deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeclareDialog(BuildContext context) {
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
