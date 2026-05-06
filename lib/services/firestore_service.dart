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

  /// Met à jour le pseudo d'un joueur
  Future<void> updatePseudo(String uid, String newPseudo) async {
    try {
      await _db.collection('users').doc(uid).update({
        'pseudo': newPseudo,
        'pseudoLowercase': newPseudo.toLowerCase(),
      });
    } catch (e) {
      debugPrint("Erreur updatePseudo: $e");
    }
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

  /// Récupère les duels en attente, triés par date (filtre sur la cible)
  Future<List<DuelRecord>> getPendingDuels(String currentUid) async {
    try {
      final snapshot = await _db
          .collection('duels')
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt', descending: true)
          .get();
          
      final allDuels = snapshot.docs.map((doc) => DuelRecord.fromMap(doc.data(), doc.id)).toList();
      
      // On ne garde que les duels publics (targetUid == null), ou ceux qui nous sont adressés, 
      // ou ceux qu'on a créés soi-même.
      return allDuels.where((duel) {
        return duel.targetUid == null || 
               duel.targetUid == currentUid || 
               duel.creatorUid == currentUid;
      }).toList();
      
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

  /// Récupère l'historique des duels (terminés) d'un joueur
  Future<List<DuelRecord>> getDuelHistory(String uid) async {
    try {
      final creatorQuery = await _db
          .collection('duels')
          .where('creatorUid', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();

      final challengerQuery = await _db
          .collection('duels')
          .where('challengerUid', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();

      final allDocs = [...creatorQuery.docs, ...challengerQuery.docs];
      
      // Éviter les doublons potentiels
      final uniqueDocs = {for (var doc in allDocs) doc.id: doc}.values.toList();

      final duels = uniqueDocs.map((doc) => DuelRecord.fromMap(doc.data(), doc.id)).toList();
      
      // Trier par date décroissante (plus récent en premier)
      duels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return duels;
    } catch (e) {
      debugPrint("Erreur getDuelHistory: $e");
      return [];
    }
  }

  // --- SOCIAL (AMIS) ---

  /// Ajoute un ami via son pseudo
  /// Retourne un message de succès ou d'erreur
  Future<String> addFriendByPseudo(String currentUid, String friendPseudo) async {
    try {
      if (friendPseudo.trim().isEmpty) return "Pseudo vide.";
      
      // Chercher l'utilisateur avec ce pseudo (insensible à la casse)
      final query = await _db
          .collection('users')
          .where('pseudoLowercase', isEqualTo: friendPseudo.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return "Joueur introuvable.";
      }

      final friendUid = query.docs.first.id;

      if (friendUid == currentUid) {
        return "Tu ne peux pas t'ajouter toi-même !";
      }

      // Ajouter à la liste d'amis
      await _db.collection('users').doc(currentUid).update({
        'friendsUids': FieldValue.arrayUnion([friendUid])
      });

      return "Ami ajouté avec succès !";
    } catch (e) {
      debugPrint("Erreur addFriendByPseudo: $e");
      return "Une erreur est survenue.";
    }
  }

  /// Retire un ami
  Future<void> removeFriend(String currentUid, String friendUid) async {
    try {
      await _db.collection('users').doc(currentUid).update({
        'friendsUids': FieldValue.arrayRemove([friendUid])
      });
    } catch (e) {
      debugPrint("Erreur removeFriend: $e");
    }
  }

  /// Récupère les profils des amis
  Future<List<UserProfile>> getFriendsProfiles(String currentUid) async {
    try {
      final currentUser = await getUserProfile(currentUid);
      if (currentUser == null || currentUser.friendsUids.isEmpty) return [];

      // Firestore limite la requête 'whereIn' à 30 éléments maximum.
      // Pour une MVP, on suppose qu'il y a < 30 amis, ou on fait des lots.
      final friendsList = currentUser.friendsUids.take(30).toList();

      final query = await _db
          .collection('users')
          .where('uid', whereIn: friendsList)
          .get();

      return query.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Erreur getFriendsProfiles: $e");
      return [];
    }
  }

  /// Recherche des utilisateurs par préfixe de pseudo (insensible à la casse)
  Future<List<UserProfile>> searchUsersByPrefix(String prefix) async {
    try {
      final searchStr = prefix.trim().toLowerCase();
      if (searchStr.isEmpty) return [];

      final query = await _db
          .collection('users')
          .where('pseudoLowercase', isGreaterThanOrEqualTo: searchStr)
          .where('pseudoLowercase', isLessThan: '$searchStr\uf8ff')
          .limit(3)
          .get();

      return query.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Erreur searchUsersByPrefix: $e");
      return [];
    }
  }

  // --- DEBUG & TESTS ---
  
  /// Génère des fausses données (joueurs, duels en attente, historique)
  /// pour tester l'UI (classement, historique, confettis).
  Future<void> generateMockData(String currentUid) async {
    try {
      debugPrint("Génération de fausses données en cours...");

      // 1. Faux Joueurs
      final fakeUsers = [
        UserProfile(uid: "mock1", pseudo: "ShadowNinja", totalPoints: 1250, duelWins: 25, duelLosses: 5),
        UserProfile(uid: "mock2", pseudo: "IronLegs", totalPoints: 850, duelWins: 15, duelLosses: 10),
        UserProfile(uid: "mock3", pseudo: "HopMaster", totalPoints: 420, duelWins: 8, duelLosses: 2),
      ];

      for (var user in fakeUsers) {
        await _db.collection('users').doc(user.uid).set(user.toMap());
      }

      // 2. Faux Duels en attente (défis que l'utilisateur actuel peut relever)
      final pendingDuels = [
        DuelRecord(creatorUid: "mock1", creatorPseudo: "ShadowNinja", creatorScore: 8),
        DuelRecord(creatorUid: "mock2", creatorPseudo: "IronLegs", creatorScore: 3),
        DuelRecord(creatorUid: "mock3", creatorPseudo: "HopMaster", creatorScore: 1),
      ];

      for (var duel in pendingDuels) {
        await _db.collection('duels').add(duel.toMap());
      }

      // 3. Faux Historique (duels déjà complétés par l'utilisateur actuel)
      final completedDuels = [
        DuelRecord(
          creatorUid: currentUid, 
          creatorPseudo: "Moi", 
          creatorScore: 12, 
          challengerUid: "mock2", 
          challengerPseudo: "IronLegs", 
          challengerScore: 9, 
          status: 'completed',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DuelRecord(
          creatorUid: "mock1", 
          creatorPseudo: "ShadowNinja", 
          creatorScore: 15, 
          challengerUid: currentUid, 
          challengerPseudo: "Moi", 
          challengerScore: 10, 
          status: 'completed',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      for (var duel in completedDuels) {
        await _db.collection('duels').add(duel.toMap());
      }

      debugPrint("Fausses données générées avec succès !");
    } catch (e) {
      debugPrint("Erreur generateMockData: $e");
    }
  }
}
