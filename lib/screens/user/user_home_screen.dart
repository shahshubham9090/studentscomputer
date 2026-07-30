import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/ad_service.dart';
import 'user_home_tab.dart';
import 'leaderboard_screen.dart';
import 'user_results_tab.dart';
import 'games/games_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/constants.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  static const List<Widget> _pages = <Widget>[
    UserHomeTab(),
    UserResultsTab(),
    GamesScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (kIsWeb) return; // Banner ads not supported on web
    try {
      _bannerAd = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _isBannerAdLoaded = false;
                _bannerAd = null;
              });
            }
            debugPrint('BannerAd failed to load: $error');
          },
        ),
      )..load();
    } catch (e) {
      debugPrint("Banner Ad Loading Failed: $e");
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _pages.elementAt(_selectedIndex)),
          if (!kIsWeb && _isBannerAdLoaded && bannerAd != null)
            SizedBox(
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              child: AdWidget(ad: bannerAd),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        backgroundColor: AppColors.primary,
        onPressed: () => _onItemTapped(2), // Games tab is index 2
        shape: const CircleBorder(),
        child: const Icon(
          Icons.sports_esports_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        backgroundColor: Theme.of(context).colorScheme.surface,
        itemCount: 4,
        tabBuilder: (int index, bool isActive) {
          // Since we moved Games to the FAB, we need to map the 4 remaining tabs to the 5 total pages
          // Tab 0 -> Page 0 (Home)
          // Tab 1 -> Page 1 (Results)
          // Tab 2 -> Page 3 (Leaderboard)  <-- Skips index 2
          // Tab 3 -> Page 4 (Profile)
          
          int pageIndex = index >= 2 ? index + 1 : index;
          
          final color = isActive ? AppColors.primary : Colors.grey.shade400;
          
          IconData icon;
          String label;
          switch (pageIndex) {
            case 0: icon = Icons.home_rounded; label = 'Home'; break;
            case 1: icon = Icons.assignment_turned_in_rounded; label = 'Results'; break;
            case 3: icon = Icons.leaderboard_rounded; label = 'Board'; break;
            case 4: icon = Icons.person_rounded; label = 'Profile'; break;
            default: icon = Icons.home; label = '';
          }
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
        // We calculate which tab should be active based on the current page index
        activeIndex: _selectedIndex == 2 
            ? -1 // If FAB is active, no bottom bar item is active
            : (_selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex),
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          // Map back to original page indices (skipping 2 for the FAB)
          int newIndex = index >= 2 ? index + 1 : index;
          _onItemTapped(newIndex);
        },
        shadow: BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }
}
