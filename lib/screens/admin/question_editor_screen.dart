import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class QuestionEditorScreen extends StatefulWidget {
  final Question? questionToEdit;
  const QuestionEditorScreen({super.key, this.questionToEdit});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _textController = TextEditingController();
  final List<TextEditingController> _choiceControllers = List.generate(4, (_) => TextEditingController());
  final _timeController = TextEditingController(text: '30'); 
  final _explanationController = TextEditingController();
  int _correctIndex = 0;
  bool get _isEditing => widget.questionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _textController.text = widget.questionToEdit!.text;
      _timeController.text = widget.questionToEdit!.timeSeconds.toString();
      _correctIndex = widget.questionToEdit!.correctChoiceIndex;
      for (int i = 0; i < 4; i++) {
        _choiceControllers[i].text = widget.questionToEdit!.choices[i];
      }
      _explanationController.text = widget.questionToEdit!.explanation ?? '';
    }
  }

  void _save() {
    // Validate question text
    if (_textController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Question text cannot be empty'))
       );
       return;
    }

    // Validate all choices are filled
    if (_choiceControllers.any((c) => c.text.trim().isEmpty)) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('All choices must be filled'))
       );
       return;
    }

    // Validate time is positive
    final timeValue = int.tryParse(_timeController.text) ?? 0;
    if (timeValue <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Time must be greater than 0 seconds'))
       );
       return;
    }

    // Validate reasonable time limit (max 5 minutes)
    if (timeValue > 300) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Time cannot exceed 300 seconds'))
       );
       return;
    }

    // Check for duplicate choices
    final choiceTexts = _choiceControllers.map((c) => c.text.trim().toLowerCase()).toList();
    if (choiceTexts.toSet().length != choiceTexts.length) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('All choices must be unique'))
       );
       return;
    }

    final question = Question(
      id: _isEditing ? widget.questionToEdit!.id : const Uuid().v4(),
      text: _textController.text.trim(),
      choices: _choiceControllers.map((c) => c.text.trim()).toList(),
      correctChoiceIndex: _correctIndex,
      explanation: _explanationController.text.trim().isEmpty ? null : _explanationController.text.trim(),
      timeSeconds: timeValue,
      imageUrl: _isEditing ? widget.questionToEdit!.imageUrl : null,
    );
    
    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Question' : 'Add Question')),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(AppSpacing.l),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             _buildQuestionDetailsCard(),
             const SizedBox(height: AppSpacing.l),
             _buildChoicesHeader(context),
             const SizedBox(height: AppSpacing.m),
             ...List.generate(4, (index) => _buildChoiceTile(index)),
             const SizedBox(height: AppSpacing.l),
             GradientButton(text: 'Save Question', onPressed: _save, icon: Icons.save),
           ],
         ),
      ),
    );
  }

  Widget _buildQuestionDetailsCard() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            CustomTextField(
              label: 'Question Text',
              controller: _textController,
              maxLines: 3,
              prefixIcon: Icons.help_outline,
            ),
            const SizedBox(height: AppSpacing.m),
            CustomTextField(
              label: 'Time Limit (seconds)',
              controller: _timeController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.timer,
            ),
            const SizedBox(height: AppSpacing.m),
            CustomTextField(
              label: 'Explanation (Optional)',
              controller: _explanationController,
              maxLines: 2,
              prefixIcon: Icons.info_outline,
              hintText: 'Why is this the correct answer?',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Answer Choices', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text('Select the radio button for the correct answer', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildChoiceTile(int index) {
    final isSelected = _correctIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.success.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
        border: Border.all(color: isSelected ? AppColors.success : Theme.of(context).colorScheme.onSurface.withOpacity(0.15), width: isSelected ? 1.5 : 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isSelected) BoxShadow(color: AppColors.success.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
          else BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: RadioListTile<int>(
        value: index,
        groupValue: _correctIndex,
        activeColor: AppColors.success,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onChanged: (v) => setState(() => _correctIndex = v!),
        title: TextField(
          controller: _choiceControllers[index],
          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? AppColors.success : Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Option ${index + 1}',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            border: InputBorder.none,
            prefixIcon: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 20, color: isSelected ? AppColors.success : Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}
