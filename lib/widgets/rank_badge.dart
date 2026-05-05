import 'package:flutter/material.dart';
import '../models/rank.dart';

class RankBadge extends StatelessWidget {
  final Rank rank;
  final double size;

  const RankBadge({
    super.key,
    required this.rank,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: rank.color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: rank.color, width: 2),
      ),
      child: Center(
        child: Text(
          rank.emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
