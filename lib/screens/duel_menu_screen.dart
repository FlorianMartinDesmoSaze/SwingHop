import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/duel_record.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Arène de Duel', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pendingDuels.isEmpty
          ? const Center(child: Text("Aucun défi en attente.\nSois le premier à en lancer un !", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingDuels.length,
              itemBuilder: (context, index) {
                final duel = _pendingDuels[index];
                final isMyDuel = duel.creatorUid == myUid;

                return Card(
                  color: isMyDuel ? Colors.amber.withValues(alpha: 0.1) : Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isMyDuel ? Colors.amber : Colors.transparent),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: Text(
                      isMyDuel ? 'Ton défi en attente' : 'Défi de ${duel.creatorPseudo}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Score à battre : ${duel.creatorScore} sauts',
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    trailing: isMyDuel 
                      ? const Icon(Icons.access_time, color: Colors.white54)
                      : ElevatedButton(
                          onPressed: () => _joinDuel(duel),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black),
                          child: const Text('Relever'),
                        ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewDuel,
        backgroundColor: Colors.amberAccent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Lancer un défi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
