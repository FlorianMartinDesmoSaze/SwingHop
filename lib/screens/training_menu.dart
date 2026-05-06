import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pose_detector_screen.dart';
import '../l10n/app_localizations.dart';

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
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ).animate().fade(duration: 500.ms).slideY(begin: -0.2),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.trainingFreeMode,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
              letterSpacing: 4,
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: -0.2),
          const SizedBox(height: 60),
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
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 100,
                color: Colors.black,
              ),
            ),
          ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}
