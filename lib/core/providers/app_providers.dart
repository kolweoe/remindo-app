import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/hero_dao.dart';
import '../db/quest_dao.dart';
import '../db/wallet_dao.dart';
import '../db/settings_dao.dart';
import '../../models/hero_profile.dart';
import '../../models/quest.dart';
import '../../models/transaction.dart';
import '../../models/savings_goal.dart';
import '../../models/notification_settings.dart';

// --- DAOs ---
final heroDaoProvider = Provider<HeroDao>((ref) => HeroDao());
final questDaoProvider = Provider<QuestDao>((ref) => QuestDao());
final walletDaoProvider = Provider<WalletDao>((ref) => WalletDao());
final settingsDaoProvider = Provider<SettingsDao>((ref) => SettingsDao());

// --- Hero Profile State ---
final hasHeroProfileProvider = FutureProvider<bool>((ref) async {
  final dao = ref.watch(heroDaoProvider);
  return await dao.hasHeroProfile();
});

class HeroProfileNotifier extends StateNotifier<AsyncValue<HeroProfile>> {
  final HeroDao _dao;
  HeroProfileNotifier(this._dao) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await _dao.getHeroProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createHero({
    required String name,
    required String starterAvatar,
    required String focusGoal,
  }) async {
    try {
      state = const AsyncValue.loading();
      final hero = await _dao.createInitialHero(
        name: name,
        starterAvatar: starterAvatar,
        focusGoal: focusGoal,
      );
      state = AsyncValue.data(hero);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRewards(int xp, int coins, {bool hasTimerBonus = false}) async {
    final updated = await _dao.addXpAndCoins(xp, coins, hasTimerBonus: hasTimerBonus);
    state = AsyncValue.data(updated);
  }

  Future<UpgradeRoomResult> upgradeRoomTo(int targetLevel) async {
    final result = await _dao.upgradeRoomTo(targetLevel);
    if (result.success) {
      await loadProfile();
    }
    return result;
  }

  Future<UpgradeRoomResult> upgradeRoom() async {
    final result = await _dao.upgradeRoomNext();
    if (result.success) {
      await loadProfile();
    }
    return result;
  }

  Future<void> setCostume(String costumeId) async {
    await _dao.updateActiveCostume(costumeId);
    await loadProfile();
  }

  Future<void> setPet(String petId) async {
    await _dao.updateActivePet(petId);
    await loadProfile();
  }
}

final heroProfileProvider =
    StateNotifierProvider<HeroProfileNotifier, AsyncValue<HeroProfile>>((ref) {
  return HeroProfileNotifier(ref.watch(heroDaoProvider));
});

// --- Quests State ---
class QuestsNotifier extends StateNotifier<AsyncValue<List<Quest>>> {
  final QuestDao _dao;
  String? _currentCategory;

  QuestsNotifier(this._dao) : super(const AsyncValue.loading()) {
    loadQuests();
  }

  Future<void> loadQuests({String? category}) async {
    try {
      _currentCategory = category;
      state = const AsyncValue.loading();
      final list = await _dao.getQuests(category: category);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addQuest(Quest quest) async {
    await _dao.insertQuest(quest);
    await loadQuests(category: _currentCategory);
  }

  Future<void> completeQuest(int id, {int focusMinutes = 0, bool hasTimerBonus = false}) async {
    await _dao.completeQuest(id, focusMinutes: focusMinutes, hasTimerBonus: hasTimerBonus);
    await loadQuests(category: _currentCategory);
  }

  Future<void> deleteQuest(int id) async {
    await _dao.deleteQuest(id);
    await loadQuests(category: _currentCategory);
  }
}

final questsProvider =
    StateNotifierProvider<QuestsNotifier, AsyncValue<List<Quest>>>((ref) {
  return QuestsNotifier(ref.watch(questDaoProvider));
});

// --- Wallet State ---
class WalletNotifier extends StateNotifier<AsyncValue<Map<String, int>>> {
  final WalletDao _dao;
  WalletNotifier(this._dao) : super(const AsyncValue.loading()) {
    loadSummary();
  }

  Future<void> loadSummary() async {
    try {
      state = const AsyncValue.loading();
      final summary = await _dao.getFinancialSummary();
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(TransactionItem item) async {
    await _dao.insertTransaction(item);
    await loadSummary();
  }

  Future<bool> depositSavings(int goalId, int amount) async {
    final success = await _dao.depositToSavings(goalId, amount);
    if (success) {
      await loadSummary();
    }
    return success;
  }
}

final walletSummaryProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<Map<String, int>>>((ref) {
  return WalletNotifier(ref.watch(walletDaoProvider));
});

// --- Transactions List State ---
final transactionsListProvider =
    FutureProvider.family<List<TransactionItem>, String?>((ref, type) async {
  final dao = ref.watch(walletDaoProvider);
  return await dao.getTransactions(type: type);
});

// --- Savings Goals State ---
class SavingsGoalsNotifier extends StateNotifier<AsyncValue<List<SavingsGoal>>> {
  final WalletDao _dao;
  SavingsGoalsNotifier(this._dao) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    try {
      state = const AsyncValue.loading();
      final list = await _dao.getSavingsGoals();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await _dao.insertSavingsGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    await _dao.deleteSavingsGoal(id);
    await loadGoals();
  }
}

final savingsGoalsProvider =
    StateNotifierProvider<SavingsGoalsNotifier, AsyncValue<List<SavingsGoal>>>((ref) {
  return SavingsGoalsNotifier(ref.watch(walletDaoProvider));
});

// --- Notification Settings State ---
class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<NotificationSettings>> {
  final SettingsDao _dao;
  NotificationSettingsNotifier(this._dao) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      state = const AsyncValue.loading();
      final s = await _dao.getNotificationSettings();
      state = AsyncValue.data(s);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveSettings(NotificationSettings s) async {
    await _dao.updateNotificationSettings(s);
    state = AsyncValue.data(s);
  }
}

final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, AsyncValue<NotificationSettings>>((ref) {
  return NotificationSettingsNotifier(ref.watch(settingsDaoProvider));
});
