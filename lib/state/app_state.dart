import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/category_data.dart';

/// Represents a single completed quiz attempt. Used by Stats,
/// Leaderboard and Home recent activity widgets.
@immutable
class QuizAttempt {
  final String categoryId;
  final int score;
  final int total;
  final DateTime takenAt;
  final int xpEarned;
  final List<String> bookmarks;

  const QuizAttempt({
    required this.categoryId,
    required this.score,
    required this.total,
    required this.takenAt,
    required this.xpEarned,
    this.bookmarks = const [],
  });

  double get percent => total == 0 ? 0 : (score / total) * 100;
}

/// Unlockable achievement shown on Profile/Stats.
@immutable
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// User-configurable preferences sourced from SharedPreferences.
@immutable
class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final String language;

  const UserPreferences({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.language = 'English',
  });

  UserPreferences copyWith({bool? darkMode, bool? notificationsEnabled, String? language}) => UserPreferences(
        darkMode: darkMode ?? this.darkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        language: language ?? this.language,
      );
}

/// Aggregated state for the premium rebuild. Provides reactive
/// counters, per-category accuracy, achievements and preferences
/// to every screen.
class AppState extends ChangeNotifier {
  AppState() {
    _accuracy = {
      for (final c in kAllCategories)
        c.id: 0.5 + (c.popularity - 4.5).abs() * 0.4,
    };
    _accuracy['flutter_basics'] = 0.85;
    _accuracy['flutter_advanced'] = 0.78;
    _accuracy['state_mgmt'] = 0.70;
    _accuracy['dart_prog'] = 0.88;
    _accuracy['hr_interview'] = 0.92;
    _accuracy['system_design'] = 0.62;
    _accuracy['sql_queries'] = 0.74;
  }

  String _userName = 'John Doe';
  String get userName => _userName;
  String _userEmail = 'hello@careercraft.pro';
  String get userEmail => _userEmail;
  String _photoUrl = '';
  String get photoUrl => _photoUrl;

  int _quizzesTaken = 25;
  int _quizzesCompleted = 18;
  int _badges = 3;
  int _xp = 1240;
  int _streakDays = 15;
  final int _dailyGoal = 5;
  final int _questionsAnsweredToday = 4;
  String _level = 'Intermediate';
  String get level => _level;

  int get quizzesTaken => _quizzesTaken;
  int get quizzesCompleted => _quizzesCompleted;
  int get badges => _badges;
  int get xp => _xp;
  int get streakDays => _streakDays;
  int get dailyGoal => _dailyGoal;
  int get questionsAnsweredToday => _questionsAnsweredToday;

  double get dailyProgress => _dailyGoal == 0 ? 0 : (_questionsAnsweredToday / _dailyGoal).clamp(0.0, 1.0);

  late final Map<String, double> _accuracy;
  Map<String, double> get accuracyByCategory => Map.unmodifiable(_accuracy);

  final List<Achievement> _achievements = [
    Achievement(
      id: 'quick_learner',
      title: 'Quick Learner',
      description: 'Finish a quiz in under 10 minutes',
      icon: Icons.flash_on,
      color: const Color(0xFFFFC107),
    ),
    Achievement(
      id: 'sharp_mind',
      title: 'Sharp Mind',
      description: 'Score 100% on any topic',
      icon: Icons.psychology,
      color: const Color(0xFF6C63FF),
    ),
    Achievement(
      id: 'streak_15',
      title: '15-Day Streak',
      description: 'Practice 15 days in a row',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF6B6B),
    ),
    Achievement(
      id: 'topic_master',
      title: 'Topic Master',
      description: 'Score over 90% in a category',
      icon: Icons.workspace_premium,
      color: const Color(0xFF4CAF50),
    ),
    Achievement(
      id: 'first_quiz',
      title: 'First Quiz',
      description: 'Complete your very first quiz',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFA726),
    ),
    Achievement(
      id: 'bookworm',
      title: 'Bookworm',
      description: 'Bookmark 25 questions',
      icon: Icons.bookmark,
      color: const Color(0xFF3F51B5),
    ),
  ];

  List<Achievement> get achievements => List.unmodifiable(_achievements);

  final List<QuizAttempt> _recentAttempts = [
    QuizAttempt(
      categoryId: 'flutter_basics',
      score: 8,
      total: 10,
      takenAt: DateTime.now().subtract(const Duration(hours: 2)),
      xpEarned: 80,
    ),
    QuizAttempt(
      categoryId: 'state_mgmt',
      score: 6,
      total: 8,
      takenAt: DateTime.now().subtract(const Duration(hours: 5)),
      xpEarned: 60,
    ),
    QuizAttempt(
      categoryId: 'hr_interview',
      score: 9,
      total: 10,
      takenAt: DateTime.now().subtract(const Duration(days: 1)),
      xpEarned: 120,
    ),
  ];

  List<QuizAttempt> get recentAttempts => List.unmodifiable(_recentAttempts);

  final List<double> _weeklyXp = [120, 180, 90, 240, 200, 160, 250];
  List<double> get weeklyXp => List.unmodifiable(_weeklyXp);

  UserPreferences _preferences = const UserPreferences();
  UserPreferences get preferences => _preferences;

  bool _onboarded = false;
  bool get onboarded => _onboarded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _onboarded = prefs.getBool('onboarded') ?? false;
    _userName = prefs.getString('user_name') ?? _userName;
    _userEmail = prefs.getString('user_email') ?? _userEmail;
    _photoUrl = prefs.getString('user_photo') ?? _photoUrl;
    _preferences = UserPreferences(
      darkMode: prefs.getBool('pref_dark') ?? false,
      notificationsEnabled: prefs.getBool('pref_notifications') ?? true,
      language: prefs.getString('pref_language') ?? 'English',
    );
    _quizzesTaken = prefs.getInt('quizzes_taken') ?? _quizzesTaken;
    _quizzesCompleted = prefs.getInt('quizzes_completed') ?? _quizzesCompleted;
    _badges = prefs.getInt('badges') ?? _badges;
    _xp = prefs.getInt('xp') ?? _xp;
    _streakDays = prefs.getInt('streak_days') ?? _streakDays;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quizzes_taken', _quizzesTaken);
    await prefs.setInt('quizzes_completed', _quizzesCompleted);
    await prefs.setInt('badges', _badges);
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak_days', _streakDays);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('user_photo', _photoUrl);
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    notifyListeners();
  }

  void updateName(String value) {
    _userName = value;
    _persist();
    notifyListeners();
  }

  void updateEmail(String value) {
    _userEmail = value;
    _persist();
    notifyListeners();
  }

  void updatePhoto(String value) {
    _photoUrl = value;
    _persist();
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences prefs) async {
    _preferences = prefs;
    final storage = await SharedPreferences.getInstance();
    await storage.setBool('pref_dark', prefs.darkMode);
    await storage.setBool('pref_notifications', prefs.notificationsEnabled);
    await storage.setString('pref_language', prefs.language);
    notifyListeners();
  }

  /// Record a finished quiz, update XP, streak, accuracy & history.
  void recordAttempt({
    required String categoryId,
    required int score,
    required int total,
    required List<String> bookmarks,
  }) {
    final percent = total == 0 ? 0.0 : score / total;
    _accuracy[categoryId] = percent;
    final xp = total == 0 ? 0 : (score * 10).round();
    _xp += xp;
    _quizzesTaken += 1;
    if (score >= (total * 0.6).round()) {
      _quizzesCompleted += 1;
    }
    if (score == total && total > 0 && _badges < _achievements.length) {
      _badges += 1;
    }
    _recentAttempts.insert(
      0,
      QuizAttempt(
        categoryId: categoryId,
        score: score,
        total: total,
        takenAt: DateTime.now(),
        xpEarned: xp,
        bookmarks: bookmarks,
      ),
    );
    if (_recentAttempts.length > 12) {
      _recentAttempts.removeLast();
    }
    _level = _xp < 500
        ? 'Beginner'
        : _xp < 1500
            ? 'Intermediate'
            : _xp < 3500
                ? 'Advanced'
                : 'Pro';
    _persist();
    notifyListeners();
  }

  /// Find a category meta by its id (helper used in many screens).
  CategoryMeta? findCategory(String id) {
    for (final c in kAllCategories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
