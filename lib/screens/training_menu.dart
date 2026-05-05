import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pose_detector_screen.dart';

/// Écran d'accueil "Jouer" : affiche le titre et le bouton de démarrage.
class TrainingMenu extends StatelessWidget {
  final List<CameraDescription> cameras;
  const TrainingMenu({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'SwingHop',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () {
              final front = cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => cameras.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PoseDetectorScreen(camera: front),
                ),
              );
            },
            child: Container(
              height: 160,
              width: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.teal],
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 80,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
