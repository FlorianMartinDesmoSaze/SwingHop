import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/training_menu.dart';
import 'screens/profile_screen.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/duel_menu_screen.dart';

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
        colorScheme: const ColorScheme.dark(primary: Colors.greenAccent),
        scaffoldBackgroundColor: Colors.black,
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
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Classement'),
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
        return const LeaderboardScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
