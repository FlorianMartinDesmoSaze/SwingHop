import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/training_menu.dart';

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
      ),
      home: MainNavigation(cameras: cameras),
    );
  }
}

/// Navigation principale avec BottomNavigationBar (Profil / Jouer / Scores).
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Jouer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Scores'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Profil — bientôt disponible'));
      case 1:
        return TrainingMenu(cameras: widget.cameras);
      case 2:
        return const Center(child: Text('Scores — bientôt disponible'));
      default:
        return const SizedBox.shrink();
    }
  }
}
