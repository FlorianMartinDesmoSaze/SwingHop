// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'Allenamento';

  @override
  String get navSocial => 'Comunità';

  @override
  String get navDuels => 'Duelli';

  @override
  String get navProfile => 'Profilo';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsProfile => 'Profilo';

  @override
  String get settingsPseudo => 'Nickname';

  @override
  String get settingsUpdate => 'Aggiorna';

  @override
  String get settingsPseudoUpdated => 'Nickname aggiornato!';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsSecureAccount => 'Proteggi account';

  @override
  String get settingsSecureButton => 'Proteggi';

  @override
  String get settingsSecureDialogTitle => 'Proteggi account';

  @override
  String get settingsSecureDialogBody =>
      'Collega un\'email per non perdere mai i tuoi progressi.';

  @override
  String get settingsSecureDialogEmail => 'Email';

  @override
  String get settingsSecureDialogPassword => 'Password';

  @override
  String get settingsSecureDialogFillAll => 'Compila email e password.';

  @override
  String get settingsSecureSuccess => 'Account protetto con successo!';

  @override
  String get settingsGuestAccount => 'Account Ospite - Rischio perdita dati';

  @override
  String settingsSecuredAccount(String email) {
    return 'Account protetto ($email)';
  }

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsGame => 'Gioco';

  @override
  String get settingsSound => 'Effetti sonori';

  @override
  String get settingsVibration => 'Vibrazione aptica';

  @override
  String get settingsDebug => 'Debug (Dev Only)';

  @override
  String get settingsMockData => 'Genera dati di test';

  @override
  String get settingsMockSubtitle => 'Aggiunge finti giocatori e sfide';

  @override
  String get settingsInject => 'Inietta';

  @override
  String get profileTitle => 'Il Mio Profilo';

  @override
  String get profilePoints => 'Punti Totali';

  @override
  String get profileWins => 'Vittorie';

  @override
  String get profileLosses => 'Sconfitte';

  @override
  String get profileHistory => 'ULTIME PARTITE';

  @override
  String get profileNoHistory => 'Ancora nessun duello completato.';

  @override
  String get socialFriends => 'I Miei Amici';

  @override
  String get socialSearchHint => 'Cerca amico per nickname...';

  @override
  String get socialNoFriends =>
      'Non hai ancora aggiunto amici.\nCerca un nickname in alto!';

  @override
  String get socialChallenge => 'Sfida a duello';

  @override
  String get socialRemove => 'Rimuovi dagli amici';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo è stato rimosso dai tuoi amici.';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return 'Sfida inviata a $pseudo con $score salti!';
  }

  @override
  String get duelTitle => 'Arena dei Duelli';

  @override
  String get duelReceived => 'Sfida ricevuta!';

  @override
  String get duelPublic => 'Duelli Pubblici';

  @override
  String get duelDirect => 'Sfide Dirette';

  @override
  String get duelJoin => 'Accetta';

  @override
  String get duelWaiting => 'La tua sfida in attesa';

  @override
  String get duelNoPending =>
      'Nessuna sfida in attesa.\nSii il primo a lanciarne una!';

  @override
  String duelLaunched(int score) {
    return 'Sfida lanciata con $score salti!';
  }

  @override
  String get duelWon => 'Hai vinto il duello! (+50 pts)';

  @override
  String get duelLost => 'Hai perso il duello... (+10 pts)';

  @override
  String duelDirectFrom(String pseudo) {
    return 'SFIDA DIRETTA DA $pseudo!';
  }

  @override
  String duelScoreToBeat(int score) {
    return 'Punteggio da battere: $score salti';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return 'Sfida di $pseudo';
  }

  @override
  String get trainingFreeMode => 'MODALITÀ LIBERA';

  @override
  String get trainingFreeDesc => 'Salta senza limiti di tempo';

  @override
  String get trainingChallengeMode => 'MODALITÀ SFIDA';

  @override
  String get trainingChallengeDesc => 'Massimo salti in 30 secondi';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonError => 'Errore';

  @override
  String get commonSuccess => 'Successo';

  @override
  String get duelStart => 'Inizia una sfida';

  @override
  String get commonSee => 'VEDI';
}
