import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retourne l'utilisateur actuel ou null s'il n'est pas connecté
  User? get currentUser => _auth.currentUser;

  /// Stream pour écouter les changements d'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Connecte l'utilisateur de manière anonyme.
  /// Renvoie l'User si succès, lance une exception sinon.
  Future<User?> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user;
  }

  /// Déconnecte l'utilisateur (utile en debug, bien que l'auth anonyme soit censée persister)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
