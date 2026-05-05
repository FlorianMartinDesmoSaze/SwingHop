import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioHapticService {
  static final AudioHapticService _instance = AudioHapticService._internal();
  factory AudioHapticService() => _instance;

  AudioHapticService._internal();

  // final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _soundEnabled = false;
  bool _vibrationEnabled = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? false;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? false;
    _initialized = true;
  }

  /// Recharge les préférences (utile quand l'utilisateur change les options)
  Future<void> reloadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? false;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? false;
  }

  /// Joue un retour haptique (vibration) lors d'un saut
  void playJumpHaptic() {
    if (_vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Joue un retour haptique léger (pour les UI)
  void playClickHaptic() {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Joue un son de saut (nécessite d'avoir assets/sounds/jump.mp3, par défaut utilise le système)
  Future<void> playJumpSound() async {
    if (_soundEnabled) {
      try {
        // En attendant d'avoir un vrai fichier audio jump.mp3 dans les assets :
        SystemSound.play(SystemSoundType.click);
        // Décommenter quand le fichier sera ajouté :
        // await _audioPlayer.play(AssetSource('sounds/jump.mp3'));
      } catch (e) {
        // Ignorer l'erreur si le fichier n'existe pas
      }
    }
  }

  /// Joue un son de victoire
  Future<void> playWinSound() async {
    if (_soundEnabled) {
      try {
        // await _audioPlayer.play(AssetSource('sounds/win.mp3'));
      } catch (e) {
        // Ignorer
      }
    }
  }
}
