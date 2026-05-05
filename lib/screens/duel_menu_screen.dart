import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/duel_record.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/audio_haptic_service.dart';
import 'duel_active_screen.dart';

class DuelMenuScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const DuelMenuScreen({super.key, required this.cameras});

  @override
  State<DuelMenuScreen> createState() => _DuelMenuScreenState();
}

class _DuelMenuScreenState extends State<DuelMenuScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  
  List<DuelRecord> _pendingDuels = [];
  UserProfile? _currentUser;
  bool _isLoading = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUser = await _firestoreService.getUserProfile(user.uid);
      _pendingDuels = await _firestoreService.getPendingDuels();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _startNewDuel() async {
    if (_currentUser == null) return;

    final frontCamera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    // 1. Jouer le duel
    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => DuelActiveScreen(camera: frontCamera, timeLimitSeconds: 30),
      ),
    );

    if (score == null) return; // Annulé

    // 2. Créer l'enregistrement
    setState(() => _isLoading = true);
    final duel = DuelRecord(
      creatorUid: _currentUser!.uid,
      creatorPseudo: _currentUser!.pseudo,
      creatorScore: score,
    );
    
    await _firestoreService.createDuel(duel);
    await _loadData(); // Rafraîchir
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Défi lancé avec $score sauts !', style: const TextStyle(color: Colors.black)), backgroundColor: Colors.amberAccent)
      );
    }
  }

  Future<void> _joinDuel(DuelRecord duel) async {
    if (_currentUser == null) return;

    final frontCamera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    // 1. Jouer le duel
    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => DuelActiveScreen(camera: frontCamera, timeLimitSeconds: 30),
      ),
    );

    if (score == null) return; // Annulé

    // 2. Résoudre le duel
    setState(() => _isLoading = true);
    await _firestoreService.resolveDuel(
      duel.id!, 
      _currentUser!.uid, 
      _currentUser!.pseudo, 
      score,
    );
    
    await _loadData(); // Rafraîchir

    if (mounted) {
      bool won = score > duel.creatorScore;
      if (won) {
        _confettiController.play();
        AudioHapticService().playWinSound();
        AudioHapticService().playClickHaptic();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(won ? 'Tu as gagné le duel ! (+50 pts)' : 'Tu as perdu le duel... (+10 pts)', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
          backgroundColor: won ? Colors.greenAccent : Colors.orangeAccent,
          duration: const Duration(seconds: 4),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.amberAccent));
    }

    final myUid = _currentUser?.uid;

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent, // Background from theme
      appBar: AppBar(
        title: const Text('Arène de Duel', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pendingDuels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, size: 80, color: Colors.amberAccent),
                  const SizedBox(height: 20),
                  const Text("Aucun défi en attente.\nSois le premier à en lancer un !", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)
                  ),
                ],
              ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingDuels.length,
              itemBuilder: (context, index) {
                final duel = _pendingDuels[index];
                final isMyDuel = duel.creatorUid == myUid;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMyDuel ? Colors.amberAccent.withOpacity(0.6) : Colors.amberAccent.withOpacity(0.1),
                      width: isMyDuel ? 2 : 1
                    ),
                    boxShadow: [
                      if (isMyDuel)
                        BoxShadow(
                          color: Colors.amberAccent.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.amberAccent.withOpacity(0.2),
                      child: const Icon(Icons.bolt, color: Colors.amberAccent),
                    ),
                    title: Text(
                      isMyDuel ? 'Ton défi en attente' : 'Défi de ${duel.creatorPseudo}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Score à battre : ${duel.creatorScore} sauts',
                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                    trailing: isMyDuel 
                      ? const Icon(Icons.access_time, color: Colors.white54)
                      : ElevatedButton(
                          onPressed: () => _joinDuel(duel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent, 
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                            shadowColor: Colors.amberAccent.withOpacity(0.5),
                          ),
                          child: const Text('Relever', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                  ),
                ).animate().fade(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.amberAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _startNewDuel,
          backgroundColor: Colors.amberAccent,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Lancer un défi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );

    return Stack(
      children: [
        scaffold,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14159 / 2, // Vers le bas
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
            colors: const [Colors.greenAccent, Colors.amberAccent, Colors.white, Colors.cyanAccent],
          ),
        ),
      ],
    );
  }
}
