import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase avec les options générées par flutterfire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final cameras = await availableCameras();
  runApp(SwingHopApp(cameras: cameras));
}