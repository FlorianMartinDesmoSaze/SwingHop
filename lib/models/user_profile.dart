import 'rank.dart';

/// Profil de l'utilisateur stocké dans Firestore
class UserProfile {
  final String uid;
  final String pseudo;
  final int totalPoints;
  final int duelWins;
  final int duelLosses;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.pseudo,
    this.totalPoints = 0,
    this.duelWins = 0,
    this.duelLosses = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Rank get rank => Rank.fromPoints(totalPoints);

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'pseudo': pseudo,
        'totalPoints': totalPoints,
        'duelWins': duelWins,
        'duelLosses': duelLosses,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        pseudo: map['pseudo'] as String,
        totalPoints: map['totalPoints'] as int? ?? 0,
        duelWins: map['duelWins'] as int? ?? 0,
        duelLosses: map['duelLosses'] as int? ?? 0,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );
}
