import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bienvenue sur',
                style: TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const Text(
                'SwingHop',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _pseudoController,
                maxLength: 15,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Choisissez un pseudo',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterStyle: const TextStyle(color: Colors.white54),
                  errorText: _errorMessage,
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.greenAccent)
                  : ElevatedButton(
                      onPressed: _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'C\'est parti !',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
