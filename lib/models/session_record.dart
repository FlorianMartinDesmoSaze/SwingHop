/// Enregistrement d'une session de jeu (libre ou duel).
class SessionRecord {
  final DateTime date;
  final int jumps;
  final int pointsEarned;
  final bool isDuel;
  final String? opponentPseudo;
  final bool? won; // null si session libre

  const SessionRecord({
    required this.date,
    required this.jumps,
    required this.pointsEarned,
    this.isDuel = false,
    this.opponentPseudo,
    this.won,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'jumps': jumps,
        'pointsEarned': pointsEarned,
        'isDuel': isDuel,
        'opponentPseudo': opponentPseudo,
        'won': won,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        date: DateTime.parse(json['date'] as String),
        jumps: json['jumps'] as int,
        pointsEarned: json['pointsEarned'] as int,
        isDuel: json['isDuel'] as bool? ?? false,
        opponentPseudo: json['opponentPseudo'] as String?,
        won: json['won'] as bool?,
      );
}
