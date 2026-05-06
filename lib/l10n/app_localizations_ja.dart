// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => 'トレーニング';

  @override
  String get navSocial => 'コミュニティ';

  @override
  String get navDuels => 'デュエル';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsProfile => 'プロフィール';

  @override
  String get settingsPseudo => 'ユーザー名';

  @override
  String get settingsUpdate => '更新';

  @override
  String get settingsPseudoUpdated => 'ユーザー名を更新しました！';

  @override
  String get settingsAccount => 'アカウント';

  @override
  String get settingsSecureAccount => 'アカウントの保護';

  @override
  String get settingsSecureButton => '保護する';

  @override
  String get settingsSecureDialogTitle => 'アカウントの保護';

  @override
  String get settingsSecureDialogBody => 'メールアドレスを登録して進捗を失わないようにしましょう。';

  @override
  String get settingsSecureDialogEmail => 'メールアドレス';

  @override
  String get settingsSecureDialogPassword => 'パスワード';

  @override
  String get settingsSecureDialogFillAll => 'メールアドレスとパスワードを入力してください。';

  @override
  String get settingsSecureSuccess => 'アカウントが保護されました！';

  @override
  String get settingsGuestAccount => 'ゲストアカウント - 紛失の恐れあり';

  @override
  String settingsSecuredAccount(String email) {
    return '保護済みアカウント ($email)';
  }

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsGame => 'ゲーム';

  @override
  String get settingsSound => '効果音';

  @override
  String get settingsVibration => '触覚フィードバック';

  @override
  String get settingsDebug => 'デバッグ (Dev Only)';

  @override
  String get settingsMockData => 'テストデータの生成';

  @override
  String get settingsMockSubtitle => '架空のプレイヤーとデュエルを追加';

  @override
  String get settingsInject => '注入';

  @override
  String get profileTitle => 'マイプロフィール';

  @override
  String get profilePoints => '合計ポイント';

  @override
  String get profileWins => '勝利数';

  @override
  String get profileLosses => '敗北数';

  @override
  String get profileHistory => '最近の対戦';

  @override
  String get profileNoHistory => '完了したデュエルはありません。';

  @override
  String get socialFriends => 'フレンド';

  @override
  String get socialSearchHint => 'ユーザー名で検索...';

  @override
  String get socialNoFriends => 'フレンドがまだいません。\n上のユーザー名で検索しましょう！';

  @override
  String get socialChallenge => 'デュエルを申し込む';

  @override
  String get socialRemove => 'フレンドから削除';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo をフレンドから削除しました。';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return '$pseudo に $score 回のチャレンジを送信しました！';
  }

  @override
  String get duelTitle => 'デュエルアリーナ';

  @override
  String get duelReceived => 'チャレンジを受け取りました！';

  @override
  String get duelPublic => 'パブリックデュエル';

  @override
  String get duelDirect => 'ダイレクトチャレンジ';

  @override
  String get duelJoin => '受ける';

  @override
  String get duelWaiting => '待機中のチャレンジ';

  @override
  String get duelNoPending => '待機中のチャレンジはありません。\n最初に始めましょう！';

  @override
  String duelLaunched(int score) {
    return '$score 回のチャレンジを開始しました！';
  }

  @override
  String get duelWon => 'デュエルに勝ちました！(+50 pts)';

  @override
  String get duelLost => 'デュエルに負けました... (+10 pts)';

  @override
  String duelDirectFrom(String pseudo) {
    return '$pseudo からのダイレクトチャレンジ！';
  }

  @override
  String duelScoreToBeat(int score) {
    return '目標スコア：$score 回';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return '$pseudo のチャレンジ';
  }

  @override
  String get trainingFreeMode => 'フリーモード';

  @override
  String get trainingFreeDesc => '時間制限なしでジャンプ';

  @override
  String get trainingChallengeMode => 'チャレンジモード';

  @override
  String get trainingChallengeDesc => '30秒間で最高回数に挑戦';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonError => 'エラー';

  @override
  String get commonSuccess => '成功';

  @override
  String get duelStart => 'チャレンジ開始';

  @override
  String get commonSee => '見る';
}
