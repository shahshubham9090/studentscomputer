enum UserRole {
  admin,
  teacher,
  user,
}

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final int points;
  final int dailyStreak;
  final DateTime joinedAt;
  final DateTime? lastPlayedAt;
  final Map<String, int> gameScores;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.role = UserRole.user,
    this.points = 0,
    this.dailyStreak = 0,
    required this.joinedAt,
    this.lastPlayedAt,
    this.gameScores = const {},
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    int? points,
    int? dailyStreak,
    DateTime? joinedAt,
    DateTime? lastPlayedAt,
    Map<String, int>? gameScores,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      points: points ?? this.points,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      joinedAt: joinedAt ?? this.joinedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      gameScores: gameScores ?? this.gameScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'points': points,
      'dailyStreak': dailyStreak,
      'joinedAt': joinedAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'gameScores': gameScores,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      points: json['points'] ?? 0,
      dailyStreak: json['dailyStreak'] ?? 0,
      joinedAt: json['joinedAt'] != null 
          ? DateTime.tryParse(json['joinedAt']) ?? DateTime.now()
          : DateTime.now(),
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.tryParse(json['lastPlayedAt']) 
          : null,
      gameScores: Map<String, int>.from(json['gameScores'] ?? {}),
    );
  }
}
