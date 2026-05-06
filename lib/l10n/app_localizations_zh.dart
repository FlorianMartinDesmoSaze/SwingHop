// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SwingHop';

  @override
  String get navTraining => '训练';

  @override
  String get navSocial => '社区';

  @override
  String get navDuels => '对决';

  @override
  String get navProfile => '个人资料';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsProfile => '个人资料';

  @override
  String get settingsPseudo => '昵称';

  @override
  String get settingsUpdate => '更新';

  @override
  String get settingsPseudoUpdated => '昵称已更新！';

  @override
  String get settingsAccount => '账户';

  @override
  String get settingsSecureAccount => '保护账户';

  @override
  String get settingsSecureButton => '保护';

  @override
  String get settingsSecureDialogTitle => '保护账户';

  @override
  String get settingsSecureDialogBody => '绑定邮箱，永不丢失进度。';

  @override
  String get settingsSecureDialogEmail => '邮箱';

  @override
  String get settingsSecureDialogPassword => '密码';

  @override
  String get settingsSecureDialogFillAll => '请填写邮箱和密码。';

  @override
  String get settingsSecureSuccess => '账户保护成功！';

  @override
  String get settingsGuestAccount => '访客账户 - 有丢失风险';

  @override
  String settingsSecuredAccount(String email) {
    return '已保护账户 ($email)';
  }

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsGame => '游戏';

  @override
  String get settingsSound => '音效';

  @override
  String get settingsVibration => '触觉反馈';

  @override
  String get settingsDebug => '调试 (Dev Only)';

  @override
  String get settingsMockData => '生成测试数据';

  @override
  String get settingsMockSubtitle => '添加虚假玩家和对决';

  @override
  String get settingsInject => '注入';

  @override
  String get profileTitle => '我的资料';

  @override
  String get profilePoints => '总积分';

  @override
  String get profileWins => '胜场';

  @override
  String get profileLosses => '败场';

  @override
  String get profileHistory => '最近比赛';

  @override
  String get profileNoHistory => '目前没有已完成的对决。';

  @override
  String get socialFriends => '我的好友';

  @override
  String get socialSearchHint => '通过昵称搜索好友...';

  @override
  String get socialNoFriends => '你还没有添加好友。\n在上方搜索昵称吧！';

  @override
  String get socialChallenge => '发起对决';

  @override
  String get socialRemove => '删除好友';

  @override
  String socialFriendRemoved(String pseudo) {
    return '$pseudo 已从您的好友列表中删除。';
  }

  @override
  String socialChallengesSent(String pseudo, int score) {
    return '已向 $pseudo 发送 $score 次跳跃的挑战！';
  }

  @override
  String get duelTitle => '对决竞技场';

  @override
  String get duelReceived => '收到挑战！';

  @override
  String get duelPublic => '公开对决';

  @override
  String get duelDirect => '直接挑战';

  @override
  String get duelJoin => '接受';

  @override
  String get duelWaiting => '你待处理的挑战';

  @override
  String get duelNoPending => '没有待处理的挑战。\n成为第一个发起挑战的人！';

  @override
  String duelLaunched(int score) {
    return '已发起 $score 次跳跃的挑战！';
  }

  @override
  String get duelWon => '你赢得了对决！(+50 pts)';

  @override
  String get duelLost => '你输掉了对决... (+10 pts)';

  @override
  String duelDirectFrom(String pseudo) {
    return '来自 $pseudo 的直接挑战！';
  }

  @override
  String duelScoreToBeat(int score) {
    return '待打破的分数：$score 次跳跃';
  }

  @override
  String duelChallengeFrom(String pseudo) {
    return '$pseudo 的挑战';
  }

  @override
  String get trainingFreeMode => '自由模式';

  @override
  String get trainingFreeDesc => '无时间限制跳跃';

  @override
  String get trainingChallengeMode => '挑战模式';

  @override
  String get trainingChallengeDesc => '30秒内挑战最高次数';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonError => '错误';

  @override
  String get commonSuccess => '成功';

  @override
  String get duelStart => '发起挑战';

  @override
  String get commonSee => '查看';
}
