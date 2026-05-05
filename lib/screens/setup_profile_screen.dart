import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';

class SetupProfileScreen extends StatefulWidget {
  final VoidCallback onProfileCreated;

  const SetupProfileScreen({super.key, required this.onProfileCreated});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _pseudoController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pseudoController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final pseudo = _pseudoController.text.trim();
    if (pseudo.isEmpty) {
      setState(() => _errorMessage = "Veuillez entrer un pseudo.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 1. Connexion anonyme
    User? user;
    try {
      user = await _authService.signInAnonymously();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur Firebase : $e";
      });
      return;
    }

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur inconnue (user null).";
      });
      return;
    }

    // 2. Création du profil Firestore
    final profile = UserProfile(
      uid: user.uid,
      pseudo: pseudo,
    );
    await _firestoreService.saveUserProfile(profile);

    // 3. Redirection vers l'app principale
    if (mounted) {
      widget.onProfileCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bienvenue sur',
                  style: TextStyle(fontSize: 24, color: Colors.white70, fontWeight: FontWeight.w300),
                ).animate().fade(duration: 500.ms).slideY(begin: -0.2),
                const Text(
                  'SwingHop',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent,
                    letterSpacing: 1.5,
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: -0.2),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _pseudoController,
                        maxLength: 15,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Choisissez un pseudo',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          counterStyle: const TextStyle(color: Colors.white54),
                          errorText: _errorMessage,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.greenAccent)
                          : ElevatedButton(
                              onPressed: _submitProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                                shadowColor: Colors.greenAccent.withOpacity(0.5),
                              ),
                              child: const Text(
                                'C\'est parti !',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ).animate().fade(delay: 400.ms).scale(curve: Curves.easeOutBack),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
