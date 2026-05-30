import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/doubt_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/doubt_model.dart';
import '../../core/constants.dart';
import '../../core/app_feedback.dart';

class CreateDoubtScreen extends StatefulWidget {
  const CreateDoubtScreen({super.key});

  @override
  State<CreateDoubtScreen> createState() => _CreateDoubtScreenState();
}

class _CreateDoubtScreenState extends State<CreateDoubtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    try {
      final doubt = Doubt(
        id: const Uuid().v4(),
        userId: user.id,
        userName: user.displayName,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<DoubtProvider>().createDoubt(doubt);
      if (mounted) {
        AppFeedback.showSuccess("Doubt posted successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<DoubtProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask a Doubt"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "What confuses you?",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                validator: (v) => v!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Describe your doubt in detail...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? "Please enter a description" : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("POST DOUBT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
