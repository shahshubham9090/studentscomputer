import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/quiz_model.dart';
import '../../core/constants.dart';
import '../../core/app_feedback.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizTakingScreen({super.key, required this.quiz});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};
  Timer? _timer;
  int _timeLeft = 30;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.quiz.questions.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_currentQuestionIndex >= widget.quiz.questions.length) return;
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    _timeLeft = currentQuestion.timeSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _answerQuestion(-1); // Time out
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _answerQuestion(int choiceIndex) {
    _timer?.cancel();
    final currentQ = widget.quiz.questions[_currentQuestionIndex];
    setState(() {
      _answers[currentQ.id] = choiceIndex;
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
          setState(() => _currentQuestionIndex++);
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
          _resetTimer();
        } else {
          _finishQuiz();
        }
      }
    });
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    int score = 0;
    for (var q in widget.quiz.questions) {
      final userAnswer = _answers[q.id];
      if (userAnswer != null && userAnswer == q.correctChoiceIndex) score++;
    }
    
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        await context.read<QuizProvider>().submitQuiz(
          quizId: widget.quiz.id, 
          userId: user.id,
          userName: user.displayName,
          quizTitle: widget.quiz.title,
          answers: _answers,
        );
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => QuizResultScreen(score: score, total: widget.quiz.questions.length, quizTitle: widget.quiz.title)),
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('This quiz has no questions. Please contact the administrator.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.quiz.questions.length,
        itemBuilder: (context, index) => _buildQuestionView(widget.quiz.questions[index]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;
    return AppBar(
      centerTitle: true,
      title: Column(
        children: [
          Text(
            "Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).toInt()}% Complete",
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      actions: [_buildTimerBadge()],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildProgressBar(),
        ),
      ),
    );
  }

  Widget _buildTimerBadge() {
    final isLowTime = _timeLeft < 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isLowTime ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 16, color: isLowTime ? AppColors.error : AppColors.primary),
          const SizedBox(width: 4),
          Text(
            "00:${_timeLeft.toString().padLeft(2, '0')}", 
            style: TextStyle(color: isLowTime ? AppColors.error : AppColors.primary, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: progress),
      builder: (context, value, _) => Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView(Question question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.m),
          Text(
            question.text, 
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, height: 1.4, color: Theme.of(context).colorScheme.onBackground),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(question.choices.length, (i) => _buildChoiceTile(question, i)),
        ],
      ),
    );
  }

  Widget _buildChoiceTile(Question question, int i) {
    final hasAnswered = _answers.containsKey(question.id);
    final isSelected = _answers[question.id] == i;
    final isCorrect = question.correctChoiceIndex == i;
    
    Color tileColor = Theme.of(context).colorScheme.surface;
    Color textColor = Theme.of(context).colorScheme.onSurface;
    IconData? icon;
    
    if (hasAnswered) {
      if (isCorrect) {
        tileColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle;
      } else if (isSelected) {
        tileColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.cancel;
      } else {
        tileColor = Theme.of(context).colorScheme.surface.withOpacity(0.5);
      }
    } 

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasAnswered ? null : () => _answerQuestion(i),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  _buildChoiceIndex(i, hasAnswered, isSelected, isCorrect),
                  const SizedBox(width: 16),
                  Expanded(child: Text(question.choices[i], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor))),
                  if (icon != null) ...[const SizedBox(width: 8), Icon(icon, color: Colors.white)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceIndex(int i, bool answered, bool selected, bool correct) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: answered && (selected || correct) ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
      ),
      alignment: Alignment.center,
      child: Text(
        String.fromCharCode(65 + i),
        style: TextStyle(fontWeight: FontWeight.bold, color: answered && (selected || correct) ? Colors.white : AppColors.primary),
      ),
    );
  }
}
