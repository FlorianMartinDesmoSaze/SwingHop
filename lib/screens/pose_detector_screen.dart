import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/jump_detector.dart';
import '../widgets/pose_painter.dart';

/// Écran principal de détection de pose et comptage de sauts en temps réel.
class PoseDetectorScreen extends StatefulWidget {
  final CameraDescription camera;
  const PoseDetectorScreen({super.key, required this.camera});

  @override
  State<PoseDetectorScreen> createState() => _PoseDetectorScreenState();
}

class _PoseDetectorScreenState extends State<PoseDetectorScreen> {
  CameraController? _controller;
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  final JumpDetector _jumpDetector = JumpDetector();

  List<Pose> _poses = [];
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _startCam();
  }

  Future<void> _startCam() async {
    // Résolution basse pour maximiser la vitesse de traitement ML Kit
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();
    _controller!.startImageStream(_processImage);
    if (mounted) setState(() {});
  }

  void _processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      // Si les points ne s'affichent pas correctement, tester rotation90deg
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
        for (final pose in poses) {
          if (_jumpDetector.processPose(pose)) {
            setState(() {}); // Met à jour le compteur à chaque nouveau saut
          }
        }
        setState(() => _poses = poses);
      }
    } catch (e) {
      debugPrint('PoseDetector error: $e');
    } finally {
      _isBusy = false;
    }
  }

  void _reset() {
    _jumpDetector.reset();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_poses.isNotEmpty)
            CustomPaint(
              painter: PosePainter(
                _poses,
                _controller!.value.previewSize!,
                size,
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  '${_jumpDetector.jumps}',
                  style: const TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        heroTag: 'btn_close',
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: Colors.white24,
                        child: const Icon(Icons.close),
                      ),
                      FloatingActionButton(
                        heroTag: 'btn_reset',
                        onPressed: _reset,
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
