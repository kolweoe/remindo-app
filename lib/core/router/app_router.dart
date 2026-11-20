import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';
import '../../screens/quests_screen.dart';
import '../../screens/timed_quest_screen.dart';
import '../../screens/wallet_screen.dart';
import '../../screens/add_transaction_screen.dart';
import '../../screens/savings_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/notification_settings_screen.dart';
import '../../screens/customize_screen.dart';
import '../../screens/room_upgrade_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String quests = '#quests';
  static const String timedQuest = '#timed-quest';
  static const String wallet = '#wallet';
  static const String addTransaction = '#add-transaction';
  static const String savings = '#savings';
  static const String settings = '#settings';
  static const String walletNotification = '#wallet-notification';
  static const String customize = '#customize';
  static const String roomUpgrade = '#room-upgrade';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
      case '#home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case quests:
        return MaterialPageRoute(builder: (_) => const QuestsScreen());
      case timedQuest:
        return MaterialPageRoute(builder: (_) => const TimedQuestScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen());
      case savings:
        return MaterialPageRoute(builder: (_) => const SavingsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case walletNotification:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      case customize:
        return MaterialPageRoute(builder: (_) => const CustomizeScreen());
      case roomUpgrade:
        return MaterialPageRoute(builder: (_) => const RoomUpgradeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
