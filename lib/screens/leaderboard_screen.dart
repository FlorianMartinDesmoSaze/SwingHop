import 'package:flutter/material.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Classement Mondial', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.greenAccent.withValues(alpha: 0.1) : Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMe ? Colors.greenAccent : Colors.transparent,
                      width: isMe ? 2 : 0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: index < 3 ? Colors.amber : Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 16),
                        RankBadge(rank: player.rank, size: 40),
                      ],
                    ),
                    title: Text(
                      player.pseudo + (isMe ? ' (Toi)' : ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 16),
                        ),
                        Text(
                          '${player.duelWins} victoires',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
