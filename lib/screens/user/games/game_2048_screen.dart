import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studentscomputer/core/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:studentscomputer/providers/game_provider.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  static const int gridSize = 4;
  List<List<int>> grid = [];
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      score = 0;
      isGameOver = false;
      _spawnTile();
      _spawnTile();
    });
  }

  void _spawnTile() {
    List<Point<int>> emptySpots = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          emptySpots.add(Point(i, j));
        }
      }
    }

    if (emptySpots.isNotEmpty) {
      Point<int> spot = emptySpots[Random().nextInt(emptySpots.length)];
      grid[spot.x][spot.y] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  // Swipe Logic
  void _onSwipe(DragEndDetails details) {
    if (isGameOver) return;

    double velocityX = details.velocity.pixelsPerSecond.dx;
    double velocityY = details.velocity.pixelsPerSecond.dy;

    // Determine direction
    if (velocityX.abs() > velocityY.abs()) {
      if (velocityX > 0) {
        _moveRight();
      } else {
        _moveLeft();
      }
    } else {
      if (velocityY > 0) {
        _moveDown();
      } else {
        _moveUp();
      }
    }
  }

  void _moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> newRow = _mergeRow(grid[i]);
      if (!_listsEqual(grid[i], newRow)) {
        grid[i] = newRow;
        moved = true;
      }
    }
    if (moved) _afterMove();
  }

  void _moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> newRow = _mergeRow(grid[i].reversed.toList()).reversed.toList();
      if (!_listsEqual(grid[i], newRow)) {
        grid[i] = newRow;
        moved = true;
      }
    }
    if (moved) _afterMove();
  }

  void _moveUp() {
    bool moved = false;
    for (int col = 0; col < gridSize; col++) {
      List<int> column = [];
      for (int row = 0; row < gridSize; row++) column.add(grid[row][col]);
      
      List<int> newCol = _mergeRow(column);
      
      if (!_listsEqual(column, newCol)) {
        for (int row = 0; row < gridSize; row++) grid[row][col] = newCol[row];
        moved = true;
      }
    }
    if (moved) _afterMove();
  }

  void _moveDown() {
    bool moved = false;
    for (int col = 0; col < gridSize; col++) {
      List<int> column = [];
      for (int row = 0; row < gridSize; row++) column.add(grid[row][col]);
      
      List<int> newCol = _mergeRow(column.reversed.toList()).reversed.toList();
      
      if (!_listsEqual(column, newCol)) {
        for (int row = 0; row < gridSize; row++) grid[row][col] = newCol[row];
        moved = true;
      }
    }
    if (moved) _afterMove();
  }

  List<int> _mergeRow(List<int> row) {
    List<int> nonZero = row.where((e) => e != 0).toList();
    List<int> newRow = [];
    
    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i+1]) {
        int mergedVal = nonZero[i] * 2;
        newRow.add(mergedVal);
        score += mergedVal;
        if (score > highScore) highScore = score;
        i += 2;
      } else {
        newRow.add(nonZero[i]);
        i++;
      }
    }
    
    while (newRow.length < gridSize) newRow.add(0);
    return newRow;
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _afterMove() {
     setState(() {
       _spawnTile();
       if (_checkGameOver()) {
         isGameOver = true;
         _showGameOverDialog();
       }
     });
  }

  bool _checkGameOver() {
    // Check if any empty spot
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) return false;
      }
    }

    // Check possible merges
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        int val = grid[i][j];
        if (j < gridSize - 1 && grid[i][j+1] == val) return false;
        if (i < gridSize - 1 && grid[i+1][j] == val) return false;
      }
    }
    
    return true;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Final Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFFeee4da);
      case 4: return const Color(0xFFede0c8);
      case 8: return const Color(0xFFf2b179);
      case 16: return const Color(0xFFf59563);
      case 32: return const Color(0xFFf67c5f);
      case 64: return const Color(0xFFf65e3b);
      case 128: return const Color(0xFFedcf72);
      case 256: return const Color(0xFFedcc61);
      case 512: return const Color(0xFFedc850);
      case 1024: return const Color(0xFFedc53f);
      case 2048: return const Color(0xFFedc22e);
      default: return const Color(0xFF3c3a32);
    }
  }

  Color _getTileTextColor(int value) {
    return value <= 4 ? const Color(0xFF776e65) : const Color(0xFFf9f6f2);
  }

  @override
  Widget build(BuildContext context) {
    final gameTextClr = Theme.of(context).brightness == Brightness.dark ? Colors.grey[300]! : const Color(0xFF776e65);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('2048', style: TextStyle(color: gameTextClr, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: gameTextClr),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score Board
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreBox('SCORE', '$score'),
                _buildScoreBox('BEST', '$highScore'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Game Board
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanEnd: _onSwipe,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFbbada0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        int x = index ~/ gridSize;
                        int y = index % gridSize;
                        int value = grid[x][y];
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: value == 0 
                                ? const Color(0xFFcdc1b4) 
                                : _getTileColor(value),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: value == 0
                                ? const SizedBox()
                                : Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: value > 100 ? 24 : 32,
                                      fontWeight: FontWeight.bold,
                                      color: _getTileTextColor(value),
                                    ),
                                  ).animate(key: ValueKey(value)).scale(
                                    duration: 200.ms, 
                                    curve: Curves.easeOutBack,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Swipe to move tiles",
            style: TextStyle(color: gameTextClr, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFbbada0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFeee4da),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
