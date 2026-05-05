import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
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
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_profile == null) {
      return const Center(child: Text('Erreur de chargement du profil', style: TextStyle(color: Colors.white)));
    }

    final rank = _profile!.rank;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RankBadge(rank: rank, size: 100),
            const SizedBox(height: 20),
            Text(
              _profile!.pseudo,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              rank.label,
              style: TextStyle(fontSize: 20, color: rank.color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            _buildStatCard('Points Totaux', _profile!.totalPoints.toString(), Icons.stars),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatCard('Victoires', _profile!.duelWins.toString(), Icons.emoji_events, color: Colors.amber)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Défaites', _profile!.duelLosses.toString(), Icons.sentiment_dissatisfied, color: Colors.redAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color color = Colors.greenAccent}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }
}
