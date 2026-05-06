import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import '../models/duel_record.dart';
import '../widgets/rank_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  UserProfile? _profile;
  List<DuelRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      final history = await _firestoreService.getDuelHistory(user.uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _history = history;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_profile == null) {
      return const Center(child: Text('Erreur de chargement du profil'));
    }

    final rank = _profile!.rank;
    final myUid = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent, // Utilise le fond de l'app
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          Center(
            child: RankBadge(rank: rank, size: 120).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _profile!.pseudo,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              rank.label.toUpperCase(),
              style: TextStyle(fontSize: 18, color: rank.color, fontWeight: FontWeight.w700, letterSpacing: 2.0),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
          ),
          const SizedBox(height: 40),
          _buildStatCard(l10n.profilePoints, _profile!.totalPoints.toString(), Icons.stars)
              .animate().fade(delay: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(l10n.profileWins, _profile!.duelWins.toString(), Icons.emoji_events, color: Colors.amber)
                    .animate().fade(delay: 500.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(l10n.profileLosses, _profile!.duelLosses.toString(), Icons.sentiment_dissatisfied, color: Colors.redAccent)
                    .animate().fade(delay: 600.ms).slideX(begin: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(l10n.profileHistory, style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5))
              .animate().fade(delay: 700.ms).slideX(begin: -0.2),
          const SizedBox(height: 16),
          if (_history.isEmpty)
            Center(
              child: Text(l10n.profileNoHistory, style: const TextStyle(color: Colors.white54))
                  .animate().fade(delay: 800.ms),
            )
          else
            ..._history.map((duel) {
              bool isCreator = duel.creatorUid == myUid;
              int myScore = isCreator ? duel.creatorScore : (duel.challengerScore ?? 0);
              int opponentScore = isCreator ? (duel.challengerScore ?? 0) : duel.creatorScore;
              String opponentPseudo = isCreator ? (duel.challengerPseudo ?? 'Inconnu') : duel.creatorPseudo;
              bool won = myScore > opponentScore || (isCreator && myScore >= opponentScore); // Règle du créateur (>= pour gagner)
              
              if (!isCreator && myScore == opponentScore) won = false; // Égalité favorise le créateur

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: won ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.5), width: 1.5),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: won ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
                    child: Icon(won ? Icons.emoji_events : Icons.close, color: won ? Colors.greenAccent : Colors.redAccent),
                  ),
                  title: Text(
                    'vs $opponentPseudo',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy - HH:mm').format(duel.createdAt),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: Text(
                    '$myScore - $opponentScore',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: won ? Colors.greenAccent : Colors.redAccent),
                  ),
                ),
              ).animate().fade(delay: 800.ms).slideY(begin: 0.1);
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color color = Colors.greenAccent}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7), // Effet glass
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
