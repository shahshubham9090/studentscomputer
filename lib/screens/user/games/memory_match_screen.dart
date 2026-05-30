import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studentscomputer/core/constants.dart';
import 'package:provider/provider.dart';
import 'package:studentscomputer/providers/game_provider.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  // Game State
  List<String> _cards = [];
  List<bool> _isFlipped = [];
  List<bool> _isMatched = [];
  int? _flippedIndex;
  bool _isProcessing = false;
  int _moves = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isGameOver = false;

  // Tech Icons/Items to match
  final List<IconData> _icons = [
    Icons.computer,
    Icons.wifi,
    Icons.memory,
    Icons.mouse,
    Icons.keyboard,
    Icons.headphones,
    Icons.storage,
    Icons.router,
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Override back button to ensure cleanup
  Future<bool> _onWillPop() async {
    _timer?.cancel();
    return true;
  }

  void _startNewGame() {
    setState(() {
      // Duplicate icons to make pairs
      List<int> cardIndices = List.generate(_icons.length, (index) => index);
      List<int> deck = [...cardIndices, ...cardIndices];
      deck.shuffle(Random());
      
      // Map randomly shuffled indices back to icon identifiers (using string for simplicity)
      _cards = deck.map((index) => index.toString()).toList();
      _isFlipped = List.filled(_cards.length, false);
      _isMatched = List.filled(_cards.length, false);
      _flippedIndex = null;
      _isProcessing = false;
      _moves = 0;
      _secondsElapsed = 0;
      _isGameOver = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameOver) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _isFlipped[index] || _isMatched[index] || _isGameOver) return;

    setState(() {
      _isFlipped[index] = true;
    });

    if (_flippedIndex == null) {
      // First card flipped
      _flippedIndex = index;
    } else {
      // Second card flipped
      _moves++;
      _isProcessing = true;

      if (_cards[index] == _cards[_flippedIndex!]) {
        // Match found
        _isMatched[index] = true;
        _isMatched[_flippedIndex!] = true;
        _flippedIndex = null;
        _isProcessing = false;

        if (_isMatched.every((matched) => matched)) {
          _gameOver();
        }
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _isFlipped[index] = false;
              _isFlipped[_flippedIndex!] = false;
              _flippedIndex = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _gameOver() {
    _timer?.cancel();
    setState(() {
      _isGameOver = true;
    });

    // Score Calculation: 
    // Base 1000 - (Moves * 10) - (Time * 2)
    // Minimum score 100
    int calculatedScore = 1000 - (_moves * 10) - (_secondsElapsed * 2);
    if (calculatedScore < 100) calculatedScore = 100;

    Provider.of<GameProvider>(context, listen: false).saveScore('memory_match', calculatedScore);

    _showWinDialog(calculatedScore);
  }

  void _showWinDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You matched all pairs!'),
            const SizedBox(height: 8),
            Text('Score: $score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            Text('Time: ${_formatTime(_secondsElapsed)}'),
            Text('Moves: $_moves'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to menu
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Tech Memory Match'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Moves', '$_moves', Icons.touch_app),
                _buildStat('Time', _formatTime(_secondsElapsed), Icons.timer),
              ],
            ),
          ),
          
          // Game Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: GridView.builder(
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _isFlipped[index] || _isMatched[index]
                            ? Theme.of(context).colorScheme.surface
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: _isMatched[index] 
                            ? Border.all(color: AppColors.success, width: 2) 
                            : null,
                      ),
                      child: _isFlipped[index] || _isMatched[index]
                          ? Center(
                              child: Icon(
                                _icons[int.parse(_cards[index])],
                                size: 32,
                                color: _isMatched[index] 
                                    ? AppColors.success 
                                    : AppColors.primary,
                              ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
                            )
                          : Center(
                              child: Icon(
                                Icons.question_mark_rounded,
                                color: Colors.white.withOpacity(0.5),
                                size: 24,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
