import 'package:flutter/material.dart';
import 'package:studentscomputer/core/constants.dart';
import 'tic_tac_toe_screen.dart';
import 'memory_match_screen.dart';
import 'game_2048_screen.dart';
import 'math_speed_run_screen.dart';
import '../study_swiper_screen.dart';
import 'game_leaderboard_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameLeaderboardScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.xl),
            
            // Study Swiper
            _buildGameCard(
              context,
              title: 'Study Swiper',
              description: 'Swipe cards to master new tech concepts!',
              icon: Icons.swipe_rounded,
              gradient: AppGradients.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudySwiperScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.l),
            
            // Tic Tac Toe
            _buildGameCard(
              context,
              title: 'Tic Tac Toe',
              description: 'Classic X and O game. Play against a friend!',
              icon: Icons.grid_3x3,
              gradient: AppGradients.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicTacToeScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.l),
            
            // Tech Memory Match
            _buildGameCard(
              context,
              title: 'Tech Memory Match',
              description: 'Match computer parts and improve your memory!',
              icon: Icons.memory,
              gradient: AppGradients.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryMatchScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.l),
            
            // 2048
            _buildGameCard(
              context,
              title: '2048 Puzzle',
              description: 'Swipe to merge numbers and reach 2048!',
              icon: Icons.grid_on,
              gradient: AppGradients.fire, // Assuming fire gradient exists or similar
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Game2048Screen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.l),
            
            // Math Speed Run
            _buildGameCard(
              context,
              title: 'Math Speed Run',
              description: 'Solve equations fast before time runs out!',
              icon: Icons.timer,
              gradient: AppGradients.success,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MathSpeedRunScreen()),
                );
              },
            ),
             const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.sports_esports, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fun & Games',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a break and play!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(icon, color: Colors.white, size: 48),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Available',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildComingSoonCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'More Games Coming Soon!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working on adding more exciting games for you to enjoy!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
