import 'package:flutter/material.dart';
import '../../core/notification_sender.dart';
import '../../core/constants.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await NotificationSender.sendNotification(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Notification Sent Successfully!'),
              ],
            ),
            backgroundColor: AppColors.correct,
          ),
        );
        _titleController.clear();
        _bodyController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to send notification')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.campaign,
                      size: 64,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Broadcast Message",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Send a push notification to all users",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Form Card
              Card(
                elevation: 2,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      CustomTextField(
                        label: "Notification Title",
                        controller: _titleController,
                        validator: (v) => v!.isEmpty ? "Enter a title" : null,
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      CustomTextField(
                        label: "Message Body",
                        controller: _bodyController,
                        validator: (v) => v!.isEmpty ? "Enter a message" : null,
                        maxLines: 4,
                        prefixIcon: Icons.message,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Send Button
              GradientButton(
                text: "Send to All Users",
                onPressed: _send,
                isLoading: _isLoading,
                icon: Icons.send,
              ),

              const SizedBox(height: AppSpacing.m),

              // Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This will send a notification to all app users instantly.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
