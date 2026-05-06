import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'leaderboard_screen.dart';
import 'friends_tab.dart';

class SocialScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const SocialScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Communauté', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            indicatorWeight: 4,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.public), text: 'Global'),
              Tab(icon: Icon(Icons.people), text: 'Mes Amis'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet 1 : Le classement global existant
            const LeaderboardScreen(isTab: true),
            // Onglet 2 : La nouvelle liste d'amis
            FriendsTab(cameras: cameras),
          ],
        ),
      ),
    );
  }
}
