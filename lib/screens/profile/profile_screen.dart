import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../core/avatar_utils.dart';
import '../../providers/theme_provider.dart';

import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/shimmer_loading.dart';

part 'edit_profile_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
      });
    } catch (e) {
      debugPrint("Error loading notification preference: $e");
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications_enabled', value);
      
      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic('all');
        debugPrint("Subscribed to topic 'all'");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('all');
        debugPrint("Unsubscribed from topic 'all'");
      }
    } catch (e) {
      debugPrint("Failed to toggle notification preference: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(user)), 
            ).animate().fade().scale(),
            const SizedBox(height: AppSpacing.m),
            Text(
              user.displayName,
              style: Theme.of(context).textTheme.displaySmall,
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            Text(user.email, style: Theme.of(context).textTheme.bodyLarge).animate().fade(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: AppSpacing.l),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Points', style: Theme.of(context).textTheme.labelLarge),
                        Text('${user.points}', style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Rank', style: Theme.of(context).textTheme.labelLarge),
                        Text('#12', style: Theme.of(context).textTheme.headlineMedium), 
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: AppSpacing.l),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Push Notifications'),
              subtitle: const Text('Get daily quiz reminders'),
              trailing: Switch(
                value: _notificationsEnabled, 
                onChanged: _toggleNotifications,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: context.watch<ThemeProvider>().isDarkMode, 
                onChanged: (v) {
                  context.read<ThemeProvider>().toggleTheme(v);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => const _EditProfileModal(),
                );
              },
            ),
             const Divider(),
             ListTile(
               leading: const Icon(Icons.logout, color: AppColors.error),
               title: const Text('Logout', style: TextStyle(color: AppColors.error)),
               onTap: () async {
                 await context.read<AuthProvider>().logout();
                 if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/welcome',
                    (route) => false,
                  );
                 }
               },
             ),
          ],
        ),
      ),
    );
  }
}
