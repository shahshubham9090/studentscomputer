import '../models/user_model.dart';

class AvatarUtils {
  static String getAvatarUrl(UserModel user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return user.avatarUrl!;
    }
    
    // Using adventurer style with user id as seed for consistency
    // Styles available: adventurer, avataaars, bottts, fun-emoji, pixel-art
    return 'https://api.dicebear.com/7.x/adventurer/png?seed=${user.id}';
  }

  static String getFunnyAvatarUrl(String seed) {
    // Generate a funny/character avatar based on a seed
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=$seed';
  }
}
