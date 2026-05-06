import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/duel_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/rank_badge.dart';
import 'duel_active_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final UserProfile player;
  final List<CameraDescription>? cameras;

  const PublicProfileScreen({super.key, required this.player, this.cameras});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  List<DuelRecord> _history = [];
  bool _isLoading = true;
  bool _isFriend = false;
  bool _isActionLoading = false;

  String get _myUid => _authService.currentUser?.uid ?? '';
  bool get _isMe => _myUid == widget.player.uid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final myProfile = await _firestoreService.getUserProfile(_myUid);
    final history = await _firestoreService.getDuelHistory(widget.player.uid);
    if (mounted) {
      setState(() {
        _history = history;
        _isFriend = myProfile?.friendsUids.contains(widget.player.uid) ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFriend() async {
    setState(() => _isActionLoading = true);
    if (_isFriend) {
      await _firestoreService.removeFriend(_myUid, widget.player.uid);
    } else {
      // Ajouter directement par UID (sans chercher par pseudo)
      await _firestoreService.addFriendByUid(_myUid, widget.player.uid);
    }
    if (mounted) {
      setState(() {
        _isFriend = !_isFriend;
        _isActionLoading = false;
      });
    }
  }

  Future<void> _challengePlayer() async {
    if (widget.cameras == null || widget.cameras!.isEmpty) return;

    final myProfile = await _firestoreService.getUserProfile(_myUid);
    if (myProfile == null) return;

    final frontCamera = widget.cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras!.first,
    );

    if (!mounted) return;

    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => DuelActiveScreen(camera: frontCamera, timeLimitSeconds: 30),
      ),
    );

    if (score == null) return;

    final duel = DuelRecord(
      creatorUid: myProfile.uid,
      creatorPseudo: myProfile.pseudo,
      creatorScore: score,
      targetUid: widget.player.uid,
    );

    await _firestoreService.createDuel(duel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Défi direct envoyé à ${widget.player.pseudo} avec $score sauts !',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = widget.player.rank;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // --- Hero Header ---
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      rank.color.withValues(alpha: 0.3),
                      const Color(0xFF0F172A),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      RankBadge(rank: rank, size: 110)
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text(
                        widget.player.pseudo,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: rank.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: rank.color.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          rank.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            color: rank.color,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ).animate().fade(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Action Buttons ---
          if (!_isMe)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    // Bouton Défi
                    if (widget.cameras != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _challengePlayer,
                          icon: const Text('⚔️', style: TextStyle(fontSize: 18)),
                          label: const Text('Provoquer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                    if (widget.cameras != null) const SizedBox(width: 12),
                    // Bouton Ami
                    Expanded(
                      child: _isActionLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                          : ElevatedButton.icon(
                              onPressed: _toggleFriend,
                              icon: Icon(_isFriend ? Icons.person_remove : Icons.person_add),
                              label: Text(
                                _isFriend ? 'Retirer' : 'Ajouter',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFriend ? Colors.white12 : Colors.greenAccent,
                                foregroundColor: _isFriend ? Colors.white70 : Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                    ),
                  ],
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
              ),
            ),

          // --- Stats ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STATISTIQUES',
                      style: TextStyle(
                          color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  _buildStatCard('Points Totaux', widget.player.totalPoints.toString(), Icons.stars)
                      .animate().fade(delay: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Victoires', widget.player.duelWins.toString(), Icons.emoji_events,
                                color: Colors.amber)
                            .animate().fade(delay: 550.ms).slideX(begin: -0.2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Défaites', widget.player.duelLosses.toString(),
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent)
                            .animate().fade(delay: 600.ms).slideX(begin: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('DERNIERS MATCHS',
                      style: TextStyle(
                          color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // --- Historique ---
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
            )
          else if (_history.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: const Text('Aucun duel terminé pour le moment.',
                      style: TextStyle(color: Colors.white54)).animate().fade(),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final duel = _history[index];
                  final uid = widget.player.uid;
                  final isCreator = duel.creatorUid == uid;
                  final myScore = isCreator ? duel.creatorScore : (duel.challengerScore ?? 0);
                  final opponentScore = isCreator ? (duel.challengerScore ?? 0) : duel.creatorScore;
                  final opponentPseudo = isCreator ? (duel.challengerPseudo ?? '?') : duel.creatorPseudo;
                  final won = isCreator ? myScore >= opponentScore : myScore > opponentScore;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: won ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.redAccent.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: won ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
                          child: Icon(won ? Icons.emoji_events : Icons.close,
                              color: won ? Colors.greenAccent : Colors.redAccent),
                        ),
                        title: Text('vs $opponentPseudo',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy').format(duel.createdAt),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        trailing: Text(
                          '$myScore - $opponentScore',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: won ? Colors.greenAccent : Colors.redAccent),
                        ),
                      ),
                    ).animate().fade(delay: Duration(milliseconds: 700 + 80 * index)).slideY(begin: 0.1),
                  );
                },
                childCount: _history.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color color = Colors.greenAccent}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
