import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/doubt_provider.dart';
import '../../models/doubt_model.dart';
import '../../core/constants.dart';
import '../../core/app_feedback.dart';

class DoubtDetailScreen extends StatefulWidget {
  final Doubt doubt;
  const DoubtDetailScreen({super.key, required this.doubt});

  @override
  State<DoubtDetailScreen> createState() => _DoubtDetailScreenState();
}

class _DoubtDetailScreenState extends State<DoubtDetailScreen> {
  final _replyController = TextEditingController();
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    if (widget.doubt.adminReply != null) {
      _replyController.text = widget.doubt.adminReply!;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isReplying = true);
    try {
      await context.read<DoubtProvider>().replyToDoubt(widget.doubt.id, _replyController.text.trim());
      if (mounted) {
        AppFeedback.showSuccess("Reply sent successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(e);
    } finally {
      if (mounted) setState(() => _isReplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doubt Details"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Question Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(widget.doubt.userName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doubt.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            DateFormat('MMM d, y • h:mm a').format(widget.doubt.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(widget.doubt.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    widget.doubt.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text("Your Reply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // Admin Reply Field
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15)),
              ),
              child: TextField(
                controller: _replyController,
                maxLines: 6,
                readOnly: widget.doubt.isResolved,
                decoration: const InputDecoration(
                  hintText: "Write a helpful solution...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!widget.doubt.isResolved)
              ElevatedButton.icon(
                onPressed: _isReplying ? null : _submitReply,
                icon: _isReplying 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.send_rounded),
                label: Text(_isReplying ? "SENDING..." : "SEND REPLY"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("This doubt has been resolved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
