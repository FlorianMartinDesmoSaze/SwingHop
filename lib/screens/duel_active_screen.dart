import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/jump_detector.dart';
import '../widgets/pose_painter.dart';

/// Écran d'un Duel Actif : chronométré (ex: 30s)
class DuelActiveScreen extends StatefulWidget {
  final CameraDescription camera;
  final int timeLimitSeconds;

  const DuelActiveScreen({
    super.key, 
    required this.camera, 
    this.timeLimitSeconds = 30,
  });

  @override
  State<DuelActiveScreen> createState() => _DuelActiveScreenState();
}

class _DuelActiveScreenState extends State<DuelActiveScreen> {
  CameraController? _controller;
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  final JumpDetector _jumpDetector = JumpDetector();

  List<Pose> _poses = [];
  bool _isBusy = false;
  
  int _timeRemaining = 0;
  int _prepTime = 10;
  Timer? _timer;
  bool _isPrepPhase = true;
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.timeLimitSeconds;
    _startCam();
  }

  Future<void> _startCam() async {
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
    if (mounted) {
      setState(() {});
      _startPrepTimer();
    }
  }

  void _startPrepTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_prepTime > 1) {
          _prepTime--;
        } else {
          _timer?.cancel();
          _isPrepPhase = false;
          _startGameTimer();
        }
      });
    });
  }

  void _startGameTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _finishDuel();
        }
      });
    });
  }

  void _finishDuel() {
    _timer?.cancel();
    _hasFinished = true;
    
    // On renvoie le score à l'écran précédent
    Navigator.pop(context, _jumpDetector.jumps);
  }

  void _processImage(CameraImage image) async {
    if (_isBusy || _hasFinished) return;
    _isBusy = true;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
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
          // On ne compte les sauts que si la préparation est finie
          if (!_isPrepPhase && _jumpDetector.processPose(pose)) {
            setState(() {}); 
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

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
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
                const SizedBox(height: 10),
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: _timeRemaining <= 5 && !_isPrepPhase ? Colors.red.withValues(alpha: 0.8) : Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _isPrepPhase ? 'PRÉPARATION' : '00:${_timeRemaining.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: _isPrepPhase ? 24 : 32, 
                      fontWeight: FontWeight.bold, 
                      color: _isPrepPhase ? Colors.orangeAccent : Colors.white
                    ),
                  ),
                ),
                
                if (_isPrepPhase) ...[
                  const Spacer(),
                  const Text('Placez-vous !', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                  Text(
                    '$_prepTime',
                    style: const TextStyle(
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      shadows: [Shadow(color: Colors.black, blurRadius: 20)],
                    ),
                  ),
                  const Spacer(),
                ] else ...[
                  const SizedBox(height: 20),
                  // Score
                  Text(
                    '${_jumpDetector.jumps}',
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
