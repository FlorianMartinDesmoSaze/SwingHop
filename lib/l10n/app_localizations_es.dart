// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'Entrenamiento';

  @override
  String get navSocial => 'Comunidad';

  @override
  String get navDuels => 'Duelos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsPseudo => 'Apodo';

  @override
  String get settingsUpdate => 'Actualizar';

  @override
  String get settingsPseudoUpdated => '¡Apodo actualizado!';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsSecureAccount => 'Asegurar cuenta';

  @override
  String get settingsSecureButton => 'Asegurar';

  @override
  String get settingsSecureDialogTitle => 'Asegurar cuenta';

  @override
  String get settingsSecureDialogBody =>
      'Vincula un email para no perder nunca tu progreso.';

  @override
  String get settingsSecureDialogEmail => 'Email';

  @override
  String get settingsSecureDialogPassword => 'Contraseña';

  @override
  String get settingsSecureDialogFillAll =>
      'Por favor rellena el email y la contraseña.';

  @override
  String get settingsSecureSuccess => '¡Cuenta asegurada con éxito!';

  @override
  String get settingsGuestAccount => 'Cuenta de invitado - Riesgo de pérdida';

  @override
  String settingsSecuredAccount(String email) {
    return 'Cuenta segura ($email)';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsGame => 'Juego';

  @override
  String get settingsSound => 'Efectos de sonido';

  @override
  String get settingsVibration => 'Vibración háptica';

  @override
  String get settingsDebug => 'Debug (Dev Only)';

  @override
  String get settingsMockData => 'Generar datos falsos';

  @override
  String get settingsMockSubtitle => 'Añade jugadores y desafíos falsos';

  @override
  String get settingsInject => 'Inyectar';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profilePoints => 'Puntos Totales';

  @override
  String get profileWins => 'Victorias';

  @override
  String get profileLosses => 'Derrotas';

  @override
  String get profileHistory => 'ÚLTIMOS PARTIDOS';

  @override
  String get profileNoHistory => 'Aún no hay duelos completados.';

  @override
  String get socialFriends => 'Mis Amigos';

  @override
  String get socialSearchHint => 'Buscar amigo por apodo...';

  @override
  String get socialNoFriends =>
      'Aún no has añadido amigos.\n¡Busca un apodo arriba!';

  @override
  String get socialChallenge => 'Desafiar a duelo';

  @override
  String get socialRemove => 'Eliminar de amigos';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo ha sido eliminado de tus amigos.';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return '¡Desafío enviado a $pseudo con $score saltos!';
  }

  @override
  String get duelTitle => 'Arena de Duelos';

  @override
  String get duelReceived => '¡Desafío recibido!';

  @override
  String get duelPublic => 'Duelos Públicos';

  @override
  String get duelDirect => 'Desafíos Directos';

  @override
  String get duelJoin => 'Aceptar';

  @override
  String get duelWaiting => 'Tu desafío pendiente';

  @override
  String get duelNoPending =>
      'No hay desafíos pendientes.\n¡Sé el primero en lanzar uno!';

  @override
  String duelLaunched(int score) {
    return '¡Desafío lanzado con $score saltos!';
  }

  @override
  String get duelWon => '¡Ganaste el duelo! (+50 pts)';

  @override
  String get duelLost => 'Perdiste el duelo... (+10 pts)';

  @override
  String duelDirectFrom(String pseudo) {
    return '¡DESAFÍO DIRECTO DE $pseudo!';
  }

  @override
  String duelScoreToBeat(int score) {
    return 'Puntuación a batir: $score saltos';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return 'Desafío de $pseudo';
  }

  @override
  String get trainingFreeMode => 'MODO LIBRE';

  @override
  String get trainingFreeDesc => 'Salta sin límite de tiempo';

  @override
  String get trainingChallengeMode => 'MODO DESAFÍO';

  @override
  String get trainingChallengeDesc => 'Máximos saltos en 30 segundos';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Éxito';

  @override
  String get duelStart => 'Iniciar desafío';

  @override
  String get commonSee => 'VER';
}
