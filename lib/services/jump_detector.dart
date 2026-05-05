import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'audio_haptic_service.dart';

/// Seuil de montée : le corps doit monter de X pixels pour déclencher _isUp
const double kJumpUpThreshold = 20.0;

/// Seuil de descente : le corps doit revenir à moins de X pixels de la baseline
const double kJumpDownThreshold = 5.0;

/// Vitesse d'adaptation de la baseline (moyenne exponentielle)
const double kBaselineAlpha = 0.05;

/// Service responsable de détecter les sauts à partir des poses ML Kit.
class JumpDetector {
  double? _baseY;
  bool _isUp = false;
  int _jumps = 0;

  int get jumps => _jumps;

  /// Traite une [Pose] et retourne true si un nouveau saut vient d'être détecté.
  bool processPose(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip] ??
        pose.landmarks[PoseLandmarkType.rightHip];

    if (hip == null) return false;

    // Initialise ou adapte la baseline de façon exponentielle
    _baseY ??= hip.y;
    _baseY = (_baseY! * (1 - kBaselineAlpha)) + (hip.y * kBaselineAlpha);

    // Phase montée
    if (hip.y < (_baseY! - kJumpUpThreshold) && !_isUp) {
      _isUp = true;
    }
    // Phase descente → saut comptabilisé
    else if (hip.y > (_baseY! - kJumpDownThreshold) && _isUp) {
      _isUp = false;
      _jumps++;
      
      // Joue le son et la vibration
      AudioHapticService().playJumpSound();
      AudioHapticService().playJumpHaptic();
      
      return true; // Nouveau saut détecté
    }

    return false;
  }

  /// Remet le compteur et l'état à zéro.
  void reset() {
    _jumps = 0;
    _baseY = null;
    _isUp = false; // Correction du bug : _isUp était oublié au reset
  }
}
