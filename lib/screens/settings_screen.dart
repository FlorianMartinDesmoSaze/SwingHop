import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/audio_haptic_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  bool _soundEnabled = false;
  bool _vibrationEnabled = false;
  
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLinking = false;
  bool _isUpdatingPseudo = false;
  String _currentPseudo = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadPreferences();
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (mounted && profile != null) {
        setState(() {
          _currentPseudo = profile.pseudo;
          _pseudoController.text = _currentPseudo;
        });
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _soundEnabled = prefs.getBool('soundEnabled') ?? false;
        _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? false;
      });
    }
  }

  Future<void> _toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    setState(() => _soundEnabled = value);
    await AudioHapticService().reloadPrefs();
  }

  Future<void> _toggleVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
    setState(() => _vibrationEnabled = value);
    await AudioHapticService().reloadPrefs();
    if (value) AudioHapticService().playClickHaptic();
  }

  Future<void> _updatePseudo() async {
    final newPseudo = _pseudoController.text.trim();
    if (newPseudo.isEmpty || newPseudo == _currentPseudo) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isUpdatingPseudo = true);
    await _firestoreService.updatePseudo(user.uid, newPseudo);
    
    if (mounted) {
      setState(() {
        _isUpdatingPseudo = false;
        _currentPseudo = newPseudo;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pseudo mis à jour !'), backgroundColor: Colors.greenAccent)
      );
    }
  }

  Future<void> _linkAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir email et mot de passe.'), backgroundColor: Colors.redAccent)
      );
      return;
    }

    setState(() => _isLinking = true);
    try {
      await _authService.linkWithEmailAndPassword(email, password);
      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte sécurisé avec succès !'), backgroundColor: Colors.greenAccent)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }

  void _showLinkAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sécuriser le compte', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Associez un email pour ne jamais perdre votre progression.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email', 
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Mot de passe', 
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: _isLinking ? null : _linkAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent, 
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLinking ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black)) : const Text('Sauvegarder', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Profil').animate().fade().slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pseudoController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Pseudo',
                      labelStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isUpdatingPseudo ? null : _updatePseudo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isUpdatingPseudo 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Mettre à jour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ).animate().fade(delay: 100.ms).slideY(),
          
          const SizedBox(height: 40),
          _buildSectionTitle('Compte').animate().fade(delay: 200.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sécuriser le compte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                isAnonymous ? 'Compte Invité - Risque de perte' : 'Compte sécurisé (${user?.email})',
                style: TextStyle(color: isAnonymous ? Colors.redAccent : Colors.white54),
              ),
              trailing: isAnonymous 
                ? ElevatedButton(
                    onPressed: _showLinkAccountDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sécuriser', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : const Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
            ),
          ).animate().fade(delay: 300.ms).slideY(),

          const SizedBox(height: 40),
          _buildSectionTitle('Jeu').animate().fade(delay: 400.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Effets sonores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                  activeThumbColor: Colors.greenAccent,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: Colors.white10),
                SwitchListTile(
                  title: const Text('Vibrations haptiques', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  value: _vibrationEnabled,
                  onChanged: _toggleVibration,
                  activeThumbColor: Colors.greenAccent,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ).animate().fade(delay: 500.ms).slideY(),

          const SizedBox(height: 40),
          _buildSectionTitle('Debug (Dev Only)').animate().fade(delay: 600.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Générer Fausses Données', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Ajoute des faux joueurs et défis', style: TextStyle(color: Colors.white54)),
              trailing: ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    await _firestoreService.generateMockData(user.uid);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Données générées avec succès !'), backgroundColor: Colors.greenAccent)
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent, 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Injecter', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ).animate().fade(delay: 700.ms).slideY(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
