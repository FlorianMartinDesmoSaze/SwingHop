import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
  runApp(MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: PoseDetectorScreen(camera: front)));
}

class PoseDetectorScreen extends StatefulWidget {
  final CameraDescription camera;
  const PoseDetectorScreen({super.key, required this.camera});
  @override
  State<PoseDetectorScreen> createState() => _PoseDetectorScreenState();
}

class _PoseDetectorScreenState extends State<PoseDetectorScreen> {
  CameraController? _controller;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  List<Pose> _poses = [];
  bool _isBusy = false;

  // LOGIQUE DU SAUT OPTIMISÉE
  int _jumpCount = 0;
  bool _isUp = false;
  double? _baselineY; 
  final double _threshold = 20.0; // Seuil réduit pour détecter de petits sauts

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // On utilise ResolutionPreset.low pour booster la vitesse de l'IA
    _controller = CameraController(widget.camera, ResolutionPreset.low, enableAudio: false, imageFormatGroup: ImageFormatGroup.nv21);
    await _controller!.initialize();
    
    // On démarre le flux d'images en direct (bien plus rapide que takePicture)
    _controller!.startImageStream((CameraImage image) {
      if (_isBusy) return;
      _processCameraImage(image);
    });

    if (mounted) setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    setState(() => _isBusy = true);

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      setState(() => _isBusy = false);
      return;
    }

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (mounted && poses.isNotEmpty) {
        _analyzeJump(poses.first);
        setState(() => _poses = poses);
      }
    } catch (e) {
      print("Erreur IA: $e");
    }

    setState(() => _isBusy = false);
  }

  void _analyzeJump(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftHip != null && rightHip != null) {
      double currentY = (leftHip.y + rightHip.y) / 2;
      
      // On stabilise la ligne de base (moyenne glissante simple)
      if (_baselineY == null) {
        _baselineY = currentY;
      } else {
        // On réajuste doucement la base pour s'adapter si tu te déplaces
        _baselineY = (_baselineY! * 0.95) + (currentY * 0.05);
      }

      // Détection de la montée (Y diminue quand on monte)
      if (currentY < (_baselineY! - _threshold) && !_isUp) {
        _isUp = true;
      } 
      // Détection de la descente
      else if (currentY > (_baselineY! - 5) && _isUp) {
        setState(() {
          _isUp = false;
          _jumpCount++;
        });
      }
    }
  }

  // Helper indispensable pour convertir le flux d'images mobile vers l'IA
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = widget.camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotations = {
        0: InputImageRotation.rotation0deg,
        90: InputImageRotation.rotation90deg,
        180: InputImageRotation.rotation180deg,
        270: InputImageRotation.rotation270deg,
      };
      rotation = rotations[sensorOrientation];
    }
    
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.length != 1) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_poses.isNotEmpty)
            CustomPaint(painter: PosePainter(_poses, _controller!.value.previewSize!)),
          
          Positioned(
            top: 60, left: 0, right: 0,
            child: Column(
              children: [
                Text("$_jumpCount", style: const TextStyle(fontSize: 120, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                const Text("SAUTS DETECTÉS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
          ),
          
          if (_isUp)
            Center(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, size: 100, color: Colors.white))),

          Positioned(
            bottom: 40, right: 20,
            child: FloatingActionButton(
              onPressed: () => setState(() { _jumpCount = 0; _baselineY = null; }),
              child: const Icon(Icons.refresh),
            ),
          )
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size previewSize;
  PosePainter(this.poses, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent..strokeWidth = 4..style = PaintingStyle.fill;
    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        final double x = size.width - (landmark.x * size.width / previewSize.height);
        final double y = landmark.y * size.height / previewSize.width;
        canvas.drawCircle(Offset(x, y), 4, paint);
      });
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Petit fix pour le format d'image Android
class Platform {
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
}