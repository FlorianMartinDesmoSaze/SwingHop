import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/rank_badge.dart';
import '../services/auth_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  List<UserProfile> _topPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final players = await _firestoreService.getLeaderboard();
    if (mounted) {
      setState(() {
        _topPlayers = players;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    final currentUid = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background from theme
      appBar: AppBar(
        title: const Text('Classement Mondial', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _topPlayers.isEmpty
          ? const Center(child: Text("Aucun joueur pour le moment.", style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _topPlayers.length,
              itemBuilder: (context, index) {
                final player = _topPlayers[index];
                final isMe = player.uid == currentUid;
                
                // Couleurs pour le Top 3
                Color rankColor;
                if (index == 0) {
                  rankColor = const Color(0xFFFFD700); // Or
                } else if (index == 1) rankColor = const Color(0xFFC0C0C0); // Argent
                else if (index == 2) rankColor = const Color(0xFFCD7F32); // Bronze
                else rankColor = Colors.white24;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.greenAccent.withOpacity(0.15) : const Color(0xFF1E293B).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMe 
                        ? Colors.greenAccent 
                        : (index < 3 ? rankColor.withOpacity(0.5) : Colors.transparent),
                      width: isMe || index < 3 ? 2 : 0,
                    ),
                    boxShadow: [
                      if (isMe)
                        BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)
                      else if (index < 3)
                        BoxShadow(color: rankColor.withOpacity(0.15), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: index < 3 ? 22 : 18,
                              fontWeight: FontWeight.w900,
                              color: index < 3 ? rankColor : Colors.white54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RankBadge(rank: player.rank, size: 40),
                      ],
                    ),
                    title: Text(
                      player.pseudo + (isMe ? ' (Toi)' : ''),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isMe ? Colors.greenAccent : Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${player.totalPoints} pts',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.greenAccent, fontSize: 18),
                        ),
                        Text(
                          '${player.duelWins} victoires',
                          style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1);
              },
            ),
    );
  }
}
