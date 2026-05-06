import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/audio_haptic_service.dart';
import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final LocaleProvider localeProvider;
  const SettingsScreen({super.key, required this.localeProvider});

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
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsPseudoUpdated), backgroundColor: Colors.greenAccent)
      );
    }
  }

  Future<void> _linkAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsSecureDialogFillAll), backgroundColor: Colors.redAccent)
      );
      return;
    }

    setState(() => _isLinking = true);
    try {
      await _authService.linkWithEmailAndPassword(email, password);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsSecureSuccess), backgroundColor: Colors.greenAccent)
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.settingsSecureDialogTitle, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.settingsSecureDialogBody, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.settingsSecureDialogEmail,
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
                labelText: l10n.settingsSecureDialogPassword,
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
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: _isLinking ? null : _linkAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLinking
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black))
                : Text(l10n.commonSave, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final l10n = AppLocalizations.of(context)!;
    final user = _authService.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle(l10n.settingsProfile).animate().fade().slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pseudoController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: l10n.settingsPseudo,
                      labelStyle: const TextStyle(color: Colors.white54),
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
                    : Text(l10n.settingsUpdate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ).animate().fade(delay: 100.ms).slideY(),
          
          const SizedBox(height: 40),
          _buildSectionTitle(l10n.settingsAccount).animate().fade(delay: 200.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsSecureAccount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                isAnonymous ? l10n.settingsGuestAccount : l10n.settingsSecuredAccount(user?.email ?? ''),
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
                    child: Text(l10n.settingsSecureButton, style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                : const Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
            ),
          ).animate().fade(delay: 300.ms).slideY(),

          const SizedBox(height: 40),
          _buildSectionTitle(l10n.settingsLanguage).animate().fade(delay: 350.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: widget.localeProvider.locale ?? const Locale('fr'),
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: Locale('fr'), child: Text('🇫🇷 Français', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('en'), child: Text('🇬🇧 English', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('es'), child: Text('🇪🇸 Español', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('de'), child: Text('🇩🇪 Deutsch', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('it'), child: Text('🇮🇹 Italiano', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('ru'), child: Text('🇷🇺 Русский', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('zh'), child: Text('🇨🇳 中文', style: TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: Locale('ja'), child: Text('🇯🇵 日本語', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    widget.localeProvider.setLocale(newLocale);
                  }
                },
              ),
            ),
          ).animate().fade(delay: 380.ms).slideY(),

          const SizedBox(height: 40),
          _buildSectionTitle(l10n.settingsGame).animate().fade(delay: 400.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.settingsSound, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                  activeThumbColor: Colors.greenAccent,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: Colors.white10),
                SwitchListTile(
                  title: Text(l10n.settingsVibration, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  value: _vibrationEnabled,
                  onChanged: _toggleVibration,
                  activeThumbColor: Colors.greenAccent,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ).animate().fade(delay: 500.ms).slideY(),

          const SizedBox(height: 40),
          _buildSectionTitle(l10n.settingsDebug).animate().fade(delay: 600.ms).slideX(),
          const SizedBox(height: 10),
          _buildGlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsMockData, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.settingsMockSubtitle, style: const TextStyle(color: Colors.white54)),
              trailing: ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    await _firestoreService.generateMockData(user.uid);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.commonSuccess), backgroundColor: Colors.greenAccent)
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent, 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.settingsInject, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
