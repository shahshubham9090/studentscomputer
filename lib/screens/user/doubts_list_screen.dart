import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/doubt_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import 'create_doubt_screen.dart';

class DoubtsListScreen extends StatefulWidget {
  const DoubtsListScreen({super.key});

  @override
  State<DoubtsListScreen> createState() => _DoubtsListScreenState();
}

class _DoubtsListScreenState extends State<DoubtsListScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<DoubtProvider>().listenToUserDoubts(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doubts = context.watch<DoubtProvider>().userDoubts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Doubts"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDoubtScreen())),
        label: const Text("Ask Doubt"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final user = context.read<AuthProvider>().currentUser;
          if (user != null) {
            context.read<DoubtProvider>().listenToUserDoubts(user.id);
          }
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: doubts.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.help_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text("No doubts ask yet", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: doubts.length,
                itemBuilder: (context, index) {
                  final doubt = doubts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: doubt.isResolved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          doubt.isResolved ? Icons.check : Icons.question_mark,
                          color: doubt.isResolved ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: Text(doubt.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, y • h:mm a').format(doubt.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Question:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                              const SizedBox(height: 4),
                              Text(doubt.description),
                              const SizedBox(height: 16),
                              if (doubt.isResolved && doubt.adminReply != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.school, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text("Teacher Reply", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(doubt.adminReply!),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                 Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text("Waiting for teacher response...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
