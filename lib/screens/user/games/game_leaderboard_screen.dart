import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentscomputer/core/constants.dart';
import 'package:studentscomputer/models/user_model.dart';
import 'package:studentscomputer/providers/game_provider.dart';
import 'package:studentscomputer/providers/auth_provider.dart';

class GameLeaderboardScreen extends StatefulWidget {
  const GameLeaderboardScreen({super.key});

  @override
  State<GameLeaderboardScreen> createState() => _GameLeaderboardScreenState();
}

class _GameLeaderboardScreenState extends State<GameLeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'id': '2048', 'label': '2048', 'icon': Icons.grid_on},
    {'id': 'memory_match', 'label': 'Memory', 'icon': Icons.memory},
    {'id': 'math_speed', 'label': 'Math', 'icon': Icons.timer},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((tab) => Tab(
            icon: Icon(tab['icon']),
            text: tab['label'],
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _GameLeaderboardList(gameId: tab['id'])).toList(),
      ),
    );
  }
}

class _GameLeaderboardList extends StatelessWidget {
  final String gameId;

  const _GameLeaderboardList({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    return StreamBuilder<List<UserModel>>(
      stream: gameProvider.getLeaderboard(gameId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading leaderboard"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  "No scores yet!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Play to claim the #1 spot!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.m),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final rank = index + 1;
            final isMe = user.id == currentUserId;
            final score = user.gameScores[gameId] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isMe 
                    ? Border.all(color: AppColors.primary.withOpacity(0.3)) 
                    : Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: _buildRankBadge(rank),
                title: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                    color: isMe ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    switch (rank) {
      case 1: color = const Color(0xFFFFD700); break;
      case 2: color = const Color(0xFFC0C0C0); break;
      case 3: color = const Color(0xFFCD7F32); break;
      default: color = Colors.grey.shade200;
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: rank <= 3 ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }
}
