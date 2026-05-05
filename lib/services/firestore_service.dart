import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/session_record.dart';
import '../models/duel_record.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PROFILS UTILISATEURS ---

  /// Crée ou met à jour le profil d'un utilisateur
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.uid).set(profile.toMap());
    } catch (e) {
      debugPrint("Erreur saveUserProfile: $e");
    }
  }

  /// Récupère le profil d'un utilisateur via son UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint("Erreur getUserProfile: $e");
    }
    return null;
  }

  /// Met à jour les points et le compte de victoires/défaites d'un joueur
  Future<void> updatePlayerStats(String uid, {required int pointsToAdd, bool? isDuelWin}) async {
    try {
      final userRef = _db.collection('users').doc(uid);
      
      Map<String, dynamic> updates = {
        'totalPoints': FieldValue.increment(pointsToAdd),
      };

      if (isDuelWin == true) {
        updates['duelWins'] = FieldValue.increment(1);
      } else if (isDuelWin == false) {
        updates['duelLosses'] = FieldValue.increment(1);
      }

      await userRef.update(updates);
    } catch (e) {
      debugPrint("Erreur updatePlayerStats: $e");
    }
  }

  // --- SESSIONS & SCORES ---

  /// Enregistre une nouvelle session (et met à jour les stats du joueur en même temps)
  Future<void> saveSession(String uid, SessionRecord session) async {
    try {
      // 1. Sauvegarder la session dans la sous-collection du joueur (pour l'historique)
      await _db
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .add(session.toJson());

      // 2. Mettre à jour le profil global du joueur
      await updatePlayerStats(
        uid,
        pointsToAdd: session.pointsEarned,
        isDuelWin: session.isDuel ? session.won : null,
      );
    } catch (e) {
      debugPrint("Erreur saveSession: $e");
    }
  }

  /// Récupère le leaderboard (Top 50 joueurs par points)
  Future<List<UserProfile>> getLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();
          
      return snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Erreur getLeaderboard: $e");
      return [];
    }
  }
  // --- DUELS ---

  /// Crée un nouveau duel en attente
  Future<void> createDuel(DuelRecord duel) async {
    try {
      await _db.collection('duels').add(duel.toMap());
    } catch (e) {
      debugPrint("Erreur createDuel: $e");
    }
  }

  /// Récupère les duels en attente, triés par date
  Future<List<DuelRecord>> getPendingDuels() async {
    try {
      final snapshot = await _db
          .collection('duels')
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt', descending: true)
          .get();
          
      return snapshot.docs.map((doc) => DuelRecord.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Erreur getPendingDuels: $e");
      return [];
    }
  }

  /// Résout un duel en comparant les scores, met à jour le statut et attribue les points
  Future<void> resolveDuel(String duelId, String challengerUid, String challengerPseudo, int challengerScore) async {
    try {
      final docRef = _db.collection('duels').doc(duelId);
      final docSnap = await docRef.get();
      
      if (!docSnap.exists) return;
      
      final duel = DuelRecord.fromMap(docSnap.data()!, docSnap.id);
      if (duel.status == 'completed') return; // Déjà résolu

      // 1. Mise à jour du document Duel
      await docRef.update({
        'challengerUid': challengerUid,
        'challengerPseudo': challengerPseudo,
        'challengerScore': challengerScore,
        'status': 'completed',
      });

      // 2. Détermination du vainqueur
      bool creatorWon = duel.creatorScore >= challengerScore;
      bool challengerWon = challengerScore > duel.creatorScore;

      // 3. Attribution des points (50 pts pour victoire, 10 pour défaite/participation)
      await updatePlayerStats(
        duel.creatorUid, 
        pointsToAdd: creatorWon ? 50 : 10, 
        isDuelWin: creatorWon,
      );

      await updatePlayerStats(
        challengerUid, 
        pointsToAdd: challengerWon ? 50 : 10, 
        isDuelWin: challengerWon,
      );

    } catch (e) {
      debugPrint("Erreur resolveDuel: $e");
    }
  }
}
