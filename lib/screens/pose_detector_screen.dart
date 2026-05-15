import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/jump_detector.dart';
import '../models/session_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/positioning_guide.dart';

enum SessionState { positioning, countdown, active }

/// Écran principal de détection de pose et comptage de sauts en temps réel.
class PoseDetectorScreen extends StatefulWidget {
  final CameraDescription camera;
  const PoseDetectorScreen({super.key, required this.camera});

  @override
  State<PoseDetectorScreen> createState() => _PoseDetectorScreenState();
}

class _PoseDetectorScreenState extends State<PoseDetectorScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  final JumpDetector _jumpDetector = JumpDetector();
  
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isBusy = false;
  bool _isSaving = false;

  // État de la session
  SessionState _sessionState = SessionState.positioning;
  bool _isWellPositioned = false;
  int _countdownValue = 3;
  Timer? _countdownTimer;

  // Animation pour le feedback de saut
  late AnimationController _jumpAnimController;

  @override
  void initState() {
    super.initState();
    _jumpAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    if (mounted) setState(() {});
  }

  bool _checkPositioning(Pose pose) {
    // Vérifier la présence et la confiance des épaules et hanches
    final landmarks = [
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.rightShoulder],
      pose.landmarks[PoseLandmarkType.leftHip],
      pose.landmarks[PoseLandmarkType.rightHip],
    ];

    for (var lm in landmarks) {
      if (lm == null || lm.likelihood < 0.6) return false;
    }
    return true;
  }

  void _startCountdown() {
    setState(() {
      _sessionState = SessionState.countdown;
      _countdownValue = 3;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!_isWellPositioned) {
        // L'utilisateur a bougé pendant le compte à rebours !
        timer.cancel();
        setState(() {
          _sessionState = SessionState.positioning;
        });
        return;
      }

      setState(() {
        if (_countdownValue > 1) {
          _countdownValue--;
        } else {
          timer.cancel();
          _sessionState = SessionState.active;
        }
      });
    });
  }

  void _processImage(CameraImage image) async {
    if (_isBusy || _isSaving) return;
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
      if (!mounted) return;

      if (poses.isNotEmpty) {
        final pose = poses.first; // Ne prendre que la première personne

        if (_sessionState == SessionState.positioning || _sessionState == SessionState.countdown) {
          final isPositionedNow = _checkPositioning(pose);
          
          if (isPositionedNow != _isWellPositioned) {
            setState(() {
              _isWellPositioned = isPositionedNow;
            });

            if (_isWellPositioned && _sessionState == SessionState.positioning) {
              _startCountdown();
            }
          }
        } else if (_sessionState == SessionState.active) {
          // Pendant l'exercice, on délègue au JumpDetector
          if (_jumpDetector.processPose(pose)) {
            setState(() {}); 
            _jumpAnimController.forward(from: 0.0); // Feedback visuel (Flash/Scale)
          }
        }
      } else {
        // Personne à l'écran
        if (_sessionState != SessionState.active && _isWellPositioned) {
          setState(() {
            _isWellPositioned = false;
          });
        }
      }
    } catch (e) {
      debugPrint('PoseDetector error: $e');
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _saveCurrentSession() async {
    final jumps = _jumpDetector.jumps;
    if (jumps == 0) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    
    final record = SessionRecord(
      date: DateTime.now(),
      jumps: jumps,
      pointsEarned: jumps,
      isDuel: false,
    );

    await _firestoreService.saveSession(user.uid, record);
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session sauvegardée : +$jumps points !', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.greenAccent,
          duration: const Duration(seconds: 2),
        )
      );
    }
  }

  void _reset() async {
    await _saveCurrentSession();
    _jumpDetector.reset();
    _countdownTimer?.cancel();
    if (mounted) {
      setState(() {
        _sessionState = SessionState.positioning;
        _isWellPositioned = false;
      });
    }
  }

  void _close() async {
    await _saveCurrentSession();
    _countdownTimer?.cancel();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _jumpAnimController.dispose();
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          
          // Flash vert lors d'un saut validé
          if (_sessionState == SessionState.active)
            AnimatedBuilder(
              animation: _jumpAnimController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: _jumpAnimController.value),
                      width: 15 * _jumpAnimController.value,
                    ),
                  ),
                );
              },
            ),

          // Mannequin de positionnement
          if (_sessionState != SessionState.active)
            PositioningGuide(isWellPositioned: _isWellPositioned),

          // Compte à rebours
          if (_sessionState == SessionState.countdown)
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_countdownValue',
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),

          // UI Principale
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Affichage du compteur seulement en mode Actif
                if (_sessionState == SessionState.active)
                  AnimatedBuilder(
                    animation: _jumpAnimController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_jumpAnimController.value * 0.2),
                        child: Text(
                          '${_jumpDetector.jumps}',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Color.lerp(Colors.white, Colors.greenAccent, _jumpAnimController.value),
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Placez-vous dans le cadre',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
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
                        onPressed: _isSaving ? null : _close,
                        backgroundColor: Colors.white24,
                        child: _isSaving 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Icon(Icons.close, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'btn_reset',
                        onPressed: _isSaving ? null : _reset,
                        backgroundColor: Colors.redAccent,
                        child: _isSaving 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Icon(Icons.refresh, color: Colors.white),
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
