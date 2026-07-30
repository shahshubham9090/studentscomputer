import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import '../../core/notification_sender.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/app_feedback.dart';
import '../../widgets/gradient_button.dart';
import '../../core/quiz_bulk_upload_service.dart';
import 'question_editor_screen.dart';
import '../../providers/auth_provider.dart';

class CreateQuizScreen extends StatefulWidget {
  final Quiz? quizToEdit;
  final String? assignedGroupId;
  const CreateQuizScreen({super.key, this.quizToEdit, this.assignedGroupId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<Question> _questions = [];
  bool _notifyUsers = false;
  bool _isLoading = false;
  bool get _isEditing => widget.quizToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.quizToEdit!.title;
      _descController.text = widget.quizToEdit!.description;
      _questions.addAll(widget.quizToEdit!.questions);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addQuestion() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionEditorScreen()));
    if (result != null && result is Question) {
      setState(() => _questions.add(result));
    }
  }

  void _editQuestion(int index) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => QuestionEditorScreen(questionToEdit: _questions[index])));
    if (result != null && result is Question) {
      setState(() => _questions[index] = result);
    }
  }

  Future<void> _bulkUpload() async {
    try {
      final newQuestions = await QuizBulkUploadService.pickAndParseQuestions();
      if (newQuestions.isNotEmpty) {
        setState(() => _questions.addAll(newQuestions));
        if (mounted) {
          AppFeedback.showSuccess('Bulk upload successful! Added ${newQuestions.length} questions.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(e);
      }
    }
  }

  void _showBulkUploadInstructions() {
    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 3,
        child: AlertDialog(
          title: const Text('Bulk Upload Guide'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  tabs: const [Tab(text: 'JSON'), Tab(text: 'CSV'), Tab(text: 'Excel')],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  indicatorColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    children: [
                      _buildInstruction('JSON', '[\n  {\n    "text": "What is 2+2?",\n    "choices": ["3", "4", "5", "6"],\n    "correctChoiceIndex": 1,\n    "explanation": "2+2 equals 4.",\n    "timeSeconds": 30\n  }\n]'),
                      _buildInstruction('CSV', '1. Question Text\n2-5. Options (A, B, C, D)\n6. Correct Index (0-3)\n7. Time in Seconds\n8. Explanation\n\nEx: What is 2+2?,3,4,5,6,1,30,2+2 equals 4.'),
                      _buildInstruction('Excel', 'A: Question\nB-E: Options\nF: Index (0-3)\nG: Seconds\nH: Explanation'),
                    ],
                  ),
                ),
                const Divider(),
                const Text('• Index starts from 0 (0=A, 1=B, etc.)', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      ),
    );
  }

  Widget _buildInstruction(String type, String code) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$type Format:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        AppFeedback.showError('Please add at least one question');
        return;
      }

      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      final quizData = Quiz(
        id: _isEditing ? widget.quizToEdit!.id : const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        publishDate: _isEditing ? widget.quizToEdit!.publishDate : DateTime.now(),
        questions: _questions,
        isPublished: _isEditing ? widget.quizToEdit!.isPublished : true,
        groupId: _isEditing ? widget.quizToEdit!.groupId : widget.assignedGroupId,
        creatorId: _isEditing ? widget.quizToEdit!.creatorId : authProvider.currentUser?.id,
      );

      try {
        if (_isEditing) {
          await context.read<QuizProvider>().updateQuiz(quizData);
        } else {
          await context.read<QuizProvider>().addQuiz(quizData);
        }
        
        if (_notifyUsers) {
           await NotificationSender.sendNotification(
             title: _isEditing ? "Updated Quiz: ${quizData.title}" : "New Quiz: ${quizData.title}",
             body: quizData.description,
           );
        }

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          AppFeedback.showSuccess(_isEditing ? 'Quiz Updated Successfully! 📝' : 'Quiz Published Successfully! 🎉');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppFeedback.showError(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Quiz' : 'Create New Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuizDetailsCard(),
              const SizedBox(height: AppSpacing.l),
              _buildQuestionsHeader(),
              const SizedBox(height: AppSpacing.m),
              _buildQuestionList(),
              const SizedBox(height: AppSpacing.m),
              _buildActionButtons(),
              const SizedBox(height: AppSpacing.xl),
               GradientButton(
                text: _isEditing ? 'Update Quiz' : 'Publish Quiz',
                onPressed: _saveQuiz,
                isLoading: _isLoading,
                icon: _isEditing ? Icons.save : Icons.check_circle,
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizDetailsCard() {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.m),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        CustomTextField(label: 'Quiz Title', controller: _titleController, validator: (v) => v!.isEmpty ? 'Required' : null, prefixIcon: Icons.title),
                        const SizedBox(height: AppSpacing.m),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Notify users immediately?"),
                          subtitle: const Text("Send a push notification to all users"),
                          value: _notifyUsers,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _notifyUsers = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      label: 'Description', 
                      controller: _descController, 
                      maxLines: 5, 
                      validator: (v) => v!.isEmpty ? 'Required' : null, 
                      prefixIcon: Icons.description
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  CustomTextField(label: 'Quiz Title', controller: _titleController, validator: (v) => v!.isEmpty ? 'Required' : null, prefixIcon: Icons.title),
                  const SizedBox(height: AppSpacing.m),
                  CustomTextField(label: 'Description', controller: _descController, maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null, prefixIcon: Icons.description),
                  const SizedBox(height: AppSpacing.m),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Notify users immediately?"),
                    subtitle: const Text("Send a push notification to all users"),
                    value: _notifyUsers,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _notifyUsers = v),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Questions (${_questions.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.info_outline, color: AppColors.primary), tooltip: 'View Bulk Upload Template', onPressed: _showBulkUploadInstructions),
      ],
    );
  }

  Widget _buildQuestionList() {
    if (_questions.isEmpty) {
      return Container(
         padding: const EdgeInsets.all(32),
         alignment: Alignment.center,
         decoration: BoxDecoration(
           border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
           borderRadius: BorderRadius.circular(16),
           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
         ),
         child: Column(
           children: [
             Icon(Icons.quiz_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
             const SizedBox(height: 8),
             Text("No questions yet", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
           ],
         ),
      );
    }
    return Column(
      children: _questions.asMap().entries.map((entry) => _buildQuestionTile(entry.key, entry.value)).toList(),
    );
  }

  Widget _buildQuestionTile(int index, Question question) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _editQuestion(index),
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
        title: Text(question.text, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${question.choices.length} choices • Correct: ${question.choices[question.correctChoiceIndex]}",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => setState(() => _questions.removeAt(index))),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton("Add Single", Icons.add_circle_outline, AppColors.primary, _addQuestion),
        const SizedBox(width: AppSpacing.m),
        _buildActionButton("Bulk Upload", Icons.upload_file, Colors.blue, _bulkUpload),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(icon, color: color, size: 20),
               const SizedBox(width: 8),
               Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
             ],
           ),
        ),
      ),
    );
  }
}
