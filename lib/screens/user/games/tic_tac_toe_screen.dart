import 'package:flutter/material.dart';
import 'package:studentscomputer/core/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<List<String?>> _board = List.generate(3, (_) => List.filled(3, null));
  String _currentPlayer = 'X';
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;
  bool _gameOver = false;
  String? _winner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            _buildStatsCard(),
            const SizedBox(height: AppSpacing.xl),
            _buildGameBoard(),
            const SizedBox(height: AppSpacing.xl),
            _buildGameInfo(),
            const SizedBox(height: AppSpacing.l),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('X Wins', _xWins, AppColors.primary),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
          _buildStatItem('O Wins', _oWins, AppColors.secondary),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
          _buildStatItem('Draws', _draws, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: List.generate(3, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (col) {
              return _buildCell(row, col);
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final value = _board[row][col];
    final isWinningCell = _winner != null && _isWinningCell(row, col);
    
    return GestureDetector(
      onTap: _gameOver || value != null ? null : () => _makeMove(row, col),
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isWinningCell 
              ? AppColors.success.withOpacity(0.2)
              : (value == null ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isWinningCell
                ? AppColors.success
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isWinningCell ? 3 : 2,
          ),
          boxShadow: value != null ? [
            BoxShadow(
              color: (value == 'X' ? AppColors.primary : AppColors.secondary).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Center(
          child: value != null
              ? Text(
                  value,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: value == 'X' ? AppColors.primary : AppColors.secondary,
                    shadows: [
                      Shadow(
                        color: (value == 'X' ? AppColors.primary : AppColors.secondary).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 200.ms, curve: Curves.elasticOut)
              : null,
        ),
      ),
    );
  }

  bool _isWinningCell(int row, int col) {
    if (_winner == null) return false;
    
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_board[i][0] == _winner && _board[i][1] == _winner && _board[i][2] == _winner) {
        if (i == row) return true;
      }
    }
    
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (_board[0][i] == _winner && _board[1][i] == _winner && _board[2][i] == _winner) {
        if (i == col) return true;
      }
    }
    
    // Check diagonals
    if (_board[0][0] == _winner && _board[1][1] == _winner && _board[2][2] == _winner) {
      if (row == col) return true;
    }
    if (_board[0][2] == _winner && _board[1][1] == _winner && _board[2][0] == _winner) {
      if (row + col == 2) return true;
    }
    
    return false;
  }

  void _makeMove(int row, int col) {
    if (_board[row][col] != null || _gameOver) return;

    setState(() {
      _board[row][col] = _currentPlayer;
      _checkWinner();
      if (!_gameOver) {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  void _checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_board[i][0] != null &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        _endGame(_board[i][0]!);
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (_board[0][i] != null &&
          _board[0][i] == _board[1][i] &&
          _board[1][i] == _board[2][i]) {
        _endGame(_board[0][i]!);
        return;
      }
    }

    // Check diagonals
    if (_board[0][0] != null &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      _endGame(_board[0][0]!);
      return;
    }

    if (_board[0][2] != null &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      _endGame(_board[0][2]!);
      return;
    }

    // Check for draw
    bool isDraw = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == null) {
          isDraw = false;
          break;
        }
      }
      if (!isDraw) break;
    }

    if (isDraw) {
      _endGame(null);
    }
  }

  void _endGame(String? winner) {
    setState(() {
      _gameOver = true;
      _winner = winner;
      if (winner == 'X') {
        _xWins++;
      } else if (winner == 'O') {
        _oWins++;
      } else {
        _draws++;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, null));
      _currentPlayer = 'X';
      _gameOver = false;
      _winner = null;
    });
  }

  void _resetStats() {
    setState(() {
      _xWins = 0;
      _oWins = 0;
      _draws = 0;
      _resetGame();
    });
  }

  Widget _buildGameInfo() {
    if (_gameOver) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _winner == null
              ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200])
              : (_winner == 'X'
                  ? AppGradients.primary
                  : AppGradients.secondary),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_winner == null
                      ? Colors.grey
                      : (_winner == 'X' ? AppColors.primary : AppColors.secondary))
                  .withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _winner == null
                  ? Icons.handshake
                  : Icons.emoji_events,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _winner == null
                  ? "It's a Draw!"
                  : "Player $_winner Wins! 🎉",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: (_currentPlayer == 'X' ? AppColors.primary : AppColors.secondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (_currentPlayer == 'X' ? AppColors.primary : AppColors.secondary).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_currentPlayer == 'X' ? AppColors.primary : AppColors.secondary).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              _currentPlayer,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _currentPlayer == 'X' ? AppColors.primary : AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Player $_currentPlayer's Turn",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _currentPlayer == 'X' ? AppColors.primary : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetStats,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset Stats'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
