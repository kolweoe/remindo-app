import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../../models/quest.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/add_quest_screen.dart';
import '../../screens/quest_history_screen.dart';
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

/// AppGate checks SQLite `hero_profile` on cold start:
/// - If profile is missing -> displays OnboardingScreen
/// - If profile exists -> displays HomeScreen
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfileAsync = ref.watch(hasHeroProfileProvider);

    return hasProfileAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.outline,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'R',
                    style: GoogleFonts.boogaloo(
                      fontSize: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'REMINDO',
                style: GoogleFonts.boogaloo(
                  fontSize: 28,
                  color: AppColors.surfaceNav,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (err, stack) => const OnboardingScreen(),
      data: (hasProfile) {
        if (hasProfile) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

class AppRouter {
  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String quests = '/quests';
  static const String timedQuest = '/timed-quest';
  static const String wallet = '/wallet';
  static const String addTransaction = '/add-transaction';
  static const String savings = '/savings';
  static const String settings = '/settings';
  static const String walletNotification = '/wallet-notification';
  static const String customize = '/customize';
  static const String roomUpgrade = '/room-upgrade';
  static const String addQuest = '/add-quest';
  static const String questHistory = '/quest-history';

  // Penpot Hash Link aliases
  static const String hashHome = '#home';
  static const String hashQuests = '#quests';
  static const String hashTimedQuest = '#timed-quest';
  static const String hashWallet = '#wallet';
  static const String hashAddTransaction = '#add-transaction';
  static const String hashSavingsChest = '#savings-chest';
  static const String hashSettings = '#settings';
  static const String hashWalletNotification = '#wallet-notification';
  static const String hashHero = '#hero';
  static const String hashHeroCostume = '#hero-costume';
  static const String hashHeroStats = '#hero-stats';
  static const String hashRoomUpgrade = '#room-upgrade';
  static const String hashAddQuest = '#add-quest';
  static const String hashAddQuestReminder = '#add-quest-reminder';
  static const String hashQuestHistory = '#quest-history';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AppGate());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case home:
      case hashHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case quests:
      case hashQuests:
        return MaterialPageRoute(builder: (_) => const QuestsScreen());

      case timedQuest:
      case hashTimedQuest:
        final questArg = routeSettings.arguments as Quest?;
        return MaterialPageRoute(builder: (_) => TimedQuestScreen(quest: questArg));

      case addQuest:
      case hashAddQuest:
        return MaterialPageRoute(builder: (_) => const AddQuestScreen(initialIsTimed: true));

      case hashAddQuestReminder:
        return MaterialPageRoute(builder: (_) => const AddQuestScreen(initialIsTimed: false));

      case questHistory:
      case hashQuestHistory:
        return MaterialPageRoute(builder: (_) => const QuestHistoryScreen());

      case wallet:
      case hashWallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());

      case addTransaction:
      case hashAddTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen());

      case savings:
      case hashSavingsChest:
        return MaterialPageRoute(builder: (_) => const SavingsScreen());

      case settings:
      case hashSettings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case walletNotification:
      case hashWalletNotification:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());

      case customize:
      case hashHero:
      case hashHeroCostume:
      case hashHeroStats:
        return MaterialPageRoute(builder: (_) => const CustomizeScreen());

      case roomUpgrade:
      case hashRoomUpgrade:
        return MaterialPageRoute(builder: (_) => const RoomUpgradeScreen());

      default:
        return MaterialPageRoute(builder: (_) => const AppGate());
    }
  }
}
