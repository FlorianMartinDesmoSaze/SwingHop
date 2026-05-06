import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'SwingHop'**
  String get appTitle;

  /// No description provided for @navTraining.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement'**
  String get navTraining;

  /// No description provided for @navSocial.
  ///
  /// In fr, this message translates to:
  /// **'Communauté'**
  String get navSocial;

  /// No description provided for @navDuels.
  ///
  /// In fr, this message translates to:
  /// **'Duels'**
  String get navDuels;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsPseudo.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get settingsPseudo;

  /// No description provided for @settingsUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get settingsUpdate;

  /// No description provided for @settingsPseudoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo mis à jour !'**
  String get settingsPseudoUpdated;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @settingsSecureAccount.
  ///
  /// In fr, this message translates to:
  /// **'Sécuriser le compte'**
  String get settingsSecureAccount;

  /// No description provided for @settingsSecureButton.
  ///
  /// In fr, this message translates to:
  /// **'Sécuriser'**
  String get settingsSecureButton;

  /// No description provided for @settingsSecureDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sécuriser le compte'**
  String get settingsSecureDialogTitle;

  /// No description provided for @settingsSecureDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'Associez un email pour ne jamais perdre votre progression.'**
  String get settingsSecureDialogBody;

  /// No description provided for @settingsSecureDialogEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get settingsSecureDialogEmail;

  /// No description provided for @settingsSecureDialogPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get settingsSecureDialogPassword;

  /// No description provided for @settingsSecureDialogFillAll.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir email et mot de passe.'**
  String get settingsSecureDialogFillAll;

  /// No description provided for @settingsSecureSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Compte sécurisé avec succès !'**
  String get settingsSecureSuccess;

  /// No description provided for @settingsGuestAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte Invité - Risque de perte'**
  String get settingsGuestAccount;

  /// No description provided for @settingsSecuredAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte sécurisé ({email})'**
  String settingsSecuredAccount(String email);

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsGame.
  ///
  /// In fr, this message translates to:
  /// **'Jeu'**
  String get settingsGame;

  /// No description provided for @settingsSound.
  ///
  /// In fr, this message translates to:
  /// **'Effets sonores'**
  String get settingsSound;

  /// No description provided for @settingsVibration.
  ///
  /// In fr, this message translates to:
  /// **'Vibrations haptiques'**
  String get settingsVibration;

  /// No description provided for @settingsDebug.
  ///
  /// In fr, this message translates to:
  /// **'Debug (Dev Only)'**
  String get settingsDebug;

  /// No description provided for @settingsMockData.
  ///
  /// In fr, this message translates to:
  /// **'Générer Fausses Données'**
  String get settingsMockData;

  /// No description provided for @settingsMockSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute des faux joueurs et défis'**
  String get settingsMockSubtitle;

  /// No description provided for @settingsInject.
  ///
  /// In fr, this message translates to:
  /// **'Injecter'**
  String get settingsInject;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileTitle;

  /// No description provided for @profilePoints.
  ///
  /// In fr, this message translates to:
  /// **'Points Totaux'**
  String get profilePoints;

  /// No description provided for @profileWins.
  ///
  /// In fr, this message translates to:
  /// **'Victoires'**
  String get profileWins;

  /// No description provided for @profileLosses.
  ///
  /// In fr, this message translates to:
  /// **'Défaites'**
  String get profileLosses;

  /// No description provided for @profileHistory.
  ///
  /// In fr, this message translates to:
  /// **'DERNIERS MATCHS'**
  String get profileHistory;

  /// No description provided for @profileNoHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun duel terminé pour le moment.'**
  String get profileNoHistory;

  /// No description provided for @socialFriends.
  ///
  /// In fr, this message translates to:
  /// **'Mes Amis'**
  String get socialFriends;

  /// No description provided for @socialSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Chercher un ami par pseudo...'**
  String get socialSearchHint;

  /// No description provided for @socialNoFriends.
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'as pas encore ajouté d\'amis.\nCherche un pseudo en haut !'**
  String get socialNoFriends;

  /// No description provided for @socialChallenge.
  ///
  /// In fr, this message translates to:
  /// **'Provoquer en duel'**
  String get socialChallenge;

  /// No description provided for @socialRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des amis'**
  String get socialRemove;

  /// No description provided for @socialFriendRemoved.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} a été retiré(e) de vos amis.'**
  String socialFriendRemoved(String pseudo);

  /// No description provided for @socialChallengesSent.
  ///
  /// In fr, this message translates to:
  /// **'Défi envoyé à {pseudo} avec {score} sauts !'**
  String socialChallengesSent(String pseudo, int score);

  /// No description provided for @duelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Arène des Duels'**
  String get duelTitle;

  /// No description provided for @duelReceived.
  ///
  /// In fr, this message translates to:
  /// **'Défi reçu !'**
  String get duelReceived;

  /// No description provided for @duelPublic.
  ///
  /// In fr, this message translates to:
  /// **'Duels Publics'**
  String get duelPublic;

  /// No description provided for @duelDirect.
  ///
  /// In fr, this message translates to:
  /// **'Défis Directs'**
  String get duelDirect;

  /// No description provided for @duelJoin.
  ///
  /// In fr, this message translates to:
  /// **'Relever'**
  String get duelJoin;

  /// No description provided for @duelWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Ton défi en attente'**
  String get duelWaiting;

  /// No description provided for @duelNoPending.
  ///
  /// In fr, this message translates to:
  /// **'Aucun défi en attente.\nSois le premier à en lancer un !'**
  String get duelNoPending;

  /// No description provided for @duelLaunched.
  ///
  /// In fr, this message translates to:
  /// **'Défi lancé avec {score} sauts !'**
  String duelLaunched(int score);

  /// No description provided for @duelWon.
  ///
  /// In fr, this message translates to:
  /// **'Tu as gagné le duel ! (+50 pts)'**
  String get duelWon;

  /// No description provided for @duelLost.
  ///
  /// In fr, this message translates to:
  /// **'Tu as perdu le duel... (+10 pts)'**
  String get duelLost;

  /// No description provided for @duelDirectFrom.
  ///
  /// In fr, this message translates to:
  /// **'DÉFI DIRECT DE {pseudo} !'**
  String duelDirectFrom(String pseudo);

  /// No description provided for @duelScoreToBeat.
  ///
  /// In fr, this message translates to:
  /// **'Score à battre : {score} sauts'**
  String duelScoreToBeat(int score);

  /// No description provided for @duelChallengeFrom.
  ///
  /// In fr, this message translates to:
  /// **'Défi de {pseudo}'**
  String duelChallengeFrom(String pseudo);

  /// No description provided for @trainingFreeMode.
  ///
  /// In fr, this message translates to:
  /// **'MODE LIBRE'**
  String get trainingFreeMode;

  /// No description provided for @trainingFreeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Saute sans limite de temps'**
  String get trainingFreeDesc;

  /// No description provided for @trainingChallengeMode.
  ///
  /// In fr, this message translates to:
  /// **'MODE DÉFI'**
  String get trainingChallengeMode;

  /// No description provided for @trainingChallengeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Fais le maximum en 30 secondes'**
  String get trainingChallengeDesc;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get commonSave;

  /// No description provided for @commonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get commonSuccess;

  /// No description provided for @duelStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer un défi'**
  String get duelStart;

  /// No description provided for @commonSee.
  ///
  /// In fr, this message translates to:
  /// **'VOIR'**
  String get commonSee;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
