import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'screens/training_menu.dart';
import 'screens/profile_screen.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/social_screen.dart';
import 'screens/duel_menu_screen.dart';
import 'screens/settings_screen.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'models/duel_record.dart';

import 'package:google_fonts/google_fonts.dart';

/// Widget racine de l'application SwingHop.
class SwingHopApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const SwingHopApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwingHop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.greenAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.amberAccent,
          surface: Color(0xFF1E293B), // Slate 800
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F172A),
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
      ),
      home: AuthWrapper(cameras: cameras),
    );
  }
}

/// Gère l'affichage entre l'onboarding (Setup) et l'app principale.
class AuthWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;
  const AuthWrapper({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return MainNavigation(cameras: cameras);
        }

        return SetupProfileScreen(
          onProfileCreated: () {},
        );
      },
    );
  }
}

/// Navigation principale avec BottomNavigationBar.
class MainNavigation extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainNavigation({super.key, required this.cameras});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;

  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  StreamSubscription<List<DuelRecord>>? _challengeSubscription;
  final Set<String> _notifiedChallengeIds = {};

  @override
  void initState() {
    super.initState();
    _startChallengeListener();
  }

  void _startChallengeListener() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _challengeSubscription = _firestoreService
        .watchIncomingDirectChallenges(uid)
        .listen((challenges) {
      for (final challenge in challenges) {
        if (challenge.id != null && !_notifiedChallengeIds.contains(challenge.id)) {
          _notifiedChallengeIds.add(challenge.id!);
          _showChallengeBanner(challenge);
        }
      }
    });
  }

  void _showChallengeBanner(DuelRecord challenge) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Text('⚔️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Défi reçu !',
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  Text(
                    '${challenge.creatorPseudo} te provoque avec ${challenge.creatorScore} sauts — à toi de jouer !',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                setState(() => _selectedIndex = 2); // Aller à l'onglet Duels
              },
              child: const Text('VOIR', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _challengeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.greenAccent,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Libre'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Duels'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Communauté'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Réglages'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ProfileScreen();
      case 1:
        return TrainingMenu(cameras: widget.cameras);
      case 2:
        return DuelMenuScreen(cameras: widget.cameras);
      case 3:
        return SocialScreen(cameras: widget.cameras);
      case 4:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
