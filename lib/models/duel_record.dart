import 'package:cloud_firestore/cloud_firestore.dart';

class DuelRecord {
  final String? id;
  final String creatorUid;
  final String creatorPseudo;
  final int creatorScore;
  
  final String? challengerUid;
  final String? challengerPseudo;
  final int? challengerScore;
  
  final String status; // 'waiting', 'completed'
  final DateTime createdAt;

  DuelRecord({
    this.id,
    required this.creatorUid,
    required this.creatorPseudo,
    required this.creatorScore,
    this.challengerUid,
    this.challengerPseudo,
    this.challengerScore,
    this.status = 'waiting',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'creatorUid': creatorUid,
        'creatorPseudo': creatorPseudo,
        'creatorScore': creatorScore,
        'challengerUid': challengerUid,
        'challengerPseudo': challengerPseudo,
        'challengerScore': challengerScore,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory DuelRecord.fromMap(Map<String, dynamic> map, String id) {
    return DuelRecord(
      id: id,
      creatorUid: map['creatorUid'] ?? '',
      creatorPseudo: map['creatorPseudo'] ?? 'Joueur Inconnu',
      creatorScore: map['creatorScore'] ?? 0,
      challengerUid: map['challengerUid'],
      challengerPseudo: map['challengerPseudo'],
      challengerScore: map['challengerScore'],
      status: map['status'] ?? 'waiting',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
