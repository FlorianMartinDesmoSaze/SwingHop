// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'Тренировка';

  @override
  String get navSocial => 'Сообщество';

  @override
  String get navDuels => 'Дуэли';

  @override
  String get navProfile => 'Профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsProfile => 'Профиль';

  @override
  String get settingsPseudo => 'Никнейм';

  @override
  String get settingsUpdate => 'Обновить';

  @override
  String get settingsPseudoUpdated => 'Никнейм обновлён!';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsSecureAccount => 'Защитить аккаунт';

  @override
  String get settingsSecureButton => 'Защитить';

  @override
  String get settingsSecureDialogTitle => 'Защитить аккаунт';

  @override
  String get settingsSecureDialogBody =>
      'Привяжите email, чтобы никогда не потерять прогресс.';

  @override
  String get settingsSecureDialogEmail => 'Email';

  @override
  String get settingsSecureDialogPassword => 'Пароль';

  @override
  String get settingsSecureDialogFillAll =>
      'Пожалуйста, заполните email и пароль.';

  @override
  String get settingsSecureSuccess => 'Аккаунт успешно защищен!';

  @override
  String get settingsGuestAccount => 'Гостевой аккаунт - риск потери данных';

  @override
  String settingsSecuredAccount(String email) {
    return 'Аккаунт защищён ($email)';
  }

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsGame => 'Игра';

  @override
  String get settingsSound => 'Звуковые эффекты';

  @override
  String get settingsVibration => 'Виброотклик';

  @override
  String get settingsDebug => 'Отладка (Dev Only)';

  @override
  String get settingsMockData => 'Генерация тестовых данных';

  @override
  String get settingsMockSubtitle => 'Добавляет фейковых игроков и дуэли';

  @override
  String get settingsInject => 'Вставить';

  @override
  String get profileTitle => 'Мой профиль';

  @override
  String get profilePoints => 'Всего очков';

  @override
  String get profileWins => 'Победы';

  @override
  String get profileLosses => 'Поражения';

  @override
  String get profileHistory => 'ПОСЛЕДНИЕ МАТЧИ';

  @override
  String get profileNoHistory => 'Завершенных дуэлей пока нет.';

  @override
  String get socialFriends => 'Мои друзья';

  @override
  String get socialSearchHint => 'Поиск друга по никнейму...';

  @override
  String get socialNoFriends =>
      'Вы еще не добавили друзей.\nПоищите никнейм выше!';

  @override
  String get socialChallenge => 'Вызвать на дуэль';

  @override
  String get socialRemove => 'Удалить из друзей';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo удалён из ваших друзей.';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return 'Вызов отправлен $pseudo с результатом $score прыжков!';
  }

  @override
  String get duelTitle => 'Арена дуэлей';

  @override
  String get duelReceived => 'Получен вызов!';

  @override
  String get duelPublic => 'Публичные дуэли';

  @override
  String get duelDirect => 'Прямые вызовы';

  @override
  String get duelJoin => 'Принять';

  @override
  String get duelWaiting => 'Ваш ожидающий вызов';

  @override
  String get duelNoPending => 'Нет ожидающих вызовов.\nБудьте первым!';

  @override
  String duelLaunched(int score) {
    return 'Вызов брошен с $score прыжками!';
  }

  @override
  String get duelWon => 'Вы выиграли дуэль! (+50 очков)';

  @override
  String get duelLost => 'Вы проиграли дуэль... (+10 очков)';

  @override
  String duelDirectFrom(String pseudo) {
    return 'ПРЯМОЙ ВЫЗОВ ОТ $pseudo!';
  }

  @override
  String duelScoreToBeat(int score) {
    return 'Счет для победы: $score прыжков';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return 'Вызов от $pseudo';
  }

  @override
  String get trainingFreeMode => 'СВОБОДНЫЙ РЕЖИМ';

  @override
  String get trainingFreeDesc => 'Прыгайте без ограничения времени';

  @override
  String get trainingChallengeMode => 'РЕЖИМ ВЫЗОВА';

  @override
  String get trainingChallengeDesc => 'Макс. прыжков за 30 секунд';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonError => 'Ошибка';

  @override
  String get commonSuccess => 'Успех';

  @override
  String get duelStart => 'Бросить вызов';

  @override
  String get commonSee => 'СМОТРЕТЬ';
}
