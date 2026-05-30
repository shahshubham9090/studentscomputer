import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/doubt_provider.dart';
import '../../core/constants.dart';
import 'doubt_detail_screen.dart';

class AdminDoubtsScreen extends StatefulWidget {
  const AdminDoubtsScreen({super.key});

  @override
  State<AdminDoubtsScreen> createState() => _AdminDoubtsScreenState();
}

class _AdminDoubtsScreenState extends State<AdminDoubtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<DoubtProvider>().listenToAllDoubts());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDoubts = context.watch<DoubtProvider>().allDoubts;
    final pendingDoubts = allDoubts.where((d) => !d.isResolved).toList();
    final resolvedDoubts = allDoubts.where((d) => d.isResolved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Doubts"),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: "Pending (${pendingDoubts.length})"),
            Tab(text: "Resolved (${resolvedDoubts.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoubtList(pendingDoubts),
          _buildDoubtList(resolvedDoubts),
        ],
      ),
    );
  }

  Widget _buildDoubtList(List doubts) {
    if (doubts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              "No doubts here",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: doubts.length,
      itemBuilder: (context, index) {
        final doubt = doubts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DoubtDetailScreen(doubt: doubt)),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doubt.userName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d').format(doubt.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doubt.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doubt.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  if (doubt.isResolved) ...[
                     const SizedBox(height: 12),
                     Row(
                       children: [
                         const Icon(Icons.check_circle, size: 14, color: Colors.green),
                         const SizedBox(width: 4),
                         Text("Resolved", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                       ],
                     )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
