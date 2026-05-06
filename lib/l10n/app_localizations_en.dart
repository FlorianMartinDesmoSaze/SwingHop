// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'Training';

  @override
  String get navSocial => 'Community';

  @override
  String get navDuels => 'Duels';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsPseudo => 'Username';

  @override
  String get settingsUpdate => 'Update';

  @override
  String get settingsPseudoUpdated => 'Username updated!';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsSecureAccount => 'Secure Account';

  @override
  String get settingsSecureButton => 'Secure';

  @override
  String get settingsSecureDialogTitle => 'Secure Account';

  @override
  String get settingsSecureDialogBody =>
      'Link an email to never lose your progress.';

  @override
  String get settingsSecureDialogEmail => 'Email';

  @override
  String get settingsSecureDialogPassword => 'Password';

  @override
  String get settingsSecureDialogFillAll =>
      'Please fill in email and password.';

  @override
  String get settingsSecureSuccess => 'Account secured successfully!';

  @override
  String get settingsGuestAccount => 'Guest Account - Risk of loss';

  @override
  String settingsSecuredAccount(String email) {
    return 'Secured account ($email)';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsGame => 'Game';

  @override
  String get settingsSound => 'Sound Effects';

  @override
  String get settingsVibration => 'Haptic Vibrations';

  @override
  String get settingsDebug => 'Debug (Dev Only)';

  @override
  String get settingsMockData => 'Generate Mock Data';

  @override
  String get settingsMockSubtitle => 'Adds fake players and challenges';

  @override
  String get settingsInject => 'Inject';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profilePoints => 'Total Points';

  @override
  String get profileWins => 'Wins';

  @override
  String get profileLosses => 'Losses';

  @override
  String get profileHistory => 'RECENT MATCHES';

  @override
  String get profileNoHistory => 'No completed duels yet.';

  @override
  String get socialFriends => 'My Friends';

  @override
  String get socialSearchHint => 'Search friend by username...';

  @override
  String get socialNoFriends =>
      'No friends added yet.\nSearch for a username above!';

  @override
  String get socialChallenge => 'Challenge to duel';

  @override
  String get socialRemove => 'Remove friend';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo has been removed from your friends.';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return 'Challenge sent to $pseudo with $score jumps!';
  }

  @override
  String get duelTitle => 'Duel Arena';

  @override
  String get duelReceived => 'Challenge received!';

  @override
  String get duelPublic => 'Public Duels';

  @override
  String get duelDirect => 'Direct Challenges';

  @override
  String get duelJoin => 'Accept';

  @override
  String get duelWaiting => 'Your pending challenge';

  @override
  String get duelNoPending =>
      'No pending challenges.\nBe the first to launch one!';

  @override
  String duelLaunched(int score) {
    return 'Challenge launched with $score jumps!';
  }

  @override
  String get duelWon => 'You won the duel! (+50 pts)';

  @override
  String get duelLost => 'You lost the duel... (+10 pts)';

  @override
  String duelDirectFrom(String pseudo) {
    return 'DIRECT CHALLENGE FROM $pseudo!';
  }

  @override
  String duelScoreToBeat(int score) {
    return 'Score to beat: $score jumps';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return 'Challenge from $pseudo';
  }

  @override
  String get trainingFreeMode => 'FREE MODE';

  @override
  String get trainingFreeDesc => 'Jump without time limit';

  @override
  String get trainingChallengeMode => 'CHALLENGE MODE';

  @override
  String get trainingChallengeDesc => 'Max jumps in 30 seconds';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get duelStart => 'Start a Challenge';

  @override
  String get commonSee => 'SEE';
}
