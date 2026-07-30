import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../core/constants.dart';

class StudySwiperScreen extends StatefulWidget {
  const StudySwiperScreen({super.key});

  @override
  State<StudySwiperScreen> createState() => _StudySwiperScreenState();
}

class _StudySwiperScreenState extends State<StudySwiperScreen> {
  final CardSwiperController _controller = CardSwiperController();

  final List<Map<String, String>> _flashcards = [
    {
      "term": "Flutter",
      "definition": "An open-source UI software development kit created by Google.",
    },
    {
      "term": "Dart",
      "definition": "A client-optimized language for fast apps on any platform.",
    },
    {
      "term": "Widget",
      "definition": "The basic building block of a Flutter app's user interface.",
    },
    {
      "term": "StatefulWidget",
      "definition": "A widget that has mutable state.",
    },
    {
      "term": "StatelessWidget",
      "definition": "A widget that doesn't require mutable state.",
    },
  ];

  bool _isFlipped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Swiper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.undo(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              Text(
                "Swipe right to master, left to review later",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: CardSwiper(
                  controller: _controller,
                  cardsCount: _flashcards.length,
                  onSwipe: _onSwipe,
                  onUndo: _onUndo,
                  numberOfCardsDisplayed: 3,
                  padding: const EdgeInsets.all(24.0),
                  cardBuilder: (context, index) {
                    final card = _flashcards[index];
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final frontTextColor = isDark ? Colors.white : AppColors.textPrimary;
                    final frontMutedColor = isDark ? Colors.white70 : AppColors.textSecondary;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFlipped = !_isFlipped;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: _isFlipped
                                ? [AppColors.secondary, AppColors.primary]
                                : isDark
                                    ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                                    : [Colors.white, Colors.indigo.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isFlipped ? "Definition" : "Term",
                                style: TextStyle(
                                  color: _isFlipped ? Colors.white70 : frontMutedColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isFlipped ? card["definition"]! : card["term"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _isFlipped ? Colors.white : frontTextColor,
                                  fontSize: _isFlipped ? 22 : 36,
                                  fontWeight: _isFlipped ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.touch_app_outlined,
                                color: _isFlipped ? Colors.white54 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap to flip",
                                style: TextStyle(
                                  color: _isFlipped ? Colors.white54 : Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: "btn_nope",
                      onPressed: () => _controller.swipeLeft(),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.close, color: Colors.redAccent, size: 30),
                    ),
                    FloatingActionButton(
                      heroTag: "btn_like",
                      onPressed: () => _controller.swipeRight(),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.favorite, color: Colors.greenAccent, size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint('The card $previousIndex was swiped $direction to $currentIndex');
    // Reset flip state for the next card
    setState(() {
      _isFlipped = false;
    });
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint('The card $currentIndex was undid from $direction to $previousIndex');
    return true;
  }
}
