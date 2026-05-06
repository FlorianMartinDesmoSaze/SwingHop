import 'rank.dart';

/// Profil de l'utilisateur stocké dans Firestore
class UserProfile {
  final String uid;
  final String pseudo;
  final int totalPoints;
  final int duelWins;
  final int duelLosses;
  final DateTime createdAt;
  final List<String> friendsUids;

  UserProfile({
    required this.uid,
    required this.pseudo,
    this.totalPoints = 0,
    this.duelWins = 0,
    this.duelLosses = 0,
    this.friendsUids = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Rank get rank => Rank.fromPoints(totalPoints);
  
  String get pseudoLowercase => pseudo.toLowerCase();

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'pseudo': pseudo,
        'pseudoLowercase': pseudoLowercase,
        'totalPoints': totalPoints,
        'duelWins': duelWins,
        'duelLosses': duelLosses,
        'friendsUids': friendsUids,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        pseudo: map['pseudo'] as String,
        totalPoints: map['totalPoints'] as int? ?? 0,
        duelWins: map['duelWins'] as int? ?? 0,
        duelLosses: map['duelLosses'] as int? ?? 0,
        friendsUids: (map['friendsUids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );
}
