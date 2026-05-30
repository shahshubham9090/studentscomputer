import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../core/avatar_utils.dart';
import '../../models/user_model.dart';
import 'user_detail_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Leaderboard"),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No students yet.",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = UserModel.fromJson(docs[index].data() as Map<String, dynamic>);
              final isTop3 = index < 3;
              Color? rankColor;
              if (index == 0) rankColor = Colors.amber;
              else if (index == 1) rankColor = Colors.grey[400];
              else if (index == 2) rankColor = Colors.brown[300];

              return Card(
                elevation: isTop3 ? 4 : 1,
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isTop3 ? BorderSide(color: rankColor!, width: 2) : BorderSide.none
                ),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailScreen(user: user))),
                  leading: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(user)),
                      ),
                      if (isTop3)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                          child: Icon(Icons.emoji_events, color: rankColor, size: 14),
                        ),
                    ],
                  ),
                  title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${user.points}",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: isTop3 ? rankColor : AppColors.primary
                        )
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.stars, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
