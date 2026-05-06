import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'audio_haptic_service.dart';

// ─── Constantes de calibration ───────────────────────────────────────────────

/// Seuil minimum de montée (en pixels) pour déclencher la phase "en l'air".
/// Adaptatif : remplacé par 8% de la hauteur du buste si celui-ci est détecté.
const double kJumpUpThresholdMin = 12.0;

/// Fraction de la hauteur du buste utilisée comme seuil de montée adaptatif.
const double kJumpUpBustFraction = 0.08;

/// Seuil de retour au sol : le centre de gravité doit revenir à moins de X px
/// de la baseline pour valider la descente et comptabiliser le saut.
const double kJumpDownThreshold = 6.0;

/// Vitesse d'adaptation lente de la baseline (gelée pendant un saut).
const double kBaselineAlpha = 0.02;

/// Confiance minimale d'un point de pose pour être pris en compte.
const double kMinLandmarkConfidence = 0.5;

/// Durée minimale entre deux sauts consécutifs (anti-rebond / anti-double-comptage).
const Duration kJumpCooldown = Duration(milliseconds: 200);

// ─────────────────────────────────────────────────────────────────────────────

/// Détecte les sauts à partir d'une séquence de [Pose] retournées par ML Kit.
///
/// Améliorations v2 :
/// - Centre de gravité = moyenne pondérée de 4 points (hanches + épaules)
/// - Baseline gelée pendant la phase de vol pour éviter les dérives
/// - Seuil adaptatif basé sur la hauteur du buste détecté
/// - Cooldown 200 ms anti-double-comptage
class JumpDetector {
  double? _baseY;
  bool _isUp = false;
  int _jumps = 0;
  DateTime? _lastJumpTime;

  int get jumps => _jumps;

  // Exposé pour l'UI (indicateur de qualité)
  double? _lastCogY;
  double? _lastBustHeight;
  bool _lastPoseValid = false;

  double? get lastCogY => _lastCogY;
  bool get lastPoseValid => _lastPoseValid;

  /// Calcule le centre de gravité vertical à partir des landmarks disponibles.
  /// Pondère chaque point par sa confiance ML Kit.
  double? _computeCenterOfGravity(Pose pose) {
    final landmarks = [
      pose.landmarks[PoseLandmarkType.leftHip],
      pose.landmarks[PoseLandmarkType.rightHip],
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.rightShoulder],
    ];

    double weightedSum = 0;
    double totalWeight = 0;

    for (final lm in landmarks) {
      if (lm != null && lm.likelihood >= kMinLandmarkConfidence) {
        weightedSum += lm.y * lm.likelihood;
        totalWeight += lm.likelihood;
      }
    }

    if (totalWeight == 0) return null;
    return weightedSum / totalWeight;
  }

  /// Calcule la hauteur du buste (distance épaule → hanche) pour le seuil adaptatif.
  double? _computeBustHeight(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftHip == null || rightHip == null ||
        leftShoulder == null || rightShoulder == null) return null;

    final hipY = (leftHip.y + rightHip.y) / 2;
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final height = (hipY - shoulderY).abs();
    return height > 10 ? height : null; // Ignorer les valeurs aberrantes
  }

  /// Traite une [Pose] et retourne `true` si un nouveau saut vient d'être détecté.
  bool processPose(Pose pose) {
    final cogY = _computeCenterOfGravity(pose);
    _lastCogY = cogY;

    if (cogY == null) {
      _lastPoseValid = false;
      return false;
    }
    _lastPoseValid = true;

    // Seuil adaptatif selon la hauteur du buste
    final bustHeight = _computeBustHeight(pose);
    _lastBustHeight = bustHeight;
    final upThreshold = bustHeight != null
        ? (bustHeight * kJumpUpBustFraction).clamp(kJumpUpThresholdMin, 60.0)
        : kJumpUpThresholdMin;

    // Initialise la baseline au premier frame valide
    _baseY ??= cogY;

    // Phase montée : détecte la phase "en l'air"
    if (cogY < (_baseY! - upThreshold) && !_isUp) {
      _isUp = true;
      // Ne pas adapter la baseline pendant le vol
      return false;
    }

    // Phase descente : valide le saut au retour au sol
    if (_isUp && cogY > (_baseY! - kJumpDownThreshold)) {
      _isUp = false;

      // Cooldown anti-rebond
      final now = DateTime.now();
      if (_lastJumpTime == null ||
          now.difference(_lastJumpTime!) >= kJumpCooldown) {
        _lastJumpTime = now;
        _jumps++;

        // Mise à jour de la baseline après atterrissage
        _baseY = (_baseY! * (1 - kBaselineAlpha)) + (cogY * kBaselineAlpha);

        AudioHapticService().playJumpSound();
        AudioHapticService().playJumpHaptic();
        return true;
      }

      // Rebond trop rapide : saut ignoré mais baseline quand même mise à jour
      _baseY = (_baseY! * (1 - kBaselineAlpha)) + (cogY * kBaselineAlpha);
      return false;
    }

    // Adaptation continue de la baseline uniquement au sol
    if (!_isUp) {
      _baseY = (_baseY! * (1 - kBaselineAlpha)) + (cogY * kBaselineAlpha);
    }

    return false;
  }

  /// Remet le compteur et l'état à zéro.
  void reset() {
    _jumps = 0;
    _baseY = null;
    _isUp = false;
    _lastJumpTime = null;
    _lastCogY = null;
    _lastBustHeight = null;
    _lastPoseValid = false;
  }
}
