class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool emailVerified;
  final List<Map<String, dynamic>> quizHistory;
  final int totalScore;
  final int quizzesTaken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    required this.createdAt,
    this.lastLogin,
    this.emailVerified = false,
    this.quizHistory = const [],
    this.totalScore = 0,
    this.quizzesTaken = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'emailVerified': emailVerified,
      'quizHistory': quizHistory,
      'totalScore': totalScore,
      'quizzesTaken': quizzesTaken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : null,
      emailVerified: map['emailVerified'] ?? false,
      quizHistory: List<Map<String, dynamic>>.from(map['quizHistory'] ?? []),
      totalScore: map['totalScore'] ?? 0,
      quizzesTaken: map['quizzesTaken'] ?? 0,
    );
  }
}
