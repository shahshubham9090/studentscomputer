import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../widgets/shimmer_loading.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const AnimatedSplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Artificial delay to show the animation
    await Future.delayed(const Duration(milliseconds: 3000));
    widget.onInitializationComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.primary,
        ),
        child: Stack(
          children: [
            // Background Pattern (Optional subtle overlay)
             /* 
             // You can add a subtle pattern here if desired
             Opacity(
               opacity: 0.05,
               child: Image.asset(
                 'assets/images/pattern.png', 
                 fit: BoxFit.cover,
                 width: double.infinity,
                 height: double.infinity,
               ),
             ), 
             */

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo with scale, fade, and breathing animation
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.jpg',
                        width: 140, // Slightly smaller for better proportion
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(
                    begin: 1.0,
                    end: 1.05,
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ) // Breathing effect
                  .animate() // Entry animation
                  .scale(
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.5, 0.5),
                  )
                  .fadeIn(duration: 600.ms),
                ),
                
                const SizedBox(height: 50),
                
                // Title with improved typography and animation
                Text(
                  "QUIZ MASTER",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),
                
                const SizedBox(height: 12),
                
                // Tagline
                Text(
                  "Learn • Compete • Grow",
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms),
                
                const Spacer(),
                
                // Loading indicator (More subtle)
                const ShimmerWidget.circular(width: 40, height: 40)
                    .animate()
                    .fadeIn(delay: 1200.ms)
                    .scale(duration: 500.ms),
                    
                const SizedBox(height: 40),

                // Version Number
                Text(
                  "v1.0.0",
                  style: GoogleFonts.robotoMono(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                )
                .animate()
                .fadeIn(delay: 1500.ms),
                
                 const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
