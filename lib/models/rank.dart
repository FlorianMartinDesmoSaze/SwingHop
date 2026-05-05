import 'package:flutter/material.dart';

/// Niveaux de rang du joueur, du plus bas au plus élevé.
enum Rank {
  bronze('Bronze', '🥉', Color(0xFFCD7F32), 0, 500),
  silver('Argent', '🥈', Color(0xFFC0C0C0), 500, 1500),
  gold('Or', '🥇', Color(0xFFFFD700), 1500, 4000),
  platinum('Platine', '💎', Color(0xFF00E5FF), 4000, 10000),
  diamond('Diamant', '👑', Color(0xFFAA00FF), 10000, null);

  final String label;
  final String emoji;
  final Color color;
  final int minPoints;
  final int? nextThreshold;

  const Rank(this.label, this.emoji, this.color, this.minPoints, this.nextThreshold);

  /// Calcule le rang correspondant à un total de points.
  static Rank fromPoints(int points) {
    if (points >= 10000) return Rank.diamond;
    if (points >= 4000)  return Rank.platinum;
    if (points >= 1500)  return Rank.gold;
    if (points >= 500)   return Rank.silver;
    return Rank.bronze;
  }
}
