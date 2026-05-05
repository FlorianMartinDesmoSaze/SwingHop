import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Paires de landmarks reliés pour former le squelette
const List<(PoseLandmarkType, PoseLandmarkType)> kBoneConnections = [
  // Torse
  (PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder),
  (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
  (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
  (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),
  // Bras gauche
  (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
  (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
  // Bras droit
  (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
  (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
  // Jambe gauche
  (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
  (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
  // Jambe droite
  (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
  (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
  // Visage
  (PoseLandmarkType.leftEar, PoseLandmarkType.leftEye),
  (PoseLandmarkType.rightEar, PoseLandmarkType.rightEye),
  (PoseLandmarkType.leftEye, PoseLandmarkType.nose),
  (PoseLandmarkType.rightEye, PoseLandmarkType.nose),
];

/// Affiche le squelette (points + os) par-dessus le flux caméra.
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize; // Taille du flux caméra
  final Size widgetSize; // Taille de l'écran

  PosePainter(this.poses, this.imageSize, this.widgetSize);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    final bonePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final pose in poses) {
      // Sur Android en portrait, largeur et hauteur sont inversées dans le flux
      final double scaleX = widgetSize.width / imageSize.height;
      final double scaleY = widgetSize.height / imageSize.width;

      Offset toOffset(PoseLandmark point) => Offset(
            widgetSize.width - (point.x * scaleX), // miroir horizontal
            point.y * scaleY,
          );

      // Dessine les os (connexions)
      for (final (typeA, typeB) in kBoneConnections) {
        final a = pose.landmarks[typeA];
        final b = pose.landmarks[typeB];
        if (a != null && b != null) {
          canvas.drawLine(toOffset(a), toOffset(b), bonePaint);
        }
      }

      // Dessine les points
      for (final point in pose.landmarks.values) {
        canvas.drawCircle(toOffset(point), 5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(PosePainter old) =>
      old.poses != poses ||
      old.imageSize != imageSize ||
      old.widgetSize != widgetSize;
}
