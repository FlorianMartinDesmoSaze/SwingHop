// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'Training';

  @override
  String get navSocial => 'Gemeinschaft';

  @override
  String get navDuels => 'Duelle';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsPseudo => 'Benutzername';

  @override
  String get settingsUpdate => 'Aktualisieren';

  @override
  String get settingsPseudoUpdated => 'Benutzername aktualisiert!';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsSecureAccount => 'Konto sichern';

  @override
  String get settingsSecureButton => 'Sichern';

  @override
  String get settingsSecureDialogTitle => 'Konto sichern';

  @override
  String get settingsSecureDialogBody =>
      'Verknüpfe eine E-Mail, um deinen Fortschritt nie zu verlieren.';

  @override
  String get settingsSecureDialogEmail => 'E-Mail';

  @override
  String get settingsSecureDialogPassword => 'Passwort';

  @override
  String get settingsSecureDialogFillAll =>
      'Bitte fülle E-Mail und Passwort aus.';

  @override
  String get settingsSecureSuccess => 'Konto erfolgreich gesichert!';

  @override
  String get settingsGuestAccount => 'Gastkonto - Risiko des Verlusts';

  @override
  String settingsSecuredAccount(String email) {
    return 'Gesichertes Konto ($email)';
  }

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsGame => 'Spiel';

  @override
  String get settingsSound => 'Soundeffekte';

  @override
  String get settingsVibration => 'Haptisches Feedback';

  @override
  String get settingsDebug => 'Debug (Dev Only)';

  @override
  String get settingsMockData => 'Testdaten generieren';

  @override
  String get settingsMockSubtitle => 'Fügt falsche Spieler und Duelle hinzu';

  @override
  String get settingsInject => 'Injizieren';

  @override
  String get profileTitle => 'Mein Profil';

  @override
  String get profilePoints => 'Gesamtpunkte';

  @override
  String get profileWins => 'Siege';

  @override
  String get profileLosses => 'Niederlagen';

  @override
  String get profileHistory => 'LETZTE MATCHES';

  @override
  String get profileNoHistory => 'Noch keine abgeschlossenen Duelle.';

  @override
  String get socialFriends => 'Meine Freunde';

  @override
  String get socialSearchHint => 'Freund suchen...';

  @override
  String get socialNoFriends =>
      'Noch keine Freunde hinzugefügt.\nSuche oben nach einem Namen!';

  @override
  String get socialChallenge => 'Zum Duell fordern';

  @override
  String get socialRemove => 'Freund entfernen';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo wurde aus deinen Freunden entfernt.';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return 'Herausforderung an $pseudo mit $score Sprüngen gesendet!';
  }

  @override
  String get duelTitle => 'Duell-Arena';

  @override
  String get duelReceived => 'Herausforderung erhalten!';

  @override
  String get duelPublic => 'Öffentliche Duelle';

  @override
  String get duelDirect => 'Direkte Herausforderungen';

  @override
  String get duelJoin => 'Annehmen';

  @override
  String get duelWaiting => 'Deine ausstehende Herausforderung';

  @override
  String get duelNoPending =>
      'Keine ausstehenden Herausforderungen.\nSei der Erste, der eine startet!';

  @override
  String duelLaunched(int score) {
    return 'Herausforderung mit $score Sprüngen gestartet!';
  }

  @override
  String get duelWon => 'Du hast das Duell gewonnen! (+50 Pkt)';

  @override
  String get duelLost => 'Du hast das Duell verloren... (+10 Pkt)';

  @override
  String duelDirectFrom(String pseudo) {
    return 'DIREKTE HERAUSFORDERUNG VON $pseudo!';
  }

  @override
  String duelScoreToBeat(int score) {
    return 'Zu schlagender Score: $score Sprünge';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return 'Herausforderung von $pseudo';
  }

  @override
  String get trainingFreeMode => 'FREIER MODUS';

  @override
  String get trainingFreeDesc => 'Springen ohne Zeitlimit';

  @override
  String get trainingChallengeMode => 'CHALLENGE-MODUS';

  @override
  String get trainingChallengeDesc => 'Max. Sprünge in 30 Sekunden';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonError => 'Fehler';

  @override
  String get commonSuccess => 'Erfolg';

  @override
  String get duelStart => 'Herausforderung starten';

  @override
  String get commonSee => 'SEHEN';
}
