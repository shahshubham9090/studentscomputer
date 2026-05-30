import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studentscomputer/core/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studentscomputer/providers/game_provider.dart';

class MathSpeedRunScreen extends StatefulWidget {
  const MathSpeedRunScreen({super.key});

  @override
  State<MathSpeedRunScreen> createState() => _MathSpeedRunScreenState();
}

class _MathSpeedRunScreenState extends State<MathSpeedRunScreen> with TickerProviderStateMixin {
  // Game Configuration
  static const int initialTime = 60;
  
  // Game State
  int _score = 0;
  int _timeLeft = initialTime;
  String _question = "";
  List<int> _options = [];
  int _correctAnswer = 0;
  bool _isPlaying = false;
  bool _isGameOver = false;
  Timer? _gameTimer;
  
  // Animation Controller for feedback
  late AnimationController _feedbackController;
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  // Override back button to ensure cleanup
  Future<bool> _onWillPop() async {
    _gameTimer?.cancel();
    return true;
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = initialTime;
      _isPlaying = true;
      _isGameOver = false;
      _generateQuestion();
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _gameOver();
      }
    });
  }

  void _generateQuestion() {
    Random rand = Random();
    int a = rand.nextInt(20) + 1; // 1 to 20
    int b = rand.nextInt(20) + 1;
    bool isAddition = rand.nextBool();

    _correctAnswer = isAddition ? a + b : a * b; // + or * for simplicity
    
    // Adjust difficulty based on score
    if (_score > 10) {
      // Harder: larger numbers or subtraction
       a = rand.nextInt(50) + 10;
       b = rand.nextInt(10) + 2;
    }

    // Ensure multiplication doesn't get too crazy too fast
    if (!isAddition && b > 12) b = rand.nextInt(10) + 1;

    _question = isAddition ? "$a + $b" : "$a x $b";
    _correctAnswer = isAddition ? a + b : a * b;

    _generateOptions();
  }

  void _generateOptions() {
    Set<int> optionsSet = {_correctAnswer};
    Random rand = Random();
    
    while (optionsSet.length < 4) {
      // Generate plausible wrong answers close to correct answer
      int variance = rand.nextInt(10) + 1;
      int wrongAnswer = rand.nextBool() 
          ? _correctAnswer + variance 
          : _correctAnswer - variance;
      
      if (wrongAnswer > 0) { // Keep positive for now
         optionsSet.add(wrongAnswer);
      }
    }
    
    _options = optionsSet.toList();
    _options.shuffle();
  }

  void _checkAnswer(int selectedAnswer) {
    if (!_isPlaying) return;

    if (selectedAnswer == _correctAnswer) {
      setState(() {
        _score++;
        _feedbackColor = AppColors.success.withOpacity(0.2);
      });
      _feedbackController.forward(from: 0).then((_) => _feedbackController.reverse());
      _generateQuestion();
    } else {
      // Penalty: -2 seconds
      setState(() {
        _timeLeft = max(0, _timeLeft - 2);
         _feedbackColor = AppColors.error.withOpacity(0.2);
      });
      _feedbackController.forward(from: 0).then((_) => _feedbackController.reverse());
      // Shake animation could be added here
    }
  }

  void _gameOver() {
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    Provider.of<GameProvider>(context, listen: false).saveScore('math_speed', _score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your Score', style: TextStyle(fontSize: 16)),
            Text(
              '$_score',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
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
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Math Speed Run'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Feedback Overlay
          AnimatedBuilder(
            animation: _feedbackController,
            builder: (context, child) {
              return Container(
                color: _feedbackColor.withOpacity(
                  _feedbackController.value * 0.5
                ),
              );
            },
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoPill(Icons.timer, '$_timeLeft s', 
                          _timeLeft < 10 ? AppColors.error : AppColors.primary),
                      _buildInfoPill(Icons.star, 'Score: $_score', AppColors.accent),
                    ],
                  ),
                  
                  const Spacer(flex: 2),
                  
                  if (!_isPlaying && !_isGameOver)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 80, color: AppColors.primary),
                          const SizedBox(height: 20),
                          const Text(
                            "Ready?",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Solve as many problems\nas you can in 60 seconds!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text(
                              "START GAME",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05)),
                        ],
                      ),
                    )
                  else if (_isPlaying)
                    Column(
                      children: [
                        // Question Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _question,
                              style: GoogleFonts.rubik(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ).animate(key: ValueKey(_question)).scale(duration: 200.ms, curve: Curves.easeOutBack),
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Options Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                              onPressed: () => _checkAnswer(_options[index]),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                foregroundColor: AppColors.primary,
                                elevation: 4,
                                textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              child: Text('${_options[index]}'),
                            ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
                          },
                        ),
                      ],
                    ),
                    
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
