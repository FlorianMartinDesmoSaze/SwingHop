import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(SwingHopApp(cameras: cameras));
}

class SwingHopApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const SwingHopApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.greenAccent),
      home: MainNavigation(cameras: cameras),
    );
  }
}

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
      body: _selectedIndex == 1 
          ? TrainingMenu(cameras: widget.cameras) 
          : Center(child: Text(_selectedIndex == 0 ? "Profil" : "Scores")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.greenAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Jouer'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Scores'),
        ],
      ),
    );
  }
}

class TrainingMenu extends StatelessWidget {
  final List<CameraDescription> cameras;
  const TrainingMenu({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("SwingHop", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () {
              final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
              Navigator.push(context, MaterialPageRoute(builder: (context) => PoseDetectorView(camera: front)));
            },
            child: Container(
              height: 160, width: 160,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.greenAccent, Colors.teal])),
              child: const Icon(Icons.play_arrow_rounded, size: 80, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class PoseDetectorView extends StatefulWidget {
  final CameraDescription camera;
  const PoseDetectorView({super.key, required this.camera});
  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  CameraController? _controller;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  List<Pose> _poses = [];
  bool _isBusy = false;
  int _jumps = 0;
  bool _isUp = false;
  double? _baseY;

  @override
  void initState() {
    super.initState();
    _startCam();
  }

  Future<void> _startCam() async {
    // Utilisation d'une résolution basse pour booster la vitesse de l'IA
    _controller = CameraController(widget.camera, ResolutionPreset.low, enableAudio: false, imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888);
    
    await _controller!.initialize();
    _controller!.startImageStream(_processImage);
    if (mounted) setState(() {});
  }

  void _processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      // TEST : Si les points n'apparaissent pas, change rotation270deg en rotation90deg
      rotation: InputImageRotation.rotation270deg, 
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: metadata,
    );

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (mounted) {
        if (poses.isNotEmpty) _processJump(poses.first);
        setState(() => _poses = poses);
      }
    } catch (e) {
      debugPrint("IA Error: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _processJump(Pose pose) {
    // On cible la hanche pour le saut
    final hip = pose.landmarks[PoseLandmarkType.leftHip] ?? pose.landmarks[PoseLandmarkType.rightHip];
    if (hip != null) {
      _baseY ??= hip.y;
      _baseY = (_baseY! * 0.95) + (hip.y * 0.05);

      // Si le corps monte (Y diminue)
      if (hip.y < (_baseY! - 20) && !_isUp) {
        _isUp = true;
      } else if (hip.y > (_baseY! - 5) && _isUp) {
        _isUp = false;
        setState(() => _jumps++);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    // Calcul du ratio pour que les points tombent pile sur la vidéo
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_poses.isNotEmpty)
            CustomPaint(painter: PosePainter(_poses, _controller!.value.previewSize!, size)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text("$_jumps", style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: Colors.white24,
                        child: const Icon(Icons.close),
                      ),
                      FloatingActionButton(
                        onPressed: () => setState(() { _jumps = 0; _baseY = null; }),
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize; // Taille du flux caméra
  final Size widgetSize; // Taille de l'écran

  PosePainter(this.poses, this.imageSize, this.widgetSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent..strokeWidth = 4;

    for (var pose in poses) {
      // Sur Android en portrait, largeur et hauteur sont inversées dans le flux
      final double scaleX = widgetSize.width / imageSize.height;
      final double scaleY = widgetSize.height / imageSize.width;

      pose.landmarks.forEach((_, point) {
        // Inversion horizontale pour l'effet miroir de la caméra frontale
        canvas.drawCircle(
          Offset(widgetSize.width - (point.x * scaleX), point.y * scaleY),
          5,
          paint,
        );
      });
    }
  }

  @override
  bool shouldRepaint(PosePainter old) => true;
}