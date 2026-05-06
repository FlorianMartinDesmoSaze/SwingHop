// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'Entraînement';

  @override
  String get navSocial => 'Communauté';

  @override
  String get navDuels => 'Duels';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsPseudo => 'Pseudo';

  @override
  String get settingsUpdate => 'Mettre à jour';

  @override
  String get settingsPseudoUpdated => 'Pseudo mis à jour !';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsSecureAccount => 'Sécuriser le compte';

  @override
  String get settingsSecureButton => 'Sécuriser';

  @override
  String get settingsSecureDialogTitle => 'Sécuriser le compte';

  @override
  String get settingsSecureDialogBody =>
      'Associez un email pour ne jamais perdre votre progression.';

  @override
  String get settingsSecureDialogEmail => 'Email';

  @override
  String get settingsSecureDialogPassword => 'Mot de passe';

  @override
  String get settingsSecureDialogFillAll =>
      'Veuillez remplir email et mot de passe.';

  @override
  String get settingsSecureSuccess => 'Compte sécurisé avec succès !';

  @override
  String get settingsGuestAccount => 'Compte Invité - Risque de perte';

  @override
  String settingsSecuredAccount(String email) {
    return 'Compte sécurisé ($email)';
  }

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsGame => 'Jeu';

  @override
  String get settingsSound => 'Effets sonores';

  @override
  String get settingsVibration => 'Vibrations haptiques';

  @override
  String get settingsDebug => 'Debug (Dev Only)';

  @override
  String get settingsMockData => 'Générer Fausses Données';

  @override
  String get settingsMockSubtitle => 'Ajoute des faux joueurs et défis';

  @override
  String get settingsInject => 'Injecter';

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get profilePoints => 'Points Totaux';

  @override
  String get profileWins => 'Victoires';

  @override
  String get profileLosses => 'Défaites';

  @override
  String get profileHistory => 'DERNIERS MATCHS';

  @override
  String get profileNoHistory => 'Aucun duel terminé pour le moment.';

  @override
  String get socialFriends => 'Mes Amis';

  @override
  String get socialSearchHint => 'Chercher un ami par pseudo...';

  @override
  String get socialNoFriends =>
      'Tu n\'as pas encore ajouté d\'amis.\nCherche un pseudo en haut !';

  @override
  String get socialChallenge => 'Provoquer en duel';

  @override
  String get socialRemove => 'Retirer des amis';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo a été retiré(e) de vos amis.';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return 'Défi envoyé à $pseudo avec $score sauts !';
  }

  @override
  String get duelTitle => 'Arène des Duels';

  @override
  String get duelReceived => 'Défi reçu !';

  @override
  String get duelPublic => 'Duels Publics';

  @override
  String get duelDirect => 'Défis Directs';

  @override
  String get duelJoin => 'Relever';

  @override
  String get duelWaiting => 'Ton défi en attente';

  @override
  String get duelNoPending =>
      'Aucun défi en attente.\nSois le premier à en lancer un !';

  @override
  String duelLaunched(int score) {
    return 'Défi lancé avec $score sauts !';
  }

  @override
  String get duelWon => 'Tu as gagné le duel ! (+50 pts)';

  @override
  String get duelLost => 'Tu as perdu le duel... (+10 pts)';

  @override
  String duelDirectFrom(String pseudo) {
    return 'DÉFI DIRECT DE $pseudo !';
  }

  @override
  String duelScoreToBeat(int score) {
    return 'Score à battre : $score sauts';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return 'Défi de $pseudo';
  }

  @override
  String get trainingFreeMode => 'MODE LIBRE';

  @override
  String get trainingFreeDesc => 'Saute sans limite de temps';

  @override
  String get trainingChallengeMode => 'MODE DÉFI';

  @override
  String get trainingChallengeDesc => 'Fais le maximum en 30 secondes';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Sauvegarder';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get duelStart => 'Lancer un défi';

  @override
  String get commonSee => 'VOIR';
}
