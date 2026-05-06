import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_profile.dart';
import '../models/duel_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'duel_active_screen.dart';
import 'public_profile_screen.dart';
import '../l10n/app_localizations.dart';

class FriendsTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FriendsTab({super.key, required this.cameras});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _searchController = TextEditingController();

  List<UserProfile> _friends = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final user = _authService.currentUser;
    if (user != null) {
      final friends = await _firestoreService.getFriendsProfiles(user.uid);
      if (mounted) {
        setState(() {
          _friends = friends;
          // Trier par points (décroissant)
          _friends.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addFriend() async {
    final pseudo = _searchController.text.trim();
    if (pseudo.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isAdding = true);

    final resultMsg = await _firestoreService.addFriendByPseudo(user.uid, pseudo);

    if (mounted) {
      setState(() => _isAdding = false);
      _searchController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: resultMsg.contains('succès') ? Colors.greenAccent : Colors.redAccent,
        )
      );
      
      if (resultMsg.contains('succès')) {
        setState(() => _isLoading = true);
        await _loadFriends();
      }
    }
  }

  Future<void> _removeFriend(UserProfile friend) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _firestoreService.removeFriend(user.uid, friend.uid);
    setState(() {
      _friends.removeWhere((f) => f.uid == friend.uid);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.socialFriendRemoved(friend.pseudo),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        )
      );
    }
  }

  Future<void> _challengeFriend(UserProfile friend) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final currentUserProfile = await _firestoreService.getUserProfile(user.uid);
    if (currentUserProfile == null) return;

    final frontCamera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    if (!mounted) return;

    // Lancer le duel
    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => DuelActiveScreen(camera: frontCamera, timeLimitSeconds: 30),
      ),
    );

    if (score == null) return; // Annulé

    // Enregistrer le défi direct
    final duel = DuelRecord(
      creatorUid: currentUserProfile.uid,
      creatorPseudo: currentUserProfile.pseudo,
      creatorScore: score,
      targetUid: friend.uid,
    );

    await _firestoreService.createDuel(duel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.socialChallengesSent(friend.pseudo, score),
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.redAccent,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    return Column(
      children: [
        // Zone de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Autocomplete<UserProfile>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.trim().isEmpty) {
                      return const Iterable<UserProfile>.empty();
                    }
                    return await _firestoreService.searchUsersByPrefix(textEditingValue.text);
                  },
                  displayStringForOption: (UserProfile option) => option.pseudo,
                  onSelected: (UserProfile selection) {
                    _searchController.text = selection.pseudo;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    // Synchronisation avec le contrôleur global
                    controller.addListener(() {
                      _searchController.text = controller.text;
                    });
                    
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.socialSearchHint,
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addFriend(),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 96, // Largeur adaptée au champ
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.greenAccent.withAlpha(50)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10, offset: const Offset(0, 5))
                            ]
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                leading: Text(option.rank.emoji, style: const TextStyle(fontSize: 20)),
                                title: Text(option.pseudo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text('${option.totalPoints} pts', style: const TextStyle(color: Colors.white54)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.greenAccent.withAlpha(50), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                child: IconButton(
                  onPressed: _isAdding ? null : _addFriend,
                  icon: _isAdding 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.person_add, color: Colors.black),
                ),
              ),
            ],
          ).animate().fade().slideY(begin: -0.2),
        ),

        // Liste des amis
        Expanded(
          child: _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_off, size: 80, color: Colors.white24),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.socialNoFriends,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ).animate().fade(duration: 600.ms).scale(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublicProfileScreen(
                              player: friend,
                              cameras: widget.cameras,
                            ),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.greenAccent.withAlpha(50),
                          child: Text(friend.rank.emoji, style: const TextStyle(fontSize: 20)),
                        ),
                        title: Text(
                          friend.pseudo,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                        ),
                        subtitle: Text(
                          '${friend.totalPoints} pts • Ratio: ${friend.duelWins}V / ${friend.duelLosses}D',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Text('⚔️', style: TextStyle(fontSize: 24)),
                              tooltip: AppLocalizations.of(context)!.socialChallenge,
                              onPressed: () => _challengeFriend(friend),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove, color: Colors.white54),
                              tooltip: AppLocalizations.of(context)!.socialRemove,
                              onPressed: () => _removeFriend(friend),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
                  },
                ),
        ),
      ],
    );
  }
}
