import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/material_provider.dart';
import '../../models/study_material_model.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import '../../core/app_feedback.dart';
import '../../core/notification_sender.dart';
import '../../widgets/shimmer_loading.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedType = 'link';
  List<Question>? _uploadedQuestions;
  bool _isLoading = false;
  bool _sendNotification = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'link', 'label': 'Link', 'icon': Icons.link},
    {'value': 'pdf', 'label': 'PDF URL', 'icon': Icons.picture_as_pdf},
    {'value': 'video', 'label': 'Video URL', 'icon': Icons.play_circle},
    {'value': 'mcq', 'label': 'MCQ (JSON)', 'icon': Icons.quiz},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
      );

      if (result != null) {
        String content;
        if (kIsWeb) {
          if (result.files.single.bytes == null) throw Exception("Failed to read file bytes");
          content = utf8.decode(result.files.single.bytes!);
        } else {
          if (result.files.single.path == null) throw Exception("Failed to get file path");
          final file = File(result.files.single.path!);
          content = await file.readAsString();
        }
        final List<dynamic> jsonData = jsonDecode(content);
        
        setState(() {
          _uploadedQuestions = jsonData.map((q) => Question.fromJson(q)).toList();
        });
        
        AppFeedback.showSuccess("Successfully loaded ${_uploadedQuestions!.length} questions");
      }
    } catch (e) {
      AppFeedback.showError("Failed to parse JSON: $e");
    }
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedType == 'mcq' && (_uploadedQuestions == null || _uploadedQuestions!.isEmpty)) {
      AppFeedback.showError("Please upload a JSON file with questions");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final material = StudyMaterial(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        url: _selectedType == 'mcq' ? null : _urlController.text.trim(),
        questions: _selectedType == 'mcq' ? _uploadedQuestions : null,
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<MaterialProvider>().addMaterial(material);
      
      if (_sendNotification && !kIsWeb) {
        try {
          await NotificationSender.sendNotification(
            title: "New Study Material! 📚",
            body: "New ${material.type.toUpperCase()}: ${material.title}",
          );
        } catch (e) {
          debugPrint("Notification failed: $e");
          // Don't fail the whole process if notification fails
        }
      }

      if (mounted) {
        AppFeedback.showSuccess("Material added successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      AppFeedback.showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Material', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
            tooltip: 'Format Guide',
          ),
        ],
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerWidget.circular(width: 60, height: 60),
                const SizedBox(height: 16),
                ShimmerWidget.rectangular(height: 16, width: 120),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: AppSpacing.l),
                  _buildTextField(_titleController, 'Title', 'Enter title', Icons.title),
                  const SizedBox(height: AppSpacing.m),
                  _buildTextField(_descriptionController, 'Description', 'Enter description', Icons.description, maxLines: 3),
                  const SizedBox(height: AppSpacing.m),
                  _buildTextField(_categoryController, 'Category (Optional)', 'e.g., Mathematics', Icons.category),
                  const SizedBox(height: AppSpacing.l),
                  
                  if (_selectedType != 'mcq')
                     _buildTextField(_urlController, 'URL', 'Enter source URL', Icons.link, validator: (v) {
                       if (v == null || v.isEmpty) return 'URL is required';
                       if (!Uri.parse(v).isAbsolute) return 'Enter a valid URL';
                       return null;
                     })
                  else
                    _buildJsonUploadButton(),

                  const SizedBox(height: AppSpacing.l),
                  _buildNotificationToggle(),

                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: _saveMaterial,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Material', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Upload Guide'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGuideSection(
                  '1. URL Formats (PDF/Video/Link)',
                  'Provide a direct, absolute URL starting with http:// or https://.',
                  'Example: https://example.com/document.pdf',
                  Icons.link,
                ),
                const Divider(),
                _buildGuideSection(
                  '2. MCQ format (JSON)',
                  'Upload a .json file with an array of question objects.',
                  'Format Example:\n[\n  {\n    "text": "Question Text",\n    "choices": ["A", "B", "C", "D"],\n    "correctChoiceIndex": 0,\n    "explanation": "Optional explanation"\n  }\n]',
                  Icons.code,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Note: Ensure the correctChoiceIndex is 0-based (0 for the first option).',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String description, String example, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
            ),
            child: Text(
              example,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        title: const Text('Send Notification', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(kIsWeb 
          ? 'Alert all students (Notifications will be sent from mobile)' 
          : 'Alert all students about this new material'),
        value: _sendNotification,
        onChanged: (val) => setState(() => _sendNotification = val),
        secondary: Icon(Icons.notifications_active_outlined, color: _sendNotification ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Material Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppSpacing.m),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _types.map((type) {
            final isSelected = _selectedType == type['value'];
            return ChoiceChip(
              label: Text(type['label']),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedType = type['value']);
              },
              avatar: Icon(type['icon'], size: 16, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return '$label is required';
        return null;
      },
    );
  }

  Widget _buildJsonUploadButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.file_upload_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            _uploadedQuestions == null 
              ? 'Upload MCQ JSON File' 
              : '${_uploadedQuestions!.length} Questions Loaded',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Format: [{"text": "...", "choices": ["..."], "correctChoiceIndex": 0}]',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickJsonFile,
            icon: const Icon(Icons.upload_file),
            label: Text(_uploadedQuestions == null ? 'Select File' : 'Change File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
