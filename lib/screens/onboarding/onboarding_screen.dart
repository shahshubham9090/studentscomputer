import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../widgets/gradient_button.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Learn & Grow",
      description: "Expand your knowledge with interactive daily quizzes designed to challenge and educate.",
      icon: Icons.school_rounded,
    ),
    OnboardingContent(
      title: "Daily Challenges",
      description: "A fresh new quiz is available every single day. Make learning a daily habit!",
      icon: Icons.calendar_today_rounded,
    ),
    OnboardingContent(
      title: "Compete with Friends",
      description: "Earn points, climb the leaderboard, and show off your achievements.",
      icon: Icons.emoji_events_rounded,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _contents[index].icon,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          _contents[index].title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          _contents[index].description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contents.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppColors.primary : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: _currentPage == _contents.length - 1 ? "Get Started" : "Next",
                        onPressed: () {
                          if (_currentPage == _contents.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  if (_currentPage != _contents.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        child: const Text("Skip"),
                      )
                    else 
                       const SizedBox(height: 48), // Spacing placeholder for Skip button height
                    const SizedBox(height: AppSpacing.l),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent({required this.title, required this.description, required this.icon});
}
